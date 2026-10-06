import type { ToolCallResult, ToolResultOf } from "claude-code";
import type { ReplayState, SkillObservation } from "../types";

export function displayLabel(value: string): string {
  return value.slice(0, 120).replace(/[\p{Cc}\p{Cf}]/gu, "?");
}

export function skillObservation(
  requested: string,
  agentId: string | undefined,
  result: ToolCallResult<"Skill">,
): SkillObservation {
  const provenance = agentId ? `agent ${displayLabel(agentId)}` : "main";
  if (result.deny !== undefined)
    return { name: displayLabel(requested), provenance, outcome: "denied" };
  if (result.isError)
    return { name: displayLabel(requested), provenance, outcome: "failed" };
  const output = result.result;
  const name = displayLabel(output.commandName);
  const outcome: SkillObservation["outcome"] = !output.success
    ? "failed"
    : output.status === "forked"
      ? output.background
        ? "forked (launched; outcome unknown)"
        : "forked (completed)"
      : output.readOnly
        ? "loaded read-only"
        : "succeeded";
  return { name, provenance, outcome };
}

export function emptyReplay(): ReplayState {
  return { entries: [], index: 0, generation: 0, excluded: 0 };
}

export function byteLength(value: string): number {
  return new TextEncoder().encode(value).length;
}

export function boundedText(value: string, max: number): string {
  let result = "";
  let bytes = 0;
  for (const character of value.slice(0, max)) {
    bytes += byteLength(character);
    if (bytes > max) break;
    result += character;
  }
  return result;
}

export function returnedPatch(patch: ToolResultOf<"Edit">["structuredPatch"]): {
  diff: string;
  truncated: boolean;
} {
  if (!patch.length)
    return {
      diff: "Diff unavailable (host returned no patch).",
      truncated: false,
    };
  let diff = "";
  let truncated = false;
  const append = (text: string) => {
    const remaining = 8192 - byteLength(diff);
    const part = boundedText(text, remaining);
    diff += part;
    truncated = part.length !== text.length;
  };
  for (const hunk of patch) {
    append(
      `${diff ? "\n" : ""}@@ -${hunk.oldStart},${hunk.oldLines} +${hunk.newStart},${hunk.newLines} @@`,
    );
    if (truncated) break;
    for (const line of hunk.lines) {
      append(`\n${line}`);
      if (truncated) break;
    }
    if (truncated) break;
  }
  // Keep newlines/tabs, neutralize terminal control sequences before retaining them.
  diff = diff.replace(/[\p{Cc}\p{Cf}]/gu, (character) =>
    character === "\n" || character === "\t" ? character : "?",
  );
  return { diff, truncated };
}
