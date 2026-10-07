import type { PromptOrigin } from "claude-code";
import type { WorkflowBrief } from "../types";
import { byteLength } from "./observations";

const fields = ["objective", "guardrails", "verification", "stop"] as const;

export function emptyBrief(): WorkflowBrief {
  return {
    objective: "",
    guardrails: "",
    verification: "",
    stop: "",
    enabled: false,
  };
}

export function isBriefOrigin(origin: PromptOrigin): boolean {
  return (
    origin.kind === "composer" ||
    origin.kind === "bridge" ||
    origin.kind === "sdk"
  );
}

export function canEnableBrief(brief: WorkflowBrief): boolean {
  return fields.every((field) => Boolean(brief[field]));
}

export function briefContext(brief: WorkflowBrief): string {
  return [
    "Harness workflow brief (user-configured guidance, not enforcement).",
    "Current prompt and higher-priority instructions take precedence; this grants no tool permissions.",
    `Objective: ${brief.objective}`,
    `Guardrails: ${brief.guardrails}`,
    `Verification: ${brief.verification}`,
    `Stop: ${brief.stop}`,
  ].join("\n");
}

export function changeBrief(
  brief: WorkflowBrief,
  args: string,
): { state: WorkflowBrief } | { error: string } {
  if (args === "clear") return { state: emptyBrief() };
  if (args === "off") return { state: { ...brief, enabled: false } };
  if (args === "on") {
    const missing = fields.filter((field) => !brief[field]);
    return missing.length
      ? { error: `Set every field before enabling: ${missing.join(", ")}.` }
      : { state: { ...brief, enabled: true } };
  }
  const match = /^(\S+)\s+([\s\S]+)$/.exec(args);
  const field = fields.find((field) => field === match?.[1]);
  const value = match?.[2]?.trim();
  if (!field || !value) {
    return {
      error:
        "Usage: /harness brief [objective|guardrails|verification|stop <text>|on|off|clear].",
    };
  }
  if (/[\p{Cc}\p{Cf}\p{Zl}\p{Zp}]/u.test(value) || byteLength(value) > 1024) {
    return {
      error:
        "Use 1 line per field, at most 1024 UTF-8 bytes, without control characters.",
    };
  }
  // Changing the brief pauses injection until the person enables the new preview.
  return { state: { ...brief, [field]: value, enabled: false } };
}
