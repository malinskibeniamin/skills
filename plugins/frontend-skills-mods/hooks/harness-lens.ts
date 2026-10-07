import {
  type EngineInterface,
  type On,
  type Register,
  type ToolCallResult,
  update,
} from "claude-code";
import type {
  CheckKind,
  ContextReading,
  DeskView,
  ProofReceipt,
  ReplayEntry,
  ReplayState,
  SkillsState,
  WorkflowBrief,
} from "../types";

import {
  boundedText,
  byteLength,
  displayLabel,
  emptyReplay,
  returnedPatch,
  skillObservation,
} from "./observations";
import {
  briefContext,
  canEnableBrief,
  changeBrief,
  emptyBrief,
  isBriefOrigin,
} from "./workflow-brief";

const contextState = {
  plugin: "frontend-skills-mods",
  key: "context",
} as const;
const skillState = {
  plugin: "frontend-skills-mods",
  key: "lastSkill",
} as const;

export const register: Register = (on) => {
  registerDesk(on);
  on("session.start", async ($, e, next) => {
    const result = await next(e);
    await readContext($);
    await startDesk($);
    return result;
  });

  on("turn.complete", async ($, e, next) => {
    const result = await next(e);
    if (!e.agentId) await readContext($);
    return result;
  });

  on("tool.call", { tool: "Skill" }, async ($, e, next) => {
    const { value: initial } = await $.state.get(skillsState);
    const generation = initial?.generation ?? 0;
    const result = await next(e);
    const observation = skillObservation(e.skill, e.agentId, result);
    await update($, skillsState, (current): SkillsState => {
      const state = current ?? { entries: [], generation: 0 };
      return state.generation !== generation
        ? state
        : { ...state, entries: [...state.entries, observation].slice(-24) };
    });
    if (
      !e.agentId &&
      result.deny === undefined &&
      !result.isError &&
      result.result?.success
    ) {
      await $.state.set(skillState, e.skill);
    }
    return result;
  });

  on("ui.render", { component: "AbovePrompt" }, async ($, e, next) => {
    if (e.props.hasSurvey || e.props.bodyColumns < 32 || e.props.view.agentId) {
      return next(e);
    }
    const { value: usage } = await $.state.get(contextState);
    const { value: lastSkill } = await $.state.get(skillState);
    const { value: brief } = await $.state.get(briefState);
    const context = usage ? `Context ${usage.percent}%` : "Context unavailable";
    const briefing = brief?.enabled ? " · Brief on" : "";
    const skill = lastSkill ? ` · Last skill ${displayLabel(lastSkill)}` : "";
    const { Box, Text } = $.ui.resolve(e);
    return Box({
      flexDirection: "column",
      children: [
        await next(e),
        Text({
          dimColor: true,
          children: `${context}${briefing}${skill}`.slice(
            0,
            e.props.bodyColumns,
          ),
        }),
      ],
    });
  });
};

async function readContext($: EngineInterface): Promise<void> {
  let context: ContextReading = null;
  try {
    const { context: usage } = await $.session.usage();
    if (usage.window > 0 && usage.tokens !== undefined) {
      const percent = usage.percent ?? (usage.tokens / usage.window) * 100;
      if (Number.isFinite(percent)) {
        context = {
          tokens: usage.tokens,
          window: usage.window,
          percent: Math.round(percent),
        };
      }
    }
  } catch {
    // Visible unavailable state replaces stale numbers; no tool/turn is denied.
    context = null;
  }
  await $.state.set(contextState, context);
}

const viewState = { plugin: "frontend-skills-mods", key: "deskView" } as const;

function registerDesk(on: On): void {
  registerReplay(on);
  registerBrief(on);
  on("tool.call", async ($, e, next) => {
    // Any tool may mutate repo state, including MCP tools. Require a fresh comparison.
    await $.state.set(repositoryState, null);
    return next(e);
  });
  on("tool.call", { tool: "Bash" }, async ($, e, next) => {
    const checks = new Map<string, CheckKind>([
      ["bun run type:check", "types"],
      ["bun run lint", "lint"],
      ["bun run lint:fix", "lint"],
      ["bun run test", "tests"],
      ["bun run test:mods", "mods"],
    ]);
    const kind = checks.get(e.command.trim());
    if (!kind || e.agentId || e.run_in_background) return next(e);
    const ref = {
      plugin: "frontend-skills-mods",
      key: "proof",
      id: kind,
    } as const;
    await $.state.set(ref, {
      toolId: e.tool_use_id,
      outcome: "pending",
      fingerprint: null,
      changedDuringCheck: false,
    });
    const before = await repositoryFingerprint($);
    let result: ToolCallResult<"Bash">;
    try {
      result = await next(e);
    } catch (error) {
      await update(
        $,
        ref,
        (current): ProofReceipt =>
          current?.toolId !== e.tool_use_id
            ? (current ?? {
                toolId: e.tool_use_id,
                outcome: "incomplete",
                fingerprint: null,
                changedDuringCheck: false,
              })
            : { ...current, outcome: "incomplete" },
      );
      throw error;
    }
    const after = await repositoryFingerprint($);
    const outcome = proofOutcome(result);
    await update(
      $,
      ref,
      (current): ProofReceipt =>
        current?.toolId !== e.tool_use_id
          ? (current ?? {
              toolId: e.tool_use_id,
              outcome: "incomplete",
              fingerprint: null,
              changedDuringCheck: false,
            })
          : {
              toolId: e.tool_use_id,
              outcome,
              fingerprint: before === after ? after : null,
              changedDuringCheck:
                before !== null && after !== null && before !== after,
            },
    );
    return result;
  });
  on("command.run", { command: "harness" }, async ($, e) => {
    const args = e.args.trim();
    const briefCommand = /^brief(?:\s+([\s\S]*))?$/.exec(args);
    const view = briefCommand ? "brief" : args || "proof";
    if (
      view !== "proof" &&
      view !== "skills" &&
      view !== "replay" &&
      view !== "brief"
    ) {
      return { text: "Usage: /harness [proof|skills|replay|brief]" };
    }
    if (briefCommand?.[1]) {
      if (!isBriefOrigin(e.origin)) {
        return {
          text: "Workflow brief not changed: use a composer, bridge or SDK command.",
        };
      }
      const briefArgs = briefCommand[1];
      let error: string | undefined;
      await update($, briefState, (current): WorkflowBrief => {
        const state = current ?? emptyBrief();
        const changed = changeBrief(state, briefArgs);
        error = "error" in changed ? changed.error : undefined;
        return "state" in changed ? changed.state : state;
      });
      if (error) return { text: `Workflow brief not changed: ${error}` };
    }
    if (view === "proof") await refreshRepository($);
    await $.state.set(viewState, view);
    const { isPlaced } = await $.ui.open({
      id: "harness",
      title: "Harness",
      focus: true,
      closeOnEscape: true,
      rows: 16,
    });
    const text = await deskText($, view);
    return {
      text: isPlaced ? text : `${text}\nPane unavailable on this surface.`,
    };
  });
  on("ui.render", { component: "Pane" }, async ($, e, next) => {
    if (e.requestId !== "harness") return next(e);
    const { value: view = "proof" } = await $.state.get(viewState);
    const { value: brief = emptyBrief() } = await $.state.get(briefState);
    const { Box, Text, Button } = $.ui.resolve(e);
    return Box({
      flexDirection: "column",
      children: [
        Box({
          children: (["proof", "skills", "replay", "brief"] as const).map(
            (tab) =>
              Button({
                key: tab,
                label: tab.charAt(0).toUpperCase() + tab.slice(1),
                onPress: () => $.state.set(viewState, tab),
              }),
          ),
        }),
        Text({ children: await deskText($, view) }),
        ...(view === "brief"
          ? [
              ...(brief.enabled || canEnableBrief(brief)
                ? [
                    Button({
                      key: "toggle-brief",
                      label: brief.enabled ? "Pause brief" : "Enable brief",
                      onPress: () =>
                        update($, briefState, (current): WorkflowBrief => {
                          const state = current ?? emptyBrief();
                          const changed = changeBrief(
                            state,
                            state.enabled ? "off" : "on",
                          );
                          return "state" in changed ? changed.state : state;
                        }),
                    }),
                  ]
                : []),
              Button({
                key: "clear-brief",
                label: "Clear brief",
                onPress: () => $.state.set(briefState, emptyBrief()),
              }),
            ]
          : []),
        ...(view === "replay"
          ? [
              Button({
                key: "previous",
                label: "Previous edit",
                onPress: () =>
                  update(
                    $,
                    replayState,
                    (state): ReplayState => ({
                      ...(state ?? emptyReplay()),
                      index: Math.max(0, (state?.index ?? 0) - 1),
                    }),
                  ),
              }),
              Button({
                key: "next",
                label: "Next edit",
                onPress: () =>
                  update(
                    $,
                    replayState,
                    (state): ReplayState => ({
                      ...(state ?? emptyReplay()),
                      index: Math.min(
                        Math.max(0, (state?.entries.length ?? 0) - 1),
                        (state?.index ?? 0) + 1,
                      ),
                    }),
                  ),
              }),
              Button({
                key: "clear-replay",
                label: "Clear replay",
                onPress: () =>
                  update(
                    $,
                    replayState,
                    (state): ReplayState => ({
                      ...emptyReplay(),
                      generation: (state?.generation ?? 0) + 1,
                    }),
                  ),
              }),
            ]
          : []),
        ...(view === "skills"
          ? [
              Button({
                key: "clear-skills",
                label: "Clear skill history",
                onPress: () =>
                  update(
                    $,
                    skillsState,
                    (state): SkillsState => ({
                      entries: [],
                      generation: (state?.generation ?? 0) + 1,
                    }),
                  ),
              }),
            ]
          : []),
        ...(view === "proof"
          ? [
              Button({
                key: "refresh",
                label: "Refresh repo state",
                onPress: () => refreshRepository($),
              }),
            ]
          : []),
        Button({
          key: "close",
          label: "Close",
          role: "dismiss",
          onPress: () => $.ui.close({ id: "harness" }),
        }),
      ],
    });
  });
}

function proofOutcome(result: ToolCallResult<"Bash">): ProofReceipt["outcome"] {
  if (result.deny !== undefined) return "denied";
  if (result.isError) return "failed";
  const output = result.result;
  return output.interrupted ||
    output.backgroundTaskId !== undefined ||
    output.backgroundedByUser ||
    output.backgroundedByTurnAbort ||
    output.backgroundedToDeliverMessage ||
    output.timedOutAfterMs !== undefined ||
    output.returnCodeInterpretation !== undefined
    ? "incomplete"
    : "passed";
}

async function deskText($: EngineInterface, view: DeskView): Promise<string> {
  if (view === "proof") return proofText($);
  if (view === "brief") {
    const { value: brief = emptyBrief() } = await $.state.get(briefState);
    return [
      `Workflow brief: ${brief.enabled ? "enabled" : "disabled"}`,
      "Future composer/bridge/SDK non-command prompts only. All 4 fields required.",
      "Edit with /harness brief <field> <text>; enable with /harness brief on.",
      "Disable with off; clear erases this mod's copy, not prior conversation context.",
      "Injected block preview:",
      briefContext(brief),
    ].join("\n");
  }
  if (view === "skills") {
    const { value: history } = await $.state.get(skillsState);
    return [
      "Skill Flight Recorder",
      "Latest 24 completions; tool observations, not adherence.",
      ...(history?.entries.length
        ? history.entries.map(
            (entry) => `${entry.name} · ${entry.outcome} · ${entry.provenance}`,
          )
        : ["No Skill calls observed."]),
    ].join("\n");
  }
  const { value: replay } = await $.state.get(replayState);
  const entry = replay?.entries[replay.index];
  const body = entry
    ? `Edit ${replay.index + 1}/${replay.entries.length} · ${entry.path}\n${entry.provenance} · observed main turn ${entry.turn} · tool ${entry.toolId}\n${entry.diff}${entry.truncated ? "\n[Patch truncated at retention limit.]" : ""}`
    : "Edit replay\nNo successful edits observed (after exclusions or clearing).";
  return `${body}\nExcluded sensitive edits: ${replay?.excluded ?? 0}\nSession memory only; latest 20 entries / 64 KiB. Secret filtering is best effort.`;
}

async function startDesk($: EngineInterface): Promise<void> {
  await $.command.register({
    name: "harness",
    description: "Inspect evidence or configure an opt-in workflow brief.",
    argumentHint: "[proof|skills|replay|brief]",
  });
}

const briefState = { plugin: "frontend-skills-mods", key: "brief" } as const;

function registerBrief(on: On): void {
  on("prompt.submit", async ($, e, next) => {
    if (!isBriefOrigin(e.origin) || e.text.trimStart().startsWith("/"))
      return next(e);
    let brief: WorkflowBrief | undefined;
    try {
      brief = (await $.state.get(briefState)).value;
    } catch {
      $.ui.log("Workflow brief unavailable; prompt passed unchanged.");
      return next(e);
    }
    if (!brief?.enabled) return next(e);
    const context = briefContext(brief);
    if (e.context?.includes(context)) return next(e);
    return next({ ...e, context: [...(e.context ?? []), context] });
  });
  on("session.end", async ($, e, next) => {
    await $.state.set(briefState, emptyBrief());
    return next(e);
  });
}

const repositoryState = {
  plugin: "frontend-skills-mods",
  key: "repository",
} as const;

async function refreshRepository($: EngineInterface): Promise<void> {
  await $.state.set(repositoryState, await repositoryFingerprint($));
}

async function proofText($: EngineInterface): Promise<string> {
  const { value: repository } = await $.state.get(repositoryState);
  const lines = [
    "Proof Desk",
    "Observed commands, not a release certification.",
  ];
  for (const [id, label] of [
    ["types", "Types"],
    ["lint", "Lint"],
    ["tests", "Tests"],
    ["mods", "Mod tests"],
  ] as const) {
    const { value: receipt } = await $.state.get({
      plugin: "frontend-skills-mods",
      key: "proof",
      id,
    });
    let status: string = receipt?.outcome ?? "missing";
    if (receipt?.outcome === "passed") {
      status = receipt.changedDuringCheck
        ? "stale (passed; files changed during check)"
        : !receipt.fingerprint || !repository
          ? "unverified (passed)"
          : receipt.fingerprint !== repository
            ? "stale (passed)"
            : "passed";
    }
    lines.push(`${label}: ${status}`);
  }
  lines.push(
    "Dogfood: missing",
    "Visual: missing",
    "Repo comparison: last refresh only; refresh after external edits.",
    "Scope: tracked/unignored repo content; no environment or dependency proof.",
  );
  return lines.join("\n");
}

async function gitOutput(
  $: EngineInterface,
  cwd: string,
  args: string[],
): Promise<string> {
  const result = await $.process.run(
    ["git", "-c", "core.fsmonitor=false", ...args],
    {
      cwd,
      timeoutMs: 1500,
      env: { GIT_OPTIONAL_LOCKS: "0" },
    },
  );
  if (
    result.exitCode !== 0 ||
    result.isStdoutTruncated ||
    result.isStderrTruncated
  ) {
    throw new Error("Repository comparison unavailable");
  }
  return result.stdout;
}

async function repositoryFingerprint(
  $: EngineInterface,
): Promise<string | null> {
  try {
    const cwd = await $.session.cwd();
    const root = (
      await gitOutput($, cwd, ["rev-parse", "--show-toplevel"])
    ).trim();
    if (cwd !== root) return null;
    const head = await gitOutput($, cwd, ["rev-parse", "--verify", "HEAD"]);
    const raw = await gitOutput($, cwd, [
      "diff",
      "--no-ext-diff",
      "--no-textconv",
      "--raw",
      "HEAD",
      "--",
    ]);
    const changed = await gitOutput($, cwd, [
      "diff",
      "--no-ext-diff",
      "--no-textconv",
      "--name-only",
      "-z",
      "HEAD",
      "--",
    ]);
    const deleted = await gitOutput($, cwd, [
      "diff",
      "--diff-filter=D",
      "--name-only",
      "-z",
      "HEAD",
      "--",
    ]);
    const untracked = await gitOutput($, cwd, [
      "ls-files",
      "--others",
      "--exclude-standard",
      "-z",
    ]);
    const removed = new Set(deleted.split("\0"));
    const files = [...new Set(`${changed}${untracked}`.split("\0"))]
      .filter((path) => path && !removed.has(path))
      .sort();
    if (
      files.length > 200 ||
      files.some(
        (path) => path.startsWith("/") || path.split("/").includes(".."),
      )
    )
      return null;
    const stats = await Promise.all(
      files.map((path) => $.fs.stat(`${cwd}/${path}`)),
    );
    if (
      stats.some(
        (stat) =>
          stat.isLink || stat.kind !== "file" || stat.size > 4 * 1024 * 1024,
      ) ||
      stats.reduce((size, stat) => size + stat.size, 0) > 16 * 1024 * 1024
    )
      return null;
    const hashes = files.length
      ? await gitOutput($, cwd, ["hash-object", "--no-filters", "--", ...files])
      : "";
    if (files.length && hashes.trim().split("\n").length !== files.length)
      return null;
    const digest = await crypto.subtle.digest(
      "SHA-256",
      new TextEncoder().encode(
        JSON.stringify([
          cwd,
          head,
          raw,
          changed,
          deleted,
          untracked,
          files,
          hashes,
        ]),
      ),
    );
    return [...new Uint8Array(digest)]
      .map((byte) => byte.toString(16).padStart(2, "0"))
      .join("");
  } catch {
    // Unsupported host/process/repo state stays visibly unverified, never green.
    return null;
  }
}

const skillsState = { plugin: "frontend-skills-mods", key: "skills" } as const;

const turnState = { plugin: "frontend-skills-mods", key: "turn" } as const;
const replayState = { plugin: "frontend-skills-mods", key: "replay" } as const;

function registerReplay(on: On): void {
  on("turn.start", async ($, e, next) => {
    await $.state.set(turnState, displayLabel(e.turnId));
    return next(e);
  });
  on("tool.call", { tool: ["Edit", "Write"] }, async ($, e, next) => {
    const { value: turn } = await $.state.get(turnState);
    const { value: initial } = await $.state.get(replayState);
    const generation = initial?.generation ?? 0;
    const result = await next(e);
    if (result.deny !== undefined || result.isError || result.result.staged)
      return result;
    const output = result.result;
    const sensitivePath =
      /(?:^|[\\/])(?:\.env(?:[.\\/]|$)|\.(?:ssh|aws|kube|git)(?:[\\/]|$)|\.(?:npmrc|netrc|pypirc)$|(?:credentials?|secrets?|passwords?)(?:[.\\/]|$)|id_(?:rsa|ed25519|dsa|ecdsa)(?:[.]|$))|\.(?:pem|key|p12|pfx|keystore)$/i;
    const patch = sensitivePath.test(output.filePath)
      ? null
      : returnedPatch(output.structuredPatch);
    const excluded =
      !patch ||
      /-----BEGIN [^\n]*PRIVATE KEY-----|\b(?:sk-(?:ant|proj)-|gh[pousr]_|github_pat_|(?:AKIA|ASIA)[A-Z0-9]{16})|(?:api[_-]?key|access[_-]?token|password|secret)\s*["']?\s*[:=]/i.test(
        patch.diff,
      );
    let entry: ReplayEntry | null = null;
    if (patch && !excluded) {
      entry = {
        path: displayLabel(output.filePath),
        toolId: displayLabel(e.tool_use_id),
        provenance: e.agentId ? `agent ${displayLabel(e.agentId)}` : "main",
        turn: turn ?? "unknown",
        ...patch,
      };
      while (byteLength(JSON.stringify(entry)) > 8192) {
        entry.diff = boundedText(
          entry.diff,
          Math.max(
            0,
            byteLength(entry.diff) - (byteLength(JSON.stringify(entry)) - 8192),
          ),
        );
        entry.truncated = true;
      }
    }
    const retained = entry;
    await update($, replayState, (current): ReplayState => {
      const state = current ?? emptyReplay();
      if (state.generation !== generation) return state;
      if (!retained) return { ...state, excluded: state.excluded + 1 };
      const entries = [...state.entries, retained].slice(-20);
      while (byteLength(JSON.stringify(entries)) > 64 * 1024) entries.shift();
      return { ...state, entries, index: entries.length - 1 };
    });
    return result;
  });
}
