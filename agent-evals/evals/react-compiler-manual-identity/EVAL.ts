import { existsSync, readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

describe("react-compiler manual identity boundary", () => {
  it("creates the subscription hook", () => {
    expect(existsSync("src/useDatasetSubscription.ts")).toBe(true);
  });

  it("imports useMemo directly from react", () => {
    const content = readFileSync("src/useDatasetSubscription.ts", "utf-8");
    expect(content).toMatch(
      /import\s*\{[^}]*\buseMemo\b[^}]*\}\s*from\s*["']react["']/s,
    );
  });

  it("keeps React Compiler enabled", () => {
    const content = readFileSync("src/useDatasetSubscription.ts", "utf-8");
    expect(content).not.toMatch(/["']use no memo["']/);
  });

  it("memoizes only the external options boundary", () => {
    const content = readFileSync("src/useDatasetSubscription.ts", "utf-8");
    expect(content).toMatch(/\bconst\s+options\s*=\s*useMemo\(/);
    expect(content).toMatch(/\{\s*datasetId\s*\}/);
    expect(content).toMatch(/\[datasetId\]/);
  });

  it("documents and passes the stable options to the legacy hook", () => {
    const content = readFileSync("src/useDatasetSubscription.ts", "utf-8");
    expect(content).toMatch(/\/\/[^\n]*identity/i);
    expect(content).toMatch(
      /useLegacyDatasetSubscription\(options,\s*listener\)/s,
    );
  });
});
