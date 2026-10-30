#!/usr/bin/env bun
import {
  existsSync,
  mkdirSync,
  readFileSync,
  realpathSync,
  renameSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { dirname, join, resolve, sep } from "node:path";
import { object } from "./github-evidence";
import {
  blocks,
  digest,
  member,
  nonempty,
  relativePath,
  reviewResult,
  strings,
  type ReviewResult,
} from "./review-results";

const harness = resolve(import.meta.dir, "..");
const stage = ".context/review-gates";
const start = "<!-- harness-review:start -->";
const end = "<!-- harness-review:end -->";
const slug = (value: unknown) => {
  const id = nonempty(value, "gate id");
  if (!/^[a-z][a-z0-9-]{0,63}$/.test(id)) throw new Error("Invalid gate id");
  return id;
};
function sha(value: unknown): string {
  const hash = nonempty(value, "fingerprint");
  if (!/^[a-f0-9]{64}$/.test(hash)) throw new Error("Invalid fingerprint");
  return hash;
}
function json(file: string): unknown {
  return JSON.parse(readFileSync(file, "utf8"));
}
function atomic(file: string, value: string) {
  mkdirSync(dirname(file), { recursive: true });
  const temporary = `${file}.${crypto.randomUUID()}.tmp`;
  try {
    writeFileSync(temporary, value, { mode: 0o600, flag: "wx" });
    renameSync(temporary, file);
  } finally {
    rmSync(temporary, { force: true });
  }
}
function save(file: string, value: unknown) {
  atomic(file, `${JSON.stringify(value, null, 2)}\n`);
}
function command(args: string[], cwd: string, allowed = [0]): string {
  const run = Bun.spawnSync(args, { cwd, timeout: 30_000 });
  if (!allowed.includes(run.exitCode ?? -1))
    throw new Error(`${args[0]} failed: ${run.stderr.toString().trim()}`);
  return run.stdout.toString();
}
function git(root: string, ...args: string[]) {
  return command(["git", ...args], root);
}
function rootAt(cwd: string) {
  return realpathSync(git(cwd, "rev-parse", "--show-toplevel").trim());
}
function lock<T>(file: string, work: () => T): T {
  mkdirSync(dirname(file), { recursive: true });
  mkdirSync(file);
  try {
    return work();
  } finally {
    rmSync(file, { recursive: true });
  }
}

type Definition = {
  id: string;
  title: string;
  always: boolean;
  globs: string[];
  skills: string[];
  lens: string;
  rereview: "full" | "delta";
  hash: string;
};
function definitions(root: string) {
  const definitions: Definition[] = [];
  for (const [file, source] of [
    [join(harness, "config/review-gates.json"), harness],
    [join(root, ".review-gates.json"), root],
  ]) {
    if (!file || !source || !existsSync(file)) continue;
    const config = object(json(file));
    if (config.version !== 1 || !Array.isArray(config.gates))
      throw new Error(`Invalid gate configuration: ${file}`);
    for (const raw of config.gates) {
      const item = object(raw);
      if (typeof item.always !== "boolean")
        throw new Error("Gate always must be a boolean");
      const skills = strings(item.skills, "gate skills").map((path) => {
        const full = realpathSync(join(source, relativePath(path)));
        if (!full.startsWith(`${realpathSync(source)}${sep}`))
          throw new Error("Gate reference escapes its source repository");
        return full;
      });
      const gate = {
        id: slug(item.id),
        title: nonempty(item.title, "gate title"),
        always: item.always,
        globs: strings(item.globs, "gate globs"),
        skills,
        lens: nonempty(item.lens, "gate lens"),
        rereview:
          item.rereview === undefined
            ? ("full" as const)
            : member(item.rereview, ["full", "delta"], "re-review scope"),
      };
      if (definitions.some((prior) => prior.id === gate.id))
        throw new Error(
          `Duplicate gate id: ${gate.id}; shared gates cannot be shadowed`,
        );
      for (const glob of gate.globs) new Bun.Glob(glob);
      definitions.push({
        ...gate,
        hash: digest(
          JSON.stringify([
            gate,
            skills.map((path) => readFileSync(path, "utf8")),
          ]),
        ),
      });
    }
  }
  if (!definitions.length) throw new Error("No review gates discovered");
  return {
    gates: definitions,
    hash: digest(
      JSON.stringify([
        definitions,
        readFileSync(
          join(harness, "agents/references/findings-schema.md"),
          "utf8",
        ),
        readFileSync(join(harness, "scripts/review-results.ts"), "utf8"),
        readFileSync(
          join(harness, "agents/references/findings-schema.jq"),
          "utf8",
        ),
        readFileSync(import.meta.path, "utf8"),
      ]),
    ),
  };
}

type Snapshot = {
  root: string;
  branch: string;
  head: string;
  base: string;
  baseRef: string;
  fingerprint: string;
  paths: string[];
  diff: string;
};
function snapshot(root: string, baseRef: string): Snapshot {
  const head = git(root, "rev-parse", "HEAD").trim();
  const base = git(root, "rev-parse", "--verify", `${baseRef}^{commit}`).trim();
  const branch = git(root, "branch", "--show-current").trim();
  const ancestor = git(root, "merge-base", base, head).trim();
  const scope = ["--", ".", `:(exclude)${stage}/**`];
  let diff = git(
    root,
    "diff",
    "--binary",
    "--no-ext-diff",
    "--no-textconv",
    "--no-renames",
    ancestor,
    ...scope,
  );
  const tracked = git(
    root,
    "diff",
    "--name-only",
    "-z",
    "--no-renames",
    ancestor,
    ...scope,
  )
    .split("\0")
    .filter(Boolean);
  const untracked = git(
    root,
    "ls-files",
    "--others",
    "--exclude-standard",
    "-z",
    ...scope,
  )
    .split("\0")
    .filter(Boolean)
    .sort();
  for (const path of untracked)
    diff += command(
      [
        "git",
        "diff",
        "--no-index",
        "--binary",
        "--no-ext-diff",
        "--no-textconv",
        "--",
        "/dev/null",
        path,
      ],
      root,
      [0, 1],
    );
  const paths = [...new Set([...tracked, ...untracked])].sort();
  const fingerprint = digest(
    JSON.stringify([root, branch, head, base, diff, paths]),
  );
  if (
    head !== git(root, "rev-parse", "HEAD").trim() ||
    base !== git(root, "rev-parse", `${baseRef}^{commit}`).trim()
  )
    throw new Error("Candidate changed while capturing review input");
  return { root, branch, head, base, baseRef, fingerprint, paths, diff };
}

// Reconstruct captured working changes without touching the caller's index or files.
function candidateTree(
  root: string,
  candidate: Omit<Snapshot, "diff">,
  diff: string,
) {
  const index = join(root, stage, `index-${crypto.randomUUID()}`);
  mkdirSync(dirname(index), { recursive: true });
  const run = (args: string[], input?: string) => {
    const result = Bun.spawnSync(["git", ...args], {
      cwd: root,
      env: { ...Bun.env, GIT_INDEX_FILE: index },
      stdin: input === undefined ? undefined : Buffer.from(input),
      timeout: 30_000,
    });
    if (result.exitCode !== 0)
      throw new Error(
        `Cannot reconstruct review candidate: ${result.stderr.toString().trim()}`,
      );
    return result.stdout.toString().trim();
  };
  try {
    run([
      "read-tree",
      git(root, "merge-base", candidate.base, candidate.head).trim(),
    ]);
    if (diff)
      run(["apply", "--cached", "--binary", "--whitespace=nowarn", "-"], diff);
    return run(["write-tree"]);
  } finally {
    rmSync(index, { force: true });
    rmSync(`${index}.lock`, { force: true });
  }
}

type Classification = { gate: string; relevant: boolean; reason: string };
function classifications(
  value: unknown,
  known: Definition[],
): Classification[] {
  if (!Array.isArray(value))
    throw new Error("Classifications must be an array");
  const result = value.map((raw: unknown) => {
    const item = object(raw);
    const gate = slug(item.gate);
    if (!known.some((definition) => definition.id === gate))
      throw new Error(`Unknown classified gate: ${gate}`);
    if (typeof item.relevant !== "boolean")
      throw new Error("Classification relevant must be a boolean");
    return {
      gate,
      relevant: item.relevant,
      reason: nonempty(item.reason, "classification reason"),
    };
  });
  if (new Set(result.map((item) => item.gate)).size !== result.length)
    throw new Error("Duplicate gate classifications");
  return result;
}
type PlannedGate = {
  id: string;
  title: string;
  lens: string;
  hash: string;
  applicable: boolean;
  reason: string;
  prompt: string;
  promptHash: string;
  scope?: "full" | "delta";
};
type Plan = {
  version: 1;
  id: string;
  directory: string;
  registry: string;
  snapshot: Omit<Snapshot, "diff">;
  diffHash: string;
  integrity: string;
  classifications: Classification[];
  gates: PlannedGate[];
  parent?: string;
  delta?: { previous: string; hash: string };
};
function planAt(root: string) {
  return join(root, stage, "plan.json");
}
function manifest(
  plan: Pick<
    Plan,
    | "registry"
    | "snapshot"
    | "classifications"
    | "gates"
    | "diffHash"
    | "parent"
    | "delta"
  >,
) {
  return digest(
    JSON.stringify([
      plan.registry,
      plan.snapshot,
      plan.classifications,
      plan.gates,
      plan.diffHash,
      ...(plan.parent ? [plan.parent] : []),
      ...(plan.delta ? [plan.delta] : []),
    ]),
  );
}
function readPlan(file: string, root: string): Plan {
  const input = object(json(file));
  const raw = object(input.snapshot);
  if (input.version !== 1 || !Array.isArray(input.gates))
    throw new Error("Invalid review plan");
  const snapshot: Omit<Snapshot, "diff"> = {
    root: nonempty(raw.root, "snapshot root"),
    branch: typeof raw.branch === "string" ? raw.branch : "",
    head: nonempty(raw.head, "snapshot head"),
    base: nonempty(raw.base, "snapshot base"),
    baseRef: nonempty(raw.baseRef, "base reference"),
    fingerprint: sha(raw.fingerprint),
    paths: Array.isArray(raw.paths)
      ? raw.paths.map(relativePath)
      : strings(raw.paths, "snapshot paths"),
  };
  const id = sha(input.id);
  const directory = join(root, stage, "runs", id);
  if (snapshot.root !== root || input.directory !== directory)
    throw new Error(
      "Review plan belongs to another checkout or candidate directory",
    );
  const gates = input.gates.map((raw: unknown) => {
    const item = object(raw);
    if (typeof item.applicable !== "boolean")
      throw new Error("Invalid gate applicability");
    const gate = slug(item.id);
    const prompt = join(directory, "prompts", `${gate}.md`);
    if (item.prompt !== prompt)
      throw new Error("Gate prompt belongs to another candidate directory");
    const promptHash = sha(item.promptHash);
    if (digest(readFileSync(prompt, "utf8")) !== promptHash)
      throw new Error(
        "Staged gate prompt changed; restore the immutable review input",
      );
    return {
      id: gate,
      title: nonempty(item.title, "gate title"),
      lens: nonempty(item.lens, "gate lens"),
      hash: sha(item.hash),
      applicable: item.applicable,
      reason: nonempty(item.reason, "routing reason"),
      prompt,
      promptHash,
      ...(item.scope === undefined
        ? {}
        : {
            scope: member(item.scope, ["full", "delta"], "review scope"),
          }),
    };
  });
  if (new Set(gates.map((gate) => gate.id)).size !== gates.length)
    throw new Error("Duplicate planned gates");
  const known = definitions(root);
  const plan: Plan = {
    version: 1,
    id,
    directory,
    registry: sha(input.registry),
    snapshot,
    diffHash: sha(input.diffHash),
    integrity: sha(input.integrity),
    classifications: classifications(input.classifications, known.gates),
    gates,
    ...(input.parent === undefined ? {} : { parent: sha(input.parent) }),
    ...(input.delta === undefined
      ? {}
      : {
          delta: {
            previous: sha(object(input.delta).previous),
            hash: sha(object(input.delta).hash),
          },
        }),
  };
  if (
    manifest(plan) !== plan.integrity ||
    digest(readFileSync(join(directory, "change.diff"), "utf8")) !==
      plan.diffHash ||
    (plan.delta &&
      digest(readFileSync(join(directory, "repair.diff"), "utf8")) !==
        plan.delta.hash) ||
    (plan.gates.some((gate) => gate.scope === "delta") && !plan.delta)
  )
    throw new Error(
      "Staged review inputs changed; restore the immutable review input",
    );
  return plan;
}
type Executor = { mode: "inline" | "agent"; label: string; model: string };
function executor(raw: unknown): Executor {
  const input = object(raw);
  return {
    mode: member(input.mode, ["inline", "agent"], "execution mode"),
    label: nonempty(input.label, "executor"),
    model: nonempty(input.model, "model provenance"),
  };
}
type Verification = {
  executor: Executor;
  verdicts: {
    finding_id: string;
    refuted: boolean;
    reason: string;
    evidence: string;
  }[];
};
type GateRecord = {
  plan: string;
  gate: string;
  hash: string;
  reviewer: string;
  executor: Executor;
  result: ReviewResult;
  verification?: Verification;
};
function recordFile(plan: Plan, gate: PlannedGate) {
  return join(plan.directory, "results", `${gate.id}.json`);
}
function verification(raw: unknown, result: ReviewResult): Verification {
  const input = object(raw);
  if (!Array.isArray(input.verdicts))
    throw new Error("Verification verdicts must be an array");
  const verdicts = input.verdicts.map((raw: unknown) => {
    const item = object(raw);
    const finding_id = nonempty(item.finding_id, "verified finding id");
    if (!result.findings.some((finding) => finding.id === finding_id))
      throw new Error("Verification cites an unknown finding");
    if (typeof item.refuted !== "boolean")
      throw new Error("Refutation must be a boolean");
    return {
      finding_id,
      refuted: item.refuted,
      reason: nonempty(item.reason, "verification reason"),
      evidence: nonempty(item.evidence, "verification evidence"),
    };
  });
  if (new Set(verdicts.map((item) => item.finding_id)).size !== verdicts.length)
    throw new Error("Duplicate verification verdicts");
  return { executor: executor(input.executor), verdicts };
}
function readRecord(plan: Plan, gate: PlannedGate): GateRecord {
  const input = object(json(recordFile(plan, gate)));
  if (
    input.plan !== plan.id ||
    input.gate !== gate.id ||
    input.hash !== gate.hash
  )
    throw new Error("Result belongs to another candidate or rubric");
  const reviewer = slug(input.reviewer);
  const result = reviewResult(input.result, reviewer);
  const record: GateRecord = {
    plan: plan.id,
    gate: gate.id,
    hash: gate.hash,
    reviewer,
    executor: executor(input.executor),
    result,
  };
  if (input.verification !== undefined) {
    record.verification = verification(input.verification, result);
    if (record.verification.executor.label === record.executor.label)
      throw new Error("A reviewer cannot refute its own findings");
  }
  return record;
}

function priorReview(root: string, plan: Plan | undefined, id: string) {
  const visited = new Set<string>();
  while (plan) {
    if (visited.has(plan.id))
      throw new Error(
        `Cyclic review history at ${plan.id}; restore its immutable predecessor plan.json`,
      );
    visited.add(plan.id);
    const gate = plan.gates.find((gate) => gate.id === id && gate.applicable);
    if (
      gate &&
      (existsSync(recordFile(plan, gate)) ||
        existsSync(`${recordFile(plan, gate)}.error`))
    )
      return { plan, gate };
    plan = plan.parent
      ? readPlan(join(root, stage, "runs", plan.parent, "plan.json"), root)
      : undefined;
  }
  return undefined;
}

function createPlan(
  root: string,
  baseRef: string,
  classificationFile?: string,
): Plan {
  return lock(join(root, stage, "planning.lock"), () => {
    const registry = definitions(root);
    const captured = snapshot(root, baseRef);
    const classified = classifications(
      classificationFile ? json(classificationFile) : [],
      registry.gates,
    );
    const previous = existsSync(planAt(root))
      ? readPlan(planAt(root), root)
      : undefined;
    if (
      previous?.snapshot.fingerprint === captured.fingerprint &&
      previous.registry === registry.hash &&
      JSON.stringify(previous.classifications) === JSON.stringify(classified)
    )
      return previous;
    const parent = previous?.id;
    let repair: string | undefined;
    if (
      previous &&
      previous.registry === registry.hash &&
      previous.snapshot.branch === captured.branch &&
      previous.snapshot.base === captured.base &&
      git(root, "merge-base", previous.snapshot.head, captured.head).trim() ===
        previous.snapshot.head &&
      previous.gates.some((gate) => existsSync(recordFile(previous, gate)))
    ) {
      repair = git(
        root,
        "diff",
        "--binary",
        "--no-ext-diff",
        "--no-textconv",
        "--no-renames",
        candidateTree(
          root,
          previous.snapshot,
          readFileSync(join(previous.directory, "change.diff"), "utf8"),
        ),
        candidateTree(root, captured, captured.diff),
      );
    }
    const delta =
      repair === undefined || !previous
        ? undefined
        : { previous: previous.id, hash: digest(repair) };
    const id = digest(
      JSON.stringify([
        captured.fingerprint,
        registry.hash,
        classified,
        ...(parent ? [parent] : []),
        ...(delta ? [delta] : []),
      ]),
    );
    const directory = join(root, stage, "runs", id);
    const gates = registry.gates.map((definition) => {
      const classifiedGate = classified.find(
        (item) => item.gate === definition.id,
      );
      const hit = captured.paths.find((path) =>
        definition.globs.some((glob) => new Bun.Glob(glob).match(path)),
      );
      let prior = "";
      let priorNeedsReview = false;
      let reviewed = false;
      try {
        const priorInput = priorReview(root, previous, definition.id);
        if (priorInput) {
          const file = recordFile(priorInput.plan, priorInput.gate);
          if (existsSync(`${file}.error`))
            throw new Error("Prior review failed to produce a valid result");
          const record = readRecord(priorInput.plan, priorInput.gate);
          priorNeedsReview =
            record.result.findings.length > 0 ||
            ["NEEDS_CHANGES", "UNAVAILABLE", "FAILED"].includes(
              record.result.status,
            );
          reviewed =
            priorInput.plan.id === previous?.id &&
            ["APPROVED", "CONCERNS", "NEEDS_CHANGES"].includes(
              record.result.status,
            );
          prior = JSON.stringify(record);
        }
      } catch (error) {
        priorNeedsReview = true;
        prior = `Prior review unavailable: ${error instanceof Error ? error.message : "unknown error"}`;
      }
      const applicable =
        definition.always ||
        Boolean(hit) ||
        priorNeedsReview ||
        classifiedGate?.relevant !== false;
      const reason = definition.always
        ? "Required on every change"
        : hit
          ? `Path signal: ${hit}`
          : priorNeedsReview
            ? "Prior findings or incomplete review need confirmation"
            : classifiedGate
              ? `Semantic applicability: ${classifiedGate.reason}`
              : "No semantic verdict; review conservatively";
      const prompt = join(directory, "prompts", `${definition.id}.md`);
      const scope: "full" | "delta" =
        delta && reviewed && definition.rereview === "delta" ? "delta" : "full";
      const input =
        scope === "delta"
          ? `Read ${join(directory, "repair.diff")} (changes since the prior captured review, including working changes). Focus on changed behavior and prior findings; expand into source, callers and ${join(directory, "change.diff")} (the full, lossless candidate diff) when needed to prove a claim. Do not hunt unrelated old defects or repost an existing finding.`
          : `Read ${join(directory, "change.diff")} (the full, lossless candidate diff). Inspect source, callers and independent evidence as needed.`;
      const promptText = `# ${definition.title}\n\n${definition.lens}\n\n${input}\n\nGuidance to load for this gate:\n${definition.skills.map((path) => `- ${path}`).join("\n")}\n\nApply only this gate's lens. Linked skills supply guidance, not permission to execute sibling workflows, dispatch agents or publish.\n\nRouting: ${reason}; review scope: ${scope}.\n\nReturn the structured review contract at ${join(harness, "agents/references/findings-schema.md")}, with reviewer ${definition.id} for inline/generic gate workers. Existing native reviewer agents retain their dispatched identity; the owner binds it with --reviewer. A clean result needs sufficiency tied to this change, not merely related existing artifacts. Report all findings; preserve their ids across re-reviews. Confirm prior findings are fixed or rebut them with source/reproduction evidence. Report the class of bug and every affected instance, not duplicate line-level findings. Do not modify code, invoke another model, invent endorsement, or claim another executor's work as your own.\n\nPrior review context (not current approval):\n${prior || "No prior review."}\n`;
      atomic(prompt, promptText);
      return {
        id: definition.id,
        title: definition.title,
        lens: definition.lens,
        hash: definition.hash,
        applicable,
        reason,
        prompt,
        promptHash: digest(promptText),
        scope,
      };
    });
    const { diff, ...candidate } = captured;
    const contents = {
      version: 1 as const,
      id,
      directory,
      registry: registry.hash,
      snapshot: candidate,
      diffHash: digest(diff),
      classifications: classified,
      gates,
      ...(parent ? { parent } : {}),
      ...(delta ? { delta } : {}),
    };
    const plan: Plan = { ...contents, integrity: manifest(contents) };
    atomic(join(directory, "change.diff"), diff);
    if (repair !== undefined) atomic(join(directory, "repair.diff"), repair);
    if (
      snapshot(root, baseRef).fingerprint !== captured.fingerprint ||
      definitions(root).hash !== registry.hash
    )
      throw new Error("Review inputs changed during planning");
    save(join(directory, "plan.json"), plan);
    save(planAt(root), plan);
    return plan;
  });
}

type Row = {
  gate: string;
  title: string;
  status:
    | "PASSED"
    | "CONCERNS"
    | "NEEDS_CHANGES"
    | "SKIPPED"
    | "PENDING"
    | "ERROR"
    | "STALE";
  reason: string;
  executor: string;
};
export type ReviewCheckpoint = {
  status: "passed" | "pending" | "blocked" | "stale" | "not-configured";
  reasons: string[];
  rows: Row[];
  head?: string;
  base?: string;
  plan?: string;
};
export function reviewCheckpoint(cwd: string, file?: string): ReviewCheckpoint {
  const root = rootAt(cwd);
  const target = file ?? planAt(root);
  if (
    !file &&
    !existsSync(target) &&
    !existsSync(join(root, ".review-gates.json"))
  )
    return { status: "not-configured", reasons: [], rows: [] };
  if (!existsSync(target))
    return {
      status: "pending",
      reasons: ["review-gates:plan-missing"],
      rows: [],
    };
  try {
    const plan = readPlan(target, root);
    const registry = definitions(root);
    const current = snapshot(root, plan.snapshot.baseRef);
    if (
      plan.snapshot.root !== root ||
      plan.registry !== registry.hash ||
      current.fingerprint !== plan.snapshot.fingerprint
    )
      return {
        status: "stale",
        reasons: ["review-gates:inputs-changed"],
        head: current.head,
        base: current.base,
        plan: plan.id,
        rows: plan.gates.map((gate) => ({
          gate: gate.id,
          title: gate.title,
          status: "STALE",
          reason:
            "Candidate, working changes or rubric inputs changed; re-plan and review",
          executor: "Not run",
        })),
      };
    const expectedId = digest(
      JSON.stringify([
        current.fingerprint,
        registry.hash,
        plan.classifications,
        ...(plan.parent ? [plan.parent] : []),
        ...(plan.delta ? [plan.delta] : []),
      ]),
    );
    if (
      plan.id !== expectedId ||
      plan.gates.length !== registry.gates.length ||
      registry.gates.some(
        (definition) =>
          !plan.gates.some(
            (gate) =>
              gate.id === definition.id && gate.hash === definition.hash,
          ),
      )
    )
      throw new Error("Review plan does not cover the configured gate set");
    const rows: Row[] = plan.gates.map((gate) => {
      const base = { gate: gate.id, title: gate.title, executor: "Not run" };
      const definition = registry.gates.find(
        (definition) => definition.id === gate.id,
      );
      const classified = plan.classifications.find(
        (item) => item.gate === gate.id,
      );
      if (!gate.applicable) {
        if (
          !definition ||
          definition.always ||
          current.paths.some((path) =>
            definition.globs.some((glob) => new Bun.Glob(glob).match(path)),
          ) ||
          classified?.relevant !== false
        )
          throw new Error(`Invalid skip for ${gate.id}`);
        return { ...base, status: "SKIPPED", reason: gate.reason };
      }
      if (existsSync(`${recordFile(plan, gate)}.error`))
        return {
          ...base,
          status: "ERROR",
          reason: readFileSync(`${recordFile(plan, gate)}.error`, "utf8"),
        };
      if (!existsSync(recordFile(plan, gate)))
        return { ...base, status: "PENDING", reason: gate.reason };
      try {
        const record = readRecord(plan, gate);
        const refuted = new Set(
          record.verification?.verdicts
            .filter((item) => item.refuted)
            .map((item) => item.finding_id),
        );
        const remaining = record.result.findings.filter(
          (finding) => !refuted.has(finding.id),
        );
        const failed =
          record.result.critical_checks_failed ||
          remaining.some(blocks) ||
          record.result.testing_gaps.length > 0 ||
          (record.result.status === "NEEDS_CHANGES" &&
            record.result.findings.length === 0);
        const status = ["SKIPPED", "UNAVAILABLE", "FAILED"].includes(
          record.result.status,
        )
          ? "ERROR"
          : failed
            ? "NEEDS_CHANGES"
            : remaining.length
              ? "CONCERNS"
              : "PASSED";
        const evidence = [
          record.result.sufficiency,
          ...remaining.map(
            (finding) =>
              `${finding.severity} ${finding.file}:${finding.line}: ${finding.why_it_matters}`,
          ),
          ...record.result.testing_gaps,
          ...(record.verification?.verdicts.map(
            (item) =>
              `${item.refuted ? "Refuted" : "Retained"} ${item.finding_id} (${record.result.findings.find((finding) => finding.id === item.finding_id)?.title}): ${item.reason}; ${item.evidence}`,
          ) ?? []),
        ]
          .filter(Boolean)
          .join("; ");
        return {
          ...base,
          status,
          reason:
            status === "ERROR"
              ? record.result.reason ||
                "An applicable gate needs completed review coverage"
              : evidence || "Review requested changes",
          executor: `${record.executor.mode}: ${record.executor.label} (${record.executor.model})${record.verification ? `; verified by ${record.verification.executor.label} (${record.verification.executor.model})${record.verification.executor.model === record.executor.model ? "; same-model verification" : ""}` : ""}`,
        };
      } catch (error) {
        return {
          ...base,
          status: "ERROR",
          reason: error instanceof Error ? error.message : "Unreadable result",
        };
      }
    });
    const reasons = rows
      .filter((row) =>
        ["ERROR", "NEEDS_CHANGES", "PENDING"].includes(row.status),
      )
      .map((row) => `review-gates:${row.gate}:${row.status.toLowerCase()}`);
    return {
      status: rows.some(
        (row) => row.status === "ERROR" || row.status === "NEEDS_CHANGES",
      )
        ? "blocked"
        : reasons.length
          ? "pending"
          : "passed",
      reasons,
      rows,
      head: current.head,
      base: current.base,
      plan: plan.id,
    };
  } catch (error) {
    return {
      status: "blocked",
      reasons: [
        `review-gates:${error instanceof Error ? error.message : "unavailable"}`,
      ],
      rows: [],
    };
  }
}
function code(state: ReviewCheckpoint) {
  return state.status === "stale"
    ? 3
    : state.status === "blocked"
      ? 2
      : state.status === "pending"
        ? 1
        : 0;
}
function cell(value: string) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll("|", "&#124;")
    .replace(/[\\`*_[\]!]/g, (character) => `&#${character.charCodeAt(0)};`)
    .replace(/[\r\n]+/g, " ");
}
function render(state: ReviewCheckpoint) {
  const labels: Record<Row["status"], string> = {
    PASSED: "✅ Passed",
    CONCERNS: "✅ Passed with notes",
    NEEDS_CHANGES: "❌ Needs changes",
    SKIPPED: "➖ Skipped",
    PENDING: "⏳ Not run",
    ERROR: "⚠️ Error",
    STALE: "⚠️ Stale",
  };
  return [
    start,
    "## Review gates",
    "",
    `Review status: ${state.status}`,
    "",
    `Candidate: ${state.head ?? "unavailable"}; base: ${state.base ?? "unavailable"}.`,
    `Review input: ${state.plan ?? "unavailable"} (full diff plus captured working changes).`,
    "",
    "| Gate | Executor | Status | Reason / evidence |",
    "|---|---|---|---|",
    ...state.rows.map(
      (row) =>
        `| ${cell(row.title)} | ${cell(row.executor)} | ${labels[row.status]} | ${cell(row.reason)} |`,
    ),
    ...(state.rows.length
      ? []
      : state.reasons.map((reason) => `- ${cell(reason)}`)),
    "",
    "Agent and inline results are not human approval or merge authorization.",
    end,
  ].join("\n");
}
function updateBody(body: string, block: string) {
  const starts = body.split(start).length - 1;
  const ends = body.split(end).length - 1;
  if (starts === 0 && ends === 0)
    return `${body}${body.endsWith("\n") ? "\n" : "\n\n"}${block}\n`;
  if (starts !== 1 || ends !== 1 || body.indexOf(start) > body.indexOf(end))
    throw new Error(
      "Ambiguous review markers; preserve the body and repair the marker pair",
    );
  return (
    body.slice(0, body.indexOf(start)) +
    block +
    body.slice(body.indexOf(end) + end.length)
  );
}

const usage = [
  "Usage: review-gates.ts <command> [options]",
  "  plan --base REF [--classifications FILE]",
  "  record --gate ID --executor LABEL --mode inline|agent --input FILE [--reviewer TYPE] [--model ID]",
  "  verify --gate ID --executor LABEL --mode agent --input FILE [--model ID]",
  "  check | render",
  "  update --body FILE --out FILE",
  "All commands accept --plan FILE except plan. Planning and rendering never dispatch agents or publish.",
].join("\n");
if (import.meta.main) {
  try {
    const [action, ...args] = process.argv.slice(2);
    if (action === "--help") {
      console.log(usage);
      process.exit(0);
    }
    const allowed: Record<string, string[]> = {
      plan: ["--base", "--classifications"],
      record: [
        "--plan",
        "--gate",
        "--executor",
        "--mode",
        "--input",
        "--model",
        "--reviewer",
      ],
      verify: [
        "--plan",
        "--gate",
        "--executor",
        "--mode",
        "--input",
        "--model",
      ],
      check: ["--plan"],
      render: ["--plan"],
      update: ["--plan", "--body", "--out"],
    };
    const flags = action ? allowed[action] : undefined;
    if (!flags || args.length % 2) throw new Error(usage);
    const options = new Map<string, string>();
    for (let i = 0; i < args.length; i += 2) {
      const key = args[i];
      const value = args[i + 1];
      if (!key || !value || !flags.includes(key) || options.has(key))
        throw new Error(usage);
      options.set(key, value);
    }
    const root = rootAt(process.cwd());
    const target = resolve(options.get("--plan") ?? planAt(root));
    if (action === "plan") {
      const base =
        options.get("--base") ??
        command(
          ["bash", join(harness, "scripts/resolve-pr-base.sh")],
          root,
        ).trim();
      console.log(
        JSON.stringify(
          createPlan(root, base, options.get("--classifications")),
        ),
      );
    } else if (
      action === "check" ||
      action === "render" ||
      action === "update"
    ) {
      const state = reviewCheckpoint(root, target);
      if (action === "check") {
        console.log(JSON.stringify(state));
        process.exitCode = code(state);
      } else if (action === "render") console.log(render(state));
      else
        atomic(
          resolve(nonempty(options.get("--out"), "output file")),
          updateBody(
            readFileSync(
              resolve(nonempty(options.get("--body"), "body file")),
              "utf8",
            ),
            render(state),
          ),
        );
    } else {
      const plan = readPlan(target, root);
      const gate = plan.gates.find((gate) => gate.id === options.get("--gate"));
      if (!gate?.applicable)
        throw new Error("Record only an applicable, known gate");
      const who = executor({
        mode: options.get("--mode"),
        label: options.get("--executor"),
        model: options.get("--model") ?? "not recorded",
      });
      if (
        plan.snapshot.root !== root ||
        reviewCheckpoint(root, target).status === "stale"
      )
        throw new Error("Review inputs changed; re-plan before recording");
      lock(`${recordFile(plan, gate)}.lock`, () => {
        try {
          const input = json(
            resolve(nonempty(options.get("--input"), "result file")),
          );
          let record: GateRecord;
          if (action === "verify") {
            record = readRecord(plan, gate);
            if (who.mode !== "agent" || who.label === record.executor.label)
              throw new Error(
                "Verification needs a distinct, explicitly dispatched reviewer",
              );
            record.verification = verification(
              { ...object(input), executor: who },
              record.result,
            );
          } else {
            const reviewer = slug(options.get("--reviewer") ?? gate.id);
            const result = reviewResult(input, reviewer);
            if (result.status === "SKIPPED")
              throw new Error("An applicable gate cannot be skipped");
            record = {
              plan: plan.id,
              gate: gate.id,
              hash: gate.hash,
              reviewer,
              executor: who,
              result,
            };
          }
          if (
            readPlan(target, root).id !== plan.id ||
            snapshot(root, plan.snapshot.baseRef).fingerprint !==
              plan.snapshot.fingerprint
          )
            throw new Error("Review candidate changed during recording");
          save(recordFile(plan, gate), record);
          rmSync(`${recordFile(plan, gate)}.error`, { force: true });
        } catch (error) {
          atomic(
            `${recordFile(plan, gate)}.error`,
            error instanceof Error ? error.message : "Review recording failed",
          );
          throw error;
        }
      });
      console.log(
        JSON.stringify({ gate: gate.id, recorded: true, plan: plan.id }),
      );
    }
  } catch (error) {
    console.error(
      error instanceof Error ? error.message : "Review gates unavailable",
    );
    process.exitCode = 2;
  }
}
