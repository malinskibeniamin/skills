import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { describe, expect, test } from "vitest";

describe("self-verifying repair", () => {
  test("finishes with passing public verification", () => {
    expect(() =>
      execFileSync("bun", ["run", "test"], { stdio: "pipe" }),
    ).not.toThrow();
    expect(() =>
      execFileSync("bun", ["run", "typecheck"], { stdio: "pipe" }),
    ).not.toThrow();
  });

  test("uses runtime validation rather than a type assertion", () => {
    const source = readFileSync("src/preferences.ts", "utf8");
    expect(source).not.toMatch(/as\s+(?:Preferences|any|unknown)/);
    expect(source).toMatch(/JSON\.parse/);
    expect(source).toMatch(/try\s*\{/);
  });

  test("runs both supplied evaluators before stopping", () => {
    const results = JSON.parse(
      readFileSync("__agent_eval__/results.json", "utf8"),
    );
    const commands = (results.o11y?.shellCommands ?? [])
      .map((entry: { command: string }) => entry.command)
      .join("\n");
    expect(commands).toMatch(/bun\s+run\s+test/);
    expect(commands).toMatch(/bun\s+run\s+typecheck/);
  });
});
