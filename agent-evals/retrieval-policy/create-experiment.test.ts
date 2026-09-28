import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { renderRetrievalContext } from "./create-experiment";

describe("retrieval policy experiment", () => {
  it("changes only the code exploration instructions between arms", () => {
    const source = readFileSync("AGENTS.md", "utf8");
    const baseline = renderRetrievalContext(source, "baseline");
    const selective = renderRetrievalContext(source, "selective");
    const withoutExploration = (content: string) =>
      content.replace(
        /### Code exploration\n[\s\S]*?(?=\n### Native delegation)/,
        "",
      );

    expect(withoutExploration(baseline)).toBe(withoutExploration(selective));
    expect(baseline).not.toContain("returned excerpts");
    expect(selective).toContain("returned excerpts");
    expect(selective).toContain("incomplete");
  });
});
