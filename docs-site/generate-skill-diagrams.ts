import { mkdir, readFile, readdir, rename, writeFile } from "node:fs/promises";
import { join } from "node:path";

interface Skill {
  description: string;
  name: string;
}

interface Palette {
  fill: string;
  stroke: string;
}

type DiagramKind =
  | "architecture"
  | "concern-matrix"
  | "decision-tree"
  | "dependency-graph"
  | "entity-relationship"
  | "evidence-funnel"
  | "feedback-loop"
  | "hierarchy"
  | "layered-architecture"
  | "lifecycle"
  | "mind-map"
  | "pipeline"
  | "progression"
  | "sequence"
  | "state-machine"
  | "swimlane"
  | "system-context"
  | "timeline"
  | "transformation-map"
  | "user-flow";

interface DiagramSpec {
  actors?: string[];
  fields?: string[][];
  kind: DiagramKind;
  nodes: string[];
  relations?: string[];
}

const REPOSITORY_ROOT = join(import.meta.dir, "..");
const OUTPUT_DIRECTORY = join(import.meta.dir, "public", "diagrams", "skills");
const FRONTMATTER = /^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/;
// Published archives still link these shared assets after a skill is retired.
// Read their description from the immutable release, not a second prose copy.
const ARCHIVED_SKILL_SOURCES: Record<string, string> = {
  deslop: "docs-site/content/v4.40.0/skills/deslop.md",
  "resolving-merge-conflicts":
    "docs-site/content/v4.38.0/skills/resolving-merge-conflicts.md",
};
const CREATED_AT = "2026-08-05T00:00:00.000Z";
const CLI = ["bunx", "mcp-excalidraw-server@2.1.2"];
const DEFAULT_PALETTE: Palette = { fill: "#1c4f73", stroke: "#4dabf7" };
const PALETTES: Palette[] = [
  DEFAULT_PALETTE,
  { fill: "#0b4f1c", stroke: "#40c057" },
  { fill: "#402f00", stroke: "#f08c00" },
  { fill: "#6b3232", stroke: "#ff8787" },
];
const SKILL_DIAGRAMS: Record<string, DiagramSpec> = {
  "ci-fixes": {
    kind: "feedback-loop",
    nodes: [
      "Measure critical path",
      "Assess scoped checks",
      "Fix 1 bottleneck",
      "Prove speed + signal",
    ],
  },
  bazel: {
    kind: "dependency-graph",
    nodes: [
      "Sources + schemas",
      "Tools + config",
      "Apps + tests",
      "Release artifacts",
    ],
  },
  accessibility: {
    kind: "concern-matrix",
    nodes: [
      "Semantic HTML",
      "Keyboard + focus",
      "Names + errors",
      "Touch + motion",
    ],
  },
  "agent-watchdog": {
    actors: ["Agent", "Watchdog", "Repository"],
    kind: "swimlane",
    nodes: [
      "Claim work complete",
      "Compare request + diff",
      "Dogfood entrypoint",
      "Repair or verdict",
    ],
  },
  protobuf: {
    kind: "pipeline",
    nodes: [
      "Schema + codegen diff",
      "Consumers + validation",
      "Compatibility evidence",
      "Defects + advisory ideas",
    ],
  },
  aip: {
    fields: [
      ["name", "display_name"],
      ["parent", "collection"],
      ["get / list", "create / update / delete"],
      ["done", "error / response"],
    ],
    kind: "entity-relationship",
    nodes: ["Resource", "Parent collection", "Standard methods", "Operation"],
    relations: ["belongs to", "exposes", "may return"],
  },
  animate: {
    kind: "decision-tree",
    nodes: [
      "Motion request",
      "Clear purpose?",
      "Build + verify",
      "Instant feedback",
    ],
  },
  "animation-performance": {
    kind: "feedback-loop",
    nodes: [
      "Trace frames",
      "Locate cost",
      "Change one cause",
      "Replay + compare",
    ],
  },
  "animation-vocabulary": {
    kind: "transformation-map",
    nodes: [
      "Observed effect",
      "Closest term",
      "Distinguish alternatives",
      "Name, not code",
    ],
  },
  "mobile-native": {
    kind: "concern-matrix",
    nodes: [
      "Viewport + keyboard",
      "Touch + scroll",
      "Zoom + safe areas",
      "Phone verification",
    ],
  },
  "break-ui": {
    kind: "evidence-funnel",
    nodes: [
      "Schema + limits",
      "Worst-case fixture",
      "Real layout stress",
      "Evidence + fixes",
    ],
  },
  "ask-sonner": {
    actors: ["Operation", "Sonner", "User"],
    kind: "sequence",
    nodes: [
      "Start loading",
      "Resolve or reject",
      "Update same toast",
      "Keep error recovery",
    ],
  },
  "ask-ben": {
    kind: "hierarchy",
    nodes: [
      "Incoming request",
      "Build / fix",
      "Plan / research",
      "Review / ship",
    ],
  },
  "bend-laws": {
    actors: ["Human", "Agent", "CI"],
    kind: "swimlane",
    nodes: [
      "Write LAWS.bend",
      "Model + prove",
      "Mutate + compare",
      "Prove + check table",
    ],
  },
  "blast-radius": {
    kind: "evidence-funnel",
    nodes: [
      "Changed behavior",
      "Non-local contracts",
      "Decisive invariant",
      "Executable proof",
    ],
  },
  "brain-dump": {
    kind: "user-flow",
    nodes: [
      "Raw signal",
      "Opportunity tracks",
      "Answer ledger",
      "Grill unresolved choices",
    ],
    relations: ["captures", "classifies", "hands off"],
  },
  "codebase-design": {
    kind: "architecture",
    nodes: ["Caller", "Small interface", "Deep module", "Adapters"],
    relations: ["calls", "hides complexity", "integrates"],
  },
  codex: {
    actors: ["Owner agent", "Codex CLI", "Worktree"],
    kind: "sequence",
    nodes: [
      "Delegate bounded task",
      "Run isolated change",
      "Return evidence",
      "Owner decides",
    ],
  },
  "codex-compat": {
    kind: "architecture",
    nodes: [
      "Canonical rules",
      "Claude surface",
      "Codex surface",
      "Parity evals",
    ],
    relations: ["generates", "adapts", "proves parity"],
  },
  "commit-push-pr": {
    actors: ["Local Git", "GitHub", "CI"],
    kind: "swimlane",
    nodes: [
      "Verify branch",
      "Commit + push",
      "Open pull request",
      "Take CI snapshot",
    ],
  },
  "connect-query": {
    kind: "architecture",
    nodes: [
      "React view",
      "Query hook + cache",
      "Connect transport",
      "RPC service",
    ],
    relations: ["subscribes", "calls", "returns typed data"],
  },
  "create-verification-skill": {
    kind: "lifecycle",
    nodes: [
      "Real app entrypoint",
      "Launch + doctor",
      "Drive + evidence",
      "Cleanup + replay",
    ],
  },
  demo: {
    kind: "user-flow",
    nodes: [
      "Open real feature",
      "Run representative task",
      "Capture evidence",
      "Tell customer story",
    ],
  },
  deslop: {
    kind: "transformation-map",
    nodes: [
      "Bloated diff",
      "Deletion test",
      "Justified surface",
      "Behavior preserved",
    ],
  },
  "development-lifecycle": {
    kind: "lifecycle",
    nodes: ["Inspect", "Act", "Verify", "Repeat or finish"],
  },
  "diagnosing-bugs": {
    kind: "feedback-loop",
    nodes: [
      "Build feedback loop",
      "Reproduce",
      "Test hypothesis",
      "Fix + regression",
    ],
  },
  dogfood: {
    kind: "user-flow",
    nodes: [
      "Real entrypoint",
      "Representative data",
      "User actions",
      "Observation + receipt",
    ],
  },
  docs: {
    kind: "evidence-funnel",
    nodes: [
      "Reader + outcome",
      "Sources + claims",
      "Clear document",
      "Verified links + results",
    ],
  },
  "domain-modeling": {
    fields: [
      ["name", "definition"],
      ["identity", "invariants"],
      ["from / to", "cardinality"],
      ["context", "consequence"],
    ],
    kind: "entity-relationship",
    nodes: ["Term", "Entity", "Relationship", "Decision / ADR"],
    relations: ["names", "connects", "constrains"],
  },
  "e2e-testing": {
    kind: "architecture",
    nodes: [
      "User journey",
      "Playwright test",
      "Real boundaries",
      "Assertions + axe",
    ],
    relations: ["drives", "crosses", "observes"],
  },
  "effect-ts": {
    kind: "pipeline",
    nodes: [
      "Choose Effect version",
      "Install + verify sources",
      "Update agent instructions",
      "Read installed guidance",
    ],
  },
  "effect-v3-to-v4": {
    kind: "feedback-loop",
    nodes: [
      "Validate v3 + v4 sources",
      "Align packages",
      "Map errors + migrate",
      "Type-check + project gates",
    ],
  },
  eli5: {
    kind: "transformation-map",
    nodes: [
      "Source evidence",
      "One mental model",
      "Big pictures + few words",
      "Beginner understanding",
    ],
    relations: ["grounds", "simplifies", "explains"],
  },
  "efficient-frontier": {
    kind: "decision-tree",
    nodes: [
      "Work request",
      "Independent + bounded?",
      "Delegate lane",
      "Keep owner judgment",
    ],
  },
  "excalidraw-diagram": {
    actors: ["Agent", "Git files", "Official CLI"],
    kind: "sequence",
    nodes: [
      "Edit native scene",
      "Render local PNG",
      "Return PNG preview",
      "Inspect + maintain docs",
    ],
  },
  "extend-harness": {
    kind: "architecture",
    nodes: [
      "Rule source",
      "Hook dispatcher",
      "Generated adapters",
      "Behavioral evals",
    ],
    relations: ["registers", "fans out", "verifies"],
  },
  "frontend-invariants": {
    kind: "mind-map",
    nodes: [
      "Frontend truth",
      "Rendering honesty",
      "State placement",
      "Design + interaction",
    ],
  },
  "frontend-starter-kit": {
    kind: "layered-architecture",
    nodes: [
      "Project conventions",
      "Toolchain + config",
      "Hooks + quality gates",
      "Specialist skills",
    ],
  },
  "full-send": {
    kind: "pipeline",
    nodes: [
      "Fix + verify",
      "PR + CI + reviews",
      "Final evidence pass",
      "Authorized merge",
    ],
  },
  go: {
    kind: "lifecycle",
    nodes: ["Verify", "Review", "Deliver", "CI or done"],
  },
  golang: {
    kind: "architecture",
    nodes: [
      "API boundary",
      "Domain logic",
      "Concurrency ownership",
      "Errors + tests",
    ],
    relations: ["validates", "coordinates", "proves"],
  },
  "golang-review": {
    kind: "evidence-funnel",
    nodes: [
      "Go diff",
      "Contracts + call sites",
      "Runtime evidence",
      "Prioritized findings",
    ],
  },
  grilling: {
    kind: "decision-tree",
    nodes: [
      "Evidence packet",
      "Material choice?",
      "Compare approaches",
      "Plan gate",
    ],
  },
  handoff: {
    actors: ["Current agent", "HANDOFF.md", "Next agent"],
    kind: "sequence",
    nodes: [
      "Summarize state",
      "Record decisions + blockers",
      "Reference artifacts",
      "Resume focused work",
    ],
  },
  "hook-audit": {
    kind: "evidence-funnel",
    nodes: [
      "Hook manifest",
      "Telemetry + latency",
      "Violations + zero-fire",
      "Actionable audit",
    ],
  },
  launchdarkly: {
    kind: "evidence-funnel",
    nodes: [
      "Integration + Production",
      "Created over 30 days ago",
      "Universally true + quiet 14 days",
      "Read-only cleanup candidates",
    ],
  },
  "lie-detector": {
    kind: "evidence-funnel",
    nodes: [
      "Diff + every claim",
      "Claims, code, tests that lie",
      "Unrequested + copyable changes",
      "Steelman merge gate",
    ],
  },
  "implement-spec": {
    kind: "dependency-graph",
    nodes: [
      "Spec + tickets",
      "Ready frontier",
      "Implementer worktrees",
      "Integration branch",
    ],
  },
  improve: {
    kind: "transformation-map",
    nodes: [
      "Current architecture",
      "Evidence-ranked candidate",
      "Executor-ready plan",
      "Measured improvement",
    ],
  },
  "improve-codebase-architecture": {
    kind: "architecture",
    nodes: [
      "Scattered callers",
      "Deep module interface",
      "Parallel state",
      "Owned invariant\n(error impossible)",
    ],
    relations: ["replaced by", "duplicates", "enforces"],
  },
  "maintain-verification-skill": {
    kind: "feedback-loop",
    nodes: [
      "Verifier + feature map",
      "Source reconciliation",
      "Live coverage",
      "Repair + replay",
    ],
  },
  "make-pr-easy-to-review": {
    kind: "timeline",
    nodes: [
      "Clean scope",
      "Reviewable commits",
      "Reviewer guidance",
      "Fast review",
    ],
  },
  "plan-arbiter": {
    kind: "decision-tree",
    nodes: [
      "Competing plans",
      "Spec fit",
      "Engineering risk",
      "Chosen merged plan",
    ],
  },
  "plow-ahead": {
    kind: "state-machine",
    nodes: [
      "Routine ambiguity",
      "Reversible assumption",
      "Evidence changes path",
      "True blocker / done",
    ],
  },
  postgresql: {
    kind: "architecture",
    nodes: [
      "Workload",
      "Schema + indexes",
      "Transactions",
      "Observability + rollout",
    ],
    relations: ["shapes", "protects", "measures"],
  },
  pr: {
    kind: "pipeline",
    nodes: ["Primary source", "Summary view", "Before + after", "Merge danger"],
  },
  "pr-shepherd": {
    kind: "state-machine",
    nodes: [
      "Changed or unseen PR",
      "Route by workspace",
      "Repair + refresh HEAD",
      "Quiet / deferred / active",
    ],
  },
  prime: {
    kind: "system-context",
    nodes: [
      "Repository",
      "Rules + docs",
      "Build + test entrypoints",
      "Current branch state",
    ],
  },
  product: {
    kind: "decision-tree",
    nodes: [
      "Plan, PR, or branch",
      "Which lane earns the time?",
      "Beneficiary, trigger, evidence, reach",
      "Justified, thin, or unjustified",
    ],
  },
  prototype: {
    kind: "user-flow",
    nodes: [
      "Open question",
      "Disposable prototype",
      "Observe behavior",
      "Keep learning, discard code",
    ],
  },
  "quantify-impact": {
    kind: "evidence-funnel",
    nodes: [
      "Before baseline",
      "Changed outcome",
      "Reproducible measure",
      "PR evidence",
    ],
  },
  "read-the-damn-docs": {
    kind: "evidence-funnel",
    nodes: [
      "Question + version",
      "Primary documentation",
      "Cross-check behavior",
      "Cited answer",
    ],
  },
  "redpanda-ai-gateway": {
    actors: ["AI CLI", "Gateway", "Provider"],
    kind: "sequence",
    nodes: [
      "Send model request",
      "Apply policy + routing",
      "Call provider",
      "Return telemetry",
    ],
  },
  "registry-workflow": {
    kind: "feedback-loop",
    nodes: [
      "Classify component",
      "Update registry",
      "Compare consumers",
      "Sync + verify",
    ],
  },
  release: {
    kind: "timeline",
    nodes: [
      "Establish release point",
      "Verify package",
      "Land main",
      "Tag + publish",
    ],
  },
  research: {
    kind: "evidence-funnel",
    nodes: [
      "Research question",
      "Primary sources",
      "Corroborated findings",
      "Cited report",
    ],
  },
  "resilience-review": {
    kind: "concern-matrix",
    nodes: [
      "Failure trigger",
      "System response",
      "User recovery",
      "Observability",
    ],
  },
  "resolve-pr-feedback": {
    kind: "state-machine",
    nodes: ["Open thread", "Actionable?", "Fix + verify", "Reply + resolve"],
  },
  "resolving-merge-conflicts": {
    kind: "dependency-graph",
    nodes: [
      "Base intent",
      "Current branch intent",
      "Conflicting hunks",
      "Verified merged result",
    ],
  },
  retro: {
    kind: "feedback-loop",
    nodes: [
      "Session transcript",
      "Friction candidates",
      "Checks + standards",
      "Better next run",
    ],
  },
  revamp: {
    kind: "transformation-map",
    nodes: [
      "Behavioral baseline",
      "Mechanical translation",
      "Idiomatic target",
      "Parity evidence",
    ],
  },
  review: {
    kind: "evidence-funnel",
    nodes: [
      "Diff",
      "Contracts + boundaries",
      "Counterexample + dogfood",
      "Prioritized findings",
    ],
  },
  "security-audit": {
    kind: "evidence-funnel",
    nodes: [
      "Map source + boundaries",
      "Hunt scoped candidates",
      "Validate + verify independently",
      "Validated records + report",
    ],
  },
  "setup-atlassian-workflow": {
    actors: ["Repository", "Atlassian CLI", "Jira"],
    kind: "sequence",
    nodes: [
      "Detect project context",
      "Configure credentials",
      "Create work item",
      "Verify workflow",
    ],
  },
  "setup-routines": {
    kind: "architecture",
    nodes: [
      "Routine templates",
      "Scheduler",
      "Isolated workspace",
      "Reports + notifications",
    ],
    relations: ["triggers", "runs in", "publishes"],
  },
  "show-me": {
    kind: "mind-map",
    nodes: [
      "Current topic",
      "Pseudocode + trees",
      "Mermaid + diffs",
      "Focused HTML",
    ],
  },
  "skeleton-loaders": {
    kind: "pipeline",
    nodes: [
      "Inspect loaded layout",
      "Reserve geometry",
      "Transparent placeholders",
      "Accessible reveal",
    ],
  },
  "snyk-ux-security": {
    kind: "evidence-funnel",
    nodes: [
      "Dependency manifests",
      "Snyk findings",
      "Exploitability triage",
      "Upgrade + release gate",
    ],
  },
  "software-factory": {
    kind: "pipeline",
    nodes: [
      "Assess fit + baseline",
      "Reuse existing services",
      "Bound 1 pilot task",
      "Plan setup, not execution",
    ],
  },
  "stack-registry": {
    kind: "hierarchy",
    nodes: [
      "Stack registry",
      "Current stack",
      "Banned stack",
      "Migration rules",
    ],
  },
  "stacked-prs": {
    kind: "dependency-graph",
    nodes: [
      "Base branch",
      "PR 1 foundation",
      "PR 2 dependent",
      "PR 3 dependent",
    ],
  },
  "stay-within-limits": {
    kind: "state-machine",
    nodes: [
      "Fresh host snapshot",
      "Capacity known?",
      "Select safe profile",
      "Unknown: do not guess",
    ],
  },
  steelman: {
    kind: "decision-tree",
    nodes: [
      "Premise",
      "Strongest alternative",
      "Falsifying evidence",
      "Revised decision",
    ],
  },
  swarm: {
    kind: "architecture",
    nodes: [
      "Owner agent",
      "Independent worktrees",
      "Parallel lanes",
      "Merge + verification",
    ],
    relations: ["assigns", "isolates", "integrates"],
  },
  "tanstack-intent": {
    kind: "pipeline",
    nodes: [
      "TanStack mention or import",
      "Installed package catalog",
      "Task-matched use ids",
      "Version-matched guidance",
    ],
  },
  "tanstack-router": {
    kind: "state-machine",
    nodes: ["Navigate", "Validate search", "Load query", "Render / error"],
  },
  "tanstack-table": {
    fields: [
      ["id", "accessor / cell"],
      ["sorting", "pagination"],
      ["rows", "derived models"],
      ["row + column", "value"],
    ],
    kind: "entity-relationship",
    nodes: ["Column definitions", "Table state", "Row model", "Rendered cells"],
    relations: ["configures", "derives", "renders"],
  },
  tdd: {
    kind: "state-machine",
    nodes: ["RED", "GREEN", "REFACTOR", "Next behavior / done"],
  },
  teach: {
    kind: "hierarchy",
    nodes: ["Mission", "Concepts", "Guided practice", "Independent mastery"],
  },
  "test-audit": {
    kind: "pipeline",
    nodes: [
      "Test + owner",
      "Junk patterns",
      "Candidate evidence",
      "Keeper proof",
    ],
  },
  "thermo-nuclear-code-quality-review": {
    kind: "evidence-funnel",
    nodes: [
      "Release diff",
      "No-skip audit surfaces",
      "Reproduced defects",
      "Blocking verdict",
    ],
  },
  "to-questionnaire": {
    kind: "mind-map",
    nodes: [
      "Decision to unblock",
      "Context",
      "Product questions",
      "Engineering questions",
    ],
  },
  "to-spec": {
    kind: "hierarchy",
    nodes: ["Problem", "Solution", "User stories", "Decisions + tests"],
  },
  "to-tickets": {
    kind: "dependency-graph",
    nodes: [
      "Parent outcome",
      "Tracer ticket",
      "Dependent ticket",
      "Acceptance evidence",
    ],
  },
  triage: {
    kind: "state-machine",
    nodes: [
      "Needs triage",
      "Needs info",
      "Ready for agent",
      "Ready for human / closed",
    ],
  },
  "upgrade-dependency": {
    kind: "transformation-map",
    nodes: [
      "Current version",
      "Migration hops",
      "Adapted call sites",
      "Verified target version",
    ],
  },
  "ux-copy": {
    kind: "transformation-map",
    nodes: [
      "Ambiguous copy",
      "User intent",
      "Clear sentence-case copy",
      "Accessible outcome",
    ],
  },
  "ux-performance": {
    kind: "feedback-loop",
    nodes: [
      "User journey baseline",
      "Critical-path waterfall",
      "Narrow intervention",
      "Paired verification",
    ],
  },
  "video-research": {
    kind: "pipeline",
    nodes: [
      "Video input",
      "Transcript + OCR",
      "Timestamped evidence",
      "Research artifact",
    ],
  },
  "visual-plan": {
    kind: "architecture",
    nodes: [
      "Plan / spec",
      "File map",
      "Diagrams + annotations",
      "Interactive plan",
    ],
    relations: ["grounds", "explains", "publishes"],
  },
  "visual-recap": {
    kind: "architecture",
    nodes: [
      "Code diff",
      "Behavior evidence",
      "Before / after visuals",
      "Interactive recap",
    ],
    relations: ["traces", "shows", "publishes"],
  },
  "visual-review": {
    kind: "user-flow",
    nodes: [
      "Open customer surface",
      "Exercise key states",
      "Inspect visuals + a11y",
      "Report defects",
    ],
  },
  "wait-what": {
    actors: ["Speaker", "Shared context", "Listener"],
    kind: "sequence",
    nodes: [
      "Message did not land",
      "Request simpler re-pitch",
      "Use domain language",
      "Confirm understanding",
    ],
  },
  wayfinder: {
    kind: "mind-map",
    nodes: [
      "Destination",
      "Decisions so far",
      "Fog of war",
      "Tickets + questions",
    ],
  },
  webmcp: {
    kind: "user-flow",
    nodes: [
      "Open exact URL",
      "Read page tools + state",
      "Call requested tool",
      "Read back result",
    ],
  },
  "what-did-i-get-done": {
    kind: "timeline",
    nodes: [
      "Authored commits",
      "Group by outcome",
      "Evidence + impact",
      "Status update",
    ],
  },
  wizard: {
    kind: "user-flow",
    nodes: [
      "Run wizard",
      "Answer prompts",
      "Preview actions",
      "Apply manual setup",
    ],
  },
  work: {
    kind: "lifecycle",
    nodes: [
      "Outcome contract",
      "Inspect + act",
      "Verify",
      "Requested endpoint",
    ],
  },
  "work-automation-kit": {
    kind: "architecture",
    nodes: [
      "Planning skills",
      "Ticket workflows",
      "Tracker adapters",
      "Project context",
    ],
    relations: ["produce", "sync through", "share"],
  },
  "writing-beats": {
    kind: "feedback-loop",
    nodes: ["Draft beat", "User reaction", "Pivot or deepen", "Next beat"],
  },
  "writing-for-agents": {
    kind: "hierarchy",
    nodes: [
      "Mission",
      "Context pointers",
      "Ordered steps",
      "Completion criteria",
    ],
  },
  "writing-fragments": {
    kind: "mind-map",
    nodes: ["Conversation", "Strong fragments", "Themes", "Reusable material"],
  },
  "writing-shape": {
    kind: "transformation-map",
    nodes: [
      "Raw Markdown",
      "Narrative shape",
      "Coherent draft",
      "User-approved direction",
    ],
  },
};
const DIAGRAM_LABELS: Record<DiagramKind, string> = {
  architecture: "COMPONENT ARCHITECTURE",
  "concern-matrix": "CONCERN MATRIX",
  "decision-tree": "DECISION TREE",
  "dependency-graph": "DEPENDENCY GRAPH",
  "entity-relationship": "ENTITY RELATIONSHIPS",
  "evidence-funnel": "EVIDENCE FUNNEL",
  "feedback-loop": "FEEDBACK LOOP",
  hierarchy: "HIERARCHY",
  "layered-architecture": "LAYERED ARCHITECTURE",
  lifecycle: "LIFECYCLE",
  "mind-map": "CONCEPT MAP",
  pipeline: "DATA PIPELINE",
  progression: "PROGRESSION",
  sequence: "SEQUENCE",
  "state-machine": "STATE MACHINE",
  swimlane: "SWIMLANE",
  "system-context": "SYSTEM CONTEXT",
  timeline: "TIMELINE",
  "transformation-map": "TRANSFORMATION",
  "user-flow": "USER FLOW",
};

const readFrontmatterField = (frontmatter: string, field: string): string => {
  const raw = frontmatter
    .match(new RegExp(`^${field}:[\\t ]*(.+)$`, "m"))?.[1]
    ?.trim();
  if (!raw) {
    throw new Error(`Skill frontmatter requires ${field}.`);
  }
  if (raw.startsWith('"')) {
    const parsed: unknown = JSON.parse(raw);
    if (typeof parsed === "string") {
      return parsed;
    }
  }
  return raw.replace(/^'(.*)'$/, "$1").replaceAll("''", "'");
};

const loadSkills = async (): Promise<Skill[]> => {
  const directories = await readdir(REPOSITORY_ROOT, { withFileTypes: true });
  const skills = await Promise.all(
    directories
      .filter((entry) => entry.isDirectory())
      .map(async (entry): Promise<Skill | undefined> => {
        const sourcePath = join(REPOSITORY_ROOT, entry.name, "SKILL.md");
        const file = Bun.file(sourcePath);
        if (!(await file.exists())) {
          return undefined;
        }
        const source = await readFile(sourcePath, "utf8");
        const frontmatter = source.match(FRONTMATTER)?.[1];
        if (!frontmatter) {
          throw new Error(`${sourcePath} requires YAML frontmatter.`);
        }
        return {
          description: readFrontmatterField(frontmatter, "description"),
          name: readFrontmatterField(frontmatter, "name"),
        };
      }),
  );

  const current = skills.filter((skill): skill is Skill => skill !== undefined);
  const currentNames = new Set(current.map((skill) => skill.name));
  const archived = await Promise.all(
    Object.entries(ARCHIVED_SKILL_SOURCES)
      .filter(([name]) => !currentNames.has(name))
      .map(async ([name, path]): Promise<Skill> => {
        const source = await readFile(join(REPOSITORY_ROOT, path), "utf8");
        const frontmatter = source.match(FRONTMATTER)?.[1];
        if (!frontmatter) throw new Error(`${path} requires YAML frontmatter.`);
        return {
          name,
          description: readFrontmatterField(frontmatter, "description"),
        };
      }),
  );
  return [...current, ...archived].sort((left, right) =>
    left.name.localeCompare(right.name),
  );
};

// Native output is the authority. No mutable canvas, browser, or account is
// needed to author scenes or render SVGs.
const wrapText = (value: string, lineLength: number): string => {
  const lines: string[] = [];
  for (const word of value.split(/\s+/)) {
    const current = lines.at(-1);
    if (!current || current.length + word.length + 1 > lineLength) {
      lines.push(word);
    } else {
      lines[lines.length - 1] = `${current} ${word}`;
    }
  }
  return lines.join("\n");
};

type Point = [number, number];
interface NativeElement {
  id: string;
  type: string;
  x: number;
  y: number;
  width: number;
  height: number;
  angle: number;
  strokeColor: string;
  backgroundColor: string;
  fillStyle: string;
  strokeWidth: number;
  strokeStyle: string;
  roughness: number;
  opacity: number;
  groupIds: string[];
  frameId: null;
  roundness: { type: number } | null;
  seed: number;
  version: number;
  versionNonce: number;
  isDeleted: boolean;
  boundElements: Array<{ id: string; type: string }>;
  updated: number;
  link: null;
  locked: boolean;
  text?: string;
  originalText?: string;
  fontFamily?: number;
  fontSize?: number;
  textAlign?: string;
  verticalAlign?: string;
  containerId?: string | null;
  lineHeight?: number;
  autoResize?: boolean;
  points?: Point[];
  startBinding?: { elementId: string; focus: number; gap: number } | null;
  endBinding?: { elementId: string; focus: number; gap: number } | null;
  startArrowhead?: null;
  endArrowhead?: "arrow" | null;
}

type SceneElement = NativeElement;
const CANVAS_WIDTH = 1480;
const FOREGROUND = "#e9ecef";
const SECONDARY = "#adb5bd";

const elementBase = (id: string, type: string): NativeElement => ({
  id,
  type,
  x: 0,
  y: 0,
  width: 0,
  height: 0,
  angle: 0,
  strokeColor: FOREGROUND,
  backgroundColor: "transparent",
  fillStyle: "solid",
  strokeWidth: 2,
  strokeStyle: "solid",
  roughness: 1,
  opacity: 100,
  groupIds: [],
  frameId: null,
  roundness: null,
  // Stable seeds avoid noisy regeneration diffs and preserve the hand-drawn look.
  seed:
    Array.from(id).reduce(
      (hash, character) => (hash * 31 + (character.codePointAt(0) ?? 0)) >>> 0,
      1,
    ) % 2147483647,
  version: 1,
  versionNonce: 1,
  isDeleted: false,
  boundElements: [],
  updated: Date.parse(CREATED_AT),
  link: null,
  locked: false,
});

const textElement = (
  id: string,
  text: string,
  x: number,
  y: number,
  fontSize = 20,
  strokeColor = FOREGROUND,
): SceneElement => ({
  ...elementBase(id, "text"),
  strokeColor,
  x,
  y,
  // Conservative bounds, verified in both the headless and official renderers.
  width: Math.ceil(
    Math.max(...text.split("\n").map((line) => line.length)) * fontSize * 0.65,
  ),
  height: text.split("\n").length * fontSize * 1.25,
  text,
  originalText: text,
  fontSize,
  fontFamily: 5,
  lineHeight: 1.25,
  textAlign: "left",
  verticalAlign: "top",
  containerId: null,
  autoResize: true,
});

const paletteAt = (offset: number, index: number): Palette =>
  PALETTES[(offset + index) % PALETTES.length] ?? DEFAULT_PALETTE;

const shapeElement = (
  id: string,
  type: "diamond" | "ellipse" | "rectangle",
  label: string,
  x: number,
  y: number,
  width: number,
  height: number,
  palette: Palette,
): SceneElement[] => {
  const shape: SceneElement = {
    ...elementBase(id, type),
    x,
    y,
    width,
    height,
    backgroundColor: palette.fill,
    strokeColor: palette.stroke,
    roundness: type === "rectangle" ? { type: 3 } : null,
  };
  if (!label) return [shape];
  const columns =
    type === "diamond"
      ? 15
      : Math.floor((width * (type === "ellipse" ? 0.78 : 1) - 40) / 13);
  const text = wrapText(label, columns);
  const caption = textElement(`${id}-label`, text, 0, 0);
  caption.x = x + (width - caption.width) / 2;
  caption.y = y + (height - caption.height) / 2;
  caption.textAlign = "center";
  caption.verticalAlign = "middle";
  caption.containerId = id;
  shape.boundElements.push({ id: caption.id, type: "text" });
  return [shape, caption];
};

const zone = (
  id: string,
  x: number,
  y: number,
  width: number,
  height: number,
): SceneElement => ({
  ...elementBase(id, "rectangle"),
  x,
  y,
  width,
  height,
  strokeColor: "#495057",
  strokeStyle: "dashed",
  roundness: { type: 3 },
});

const arrowElement = (
  id: string,
  start: Point,
  end: Point,
  options: {
    via?: Point[];
    dashed?: boolean;
    endArrowhead?: "arrow" | null;
    type?: "arrow" | "line";
  } = {},
): SceneElement => {
  const points: Point[] = [start, ...(options.via ?? []), end].map(([x, y]) => [
    x - start[0],
    y - start[1],
  ]);
  return {
    ...elementBase(id, options.type ?? "arrow"),
    x: start[0],
    y: start[1],
    points,
    width:
      Math.max(...points.map(([x]) => x)) - Math.min(...points.map(([x]) => x)),
    height:
      Math.max(...points.map(([, y]) => y)) -
      Math.min(...points.map(([, y]) => y)),
    roundness: { type: 2 },
    strokeStyle: options.dashed ? "dashed" : "solid",
    startBinding: null,
    endBinding: null,
    startArrowhead: null,
    endArrowhead:
      options.endArrowhead === undefined ? "arrow" : options.endArrowhead,
  };
};

const center = (element: SceneElement): Point => [
  element.x + element.width / 2,
  element.y + element.height / 2,
];
const requireShape = (elements: SceneElement[], id: string): SceneElement => {
  const element = elements.find((candidate) => candidate.id === id);
  if (!element) throw new Error(`Missing diagram node ${id}.`);
  return element;
};

// Intersect the actual rectangle/ellipse/diamond contour, not its bounding box.
const borderPoint = (element: SceneElement, toward: Point): Point => {
  const [cx, cy] = center(element);
  const dx = toward[0] - cx;
  const dy = toward[1] - cy;
  const rx = element.width / 2;
  const ry = element.height / 2;
  const normalized =
    element.type === "ellipse"
      ? Math.hypot(dx / rx, dy / ry)
      : element.type === "diamond"
        ? Math.abs(dx / rx) + Math.abs(dy / ry)
        : Math.max(Math.abs(dx / rx), Math.abs(dy / ry));
  if (!normalized) throw new Error(`Coincident connector at ${element.id}.`);
  const distance = Math.hypot(dx, dy);
  return [
    cx + dx / normalized + (dx / distance) * 4,
    cy + dy / normalized + (dy / distance) * 4,
  ];
};

const connect = (
  elements: SceneElement[],
  id: string,
  from: string,
  to: string,
  options: {
    via?: Point[];
    dashed?: boolean;
    endArrowhead?: "arrow" | null;
  } = {},
): SceneElement => {
  const source = requireShape(elements, from);
  const target = requireShape(elements, to);
  const arrow = arrowElement(
    id,
    borderPoint(source, options.via?.[0] ?? center(target)),
    borderPoint(target, options.via?.at(-1) ?? center(source)),
    options,
  );
  arrow.startBinding = { elementId: from, focus: 0, gap: 4 };
  arrow.endBinding = { elementId: to, focus: 0, gap: 4 };
  source.boundElements.push({ id, type: "arrow" });
  target.boundElements.push({ id, type: "arrow" });
  return arrow;
};

type LayoutRenderer = (
  stages: string[],
  paletteOffset: number,
) => SceneElement[];
type DiagramRenderer = (
  spec: DiagramSpec,
  paletteOffset: number,
) => SceneElement[];

const renderLinear: LayoutRenderer = (stages, offset) => {
  const nodes = stages.flatMap((stage, i) =>
    shapeElement(
      `linear-stage-${i + 1}`,
      "rectangle",
      stage,
      60 + i * 350,
      340,
      280,
      120,
      paletteAt(offset, i),
    ),
  );
  return [
    ...nodes,
    ...stages
      .slice(1)
      .map((_, i) =>
        connect(
          nodes,
          `linear-arrow-${i + 1}`,
          `linear-stage-${i + 1}`,
          `linear-stage-${i + 2}`,
        ),
      ),
  ];
};

const renderTimeline: LayoutRenderer = (stages, offset) => {
  const nodes = stages.flatMap((stage, i) => [
    ...shapeElement(
      `timeline-node-${i + 1}`,
      "ellipse",
      String(i + 1).padStart(2, "0"),
      90 + i * 350,
      360,
      120,
      60,
      paletteAt(offset, i),
    ),
    textElement(
      `timeline-label-${i + 1}`,
      wrapText(stage, 23),
      70 + i * 350,
      i % 2 === 0 ? 280 : 470,
      20,
    ),
  ]);
  return [
    ...nodes,
    ...stages
      .slice(1)
      .map((_, i) =>
        connect(
          nodes,
          `timeline-line-${i + 1}`,
          `timeline-node-${i + 1}`,
          `timeline-node-${i + 2}`,
        ),
      ),
  ];
};

const renderCycle: LayoutRenderer = (stages, offset) => {
  const positions: Point[] =
    stages.length === 3
      ? [
          [590, 250],
          [1020, 510],
          [160, 510],
        ]
      : [
          [590, 250],
          [1040, 460],
          [590, 670],
          [140, 460],
        ];
  const nodes = stages.flatMap((stage, i) => {
    const [x, y] = positions[i] ?? [590, 250];
    return shapeElement(
      `cycle-stage-${i + 1}`,
      "ellipse",
      stage,
      x,
      y,
      280,
      120,
      paletteAt(offset, i),
    );
  });
  return [
    ...nodes,
    ...stages.map((_, i) =>
      connect(
        nodes,
        `cycle-arrow-${i + 1}`,
        `cycle-stage-${i + 1}`,
        `cycle-stage-${((i + 1) % stages.length) + 1}`,
      ),
    ),
  ];
};

const renderFunnel: LayoutRenderer = (stages, offset) => {
  const nodes = stages.flatMap((stage, i) => {
    const width = 1000 - i * 180;
    return shapeElement(
      `funnel-stage-${i + 1}`,
      "rectangle",
      stage,
      (CANVAS_WIDTH - width) / 2,
      240 + i * 140,
      width,
      80,
      paletteAt(offset, i),
    );
  });
  return [
    ...nodes,
    ...stages
      .slice(1)
      .map((_, i) =>
        connect(
          nodes,
          `funnel-arrow-${i + 1}`,
          `funnel-stage-${i + 1}`,
          `funnel-stage-${i + 2}`,
        ),
      ),
  ];
};

const renderLayers: LayoutRenderer = (stages, offset) =>
  stages.flatMap((stage, i) =>
    shapeElement(
      `layer-${i + 1}`,
      "rectangle",
      stage,
      140 + i * 50,
      240 + i * 140,
      1200 - i * 100,
      80,
      paletteAt(offset, i),
    ),
  );

const renderBranch: LayoutRenderer = (stages, offset) => {
  const nodes = [
    ...shapeElement(
      "branch-input",
      "rectangle",
      stages[0] ?? "Input",
      80,
      390,
      280,
      120,
      paletteAt(offset, 0),
    ),
    ...shapeElement(
      "branch-decision",
      "diamond",
      stages[1] ?? "Decision",
      490,
      340,
      360,
      220,
      paletteAt(offset, 1),
    ),
    ...stages
      .slice(2)
      .flatMap((stage, i) =>
        shapeElement(
          `branch-outcome-${i + 1}`,
          "rectangle",
          stage,
          1080,
          stages.length === 3 ? 390 : 270 + i * 280,
          300,
          120,
          paletteAt(offset, i + 2),
        ),
      ),
  ];
  return [
    ...nodes,
    connect(nodes, "branch-arrow-input", "branch-input", "branch-decision"),
    ...stages
      .slice(2)
      .map((_, i) =>
        connect(
          nodes,
          `branch-arrow-${i + 1}`,
          "branch-decision",
          `branch-outcome-${i + 1}`,
        ),
      ),
  ];
};

const renderMatrix: LayoutRenderer = (stages, offset) =>
  stages.flatMap((stage, i) =>
    shapeElement(
      `matrix-cell-${i + 1}`,
      "rectangle",
      stage,
      180 + (i % 2) * 640,
      260 + Math.floor(i / 2) * 220,
      480,
      140,
      paletteAt(offset, i),
    ),
  );

const renderBeforeAfter: LayoutRenderer = (stages, offset) => {
  const split = Math.ceil(stages.length / 2);
  const nodes = [
    zone("before-zone", 60, 240, 560, 420),
    zone("after-zone", 860, 240, 560, 420),
    textElement("before-label", "BEFORE", 110, 265, 20, SECONDARY),
    textElement("after-label", "AFTER", 910, 265, 20, SECONDARY),
    ...stages.flatMap((stage, i) =>
      shapeElement(
        `${i < split ? "before" : "after"}-stage-${(i % split) + 1}`,
        "rectangle",
        stage,
        i < split ? 110 : 910,
        340 + (i % split) * 150,
        460,
        100,
        paletteAt(offset, i),
      ),
    ),
  ];
  return [
    ...nodes,
    connect(nodes, "transformation-arrow", "before-zone", "after-zone"),
  ];
};

const renderStaircase: LayoutRenderer = (stages, offset) => {
  const nodes = stages.flatMap((stage, i) =>
    shapeElement(
      `stair-${i + 1}`,
      "rectangle",
      stage,
      60 + i * 350,
      600 - i * 100,
      280,
      110,
      paletteAt(offset, i),
    ),
  );
  return [
    ...nodes,
    ...stages
      .slice(1)
      .map((_, i) =>
        connect(
          nodes,
          `stair-arrow-${i + 1}`,
          `stair-${i + 1}`,
          `stair-${i + 2}`,
        ),
      ),
  ];
};

const renderArchitecture: DiagramRenderer = (spec, offset) => {
  const nodeWidth = Math.min(
    380,
    Math.max(320, ...spec.nodes.map((node) => node.length * 12)),
  );
  const nodes = [
    zone("architecture-boundary", 80, 240, 1320, 540),
    ...spec.nodes.flatMap((node, i) =>
      shapeElement(
        `component-${i + 1}`,
        "rectangle",
        node,
        140 + (i % 2) * 820,
        300 + Math.floor(i / 2) * 300,
        nodeWidth,
        120,
        paletteAt(offset, i),
      ),
    ),
  ];
  const links = [
    [1, 2],
    [1, 3],
    [2, 4],
    [3, 4],
  ];
  return [
    ...nodes,
    ...links.map(([from, to], i) =>
      connect(
        nodes,
        `component-link-${i + 1}`,
        `component-${from}`,
        `component-${to}`,
      ),
    ),
    ...(spec.relations ?? []).map((relation, i) =>
      textElement(
        `component-relation-${i + 1}`,
        wrapText(relation, 18),
        [600, 350, 1170][i] ?? 600,
        [325, 475, 475][i] ?? 325,
        18,
        SECONDARY,
      ),
    ),
  ];
};

const renderHierarchy: DiagramRenderer = (spec, offset) => {
  const nodes = [
    ...shapeElement(
      "hierarchy-root",
      "rectangle",
      spec.nodes[0] ?? "Root",
      580,
      250,
      320,
      110,
      paletteAt(offset, 0),
    ),
    ...spec.nodes
      .slice(1)
      .flatMap((node, i) =>
        shapeElement(
          `hierarchy-child-${i + 1}`,
          "rectangle",
          node,
          80 + i * 500,
          550,
          320,
          120,
          paletteAt(offset, i + 1),
        ),
      ),
  ];
  return [
    ...nodes,
    ...spec.nodes
      .slice(1)
      .map((_, i) =>
        connect(
          nodes,
          `hierarchy-branch-${i + 1}`,
          "hierarchy-root",
          `hierarchy-child-${i + 1}`,
          { endArrowhead: null },
        ),
      ),
  ];
};

const renderUserFlow: DiagramRenderer = (spec, offset) => {
  const ids = ["entry", "action", "decision", "outcome"];
  const nodes = spec.nodes.flatMap((node, i) =>
    shapeElement(
      `user-flow-${ids[i]}`,
      i === 2 ? "diamond" : i === 1 ? "rectangle" : "ellipse",
      node,
      60 + i * 350,
      i === 2 ? 310 : 350,
      280,
      i === 2 ? 200 : 120,
      paletteAt(offset, i),
    ),
  );
  return [
    ...nodes,
    ...spec.nodes
      .slice(1)
      .map((_, i) =>
        connect(
          nodes,
          `user-flow-arrow-${i + 1}`,
          `user-flow-${ids[i]}`,
          `user-flow-${ids[i + 1]}`,
        ),
      ),
  ];
};

const renderSequence: DiagramRenderer = (spec, offset) => {
  const actorX = [100, 600, 1100];
  const nodes = actorX.flatMap((x, i) => [
    ...shapeElement(
      `sequence-actor-${i + 1}`,
      "rectangle",
      spec.actors?.[i] ?? ["Caller", "System", "Evidence"][i] ?? "Actor",
      x,
      250,
      280,
      80,
      paletteAt(offset, i),
    ),
    // Thin native activation bars support real endpoint bindings at each message.
    {
      ...zone(`sequence-lifeline-${i + 1}`, x + 134, 354, 12, 430),
      strokeStyle: "solid",
    },
  ]);
  const pairs: Array<[number, number]> = [
    [0, 1],
    [1, 2],
    [2, 1],
    [1, 0],
  ];
  const messages = spec.nodes.flatMap((message, i) => {
    const [from, to] = pairs[i] ?? [0, 1];
    const y = 430 + i * 105;
    const startX = (actorX[from] ?? 100) + 140;
    const endX = (actorX[to] ?? 600) + 140;
    const direction = Math.sign(endX - startX);
    const arrow = arrowElement(
      `sequence-message-${i + 1}`,
      [startX + direction * 10, y],
      [endX - direction * 10, y],
      { dashed: i >= 2 },
    );
    const source = requireShape(nodes, `sequence-lifeline-${from + 1}`);
    const target = requireShape(nodes, `sequence-lifeline-${to + 1}`);
    for (const [side, node] of [
      ["startBinding", source],
      ["endBinding", target],
    ] as const) {
      arrow[side] = {
        elementId: node.id,
        focus: (y - (node.y + node.height / 2)) / (node.height / 2),
        gap: 4,
      };
      node.boundElements.push({ id: arrow.id, type: "arrow" });
    }
    const label = textElement(
      `sequence-message-label-${i + 1}`,
      wrapText(message, 32),
      Math.min(startX, endX) + 40,
      0,
      18,
    );
    label.y = y - label.height - 12;
    return [arrow, label];
  });
  return [...nodes, ...messages];
};

const renderEntityRelationship: DiagramRenderer = (spec, offset) => {
  const nodes = spec.nodes.flatMap((node, i) => {
    const x = 140 + (i % 2) * 820;
    const y = 250 + Math.floor(i / 2) * 350;
    const title = textElement(
      `entity-title-${i + 1}`,
      wrapText(node, 25),
      x + 25,
      y + 20,
      22,
    );
    const fields = textElement(
      `entity-fields-${i + 1}`,
      (spec.fields?.[i] ?? ["key", "relationship"]).join("\n"),
      x + 25,
      y + 100,
      18,
      SECONDARY,
    );
    return [
      ...shapeElement(
        `entity-${i + 1}`,
        "rectangle",
        "",
        x,
        y,
        380,
        210,
        paletteAt(offset, i),
      ),
      title,
      arrowElement(
        `entity-divider-${i + 1}`,
        [x + 20, y + 80],
        [x + 360, y + 80],
        { type: "line", endArrowhead: null },
      ),
      fields,
    ];
  });
  const links = [
    [1, 2],
    [1, 3],
    [2, 4],
  ];
  return [
    ...nodes,
    ...links.map(([from, to], i) =>
      connect(nodes, `entity-link-${i + 1}`, `entity-${from}`, `entity-${to}`, {
        endArrowhead: null,
      }),
    ),
    ...(spec.relations ?? []).map((relation, i) =>
      textElement(
        `entity-relation-${i + 1}`,
        wrapText(relation, 22),
        [600, 355, 1175][i] ?? 600,
        [325, 490, 490][i] ?? 325,
        18,
        SECONDARY,
      ),
    ),
  ];
};

const renderStateMachine: DiagramRenderer = (spec, offset) => {
  const nodes = [
    ...shapeElement("state-initial", "ellipse", "", 25, 438, 30, 30, {
      fill: FOREGROUND,
      stroke: FOREGROUND,
    }),
    ...spec.nodes.flatMap((node, i) =>
      shapeElement(
        `state-${i + 1}`,
        i === spec.nodes.length - 1 ? "ellipse" : "rectangle",
        node,
        120 + i * 340,
        400,
        260,
        110,
        paletteAt(offset, i),
      ),
    ),
  ];
  return [
    ...nodes,
    connect(nodes, "state-transition-start", "state-initial", "state-1"),
    ...spec.nodes
      .slice(1)
      .map((_, i) =>
        connect(
          nodes,
          `state-transition-${i + 1}`,
          `state-${i + 1}`,
          `state-${i + 2}`,
        ),
      ),
    connect(nodes, "state-retry", "state-3", "state-2", {
      dashed: true,
      via: [
        [930, 290],
        [590, 290],
      ],
    }),
    textElement("state-retry-label", "retry / revise", 660, 250, 18, SECONDARY),
  ];
};

const renderDependencyGraph: DiagramRenderer = (spec, offset) => {
  const positions: Point[] = [
    [140, 250],
    [1040, 250],
    [590, 500],
    [590, 700],
  ];
  const nodes = spec.nodes.flatMap((node, i) => {
    const [x, y] = positions[i] ?? [590, 500];
    return shapeElement(
      `dependency-node-${i + 1}`,
      "rectangle",
      node,
      x,
      y,
      300,
      120,
      paletteAt(offset, i),
    );
  });
  return [
    ...nodes,
    connect(
      nodes,
      "dependency-edge-1",
      "dependency-node-1",
      "dependency-node-3",
    ),
    connect(
      nodes,
      "dependency-edge-2",
      "dependency-node-2",
      "dependency-node-3",
    ),
    connect(
      nodes,
      "dependency-edge-3",
      "dependency-node-3",
      "dependency-node-4",
    ),
  ];
};

const renderSwimlane: DiagramRenderer = (spec, offset) => {
  const nodes = [0, 1, 2].flatMap((i) => [
    zone(`swimlane-${i + 1}`, 60, 240 + i * 260, 1360, 220),
    textElement(
      `swimlane-label-${i + 1}`,
      spec.actors?.[i] ?? ["Actor", "System", "Evidence"][i] ?? "Actor",
      110,
      260 + i * 260,
      18,
      SECONDARY,
    ),
  ]);
  const positions: Point[] = [
    [180, 320],
    [540, 580],
    [900, 580],
    [1080, 840],
  ];
  nodes.push(
    ...spec.nodes.flatMap((node, i) => {
      const [x, y] = positions[i] ?? [540, 580];
      return shapeElement(
        `swimlane-task-${i + 1}`,
        "rectangle",
        node,
        x,
        y,
        280,
        90,
        paletteAt(offset, i),
      );
    }),
  );
  return [
    ...nodes,
    ...spec.nodes
      .slice(1)
      .map((_, i) =>
        connect(
          nodes,
          `swimlane-flow-${i + 1}`,
          `swimlane-task-${i + 1}`,
          `swimlane-task-${i + 2}`,
        ),
      ),
  ];
};

const renderRadial = (
  spec: DiagramSpec,
  offset: number,
  prefix: "context" | "mind-map",
): SceneElement[] => {
  const root = prefix === "context" ? "context-system" : "mind-map-center";
  const child = prefix === "context" ? "context-external" : "mind-map-branch";
  const positions: Point[] = [
    [580, 240],
    [120, 510],
    [1040, 510],
  ];
  const nodes = [
    ...shapeElement(
      root,
      prefix === "context" ? "rectangle" : "ellipse",
      spec.nodes[0] ?? "System",
      580,
      500,
      320,
      140,
      paletteAt(offset, 0),
    ),
    ...spec.nodes.slice(1).flatMap((node, i) => {
      const [x, y] = positions[i] ?? [120, 510];
      return shapeElement(
        `${child}-${i + 1}`,
        "ellipse",
        node,
        x,
        y,
        320,
        120,
        paletteAt(offset, i + 1),
      );
    }),
  ];
  return [
    ...nodes,
    ...spec.nodes.slice(1).map((_, i) =>
      connect(nodes, `${prefix}-link-${i + 1}`, `${child}-${i + 1}`, root, {
        endArrowhead: null,
      }),
    ),
  ];
};

const DIAGRAM_RENDERERS: Record<DiagramKind, DiagramRenderer> = {
  architecture: renderArchitecture,
  "concern-matrix": (spec, offset) => renderMatrix(spec.nodes, offset),
  "decision-tree": (spec, offset) => renderBranch(spec.nodes, offset),
  "dependency-graph": renderDependencyGraph,
  "entity-relationship": renderEntityRelationship,
  "evidence-funnel": (spec, offset) => renderFunnel(spec.nodes, offset),
  "feedback-loop": (spec, offset) => renderCycle(spec.nodes, offset),
  hierarchy: renderHierarchy,
  "layered-architecture": (spec, offset) => renderLayers(spec.nodes, offset),
  lifecycle: (spec, offset) => renderCycle(spec.nodes, offset),
  "mind-map": (spec, offset) => renderRadial(spec, offset, "mind-map"),
  pipeline: (spec, offset) => renderLinear(spec.nodes, offset),
  progression: (spec, offset) => renderStaircase(spec.nodes, offset),
  sequence: renderSequence,
  "state-machine": renderStateMachine,
  swimlane: renderSwimlane,
  "system-context": (spec, offset) => renderRadial(spec, offset, "context"),
  timeline: (spec, offset) => renderTimeline(spec.nodes, offset),
  "transformation-map": (spec, offset) => renderBeforeAfter(spec.nodes, offset),
  "user-flow": renderUserFlow,
};

const createScene = (skill: Skill): Record<string, unknown> => {
  const spec = SKILL_DIAGRAMS[skill.name];
  if (!spec) throw new Error(`Choose a semantic diagram for /${skill.name}.`);
  const body = DIAGRAM_RENDERERS[spec.kind](spec, 0);
  const bottom = Math.max(...body.map((element) => element.y + element.height));
  const footerY = Math.max(700, bottom + 60);
  const canvas = {
    ...zone("canvas", 0, 0, CANVAS_WIDTH, footerY + 120),
    backgroundColor: "#121212",
    strokeColor: "#121212",
    strokeStyle: "solid",
    roughness: 0,
    roundness: null,
    locked: true,
  };
  return {
    appState: { gridSize: null, viewBackgroundColor: "#121212" },
    elements: [
      canvas,
      textElement("title", `/${skill.name}`, 60, 40, 30),
      textElement(
        "map-label",
        DIAGRAM_LABELS[spec.kind],
        60,
        95,
        18,
        SECONDARY,
      ),
      textElement(
        "description",
        wrapText(skill.description, 112),
        60,
        140,
        18,
        SECONDARY,
      ),
      ...body,
      textElement(
        "footer",
        "canonical guidance / focused action / observable proof",
        60,
        footerY,
        20,
      ),
      textElement(
        "source-note",
        "Editable Excalidraw source included with this page",
        60,
        footerY + 45,
        16,
        SECONDARY,
      ),
    ],
    files: {},
    diagramDescription: `${DIAGRAM_LABELS[spec.kind].toLowerCase()} covering ${spec.nodes.join("; ")}.`,
    diagramKind: spec.kind,
    source: "frontend-skills/docs-site/generate-skill-diagrams.ts",
    type: "excalidraw",
    version: 2,
  };
};

const escapeXml = (text: string): string =>
  text.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
const addSvgTitle = async (
  path: string,
  skillName: string,
  spec: DiagramSpec,
): Promise<void> => {
  const svg = await readFile(path, "utf8");
  const title = `${spec.kind.replaceAll("-", " ")} diagram for the /${skillName} skill`;
  const description = `${DIAGRAM_LABELS[spec.kind].toLowerCase()} covering ${spec.nodes.join("; ")}.`;
  await writeFile(
    path,
    svg.replace(
      /^(<svg[^>]*>)/,
      `$1<title>${escapeXml(title)}</title><desc>${escapeXml(description)}</desc>`,
    ),
  );
};

const skills = await loadSkills();
const skillNames = new Set(skills.map((skill) => skill.name));
const unmappedSkills = skills.filter((skill) => !SKILL_DIAGRAMS[skill.name]);
const staleDiagrams = Object.keys(SKILL_DIAGRAMS).filter(
  (name) => !skillNames.has(name),
);
if (unmappedSkills.length || staleDiagrams.length) {
  throw new Error(
    `Semantic diagram map drifted. Missing: ${unmappedSkills.map((skill) => skill.name).join(", ") || "none"}. Stale: ${staleDiagrams.join(", ") || "none"}.`,
  );
}
await mkdir(OUTPUT_DIRECTORY, { recursive: true });
for (const skill of skills) {
  await writeFile(
    join(OUTPUT_DIRECTORY, `${skill.name}.excalidraw`),
    `${JSON.stringify(createScene(skill), null, 2)}\n`,
  );
}
const renderSkill = async (skill: Skill): Promise<void> => {
  const base = join(OUTPUT_DIRECTORY, skill.name);
  const temporary = `${base}.pending.svg`;
  const process = Bun.spawn(
    [
      ...CLI,
      "render",
      `${base}.excalidraw`,
      "--format",
      "svg",
      "--padding",
      "0",
      "--out",
      temporary,
    ],
    { cwd: REPOSITORY_ROOT, stdout: "pipe", stderr: "pipe" },
  );
  const [status, stdout, stderr] = await Promise.all([
    process.exited,
    new Response(process.stdout).text(),
    new Response(process.stderr).text(),
  ]);
  if (status !== 0)
    throw new Error(
      `SVG export failed for /${skill.name}: ${stdout}\n${stderr}`,
    );
  const spec = SKILL_DIAGRAMS[skill.name];
  if (!spec) throw new Error(`Missing diagram spec for /${skill.name}.`);
  await addSvgTitle(temporary, skill.name, spec);
  // Atomic sibling replacement preserves a valid SVG if its export fails.
  await rename(temporary, `${base}.svg`);
  console.log(`Rendered /${skill.name}`);
};
if (Bun.argv.includes("--render")) {
  // Independent native files need no shared canvas. Bound local renderer work;
  // settle each batch before reporting failure so nothing outlives the command.
  for (let start = 0; start < skills.length; start += 4) {
    const results = await Promise.allSettled(
      skills.slice(start, start + 4).map(renderSkill),
    );
    const failures = results.filter((result) => result.status === "rejected");
    if (failures.length)
      throw new AggregateError(
        failures.map((result) => result.reason),
        "Skill diagram export failed; previous valid SVGs preserved.",
      );
  }
}

console.log(
  `Wrote ${skills.length} native scenes${Bun.argv.includes("--render") ? " and SVGs" : "; pass --render to refresh SVGs"}.`,
);
