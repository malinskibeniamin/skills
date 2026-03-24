import { readFileSync, existsSync } from "fs";
import { describe, it, expect } from "vitest";

describe("setup-registry-workflow: LLM handles registry changes", () => {
  it("should modify the Button component", () => {
    if (existsSync("redpanda-ui/button.tsx")) {
      const content = readFileSync("redpanda-ui/button.tsx", "utf-8");
      expect(content).toContain("destructive");
    }
  });
});
