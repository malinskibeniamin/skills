import { describe, expect, test } from "bun:test";
import {
  selectAntigravityRoute,
  selectModelRoute,
} from "../agent-evals/model-policy.ts";

describe("selectModelRoute (Claude / Codex)", () => {
  test("selects configured Claude and Codex routes at xhigh", () => {
    expect(selectModelRoute("claude-code")).toEqual({
      agent: "claude-code",
      model: "claude-opus-5-5",
      effort: "xhigh",
    });
    expect(
      selectModelRoute("claude-code", "claude-fable-5-2", "xhigh"),
    ).toEqual({
      agent: "claude-code",
      model: "claude-fable-5-2",
      effort: "xhigh",
    });
    expect(selectModelRoute("codex")).toEqual({
      agent: "codex",
      model: "gpt-6.1-sol?reasoningEffort=xhigh",
      effort: "xhigh",
    });
  });

  test("rejects unapproved models, efforts, and unknown agents", () => {
    expect(() =>
      selectModelRoute("claude-code", "claude-opus-5-5", "high"),
    ).toThrow();
    expect(() => selectModelRoute("codex", "gpt-6.1-sol", "max")).toThrow();
    expect(() => selectModelRoute("unknown-host")).toThrow();
  });
});

describe("selectAntigravityRoute (Gemini 4)", () => {
  test("defaults to gemini-4-neon at xhigh and permits configured efforts", () => {
    expect(selectAntigravityRoute()).toEqual({
      agent: "antigravity",
      model: "gemini-4-neon",
      effort: "xhigh",
    });
    expect(selectAntigravityRoute("gemini-4-neon", "high")).toEqual({
      agent: "antigravity",
      model: "gemini-4-neon",
      effort: "high",
    });
    expect(selectAntigravityRoute("gemini-4-carbon")).toEqual({
      agent: "antigravity",
      model: "gemini-4-carbon",
      effort: "xhigh",
    });
    expect(selectAntigravityRoute("gemini-4-hydrogen")).toEqual({
      agent: "antigravity",
      model: "gemini-4-hydrogen",
      effort: "high",
    });
  });

  test("rejects unconfigured Antigravity models and disallowed efforts", () => {
    expect(() => selectAntigravityRoute("gemini-2-flash")).toThrow();
    expect(() => selectAntigravityRoute("gemini-4-neon", "max")).toThrow();
    expect(() =>
      selectAntigravityRoute("gemini-4-hydrogen", "xhigh"),
    ).toThrow();
  });
});
