// Copyright 2026 Redpanda Data, Inc.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { basename, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

interface LeakRule {
  label: string;
  pattern: RegExp;
}

interface PromptLeak {
  file: string;
  line: number;
  rule: string;
  text: string;
}

const leakRules = [
  {
    label: "hidden evaluator artifact",
    pattern: /\bhidden\s+(?:grader|tests?|rubric)\b/i,
  },
  {
    label: "explicit evaluator framing",
    pattern:
      /\b(?:this|the)\s+(?:eval|evaluation)\s+(?:checks?|grades?|judges?|scores?)\b/i,
  },
  {
    label: "evaluation harness framing",
    pattern: /\bevaluation\s+(?:harness|loop|run|suite)\b/i,
  },
  {
    label: "candidate identity",
    pattern: /\bcandidate\s+(?:agent|model|output|response)\b/i,
  },
  {
    label: "baseline identity",
    pattern: /\bbaseline\s+(?:agent|model|output|response|score)\b/i,
  },
  {
    label: "rubric framing",
    pattern: /\b(?:evaluation|grading|scoring)\s+rubric\b/i,
  },
  {
    label: "second-person scoring",
    pattern:
      /\byou\s+(?:are|will be)\s+(?:being\s+)?(?:evaluated|graded|scored)\b/i,
  },
] satisfies readonly LeakRule[];

function collectPromptFiles(path: string): string[] {
  const resolvedPath = resolve(path);
  const stats = statSync(resolvedPath);

  if (stats.isFile()) {
    return [resolvedPath];
  }

  if (!stats.isDirectory()) {
    return [];
  }

  return readdirSync(resolvedPath, { withFileTypes: true })
    .sort((left, right) => left.name.localeCompare(right.name))
    .flatMap((entry) => {
      const entryPath = join(resolvedPath, entry.name);
      if (entry.isDirectory()) {
        return collectPromptFiles(entryPath);
      }
      if (entry.isFile() && entry.name === "PROMPT.md") {
        return [entryPath];
      }
      return [];
    });
}

function inspectPrompt(file: string): PromptLeak[] {
  const displayPath = relative(process.cwd(), file) || basename(file);
  return readFileSync(file, "utf8")
    .split(/\r?\n/)
    .flatMap((text, index) =>
      leakRules
        .filter((rule) => rule.pattern.test(text))
        .map((rule) => ({
          file: displayPath,
          line: index + 1,
          rule: rule.label,
          text: text.trim(),
        })),
    );
}

function inspectPromptPaths(paths: readonly string[]): {
  files: string[];
  leaks: PromptLeak[];
} {
  const files = [...new Set(paths.flatMap(collectPromptFiles))].sort();
  return { files, leaks: files.flatMap(inspectPrompt) };
}

function main(): void {
  const defaultRoot = fileURLToPath(new URL("evals", import.meta.url));
  const roots = process.argv.slice(2);
  const { files, leaks } = inspectPromptPaths(
    roots.length > 0 ? roots : [defaultRoot],
  );

  if (files.length === 0) {
    throw new Error("No candidate-facing PROMPT.md files found");
  }

  if (leaks.length === 0) {
    const noun = files.length === 1 ? "prompt" : "prompts";
    console.log(`Prompt blinding passed (${files.length} ${noun})`);
    return;
  }

  console.error("Evaluator context leaked into candidate-facing prompts:");
  for (const leak of leaks) {
    console.error(`- ${leak.file}:${leak.line} [${leak.rule}] ${leak.text}`);
  }
  process.exitCode = 1;
}

if (import.meta.main) {
  try {
    main();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`Prompt blinding check failed: ${message}`);
    process.exitCode = 1;
  }
}
