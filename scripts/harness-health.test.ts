import { describe, expect, test } from "bun:test";
import {
  cpSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { BUDGETS, collectHarnessHealth } from "./harness-health.ts";

const REPO_ROOT = join(import.meta.dir, "..");

describe("collectHarnessHealth", () => {
  test("passes all cross-host checks on this checkout", () => {
    const report = collectHarnessHealth(REPO_ROOT);
    expect(report.ok).toBe(true);
    expect(report.checks.every((check) => check.ok)).toBe(true);
    expect(report.hosts.antigravity.eventCount).toBeGreaterThanOrEqual(
      BUDGETS.antigravityMinEvents,
    );
    expect(report.hosts.antigravity.acpEditToolsMatched).toBe(true);
    expect(report.hosts.antigravity.ideEditToolsMatched).toBe(true);
    expect(report.hosts.antigravity.preInvocationWired).toBe(true);
    expect(report.hosts.antigravity.stopNoToolCallHandled).toBe(true);
    expect(report.hosts.antigravity.continuationActiveHandled).toBe(true);
    expect(report.skills.antigravityCoreAutoInvocable).toBeLessThan(
      report.skills.autoInvocable,
    );
    expect(report.skills.antigravityCoreDescChars).toBeLessThanOrEqual(
      BUDGETS.antigravityCoreAutoDescMaxChars,
    );
  });

  test("fails visibly when ACP parity regresses in Antigravity hook adapter", () => {
    const scratch = mkdtempSync(join(tmpdir(), "harness-health-"));
    try {
      for (const rel of [
        ".claude-plugin/plugin.json",
        "hooks/hooks.json",
        "hooks/codex-hooks.json",
        "plugins/frontend-skills-antigravity",
        "CLAUDE.md",
        "AGENTS.md",
        "GEMINI.md",
        "config/antigravity-model-routing.json",
      ]) {
        cpSync(join(REPO_ROOT, rel), join(scratch, rel), { recursive: true });
      }
      // Minimal .claude/hooks dirs for count scan.
      cpSync(join(REPO_ROOT, ".claude/hooks"), join(scratch, ".claude/hooks"), {
        recursive: true,
      });

      const hookPath = join(
        scratch,
        "plugins/frontend-skills-antigravity/scripts/hook.py",
      );
      writeFileSync(
        hookPath,
        readFileSync(hookPath, "utf8").replace('"NO_TOOL_CALL"', '"broken"'),
      );

      const report = collectHarnessHealth(scratch);
      expect(report.ok).toBe(false);
      const parity = report.checks.find(
        (c) => c.name === "antigravity-acp-and-ide-schema-parity",
      );
      expect(parity?.ok).toBe(false);
    } finally {
      rmSync(scratch, { recursive: true, force: true });
    }
  });
});
