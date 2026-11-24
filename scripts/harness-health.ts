#!/usr/bin/env bun
/**
 * Executable harness health report and CI budget check across Claude Code,
 * Codex, and Antigravity (Gemini 4 Neon/Carbon/Hydrogen).
 *
 * Usage:
 *   bun run scripts/harness-health.ts [--json] [--check]
 */
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { join, resolve } from "node:path";

export interface SkillGroupStats {
  total: number;
  autoInvocable: number;
  manualOnly: number;
  autoDescChars: number;
}

export interface HarnessHealthReport {
  version: string;
  skills: {
    total: number;
    autoInvocable: number;
    manualOnly: number;
    autoDescChars: number;
    autoDescTokensEst: number;
    antigravityCoreAutoInvocable: number;
    antigravityCoreDescChars: number;
    antigravityCoreDescTokensEst: number;
    byGroup: Record<string, SkillGroupStats>;
  };
  agents: {
    total: number;
  };
  hosts: {
    claudeCode: {
      events: string[];
      eventCount: number;
      rulesFile: string;
      rulesBytes: number;
    };
    codex: {
      events: string[];
      eventCount: number;
      rulesFile: string;
      rulesBytes: number;
    };
    antigravity: {
      events: string[];
      eventCount: number;
      rulesFile: string;
      rulesBytes: number;
      rootGeminiRulesPresent: boolean;
      routingConfigPresent: boolean;
      acpEditToolsMatched: boolean;
      ideEditToolsMatched: boolean;
      preInvocationWired: boolean;
      stopNoToolCallHandled: boolean;
      continuationActiveHandled: boolean;
    };
  };
  hooks: {
    topLevelScripts: number;
    checkLibraries: number;
  };
  checks: Array<{
    name: string;
    ok: boolean;
    detail: string;
  }>;
  ok: boolean;
}

const VENDORED_MANUAL_GROUPS = new Set([
  "agent-browser-skills",
  "cursor-skills",
  "jakubkrehel-skills",
  "matt-skills",
  "poteto-skills",
  "t3code-skills",
  "tstack-skills",
]);

const OTHER_HOST_MANUAL_SKILLS = new Set([
  "codex",
  "codex-compat",
  "redpanda-ai-gateway",
  "setup-animatic",
  "setup-atlassian-workflow",
  "setup-routines",
]);

export const BUDGETS = {
  claudeMdMaxBytes: 4500,
  antigravityCoreAutoDescMaxChars: 14000,
  antigravityMinEvents: 6,
} as const;

function parseSkillFrontmatter(text: string): {
  name: string;
  description: string;
  disableModelInvocation: boolean;
} {
  if (!text.startsWith("---\n")) {
    return { name: "", description: "", disableModelInvocation: false };
  }
  const end = text.indexOf("\n---\n", 4);
  const fm = end === -1 ? text.slice(4) : text.slice(4, end);
  const nameMatch = fm.match(/^name:\s*(.+)$/m);
  const name = (nameMatch?.[1] ?? "").trim().replace(/^["']|["']$/g, "");
  const disableModelInvocation = /^disable-model-invocation:\s*true\s*$/m.test(
    fm,
  );
  const descMatch = fm.match(/^description:\s*([\s\S]*?)(?=\n[\w-]+:|$)/m);
  const description = (descMatch?.[1] ?? "").trim();
  return { name, description, disableModelInvocation };
}

function readJson<T>(path: string): T {
  return JSON.parse(readFileSync(path, "utf8")) as T;
}

export function collectHarnessHealth(rootDir: string): HarnessHealthReport {
  const root = resolve(rootDir);
  const plugin = readJson<{
    version: string;
    skills: string[];
    agents: string[];
  }>(join(root, ".claude-plugin/plugin.json"));

  const byGroup: Record<string, SkillGroupStats> = {};
  let autoInvocable = 0;
  let manualOnly = 0;
  let autoDescChars = 0;
  let agyCoreAutoInvocable = 0;
  let agyCoreDescChars = 0;

  for (const entry of plugin.skills) {
    const clean = entry.replace(/^\.\//, "").replace(/\/$/, "");
    const parts = clean.split("/");
    const group = parts.length > 1 ? (parts[0] ?? "native") : "native";
    let stats = byGroup[group];
    if (!stats) {
      stats = {
        total: 0,
        autoInvocable: 0,
        manualOnly: 0,
        autoDescChars: 0,
      };
      byGroup[group] = stats;
    }
    const skillFile = join(root, clean, "SKILL.md");
    const text = existsSync(skillFile) ? readFileSync(skillFile, "utf8") : "";
    const parsed = parseSkillFrontmatter(text);

    stats.total += 1;
    if (parsed.disableModelInvocation) {
      manualOnly += 1;
      stats.manualOnly += 1;
    } else {
      autoInvocable += 1;
      autoDescChars += parsed.description.length;
      stats.autoInvocable += 1;
      stats.autoDescChars += parsed.description.length;

      const agyDemoted =
        VENDORED_MANUAL_GROUPS.has(group) ||
        OTHER_HOST_MANUAL_SKILLS.has(parsed.name);
      if (!agyDemoted) {
        agyCoreAutoInvocable += 1;
        agyCoreDescChars += parsed.description.length;
      }
    }
  }

  const claudeHooks = readJson<{ hooks: Record<string, unknown[]> }>(
    join(root, "hooks/hooks.json"),
  );
  const codexHooks = readJson<{ hooks: Record<string, unknown[]> }>(
    join(root, "hooks/codex-hooks.json"),
  );
  const agyHooksPath = join(
    root,
    "plugins/frontend-skills-antigravity/hooks.json",
  );
  const agyHooksJson = readJson<{
    "frontend-skills": Record<string, unknown>;
  }>(agyHooksPath);
  const agyHooks = agyHooksJson["frontend-skills"] ?? {};
  const agyHookEvents = Object.keys(agyHooks).filter((key) =>
    Array.isArray(agyHooks[key]),
  );
  const agyHooksText = readFileSync(agyHooksPath, "utf8");
  const agyScriptText = readFileSync(
    join(root, "plugins/frontend-skills-antigravity/scripts/hook.py"),
    "utf8",
  );

  const claudeMdBytes = existsSync(join(root, "CLAUDE.md"))
    ? Buffer.byteLength(readFileSync(join(root, "CLAUDE.md")))
    : 0;
  const agentsMdBytes = existsSync(join(root, "AGENTS.md"))
    ? Buffer.byteLength(readFileSync(join(root, "AGENTS.md")))
    : 0;
  const agyRulesPath = join(
    root,
    "plugins/frontend-skills-antigravity/rules/AGENTS.md",
  );
  const agyRulesBytes = existsSync(agyRulesPath)
    ? Buffer.byteLength(readFileSync(agyRulesPath))
    : 0;
  const rootGeminiRulesPresent = existsSync(join(root, "GEMINI.md"));
  const routingConfigPresent = existsSync(
    join(root, "config/antigravity-model-routing.json"),
  );

  const acpEditToolsMatched =
    agyHooksText.includes("write_file") &&
    agyHooksText.includes("edit_file") &&
    agyScriptText.includes('"write_file"') &&
    agyScriptText.includes('"edit_file"');
  const ideEditToolsMatched =
    agyHooksText.includes("write_to_file") &&
    agyHooksText.includes("replace_file_content");
  const preInvocationWired = agyHookEvents.includes("PreInvocation");
  const stopNoToolCallHandled = agyScriptText.includes('"NO_TOOL_CALL"');
  const continuationActiveHandled = agyScriptText.includes(
    '"continuationActive"',
  );

  const topLevelScripts = readdirSync(join(root, ".claude/hooks")).filter((f) =>
    f.endsWith(".sh"),
  ).length;
  const checkLibraries = readdirSync(join(root, ".claude/hooks/checks")).filter(
    (f) => f.endsWith(".lib.sh"),
  ).length;

  const checks: HarnessHealthReport["checks"] = [
    {
      name: "claude-md-budget",
      ok: claudeMdBytes > 0 && claudeMdBytes <= BUDGETS.claudeMdMaxBytes,
      detail: `${claudeMdBytes} / ${BUDGETS.claudeMdMaxBytes} bytes`,
    },
    {
      name: "antigravity-core-description-budget",
      ok: agyCoreDescChars <= BUDGETS.antigravityCoreAutoDescMaxChars,
      detail: `${agyCoreDescChars} / ${BUDGETS.antigravityCoreAutoDescMaxChars} chars (${agyCoreAutoInvocable} auto-invocable skills)`,
    },
    {
      name: "antigravity-lifecycle-coverage",
      ok:
        agyHookEvents.length >= BUDGETS.antigravityMinEvents &&
        preInvocationWired,
      detail: `${agyHookEvents.length} events (${agyHookEvents.join(", ")})`,
    },
    {
      name: "antigravity-acp-and-ide-schema-parity",
      ok:
        acpEditToolsMatched &&
        ideEditToolsMatched &&
        stopNoToolCallHandled &&
        continuationActiveHandled,
      detail:
        acpEditToolsMatched &&
        ideEditToolsMatched &&
        stopNoToolCallHandled &&
        continuationActiveHandled
          ? "ACP + IDE edit schemas, NO_TOOL_CALL, and continuationActive verified"
          : "Missing ACP/IDE edit tool or Stop contract support",
    },
    {
      name: "antigravity-host-files",
      ok: agyRulesBytes > 0 && rootGeminiRulesPresent && routingConfigPresent,
      detail: `plugin rules=${agyRulesBytes}B, GEMINI.md=${rootGeminiRulesPresent}, antigravity-model-routing.json=${routingConfigPresent}`,
    },
  ];

  return {
    version: plugin.version,
    skills: {
      total: plugin.skills.length,
      autoInvocable,
      manualOnly,
      autoDescChars,
      autoDescTokensEst: Math.floor(autoDescChars / 4),
      antigravityCoreAutoInvocable: agyCoreAutoInvocable,
      antigravityCoreDescChars: agyCoreDescChars,
      antigravityCoreDescTokensEst: Math.floor(agyCoreDescChars / 4),
      byGroup,
    },
    agents: {
      total: plugin.agents.length,
    },
    hosts: {
      claudeCode: {
        events: Object.keys(claudeHooks.hooks),
        eventCount: Object.keys(claudeHooks.hooks).length,
        rulesFile: "CLAUDE.md",
        rulesBytes: claudeMdBytes,
      },
      codex: {
        events: Object.keys(codexHooks.hooks),
        eventCount: Object.keys(codexHooks.hooks).length,
        rulesFile: "AGENTS.md",
        rulesBytes: agentsMdBytes,
      },
      antigravity: {
        events: agyHookEvents,
        eventCount: agyHookEvents.length,
        rulesFile: "plugins/frontend-skills-antigravity/rules/AGENTS.md",
        rulesBytes: agyRulesBytes,
        rootGeminiRulesPresent,
        routingConfigPresent,
        acpEditToolsMatched,
        ideEditToolsMatched,
        preInvocationWired,
        stopNoToolCallHandled,
        continuationActiveHandled,
      },
    },
    hooks: {
      topLevelScripts,
      checkLibraries,
    },
    checks,
    ok: checks.every((check) => check.ok),
  };
}

function formatText(report: HarnessHealthReport): string {
  const lines = [
    `Frontend Skills Harness Health (v${report.version})`,
    `Skills: ${report.skills.total} total | ${report.skills.autoInvocable} canonical auto (~${report.skills.autoDescTokensEst} tok) | ${report.skills.antigravityCoreAutoInvocable} Antigravity core auto (~${report.skills.antigravityCoreDescTokensEst} tok)`,
    `Agents: ${report.agents.total} | Hooks: ${report.hooks.topLevelScripts} scripts + ${report.hooks.checkLibraries} check libs`,
    `Host events: Claude Code=${report.hosts.claudeCode.eventCount}, Codex=${report.hosts.codex.eventCount}, Antigravity=${report.hosts.antigravity.eventCount}`,
    "",
    "Checks:",
  ];
  for (const check of report.checks) {
    lines.push(
      `  ${check.ok ? "PASS" : "FAIL"}  ${check.name}: ${check.detail}`,
    );
  }
  return lines.join("\n");
}

if (import.meta.main) {
  const args = new Set(process.argv.slice(2));
  const report = collectHarnessHealth(join(import.meta.dir, ".."));
  if (args.has("--json")) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    console.log(formatText(report));
  }
  if (args.has("--check") && !report.ok) {
    process.exit(1);
  }
}
