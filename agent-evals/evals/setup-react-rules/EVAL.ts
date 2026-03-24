import { readFileSync, existsSync } from "fs";
import { describe, it, expect } from "vitest";

describe("setup-react-rules: LLM respects React enforcement rules", () => {
  it("should create the component file", () => {
    expect(existsSync("src/UserProfile.tsx")).toBe(true);
  });

  it("should NOT use useEffect for data fetching", () => {
    const content = readFileSync("src/UserProfile.tsx", "utf-8");
    const hasUseEffect = /\buseEffect\b/.test(content);
    const hasAllowComment = /\/\/\s*allow-useEffect:/.test(content);
    expect(hasUseEffect && !hasAllowComment).toBe(false);
  });

  it("should use React Query or TanStack Query", () => {
    const content = readFileSync("src/UserProfile.tsx", "utf-8");
    expect(content).toMatch(/useQuery|useMutation|@tanstack\/react-query/);
  });

  it("should NOT use raw <button> element", () => {
    const content = readFileSync("src/UserProfile.tsx", "utf-8");
    expect(content).not.toMatch(/<button[\s>]/);
  });

  it("should NOT use raw <form> element", () => {
    const content = readFileSync("src/UserProfile.tsx", "utf-8");
    expect(content).not.toMatch(/<form[\s>]/);
  });

  it("should NOT use raw <input> element", () => {
    const content = readFileSync("src/UserProfile.tsx", "utf-8");
    expect(content).not.toMatch(/<input[\s/>]/);
  });

  it("should NOT use 'as any'", () => {
    const content = readFileSync("src/UserProfile.tsx", "utf-8");
    expect(content).not.toMatch(/\bas\s+any\b/);
  });

  it("should NOT use @ts-ignore", () => {
    const content = readFileSync("src/UserProfile.tsx", "utf-8");
    expect(content).not.toContain("@ts-ignore");
  });

  it("should NOT use @ts-expect-error", () => {
    const content = readFileSync("src/UserProfile.tsx", "utf-8");
    expect(content).not.toContain("@ts-expect-error");
  });

  it("should NOT import from @chakra-ui", () => {
    const content = readFileSync("src/UserProfile.tsx", "utf-8");
    expect(content).not.toMatch(/@chakra-ui/);
  });
});
