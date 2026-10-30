import { afterEach, expect, setDefaultTimeout, test } from "bun:test";
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";

const directories: string[] = [];
// These public-seam tests launch real Git and CLI processes, including under CI load.
setDefaultTimeout(15_000);
afterEach(() => {
  for (const path of directories.splice(0))
    rmSync(path, { recursive: true, force: true });
});

const hook = new URL("../.claude/hooks/subagent-stop.sh", import.meta.url)
  .pathname;
const finding = {
  id: "data-loss-1",
  title: "Data removed before commit",
  severity: "P0",
  file: "src/store.ts",
  line: 4,
  category: "security",
  why_it_matters: "A failed commit loses the caller's data.",
  scenario: "Commit fails after data is deleted.",
  evidence: "src/store.ts:4 deletes before the commit guard.",
  verification: "Fail the commit and assert the caller data is retained.",
  autofix_class: "manual",
  suggested_fix: null,
  pre_existing: false,
  confidence: 0.9,
};

function collect(result: Record<string, unknown>, reviewer = "code-reviewer") {
  const root = mkdtempSync(join(tmpdir(), "review-collector-"));
  directories.push(root);
  const session = `review-contract-${root.split("/").at(-1)}`;
  const sessionRoot = `/tmp/hook-session-${session}`;
  directories.push(sessionRoot);
  const run = Bun.spawnSync(["bash", hook], {
    cwd: root,
    env: { ...Bun.env, CLAUDE_SESSION_ID: session },
    stdin: Buffer.from(
      JSON.stringify({
        session_id: session,
        agent_id: "review-probe",
        agent_type: reviewer,
        last_assistant_message: JSON.stringify({
          schema_version: 1,
          testing_gaps: [],
          simplification_opportunities: [],
          ...result,
        }),
      }),
    ),
  });
  return {
    code: run.exitCode,
    output: run.stdout.toString() + run.stderr.toString(),
    stored: () =>
      JSON.parse(
        readFileSync(join(sessionRoot, "review-findings.json"), "utf8"),
      ),
  };
}

test("the reviewer collector accepts its documented reasoned skip", () => {
  const result = collect(
    {
      reviewer: "adversarial-reviewer",
      status: "SKIPPED",
      findings: [],
      reason:
        "No adversarial trigger applies to this documentation-only change.",
    },
    "adversarial-reviewer",
  );
  expect(result.code).toBe(0);
  expect(result.stored().status).toBe("SKIPPED");
});

test("the reviewer collector rejects approval contradicting an introduced P0", () => {
  const result = collect({
    reviewer: "code-reviewer",
    status: "APPROVED",
    findings: [finding],
  });
  expect(result.code).toBe(2);
  expect(result.output).not.toContain("code-reviewer: APPROVED");
});

test("the collector retains coordinator findings and explanatory reviewer context", () => {
  const result = collect({
    reviewer: "code-reviewer",
    status: "NEEDS_CHANGES",
    findings: [],
    sufficiency: "The primary pass found no defect.",
    cross_model_findings: [finding],
    karpathy_checks: { assumptions_stated: "pass" },
  });
  expect(result.code).toBe(0);
  expect(result.stored().status).toBe("NEEDS_CHANGES");
  expect(result.stored().cross_model_findings).toHaveLength(1);
  expect(result.stored().karpathy_checks).toEqual({
    assumptions_stated: "pass",
  });
});

test("the reviewer collector rejects malformed findings and false identity", () => {
  for (const change of [
    { severity: "UNKNOWN" },
    { category: "UNKNOWN" },
    { autofix_class: "UNKNOWN" },
    { why_it_matters: "" },
    { line: 0 },
    { confidence: 2 },
  ]) {
    const result = collect({
      reviewer: "code-reviewer",
      status: "NEEDS_CHANGES",
      findings: [{ ...finding, ...change }],
    });
    expect(result.code).toBe(2);
  }
  const result = collect({
    reviewer: "someone-else",
    status: "APPROVED",
    findings: [],
    sufficiency: "Inspected the complete change and affected callers.",
  });
  expect(result.code).toBe(2);
});

const entry = new URL("./review-gates.ts", import.meta.url).pathname;

test.each([
  { reviewer: "self-reviewer", specialist: true },
  { reviewer: "code-reviewer", specialist: true },
  { reviewer: "adversarial-reviewer", specialist: true },
  { reviewer: "explorer", specialist: false },
])(
  "$reviewer startup scopes specialist routing outside the harness checkout",
  ({ reviewer, specialist }) => {
    const root = mkdtempSync(join(tmpdir(), "review-start-"));
    directories.push(root);
    const session = `review-start-${root.split("/").at(-1)}`;
    directories.push(`/tmp/hook-session-${session}`);
    const result = Bun.spawnSync(
      [
        "bash",
        new URL("../.claude/hooks/subagent-start.sh", import.meta.url).pathname,
      ],
      {
        cwd: root,
        env: { ...Bun.env, CLAUDE_SESSION_ID: session },
        stdin: Buffer.from(
          JSON.stringify({ session_id: session, agent_type: reviewer }),
        ),
      },
    );
    expect(result.exitCode).toBe(0);
    const context = JSON.parse(result.stdout.toString()).hookSpecificOutput
      .additionalContext;
    const guidance = new URL("../shared/change-evidence.md", import.meta.url)
      .pathname;
    expect(context.includes(guidance)).toBe(specialist);
    expect(existsSync(guidance)).toBe(true);
  },
);

function checkout(files: Record<string, string> = {}) {
  const root = mkdtempSync(join(tmpdir(), "review-gates-"));
  directories.push(root);
  const git = (...args: string[]) => {
    const run = Bun.spawnSync(["git", ...args], { cwd: root });
    if (run.exitCode !== 0) throw new Error(run.stderr.toString());
    return run.stdout.toString().trim();
  };
  git("init", "-b", "main");
  git("config", "user.name", "Review fixture");
  git("config", "user.email", "review@example.invalid");
  writeFileSync(join(root, ".gitignore"), ".context/\n");
  writeFileSync(join(root, "README.md"), "Before\n");
  for (const [path, content] of Object.entries(files)) {
    const file = join(root, path);
    mkdirSync(dirname(file), { recursive: true });
    writeFileSync(file, content);
  }
  git("add", ".");
  git("commit", "-m", "test(review): baseline");
  git("switch", "-c", "ben-malinski/TEST-1/review-gates");
  writeFileSync(join(root, "README.md"), "After\n");
  const run = (...args: string[]) => {
    const result = Bun.spawnSync(
      [process.execPath, "--no-install", entry, ...args],
      { cwd: root },
    );
    return {
      code: result.exitCode,
      text: result.stdout.toString(),
      error: result.stderr.toString(),
    };
  };
  const input = (name: string, value: unknown) => {
    const file = join(root, ".context", name);
    mkdirSync(join(root, ".context"), { recursive: true });
    writeFileSync(file, JSON.stringify(value));
    return file;
  };
  const plan = (classified?: unknown) => {
    const result = run(
      "plan",
      "--base",
      "main",
      ...(classified
        ? ["--classifications", input("classifications.json", classified)]
        : []),
    );
    expect(result.code).toBe(0);
    return JSON.parse(result.text) as {
      id: string;
      directory: string;
      delta?: { previous: string; hash: string };
      snapshot: { head: string; paths: string[] };
      gates: {
        id: string;
        applicable: boolean;
        reason: string;
        prompt: string;
        scope: "full" | "delta";
      }[];
    };
  };
  const record = (gate: string, extra: Record<string, unknown> = {}) =>
    run(
      "record",
      "--gate",
      gate,
      "--executor",
      "owner",
      "--mode",
      "inline",
      "--input",
      input("result.json", {
        schema_version: 1,
        testing_gaps: [],
        simplification_opportunities: [],
        reviewer: gate,
        status: "APPROVED",
        findings: [],
        sufficiency:
          "Reviewed the complete change, affected callers and failure-path evidence.",
        ...extra,
      }),
    );
  return { root, git, run, input, plan, record };
}

test("gate plans retain lockfiles, generated changes and names with spaces", () => {
  const f = checkout();
  writeFileSync(join(f.root, "bun.lock"), "changed dependency resolution\n");
  writeFileSync(
    join(f.root, "generated file.ts"),
    "// @generated\nexport const version = 2;\n",
  );
  const plan = f.plan();
  expect(plan.snapshot.paths).toEqual(
    expect.arrayContaining(["bun.lock", "generated file.ts", "README.md"]),
  );
  const diff = readFileSync(join(plan.directory, "change.diff"), "utf8");
  expect(diff).toContain("changed dependency resolution");
  expect(diff).toContain("export const version = 2");
  expect(plan.gates.every((gate) => gate.applicable && gate.reason)).toBe(true);
  expect(f.run("check").code).toBe(1);
});

test("repair reviews focus on the captured delta without reusing approval or dropping prior findings", () => {
  const f = checkout();
  writeFileSync(
    join(f.root, "service.proto"),
    'syntax = "proto3";\nmessage Request { string label = 1; }\n',
  );
  writeFileSync(
    join(f.root, "context.ts"),
    "export const unchanged = 'first review context';\n",
  );
  const first = f.plan();
  expect(
    f.record("correctness", { status: "NEEDS_CHANGES", findings: [finding] })
      .code,
  ).toBe(0);
  expect(f.record("operations").code).toBe(0);
  expect(f.record("protobuf").code).toBe(0);
  const status = f.git("status", "--porcelain");
  writeFileSync(join(f.root, "README.md"), "Repaired candidate\n");
  writeFileSync(
    join(f.root, "service.proto"),
    'syntax = "proto3";\nmessage Request { optional string label = 1; }\n',
  );
  expect(f.run("check").code).toBe(3);
  const repair = f.plan();
  const correctness = repair.gates.find((gate) => gate.id === "correctness");
  expect(correctness?.scope).toBe("delta");
  expect(repair.gates.find((gate) => gate.id === "operations")?.scope).toBe(
    "full",
  );
  expect(repair.gates.find((gate) => gate.id === "protobuf")?.scope).toBe(
    "full",
  );
  expect(
    repair.gates.find((gate) => gate.id === "value-and-claims")?.scope,
  ).toBe("full");
  expect(repair.delta?.previous).toBe(first.id);
  const diff = readFileSync(join(repair.directory, "repair.diff"), "utf8");
  expect(diff).toContain("-After");
  expect(diff).toContain("+Repaired candidate");
  expect(diff).not.toContain("first review context");
  expect(readFileSync(join(repair.directory, "change.diff"), "utf8")).toContain(
    "first review context",
  );
  expect(correctness).toBeDefined();
  if (!correctness) throw new Error("Missing correctness gate");
  expect(readFileSync(correctness.prompt, "utf8")).toContain(finding.id);
  expect(f.run("check").code).toBe(1);
  expect(f.plan().id).toBe(repair.id);
  expect(f.git("status", "--porcelain")).toBe(status);
  writeFileSync(join(repair.directory, "repair.diff"), "A different repair\n");
  expect(f.record("correctness").code).toBe(2);
  expect(f.run("check").code).toBe(2);
});

test("base, branch, history, rubric and unavailable-review changes require full review", () => {
  for (const change of [
    "base",
    "branch",
    "history",
    "rubric",
    "unavailable",
  ] as const) {
    const f = checkout();
    f.git("add", "README.md");
    f.git("commit", "-m", "test(review): first candidate");
    f.plan();
    expect(
      f.record(
        "correctness",
        change === "unavailable"
          ? {
              status: "UNAVAILABLE",
              reason: "Prior source could not be inspected",
            }
          : {},
      ).code,
    ).toBe(0);
    writeFileSync(join(f.root, "README.md"), "Repair\n");
    if (change === "base") {
      const commit = f.git(
        "commit-tree",
        "main^{tree}",
        "-p",
        "main",
        "-m",
        "test(review): base movement",
      );
      f.git("update-ref", "refs/heads/main", commit);
    } else if (change === "branch") {
      f.git("branch", "-m", "ben-malinski/TEST-2/different-change");
    } else if (change === "history") {
      f.git("reset", "--soft", "main");
    } else if (change === "rubric") {
      writeFileSync(
        join(f.root, ".review-gates.json"),
        JSON.stringify({
          version: 1,
          gates: [
            {
              id: "consumer",
              title: "Consumer",
              always: true,
              globs: [],
              skills: [],
              lens: "A new responsibility",
            },
          ],
        }),
      );
    }
    const next = f.plan();
    expect(next.gates.find((gate) => gate.id === "correctness")?.scope).toBe(
      "full",
    );
    expect(f.run("check").code).toBe(1);
  }
});

test("consumer re-review scope defaults to full and rejects invalid policy", () => {
  const f = checkout();
  const file = join(f.root, ".review-gates.json");
  const gate = {
    id: "consumer",
    title: "Consumer",
    always: true,
    globs: [],
    skills: [],
    lens: "Check consumer behavior",
  };
  writeFileSync(file, JSON.stringify({ version: 1, gates: [gate] }));
  f.plan();
  expect(f.record("consumer").code).toBe(0);
  writeFileSync(join(f.root, "README.md"), "Repair\n");
  expect(f.plan().gates.find((item) => item.id === "consumer")?.scope).toBe(
    "full",
  );
  writeFileSync(
    file,
    JSON.stringify({ version: 1, gates: [{ ...gate, rereview: "skip" }] }),
  );
  expect(f.run("plan", "--base", "main").error).toContain(
    "Invalid re-review scope",
  );
});

test("repair snapshots retain binary changes and deletions without modifying the index", () => {
  const f = checkout();
  writeFileSync(join(f.root, "asset.bin"), Buffer.from([0, 1, 2, 3]));
  f.git("add", "asset.bin");
  f.plan();
  expect(f.record("correctness").code).toBe(0);
  writeFileSync(join(f.root, "asset.bin"), Buffer.from([0, 3, 2, 1]));
  rmSync(join(f.root, "README.md"));
  writeFileSync(join(f.root, "new file.ts"), "export const repair = true;\n");
  const index = f.git("diff", "--cached", "--binary");
  const next = f.plan();
  expect(next.gates.find((gate) => gate.id === "correctness")?.scope).toBe(
    "delta",
  );
  const diff = readFileSync(join(next.directory, "repair.diff"), "utf8");
  expect(diff).toContain("GIT binary patch");
  expect(diff).toContain("deleted file mode");
  expect(diff).toContain("+export const repair = true;");
  expect(f.git("diff", "--cached", "--binary")).toBe(index);
});

test("one gate state drives readiness, resumability and a safe PR-body table", () => {
  const f = checkout();
  const plan = f.plan();
  for (const gate of plan.gates.filter((gate) => gate.applicable))
    expect(f.record(gate.id).code).toBe(0);
  expect(f.run("check").code).toBe(0);
  expect(f.plan().id).toBe(plan.id);
  expect(f.run("check").code).toBe(0);
  const body = f.input("body.md", "unused");
  writeFileSync(
    body,
    "## Summary\nHuman-written context.\n\n## Tests\nExisting evidence.\n",
  );
  const output = join(f.root, ".context", "published.md");
  const update = () => f.run("update", "--body", body, "--out", output);
  expect(update().code).toBe(0);
  const rendered = readFileSync(output, "utf8");
  expect(rendered).toContain("Human-written context.");
  expect(rendered).toContain("Existing evidence.");
  expect(rendered).toContain(
    "| Gate | Executor | Status | Reason / evidence |",
  );
  expect(rendered).toContain("Review status: passed");
  expect(rendered).toContain(plan.id);
  expect(rendered).not.toContain("LGTM");
  writeFileSync(body, rendered);
  expect(update().code).toBe(0);
  expect(readFileSync(output, "utf8")).toBe(rendered);
  writeFileSync(join(f.root, "README.md"), "Changed after review\n");
  expect(f.run("check").code).toBe(3);
  expect(f.run("render").text).toContain("Stale");
});

test("a gate cannot pass a blocking finding or a reasonless clean result", () => {
  const f = checkout();
  const plan = f.plan();
  const gate = plan.gates[0];
  if (!gate) throw new Error("No gates discovered");
  expect(
    f.record(gate.id, { status: "NEEDS_CHANGES", findings: [finding] }).code,
  ).toBe(0);
  const state = f.run("check");
  expect(state.code).toBe(2);
  expect(state.text).toContain("NEEDS_CHANGES");
  expect(f.record(gate.id, { sufficiency: "" }).code).toBe(2);
  expect(f.run("check").code).toBe(2);
  expect(existsSync(join(plan.directory, "results", `${gate.id}.json`))).toBe(
    true,
  );
});

test("an existing native reviewer result keeps its identity when bound to a gate", () => {
  const f = checkout();
  const plan = f.plan();
  const native = collect({
    reviewer: "code-reviewer",
    status: "APPROVED",
    findings: [],
    sufficiency: "Inspected the changed contract and its callers.",
  });
  expect(native.code).toBe(0);
  const result = f.run(
    "record",
    "--gate",
    "correctness",
    "--reviewer",
    "code-reviewer",
    "--executor",
    "native-review",
    "--mode",
    "agent",
    "--input",
    f.input("native.json", native.stored()),
  );
  expect(result.code).toBe(0);
  const record = JSON.parse(
    readFileSync(join(plan.directory, "results/correctness.json"), "utf8"),
  );
  expect(record.result.reviewer).toBe("code-reviewer");
  expect(record.gate).toBe("correctness");
});

test("routing unions path and semantic signals and permits only justified skips", () => {
  const f = checkout();
  writeFileSync(join(f.root, "bun.lock"), "dependency change");
  const plan = f.plan([
    {
      gate: "correctness",
      relevant: false,
      reason: "Must not override a required gate",
    },
    {
      gate: "dependencies-and-licenses",
      relevant: false,
      reason: "Must not override a path hit",
    },
    {
      gate: "operations",
      relevant: false,
      reason: "No deployment, configuration or operational behavior changes",
    },
  ]);
  expect(plan.gates.find((gate) => gate.id === "correctness")?.applicable).toBe(
    true,
  );
  expect(
    plan.gates.find((gate) => gate.id === "dependencies-and-licenses")
      ?.applicable,
  ).toBe(true);
  expect(plan.gates.find((gate) => gate.id === "operations")?.applicable).toBe(
    false,
  );
  expect(
    plan.gates.find((gate) => gate.id === "security-and-recovery")?.applicable,
  ).toBe(true);
  const bad = f.input("invalid-classification.json", [
    { gate: "operations", relevant: false, reason: "" },
  ]);
  expect(f.run("plan", "--base", "main", "--classifications", bad).code).toBe(
    2,
  );
});

test.each([
  "service.proto",
  "api/example/v1/service.proto",
  "buf.yaml",
  "buf.gen.yaml",
  "buf.gen.forms.yaml",
  "buf.work.yaml",
  "buf.lock",
  "services/catalog/buf.gen.client.yaml",
])("%s routes to protobuf guidance despite a semantic exclusion", (path) => {
  const f = checkout();
  const file = join(f.root, path);
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, "changed contract input\n");
  const plan = f.plan([
    {
      gate: "protobuf",
      relevant: false,
      reason: "Must not override changed protobuf inputs",
    },
  ]);
  const gate = plan.gates.find((item) => item.id === "protobuf");
  expect(gate?.applicable).toBe(true);
  if (!gate) throw new Error("Missing protobuf review gate");
  expect(gate.reason).toBe(`Path signal: ${path}`);
  expect(readFileSync(gate.prompt, "utf8")).toContain("protobuf/SKILL.md");
});

test.each(["modify", "delete", "rename"] as const)(
  "tracked proto %s keeps its review gate",
  (change) => {
    const f = checkout({
      "service.proto":
        'syntax = "proto3";\npackage example.v1;\nmessage Request {}\n',
    });
    switch (change) {
      case "modify":
        writeFileSync(join(f.root, "service.proto"), "changed schema\n");
        break;
      case "delete":
        f.git("rm", "service.proto");
        break;
      case "rename":
        f.git("mv", "service.proto", "archived-schema.txt");
        break;
      default:
        change satisfies never;
    }
    const plan = f.plan([
      {
        gate: "protobuf",
        relevant: false,
        reason: "Must not override a changed or removed schema",
      },
    ]);
    expect(plan.snapshot.paths).toContain("service.proto");
    expect(plan.gates.find((gate) => gate.id === "protobuf")).toMatchObject({
      applicable: true,
      reason: "Path signal: service.proto",
    });
  },
);

test("protobuf routing distinguishes unrelated text from consumer-only contracts", () => {
  const f = checkout();
  const unrelated = f.plan([
    {
      gate: "protobuf",
      relevant: false,
      reason:
        "Only editorial README changes; no protobuf contract or consumers",
    },
  ]);
  expect(
    unrelated.gates.find((gate) => gate.id === "protobuf")?.applicable,
  ).toBe(false);
  writeFileSync(
    join(f.root, "client.ts"),
    "export const useBinaryFormat = true;\n",
  );
  const consumer = f.plan([
    {
      gate: "protobuf",
      relevant: true,
      reason: "The client changes its protobuf serialization contract",
    },
  ]);
  expect(consumer.gates.find((gate) => gate.id === "protobuf")).toMatchObject({
    applicable: true,
    reason:
      "Semantic applicability: The client changes its protobuf serialization contract",
  });
});

test("a preliminary plan can refine applicability without inventing a failed review", () => {
  const f = checkout();
  f.plan();
  const refined = f.plan([
    {
      gate: "operations",
      relevant: false,
      reason: "No operational behavior changes in this documentation edit",
    },
  ]);
  expect(
    refined.gates.find((gate) => gate.id === "operations")?.applicable,
  ).toBe(false);
});

test("sensitive changes require security review despite a negative semantic verdict", () => {
  for (const path of [
    ".github/workflows/test.yml",
    "src/auth/session.ts",
    "src/billing/charge.ts",
    "packages/cli/updater.ts",
    "scripts/install.sh",
    "release/publish.ts",
  ]) {
    const f = checkout();
    const file = join(f.root, path);
    mkdirSync(join(file, ".."), { recursive: true });
    writeFileSync(file, "Sensitive change\n");
    const plan = f.plan([
      {
        gate: "security-and-recovery",
        relevant: false,
        reason: "Semantic classifier found no risk",
      },
    ]);
    const gate = plan.gates.find((gate) => gate.id === "security-and-recovery");
    expect(gate?.applicable).toBe(true);
    expect(gate?.reason).toBe(`Path signal: ${path}`);
    expect(f.run("check").code).toBe(1);
  }
});

test("consumer gates are additive and rubric changes invalidate otherwise identical candidates", () => {
  const f = checkout();
  const reference = f.input("local-review.md", "unused");
  writeFileSync(reference, "Check the component's recovery contract.\n");
  const custom = {
    id: "component-recovery",
    title: "Component recovery",
    always: true,
    globs: [],
    skills: [".context/local-review.md"],
    lens: "Inspect the component's recovery evidence.",
  };
  writeFileSync(
    join(f.root, ".review-gates.json"),
    JSON.stringify({ version: 1, gates: [custom] }),
  );
  const plan = f.plan();
  expect(plan.gates.some((gate) => gate.id === "component-recovery")).toBe(
    true,
  );
  const status = f.git("status", "--porcelain");
  writeFileSync(reference, "Also check restore evidence.\n");
  expect(f.git("status", "--porcelain")).toBe(status);
  expect(f.run("check").code).toBe(3);
  writeFileSync(
    join(f.root, ".review-gates.json"),
    JSON.stringify({ version: 1, gates: [{ ...custom, id: "correctness" }] }),
  );
  expect(f.run("plan", "--base", "main").error).toContain("cannot be shadowed");
});

test("verification retains claims and requires distinct reviewers and concrete counterevidence", () => {
  const f = checkout();
  const plan = f.plan();
  for (const gate of plan.gates) expect(f.record(gate.id).code).toBe(0);
  expect(
    f.record("correctness", { status: "NEEDS_CHANGES", findings: [finding] })
      .code,
  ).toBe(0);
  const verify = (verdict: Record<string, unknown>, executor = "skeptic") =>
    f.run(
      "verify",
      "--gate",
      "correctness",
      "--executor",
      executor,
      "--mode",
      "agent",
      "--model",
      "fixture-reviewer",
      "--input",
      f.input("verification.json", {
        verdicts: [{ finding_id: finding.id, ...verdict }],
      }),
    );
  expect(verify({ refuted: true }).code).toBe(2);
  expect(f.run("check").code).toBe(2);
  expect(
    verify({
      refuted: "false",
      reason: "Not a boolean",
      evidence: "src/store.ts:4",
    }).code,
  ).toBe(2);
  expect(
    verify(
      {
        refuted: true,
        reason: "Read the transaction guard",
        evidence: "src/store.ts:4-12 and the rollback regression",
      },
      "owner",
    ).code,
  ).toBe(2);
  expect(
    verify({
      refuted: false,
      reason: "The guard does not protect the delete",
      evidence: "src/store.ts:4",
    }).code,
  ).toBe(0);
  expect(f.run("check").code).toBe(2);
  expect(
    verify({
      refuted: true,
      reason: "Deletion is rolled back before returning",
      evidence: "src/store.ts:4-12 and the rollback regression",
    }).code,
  ).toBe(0);
  expect(f.run("check").code).toBe(0);
  const record = JSON.parse(
    readFileSync(join(plan.directory, "results/correctness.json"), "utf8"),
  );
  expect(record.result.findings).toHaveLength(1);
  expect(f.run("render").text).toContain("rollback regression");
  expect(f.run("render").text).toContain("fixture-reviewer");
});

test("prior findings cannot disappear through a later applicability skip", () => {
  const f = checkout();
  f.plan();
  expect(
    f.record("performance", {
      status: "NEEDS_CHANGES",
      findings: [{ ...finding, category: "performance" }],
    }).code,
  ).toBe(0);
  writeFileSync(join(f.root, "README.md"), "Another revision\n");
  const plan = f.plan([
    { gate: "performance", relevant: false, reason: "No path trigger" },
  ]);
  const gate = plan.gates.find((gate) => gate.id === "performance");
  expect(gate?.applicable).toBe(true);
  expect(gate?.reason).toContain("Prior findings");
  expect(readFileSync(gate?.prompt ?? "", "utf8")).toContain(
    finding.why_it_matters,
  );
  expect(f.run("check").code).toBe(1);
});

test("completed gate re-reviews focus on a lossless delta and still need fresh receipts", () => {
  const f = checkout();
  writeFileSync(join(f.root, "stable.txt"), "Already reviewed context\n");
  writeFileSync(join(f.root, "removed.txt"), "Remove after review\n");
  f.git("add", ".");
  f.git("commit", "-m", "test(review): first candidate");
  const first = f.plan();
  expect(
    f.record("correctness", { status: "NEEDS_CHANGES", findings: [finding] })
      .code,
  ).toBe(0);
  writeFileSync(join(f.root, "README.md"), "Fixed after review\n");
  rmSync(join(f.root, "removed.txt"));
  writeFileSync(join(f.root, "new file.ts"), "export const fixed = true;\n");
  writeFileSync(join(f.root, "image.bin"), Buffer.from([0, 255, 0, 17]));
  const next = f.plan();
  expect(existsSync(join(next.directory, "repair.diff"))).toBe(true);
  const delta = readFileSync(join(next.directory, "repair.diff"), "utf8");
  expect(delta).toContain("Fixed after review");
  expect(delta).toContain("deleted file mode");
  expect(delta).toContain("export const fixed = true");
  expect(delta).toContain("GIT binary patch");
  expect(delta).not.toContain("Already reviewed context");
  expect(readFileSync(join(next.directory, "change.diff"), "utf8")).toContain(
    "Already reviewed context",
  );
  const prompt = (id: string) =>
    readFileSync(
      next.gates.find((gate) => gate.id === id)?.prompt ?? "",
      "utf8",
    );
  expect(prompt("correctness")).toContain("repair.diff");
  expect(prompt("correctness")).toContain(first.id);
  expect(prompt("correctness")).toContain(finding.id);
  // An unreviewed lens cannot inherit another gate's initial coverage.
  expect(prompt("value-and-claims")).not.toContain("repair.diff");
  expect(f.run("check").code).toBe(1);
  expect(f.plan().id).toBe(next.id);
  writeFileSync(
    join(next.directory, "repair.diff"),
    "Truncated review input\n",
  );
  expect(f.run("check").code).toBe(2);
  expect(f.record("correctness").code).toBe(2);
});

for (const fallback of [
  "missing review",
  "UNAVAILABLE",
  "FAILED",
  "recording error",
  "moved base",
  "changed rubric",
  "changed branch",
]) {
  test(`re-review uses the complete candidate for ${fallback}`, () => {
    const f = checkout();
    const guidance = f.input("rubric.md", "Original guidance");
    writeFileSync(
      join(f.root, ".review-gates.json"),
      JSON.stringify({
        version: 1,
        gates: [
          {
            id: "consumer",
            title: "Consumer",
            always: true,
            globs: [],
            skills: [".context/rubric.md"],
            lens: "Check consumer behavior.",
          },
        ],
      }),
    );
    f.git("add", ".");
    f.git("commit", "-m", "test(review): first candidate");
    f.plan();
    if (fallback !== "missing review") {
      const result = f.record("correctness", {
        ...(fallback === "UNAVAILABLE" || fallback === "FAILED"
          ? { status: fallback, reason: "The initial review did not complete" }
          : {}),
        ...(fallback === "recording error" ? { sufficiency: "" } : {}),
      });
      expect(result.code).toBe(fallback === "recording error" ? 2 : 0);
    }
    if (fallback === "moved base") f.git("branch", "-f", "main", "HEAD");
    if (fallback === "changed rubric") writeFileSync(guidance, "New guidance");
    if (fallback === "changed branch")
      f.git("branch", "-m", "ben-malinski/TEST-1/other-feature");
    writeFileSync(join(f.root, "README.md"), "Next candidate\n");
    const next = f.plan();
    const gate = next.gates.find((gate) => gate.id === "correctness");
    const prompt = readFileSync(gate?.prompt ?? "", "utf8");
    expect(gate?.scope).toBe("full");
    expect(prompt).not.toContain("repair.diff");
    expect(f.run("check").code).toBe(1);
  });
}

test("returning to earlier contents preserves prior findings without rewriting old inputs", () => {
  const f = checkout();
  f.git("add", ".");
  f.git("commit", "-m", "test(review): first candidate");
  const first = f.plan();
  const prompt = first.gates.find((gate) => gate.id === "correctness")?.prompt;
  const original = readFileSync(prompt ?? "", "utf8");
  expect(f.record("correctness").code).toBe(0);
  writeFileSync(join(f.root, "README.md"), "Temporary repair\n");
  f.plan();
  expect(
    f.record("correctness", { status: "NEEDS_CHANGES", findings: [finding] })
      .code,
  ).toBe(0);
  writeFileSync(join(f.root, "README.md"), "After\n");
  const next = f.plan();
  expect(next.id).not.toBe(first.id);
  expect(readFileSync(prompt ?? "", "utf8")).toBe(original);
  expect(
    readFileSync(
      next.gates.find((gate) => gate.id === "correctness")?.prompt ?? "",
      "utf8",
    ),
  ).toContain(finding.id);
  const state = JSON.parse(f.run("check").text);
  expect(
    state.rows.find((row: { gate: string }) => row.gate === "correctness")
      .status,
  ).toBe("PENDING");
});

test("unreviewed intermediate plans cannot erase a known finding or narrow its review delta", () => {
  const f = checkout();
  f.git("add", ".");
  f.git("commit", "-m", "test(review): first candidate");
  f.plan();
  expect(
    f.record("performance", { status: "NEEDS_CHANGES", findings: [finding] })
      .code,
  ).toBe(0);
  writeFileSync(join(f.root, "README.md"), "Unreviewed intermediate repair\n");
  f.git("add", "README.md");
  f.git("commit", "-m", "test(review): intermediate repair");
  const intermediate = f.plan();
  expect(f.record("correctness").code).toBe(0);
  writeFileSync(join(f.root, "README.md"), "Another repair\n");
  const next = f.plan([
    {
      gate: "performance",
      relevant: false,
      reason: "No path trigger",
    },
  ]);
  const gate = next.gates.find((gate) => gate.id === "performance");
  expect(gate?.applicable).toBe(true);
  expect(next.delta?.previous).toBe(intermediate.id);
  expect(gate?.scope).toBe("full");
  const prompt = readFileSync(gate?.prompt ?? "", "utf8");
  expect(prompt).toContain(finding.id);
  expect(prompt).not.toContain("repair.diff");
  expect(f.run("check").code).toBe(1);
});

test("plan files cannot redirect result writes outside their candidate directory", () => {
  const f = checkout();
  const plan = f.plan();
  const outside = mkdtempSync(join(tmpdir(), "other-review-owner-"));
  directories.push(outside);
  writeFileSync(
    join(f.root, ".context/review-gates/plan.json"),
    JSON.stringify({
      ...JSON.parse(readFileSync(join(plan.directory, "plan.json"), "utf8")),
      directory: outside,
    }),
  );
  expect(f.record("correctness").code).toBe(2);
  expect(existsSync(join(outside, "results"))).toBe(false);
});

test("PR projection escapes cell content and refuses ambiguous markers without overwriting", () => {
  const f = checkout();
  f.plan();
  expect(
    f.record("correctness", {
      sufficiency:
        "Observed | <script>bad</script>\n<!-- harness-review:end --> ![](https://invalid.example/pixel)",
    }).code,
  ).toBe(0);
  const rendered = f.run("render").text;
  expect(rendered).toContain("Observed &#124; &lt;script&gt;");
  expect(rendered).not.toContain("![](");
  expect(rendered.split("<!-- harness-review:end -->")).toHaveLength(2);
  const body = f.input("body.md", "unused");
  writeFileSync(body, `${rendered}\n${rendered}`);
  const output = join(f.root, ".context", "output.md");
  writeFileSync(output, "Preserve this output");
  expect(f.run("update", "--body", body, "--out", output).code).toBe(2);
  expect(readFileSync(output, "utf8")).toBe("Preserve this output");
});

test("a changed staged diff or prompt cannot certify an unchanged checkout", () => {
  const f = checkout();
  const plan = f.plan();
  const diff = join(plan.directory, "change.diff");
  const original = readFileSync(diff, "utf8");
  writeFileSync(diff, "A different review input");
  expect(f.record("correctness").code).toBe(2);
  expect(f.run("check").code).toBe(2);
  writeFileSync(diff, original);
  const gate = plan.gates[0];
  if (!gate) throw new Error("Missing planned gate");
  writeFileSync(gate.prompt, "A different review lens");
  expect(f.run("check").code).toBe(2);
});

test("gate recording shares the installed versioned reviewer contract", () => {
  const f = checkout();
  f.plan();
  expect(f.record("correctness", { schema_version: 2 }).code).toBe(2);
  expect(
    f.record("correctness", {
      status: "NEEDS_CHANGES",
      findings: [{ ...finding, evidence: undefined }],
    }).code,
  ).toBe(2);
  expect(
    f.record("correctness", { karpathy_checks: { "hallucinated-api": "fail" } })
      .code,
  ).toBe(2);
  expect(
    f.record("correctness", {
      status: "NEEDS_CHANGES",
      findings: [{ ...finding, severity: "P2" }],
      critical_checks_failed: false,
      karpathy_checks: { "hallucinated-api": "fail" },
    }).code,
  ).toBe(0);
  expect(
    JSON.parse(f.run("check").text).rows.find(
      (row: { gate: string }) => row.gate === "correctness",
    ).status,
  ).toBe("NEEDS_CHANGES");
  expect(
    f.run(
      "verify",
      "--gate",
      "correctness",
      "--executor",
      "fixture-verifier",
      "--mode",
      "agent",
      "--input",
      f.input("critical-verification.json", {
        verdicts: [
          {
            finding_id: finding.id,
            refuted: true,
            reason: "The minor fixture finding was refuted",
            evidence: "Fixture source counterexample",
          },
        ],
      }),
    ).code,
  ).toBe(0);
  expect(
    JSON.parse(f.run("check").text).rows.find(
      (row: { gate: string }) => row.gate === "correctness",
    ).status,
  ).toBe("NEEDS_CHANGES");
  expect(
    f.record("correctness", {
      schema_version: 1,
      status: "UNAVAILABLE",
      reason: "Source access is unavailable",
      findings: [],
    }).code,
  ).toBe(0);
  expect(
    f.record("performance", {
      status: "FAILED",
      reason: "The review did not complete",
    }).code,
  ).toBe(0);
  const state = JSON.parse(f.run("check").text);
  expect(state.status).toBe("blocked");
  expect(
    state.rows.find((row: { gate: string }) => row.gate === "correctness")
      .status,
  ).toBe("ERROR");
  writeFileSync(join(f.root, "README.md"), "Next candidate\n");
  expect(
    f
      .plan([
        {
          gate: "performance",
          relevant: false,
          reason: "No performance change",
        },
      ])
      .gates.find((gate) => gate.id === "performance")?.applicable,
  ).toBe(true);
});
