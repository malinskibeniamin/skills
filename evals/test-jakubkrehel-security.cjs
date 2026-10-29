// Public worker/checker contracts, without launching a browser or making requests.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const vm = require("node:vm");
const source = path.join(__dirname, "../vendor/jakubkrehel/skills/teardown");

function worker() {
  const messages = [];
  const activity = { modelCalls: 0 };
  const context = {
    location: { origin: "https://trusted.invalid" },
    DrawingModels: {
      fixture: () => {
        activity.modelCalls++;
        return { markup: "rendered" };
      },
    },
    postMessage: (value) => messages.push(value),
  };
  context.self = context;
  vm.runInNewContext(
    fs.readFileSync(path.join(source, "assets/worker.js"), "utf8"),
    context,
  );
  return { context, messages, activity };
}

test("worker rejects a foreign window origin without executing the model", () => {
  const { context, messages, activity } = worker();
  context.onmessage({
    origin: "https://attacker.invalid",
    data: { request: 1, id: "fixture" },
  });
  assert.equal(messages.length, 0);
  assert.equal(activity.modelCalls, 0);
});

test("worker accepts dedicated-worker empty origins and reports model errors", () => {
  const { context, messages, activity } = worker();
  context.onmessage({ origin: "", data: { request: 1, id: "fixture" } });
  context.onmessage({
    origin: "https://trusted.invalid",
    data: { request: 2, id: "missing" },
  });
  assert.equal(messages[0].result.markup, "rendered");
  assert.equal(activity.modelCalls, 1);
  assert.equal(messages[1].error, "Unknown drawing model");
});

function checker(port, drawingId = "fixture") {
  const requests = [],
    outputs = [],
    values = [],
    selected = {
      value: "",
      dispatchEvent() {
        values.push(this.value);
      },
    };
  const browser = {
    killed: false,
    kill() {
      this.killed = true;
    },
  };
  const fakeFs = {
    existsSync: () => true,
    readFileSync: () => `${port}\n/devtools/browser/fixture\n`,
    mkdirSync() {},
    mkdtempSync: () => "/fixture/profile",
    rmSync() {},
    writeFileSync(file) {
      outputs.push(file);
    },
  };
  const document = {
    getElementById(id) {
      if (id === "subject") return selected;
      if (id === "drawing-data")
        return { textContent: JSON.stringify([{ id: drawingId, parts: [1] }]) };
      if (id === "viewport") return { getAttribute: () => "false" };
      return { textContent: id === "render-status" ? "Drawing updated" : "" };
    },
    querySelectorAll: () => [1],
  };
  class Socket {
    constructor() {
      queueMicrotask(() => this.onopen());
    }
    close() {}
    send(message) {
      const { id, method, params } = JSON.parse(message);
      let result = {};
      if (method === "Runtime.evaluate")
        result = {
          result: {
            value: vm.runInNewContext(params.expression, {
              document,
              Event: class {},
            }),
          },
        };
      if (method === "Page.captureScreenshot")
        result = { data: Buffer.from("fixture PNG").toString("base64") };
      queueMicrotask(() =>
        this.onmessage({ data: JSON.stringify({ id, result }) }),
      );
    }
  }
  const context = {
    module: { exports: {} },
    console: { log() {}, warn() {} },
    Buffer,
    WebSocket: Socket,
    setTimeout: (callback) => queueMicrotask(callback),
    fetch: async (url) => {
      requests.push(String(url));
      return {
        json: async () => [
          {
            type: "page",
            webSocketDebuggerUrl: "ws://127.0.0.1:9222/devtools/page/fixture",
          },
        ],
      };
    },
    require(name) {
      if (name === "node:fs") return fakeFs;
      if (name === "node:child_process") return { spawn: () => browser };
      if (name === "./commands.cjs")
        return { findChrome: () => "fixture-chrome" };
      return require(name);
    },
  };
  vm.runInNewContext(
    fs.readFileSync(path.join(source, "scripts/check-viewer.cjs"), "utf8"),
    context,
  );
  return {
    run: () =>
      context.module.exports("/fixture/viewer.html", "/fixture/output"),
    requests,
    outputs,
    values,
    browser,
  };
}

test("checker rejects malformed or out-of-range debugging ports before network access", async () => {
  for (const port of [
    "9222@attacker.invalid",
    "9222/redirect",
    "0",
    "65536",
    "NaN",
  ]) {
    const check = checker(port);
    await assert.rejects(check.run(), /port/i);
    assert.deepEqual(check.requests, []);
    assert.equal(check.browser.killed, true);
  }
});

test("checker keeps drawing IDs as data through CDP and releases its owned browser", async () => {
  const id = "fixture-one";
  const check = checker("9222", id);
  const result = await check.run();
  assert.deepEqual(check.requests, ["http://127.0.0.1:9222/json/list"]);
  assert.deepEqual(check.values, [id]);
  assert.equal(result.results[0].id, id);
  assert.equal(result.problems.length, 0);
  assert.equal(check.outputs.length, 1);
  assert.equal(check.browser.killed, true);
});

test("checker rejects IDs that could escape the screenshot directory or become code", async () => {
  for (const id of [
    "../../escape",
    "fixture</script><script>injected()</script>",
  ]) {
    const check = checker("9222", id);
    await assert.rejects(check.run(), /drawing id/i);
    assert.deepEqual(check.outputs, []);
    assert.equal(check.browser.killed, true);
  }
});
