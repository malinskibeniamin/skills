import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { describe, expect, test } from "vitest";

const read = (path: string) => readFileSync(path, "utf8");

interface ShellCommand {
  command: string;
}

interface EvalResults {
  o11y?: { shellCommands?: ShellCommand[] };
}

const isShellCommand = (value: unknown): value is ShellCommand =>
  typeof value === "object" &&
  value !== null &&
  "command" in value &&
  typeof value.command === "string";

const isEvalResults = (value: unknown): value is EvalResults => {
  if (typeof value !== "object" || value === null) return false;
  if (!("o11y" in value) || value.o11y === undefined) return true;
  if (typeof value.o11y !== "object" || value.o11y === null) return false;
  if (
    !("shellCommands" in value.o11y) ||
    value.o11y.shellCommands === undefined
  )
    return true;
  return (
    Array.isArray(value.o11y.shellCommands) &&
    value.o11y.shellCommands.every(isShellCommand)
  );
};

const readShellCommands = () => {
  const results: unknown = JSON.parse(read("__agent_eval__/results.json"));
  if (!isEvalResults(results)) return [];
  return (results.o11y?.shellCommands ?? []).map((entry) => entry.command);
};

describe("TanStack Router query and navigation lifetimes", () => {
  test("passes the supplied behavioral contracts and typecheck", () => {
    expect(() =>
      execFileSync("bun", ["run", "test"], { stdio: "pipe" }),
    ).not.toThrow();
    expect(() =>
      execFileSync("bun", ["run", "typecheck"], { stdio: "pipe" }),
    ).not.toThrow();
  });

  test("uses 1 loader-owned dashboard dependency pipeline", () => {
    const route = read("src/routes/dashboard.tsx");
    const page = read("src/dashboard-page.tsx");

    expect(route).toMatch(/loaderDeps[\s\S]*asOf/);
    expect(route).not.toMatch(
      /loaderDeps\s*:\s*\(\s*\{\s*search\s*\}\s*\)\s*=>\s*search/,
    );
    expect(route).toMatch(/ensureQueryData/);
    expect(route).not.toMatch(/prefetchQuery/);

    const supportedLoaderDeps =
      /useLoaderDeps/.test(page) && !/useSearch/.test(page);
    const supportedSharedContext =
      /context\s*:[\s\S]*dashboardQueryOptions/.test(route) &&
      /useRouteContext/.test(page) &&
      !/useSearch/.test(page);
    expect(supportedLoaderDeps || supportedSharedContext).toBe(true);
  });

  test("keeps Query as the single preload cache owner", () => {
    expect(read("src/router.ts")).toMatch(/defaultPreloadStaleTime\s*:\s*0/);
  });

  test("keeps beforeLoad replay-safe and redirects as control flow", () => {
    const route = read("src/routes/account.tsx");
    const beforeLoad =
      route.match(/beforeLoad\s*:[\s\S]*?(?=\n\s*loader\s*:)/)?.[0] ?? "";
    const loader =
      route.match(
        /loader\s*:[\s\S]*?(?=\n\s*(?:errorComponent|component)\s*:)/,
      )?.[0] ?? "";

    expect(beforeLoad).toMatch(/throw\s+redirect\s*\(/);
    expect(beforeLoad).not.toMatch(
      /analytics\.|toast\.|\.mutate\s*\(|fetch\s*\(/,
    );
    expect(loader).not.toMatch(/\bnavigate\s*\(/);
    expect(loader).toMatch(/abortController\.signal/);
  });

  test("tests the latest rendered route rather than URL publication alone", () => {
    const spec = read("e2e/navigation-race.spec.ts");
    expect(spec).not.toMatch(/waitForTimeout/);
    expect(spec).toMatch(/waitForURL/);
    expect(spec).toMatch(/getByRole\(\s*["']heading["']/);
    expect(spec).toMatch(/not\.toBeVisible|toBeHidden|count\(\).*toBe\(0\)/s);
    expect(spec).toMatch(/login/i);
    expect(spec).toMatch(
      /(?:error|failed)[\s\S]*(?:not\.toBeVisible|toBeHidden|count\(\).*toBe\(0\))/i,
    );
  });

  test("loads version-matched guidance and runs both verification commands", () => {
    const commands = readShellCommands().join("\n");
    expect(commands).toMatch(/@tanstack\/intent(?:@latest)?\s+list/);
    expect(commands).toMatch(/@tanstack\/intent(?:@latest)?\s+use/);
    expect(commands).toMatch(/bun\s+run\s+test/);
    expect(commands).toMatch(/bun\s+run\s+typecheck/);
  });
});
