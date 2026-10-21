import { createHash } from "node:crypto";
import { fileURLToPath } from "node:url";
import { object } from "./github-evidence";

export type ReviewFinding = {
  id: string;
  title: string;
  severity: "P0" | "P1" | "P2" | "P3";
  file: string;
  line: number;
  category: string;
  why_it_matters: string;
  scenario: string;
  evidence: string;
  verification: string;
  autofix_class: "safe_auto" | "gated_auto" | "manual" | "advisory";
  suggested_fix: string | null;
  pre_existing: boolean;
  confidence: number;
};

export type ReviewResult = {
  schema_version: 1;
  reviewer: string;
  status:
    | "APPROVED"
    | "CONCERNS"
    | "NEEDS_CHANGES"
    | "SKIPPED"
    | "UNAVAILABLE"
    | "FAILED";
  findings: ReviewFinding[];
  cross_model_findings: ReviewFinding[];
  testing_gaps: string[];
  simplification_opportunities: string[];
  sufficiency: string;
  reason: string;
};

export function digest(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

export function nonempty(value: unknown, name: string): string {
  if (typeof value !== "string" || !value.trim())
    throw new Error(`${name} must be a non-empty string`);
  return value.trim();
}

export function member<T extends string>(
  value: unknown,
  values: readonly T[],
  name: string,
): T {
  const match = values.find((item) => item === value);
  if (match === undefined) throw new Error(`Invalid ${name}: ${String(value)}`);
  return match;
}

export function strings(value: unknown, name: string): string[] {
  if (!Array.isArray(value)) throw new Error(`${name} must be an array`);
  return value.map((item: unknown) => nonempty(item, name));
}

export function relativePath(value: unknown): string {
  if (typeof value !== "string" || !value.length)
    throw new Error("Repository-relative path must be a non-empty string");
  const path = value;
  if (
    path.startsWith("/") ||
    path.split("/").includes("..") ||
    /[\r\n\0]/.test(path)
  )
    throw new Error(`Invalid repository-relative path: ${path}`);
  return path;
}

export function blocks(finding: ReviewFinding): boolean {
  return (
    !finding.pre_existing &&
    (finding.severity === "P0" || finding.severity === "P1")
  );
}

function parseFinding(value: unknown): ReviewFinding {
  const input = object(value);
  const title = nonempty(input.title, "finding title");
  const file = relativePath(input.file);
  const category = member(
    input.category,
    [
      "correctness",
      "security",
      "type-safety",
      "error-handling",
      "accessibility",
      "testing",
      "maintainability",
      "performance",
      "simplification",
      "compatibility",
      "documentation",
      "dependency",
      "license",
      "product",
      "claims",
      "operations",
    ],
    "finding category",
  );
  const id =
    input.id === undefined
      ? digest(JSON.stringify([category, file, title])).slice(0, 20)
      : nonempty(input.id, "finding id");
  if (!/^[A-Za-z0-9][A-Za-z0-9_.-]{0,127}$/.test(id))
    throw new Error("Invalid finding id");
  if (
    typeof input.line !== "number" ||
    !Number.isInteger(input.line) ||
    input.line < 1
  )
    throw new Error("Finding line must be a positive integer");
  if (typeof input.pre_existing !== "boolean")
    throw new Error("Finding pre_existing must be a boolean");
  if (
    typeof input.confidence !== "number" ||
    !Number.isFinite(input.confidence) ||
    input.confidence < 0 ||
    input.confidence > 1
  )
    throw new Error("Finding confidence must be between 0 and 1");
  return {
    id,
    title,
    file,
    category,
    line: input.line,
    severity: member(
      input.severity,
      ["P0", "P1", "P2", "P3"],
      "finding severity",
    ),
    why_it_matters: nonempty(input.why_it_matters, "finding impact"),
    scenario: nonempty(input.scenario, "finding scenario"),
    evidence: nonempty(input.evidence, "finding evidence"),
    verification: nonempty(input.verification, "finding verification"),
    autofix_class: member(
      input.autofix_class,
      ["safe_auto", "gated_auto", "manual", "advisory"],
      "autofix class",
    ),
    suggested_fix:
      input.suggested_fix === null
        ? null
        : nonempty(input.suggested_fix, "suggested fix"),
    pre_existing: input.pre_existing,
    confidence: input.confidence,
  };
}

// The installed hook and gate adapter use the same versioned jq contract.
// The adapter adds stable ids, typed fields and candidate-bound gate requirements.
export function reviewResult(value: unknown, reviewer: string): ReviewResult {
  const validation = Bun.spawnSync(
    [
      "jq",
      "-e",
      "-s",
      "--arg",
      "reviewer",
      reviewer,
      "--argjson",
      "gate",
      "true",
      "-f",
      fileURLToPath(
        new URL("../agents/references/findings-schema.jq", import.meta.url),
      ),
    ],
    { stdin: Buffer.from(JSON.stringify(value)), timeout: 5_000 },
  );
  if (validation.exitCode !== 0)
    throw new Error(
      "Invalid version 1 reviewer contract, evidence or verdict; use findings-schema.md",
    );
  const input = object(value);
  if (input.reviewer !== reviewer)
    throw new Error("Reviewer does not match the dispatched identity");
  const requested = member(
    input.status,
    [
      "APPROVED",
      "CONCERNS",
      "NEEDS_CHANGES",
      "SKIPPED",
      "UNAVAILABLE",
      "FAILED",
    ],
    "review status",
  );
  const rawFindings =
    input.findings ?? (requested === "SKIPPED" ? [] : undefined);
  if (!Array.isArray(rawFindings))
    throw new Error("Review findings must be an array");
  const findings = rawFindings.map(parseFinding);
  if (new Set(findings.map((finding) => finding.id)).size !== findings.length)
    throw new Error("Duplicate finding ids");
  const rawIndependent = input.cross_model_findings ?? [];
  if (!Array.isArray(rawIndependent))
    throw new Error("Coordinator findings must be an array");
  const cross_model_findings = rawIndependent.map(parseFinding);
  for (const finding of cross_model_findings) {
    const prior = findings.find((item) => item.id === finding.id);
    if (!prior) findings.push(finding);
    else if (JSON.stringify(prior) !== JSON.stringify(finding))
      throw new Error(
        "Conflicting findings share an id; reconcile them before recording",
      );
  }
  const testing_gaps = strings(input.testing_gaps ?? [], "testing gaps");
  const simplification_opportunities = strings(
    input.simplification_opportunities ?? [],
    "simplification opportunities",
  );
  const optionalText = (value: unknown, name: string) => {
    if (value === undefined) return "";
    if (typeof value !== "string") throw new Error(`${name} must be a string`);
    return value.trim();
  };
  const sufficiency = optionalText(input.sufficiency, "sufficiency");
  const reason = optionalText(input.reason, "skip reason");
  const incomplete = ["SKIPPED", "UNAVAILABLE", "FAILED"].includes(requested);
  if (incomplete) {
    if (!reason || findings.length || testing_gaps.length)
      throw new Error(
        "An incomplete review needs a reason and no findings or testing gaps",
      );
  } else if (!findings.length && !testing_gaps.length && !sufficiency) {
    throw new Error("A clean review needs a sufficiency explanation");
  }
  const status = incomplete
    ? requested
    : findings.some(blocks) ||
        testing_gaps.length ||
        requested === "NEEDS_CHANGES"
      ? "NEEDS_CHANGES"
      : findings.length || requested === "CONCERNS"
        ? "CONCERNS"
        : "APPROVED";
  return {
    ...input,
    schema_version: 1,
    reviewer,
    status,
    findings,
    cross_model_findings,
    testing_gaps,
    simplification_opportunities,
    sufficiency,
    reason,
  };
}

if (import.meta.main) {
  try {
    const reviewer = nonempty(process.argv[2], "expected reviewer");
    console.log(
      JSON.stringify(
        reviewResult(JSON.parse(await Bun.stdin.text()), reviewer),
      ),
    );
  } catch (error) {
    console.error(
      error instanceof Error ? error.message : "Invalid review result",
    );
    process.exitCode = 2;
  }
}
