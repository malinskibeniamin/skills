import { createInterface } from "node:readline";
import { spawn } from "node:child_process";

type DoctorResult = {
  ok: boolean;
  code:
    | "signed-in"
    | "codex-missing"
    | "login-required"
    | "backend-unavailable";
  message: string;
};

function record(value: unknown): Record<string, unknown> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw new Error("Invalid app-server response");
  }
  return Object.fromEntries(Object.entries(value));
}

async function accountType(codex: string): Promise<unknown> {
  // This probe has no thread/turn requests and never refreshes or exports credentials.
  const proc = spawn(codex, ["app-server"], {
    stdio: ["pipe", "pipe", "ignore"],
  });
  const lines = createInterface({
    input: proc.stdout,
    crlfDelay: Number.POSITIVE_INFINITY,
  });
  const exited = new Promise<void>((resolve) =>
    proc.once("close", () => resolve()),
  );
  const abort = () => {
    proc.kill("SIGKILL");
    lines.close();
  };
  const timeout = setTimeout(abort, 5000);
  proc.on("error", abort);
  proc.stdin.on("error", abort);
  const send = (value: unknown) =>
    proc.stdin.write(`${JSON.stringify(value)}\n`);
  let initialized = false;
  try {
    send({
      method: "initialize",
      id: 1,
      params: { clientInfo: { name: "bao", version: "0.1.0" } },
    });
    for await (const line of lines) {
      const message = record(JSON.parse(line));
      if (message.id === 1 && !initialized) {
        record(message.result);
        initialized = true;
        send({ method: "initialized" });
        send({
          method: "account/read",
          id: 2,
          params: { refreshToken: false },
        });
      } else if (message.id === 2 && initialized) {
        const result = record(message.result);
        if (result.requiresOpenaiAuth !== true || result.account === null)
          return null;
        return record(result.account).type;
      }
    }
    throw new Error("App-server exited before reporting an account");
  } finally {
    clearTimeout(timeout);
    abort();
    await exited;
  }
}

export async function doctor(): Promise<DoctorResult> {
  const codex = Bun.which("codex");
  if (!codex)
    return {
      ok: false,
      code: "codex-missing",
      message:
        "Codex was not found on PATH. Install Codex CLI before checking sign-in.",
    };

  try {
    if ((await accountType(codex)) === "chatgpt") {
      return {
        ok: true,
        code: "signed-in",
        message:
          "Local Codex app-server is reachable and reports a ChatGPT sign-in. Run readiness and quota were not checked.",
      };
    }
    return {
      ok: false,
      code: "login-required",
      message:
        "Codex did not report a ChatGPT sign-in on the OpenAI backend. Check your local Codex login and provider. Bao does not fall back to API keys.",
    };
  } catch {
    return {
      ok: false,
      code: "backend-unavailable",
      message:
        "Could not read sign-in status from Codex app-server. Check whether your installed Codex starts and supports account/read.",
    };
  }
}
