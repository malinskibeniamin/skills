import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
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

type SceneElement = Record<string, unknown>;

const REPOSITORY_ROOT = join(import.meta.dir, "..");
const OUTPUT_DIRECTORY = join(import.meta.dir, "public", "diagrams", "skills");
const FRONTMATTER = /^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/;
const CREATED_AT = "2026-08-05T00:00:00.000Z";
const CLI = ["bunx", "mcp-excalidraw-server@1.1.0"];
const DEFAULT_PALETTE: Palette = { fill: "#1c4f73", stroke: "#4dabf7" };
const PALETTES: Palette[] = [
  DEFAULT_PALETTE,
  { fill: "#0b4f1c", stroke: "#40c057" },
  { fill: "#402f00", stroke: "#f08c00" },
  { fill: "#2d1b69", stroke: "#9775fa" },
  { fill: "#134e4a", stroke: "#38d9a9" },
  { fill: "#6b3232", stroke: "#ff8787" },
];
const SKILL_DIAGRAMS: Record<string, DiagramSpec> = {
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
  "ask-ben": {
    kind: "hierarchy",
    nodes: [
      "Incoming request",
      "Build / fix",
      "Plan / research",
      "Review / ship",
    ],
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
    actors: ["Agent", "Canvas server", "Browser"],
    kind: "sequence",
    nodes: [
      "Describe visual",
      "Create elements",
      "Render + inspect",
      "Export source + SVG",
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
  "snyk-ux-security": {
    kind: "evidence-funnel",
    nodes: [
      "Dependency manifests",
      "Snyk findings",
      "Exploitability triage",
      "Upgrade + release gate",
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

  return skills
    .filter((skill): skill is Skill => skill !== undefined)
    .sort((left, right) => left.name.localeCompare(right.name));
};

const conciseLabel = (value: string): string => {
  const clause = value.split(/\s+--\s+|[.;]\s+/)[0] ?? value;
  return clause.split(/\s+/).slice(0, 7).join(" ");
};

const wrapText = (
  value: string,
  lineLength: number,
  maximumLines: number,
): string => {
  const words = value.split(/\s+/);
  const lines: string[] = [];
  for (const word of words) {
    const current = lines.at(-1);
    if (!current || current.length + word.length + 1 > lineLength) {
      lines.push(word);
    } else {
      lines[lines.length - 1] = `${current} ${word}`;
    }
  }
  if (lines.length > maximumLines) {
    const retained = lines.slice(0, maximumLines);
    retained[maximumLines - 1] = conciseLabel(retained[maximumLines - 1] ?? "");
    return retained.join("\n");
  }
  return lines.join("\n");
};

const elementBase = (id: string, type: string): SceneElement => ({
  createdAt: CREATED_AT,
  id,
  type,
  updatedAt: CREATED_AT,
  version: 1,
});

const textElement = (
  id: string,
  text: string,
  x: number,
  y: number,
  fontSize: number,
  strokeColor: string,
): SceneElement => {
  const lines = text.split("\n");
  return {
    ...elementBase(id, "text"),
    fontFamily: "excalifont",
    fontSize,
    height: Math.ceil(lines.length * fontSize * 1.35),
    strokeColor,
    text,
    width: Math.ceil(
      Math.max(...lines.map((line) => line.length)) * fontSize * 0.62,
    ),
    x,
    y,
  };
};

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
  options: { fontSize?: number; strokeStyle?: "dashed" | "solid" } = {},
): SceneElement => ({
  ...elementBase(id, type),
  backgroundColor: palette.fill,
  fillStyle: "solid",
  fontFamily: "excalifont",
  fontSize: options.fontSize ?? 20,
  height,
  label: { text: wrapText(label, 18, 3) },
  roughness: 1,
  roundness: type === "rectangle" ? { type: 3 } : undefined,
  strokeColor: palette.stroke,
  strokeStyle: options.strokeStyle ?? "solid",
  strokeWidth: 2,
  width,
  x,
  y,
});

const arrowElement = (
  id: string,
  start: [number, number],
  end: [number, number],
  options: {
    endArrowhead?: "arrow" | null;
    strokeStyle?: "dashed" | "solid";
    via?: Array<[number, number]>;
  } = {},
): SceneElement => {
  const points = [start, ...(options.via ?? []), end].map(
    ([x, y]): [number, number] => [x - start[0], y - start[1]],
  );
  const xCoordinates = points.map(([x]) => x);
  const yCoordinates = points.map(([, y]) => y);
  return {
    ...elementBase(id, "arrow"),
    endArrowhead:
      options.endArrowhead === undefined ? "arrow" : options.endArrowhead,
    height: Math.max(...yCoordinates) - Math.min(...yCoordinates),
    points,
    roughness: 1,
    roundness: { type: 2 },
    strokeColor: "#e9ecef",
    strokeStyle: options.strokeStyle ?? "solid",
    strokeWidth: 2,
    width: Math.max(...xCoordinates) - Math.min(...xCoordinates),
    x: start[0],
    y: start[1],
  };
};

type LayoutRenderer = (
  stages: string[],
  paletteOffset: number,
) => SceneElement[];

const renderLinear: LayoutRenderer = (stages, paletteOffset) => {
  const gap = 50;
  const width = (1080 - gap * (stages.length - 1)) / stages.length;
  const shapes = stages.map((stage, index) =>
    shapeElement(
      `linear-stage-${index + 1}`,
      "rectangle",
      stage,
      60 + index * (width + gap),
      245,
      width,
      185,
      paletteAt(paletteOffset, index),
    ),
  );
  const arrows = stages.slice(1).map((_stage, index) => {
    const x = 60 + (index + 1) * width + index * gap;
    return arrowElement(`linear-arrow-${index + 1}`, [x, 338], [x + gap, 338]);
  });
  return [...shapes, ...arrows];
};

const renderTimeline: LayoutRenderer = (stages, paletteOffset) => {
  const startX = 150;
  const step = 900 / (stages.length - 1);
  const line = arrowElement("timeline-line", [110, 345], [1090, 345]);
  const nodes = stages.flatMap((stage, index) => {
    const centerX = startX + index * step;
    const labelY = index % 2 === 0 ? 220 : 405;
    return [
      shapeElement(
        `timeline-node-${index + 1}`,
        "ellipse",
        String(index + 1).padStart(2, "0"),
        centerX - 42,
        303,
        84,
        84,
        paletteAt(paletteOffset, index),
        { fontSize: 18 },
      ),
      textElement(
        `timeline-label-${index + 1}`,
        wrapText(stage, 18, 3),
        centerX - 88,
        labelY,
        18,
        paletteAt(paletteOffset, index).stroke,
      ),
    ];
  });
  return [line, ...nodes];
};

const renderCycle: LayoutRenderer = (stages, paletteOffset) => {
  const positions =
    stages.length === 3
      ? [
          { x: 470, y: 180 },
          { x: 770, y: 385 },
          { x: 170, y: 385 },
        ]
      : [
          { x: 470, y: 175 },
          { x: 820, y: 300 },
          { x: 470, y: 425 },
          { x: 120, y: 300 },
        ];
  const shapes = stages.map((stage, index) => {
    const position = positions[index] ?? { x: 470, y: 180 };
    return shapeElement(
      `cycle-stage-${index + 1}`,
      "ellipse",
      stage,
      position.x,
      position.y,
      260,
      88,
      paletteAt(paletteOffset, index),
      { fontSize: 18 },
    );
  });
  const arrows =
    stages.length === 3
      ? [
          arrowElement("cycle-arrow-1", [730, 220], [770, 410]),
          arrowElement("cycle-arrow-2", [770, 470], [430, 470]),
          arrowElement("cycle-arrow-3", [300, 410], [470, 220]),
        ]
      : [
          arrowElement("cycle-arrow-1", [730, 220], [820, 335]),
          arrowElement("cycle-arrow-2", [820, 365], [730, 465]),
          arrowElement("cycle-arrow-3", [470, 465], [380, 365]),
          arrowElement("cycle-arrow-4", [380, 335], [470, 220]),
        ];
  return [...shapes, ...arrows];
};

const renderFunnel: LayoutRenderer = (stages, paletteOffset) => {
  const shapes = stages.map((stage, index) => {
    const width = 900 - index * 180;
    return shapeElement(
      `funnel-stage-${index + 1}`,
      "rectangle",
      stage,
      (1200 - width) / 2,
      180 + index * 84,
      width,
      60,
      paletteAt(paletteOffset, index),
      { fontSize: 18 },
    );
  });
  const arrows = stages
    .slice(1)
    .map((_stage, index) =>
      arrowElement(
        `funnel-arrow-${index + 1}`,
        [600, 240 + index * 84],
        [600, 264 + index * 84],
      ),
    );
  return [...shapes, ...arrows];
};

const renderLayers: LayoutRenderer = (stages, paletteOffset) =>
  stages.map((stage, index) =>
    shapeElement(
      `layer-${index + 1}`,
      "rectangle",
      stage,
      100 + index * 45,
      180 + index * 82,
      1000 - index * 90,
      66,
      paletteAt(paletteOffset, index),
      { fontSize: 18 },
    ),
  );

const renderBranch: LayoutRenderer = (stages, paletteOffset) => {
  const root = shapeElement(
    "branch-input",
    "rectangle",
    stages[0] ?? "Input",
    70,
    300,
    240,
    105,
    paletteAt(paletteOffset, 0),
    { fontSize: 18 },
  );
  const decision = shapeElement(
    "branch-decision",
    "diamond",
    stages[1] ?? "Decision",
    420,
    280,
    220,
    145,
    paletteAt(paletteOffset, 1),
    { fontSize: 17 },
  );
  const outcomes = stages
    .slice(2)
    .map((stage, index) =>
      shapeElement(
        `branch-outcome-${index + 1}`,
        "rectangle",
        stage,
        800,
        stages.length === 3 ? 300 : 210 + index * 190,
        300,
        105,
        paletteAt(paletteOffset, index + 2),
        { fontSize: 18 },
      ),
    );
  const arrows = [
    arrowElement("branch-arrow-input", [307, 352], [423, 352]),
    ...outcomes.map((_outcome, index) =>
      arrowElement(
        `branch-arrow-${index + 1}`,
        [637, 352],
        [803, stages.length === 3 ? 352 : 262 + index * 190],
      ),
    ),
  ];
  return [root, decision, ...outcomes, ...arrows];
};

const renderMatrix: LayoutRenderer = (stages, paletteOffset) => {
  const positions =
    stages.length === 3
      ? [
          { x: 130, y: 190 },
          { x: 650, y: 190 },
          { x: 390, y: 370 },
        ]
      : [
          { x: 130, y: 190 },
          { x: 650, y: 190 },
          { x: 130, y: 370 },
          { x: 650, y: 370 },
        ];
  return stages.map((stage, index) => {
    const position = positions[index] ?? { x: 130, y: 190 };
    return shapeElement(
      `matrix-cell-${index + 1}`,
      "rectangle",
      stage,
      position.x,
      position.y,
      420,
      120,
      paletteAt(paletteOffset, index),
      { fontSize: 19 },
    );
  });
};

const renderBeforeAfter: LayoutRenderer = (stages, paletteOffset) => {
  const split = Math.ceil(stages.length / 2);
  const left = stages.slice(0, split);
  const right = stages.slice(split);
  const zonePalette = { fill: "transparent", stroke: "#495057" };
  const zones = [
    shapeElement(
      "before-zone",
      "rectangle",
      "",
      70,
      185,
      450,
      320,
      zonePalette,
      {
        strokeStyle: "dashed",
      },
    ),
    shapeElement(
      "after-zone",
      "rectangle",
      "",
      680,
      185,
      450,
      320,
      zonePalette,
      {
        strokeStyle: "dashed",
      },
    ),
    textElement("before-label", "BEFORE", 95, 205, 17, "#adb5bd"),
    textElement("after-label", "AFTER", 705, 205, 17, "#adb5bd"),
  ];
  const leftShapes = left.map((stage, index) =>
    shapeElement(
      `before-stage-${index + 1}`,
      "rectangle",
      stage,
      110,
      260 + index * 125,
      370,
      90,
      paletteAt(paletteOffset, index),
      { fontSize: 18 },
    ),
  );
  const rightShapes = right.map((stage, index) =>
    shapeElement(
      `after-stage-${index + 1}`,
      "rectangle",
      stage,
      720,
      260 + index * 125,
      370,
      90,
      paletteAt(paletteOffset, index + split),
      { fontSize: 18 },
    ),
  );
  return [
    ...zones,
    ...leftShapes,
    ...rightShapes,
    arrowElement("transformation-arrow", [520, 345], [680, 345]),
  ];
};

const renderStaircase: LayoutRenderer = (stages, paletteOffset) => {
  const shapes = stages.map((stage, index) =>
    shapeElement(
      `stair-${index + 1}`,
      "rectangle",
      stage,
      90 + index * 260,
      420 - index * 68,
      220,
      78,
      paletteAt(paletteOffset, index),
      { fontSize: 17 },
    ),
  );
  const arrows = stages
    .slice(1)
    .map((_stage, index) =>
      arrowElement(
        `stair-arrow-${index + 1}`,
        [310 + index * 260, 450 - index * 68],
        [350 + index * 260, 420 - index * 68],
      ),
    );
  return [...shapes, ...arrows];
};

type DiagramRenderer = (
  spec: DiagramSpec,
  paletteOffset: number,
) => SceneElement[];

const renderArchitecture: DiagramRenderer = (spec, paletteOffset) => {
  const positions = [
    { x: 130, y: 215 },
    { x: 710, y: 215 },
    { x: 130, y: 385 },
    { x: 710, y: 385 },
  ];
  const boundary = shapeElement(
    "architecture-boundary",
    "rectangle",
    "",
    80,
    175,
    1040,
    340,
    { fill: "transparent", stroke: "#495057" },
    { strokeStyle: "dashed" },
  );
  const components = spec.nodes.map((node, index) => {
    const position = positions[index] ?? { x: 130, y: 215 };
    return shapeElement(
      `component-${index + 1}`,
      "rectangle",
      node,
      position.x,
      position.y,
      360,
      88,
      paletteAt(paletteOffset, index),
      { fontSize: 18 },
    );
  });
  const connections = [
    arrowElement("component-link-1", [490, 259], [710, 259]),
    arrowElement("component-link-2", [310, 303], [310, 385]),
    arrowElement("component-link-3", [890, 303], [890, 385]),
    arrowElement("component-link-4", [490, 429], [710, 429]),
  ];
  const relationLabels = (spec.relations ?? []).map((relation, index) =>
    textElement(
      `component-relation-${index + 1}`,
      relation,
      [555, 325, 920][index] ?? 555,
      [230, 330, 330][index] ?? 230,
      15,
      "#adb5bd",
    ),
  );
  return [boundary, ...components, ...connections, ...relationLabels];
};

const renderHierarchy: DiagramRenderer = (spec, paletteOffset) => {
  const root = shapeElement(
    "hierarchy-root",
    "rectangle",
    spec.nodes[0] ?? "Root",
    440,
    185,
    320,
    88,
    paletteAt(paletteOffset, 0),
  );
  const children = spec.nodes
    .slice(1)
    .map((node, index) =>
      shapeElement(
        `hierarchy-child-${index + 1}`,
        "rectangle",
        node,
        90 + index * 360,
        385,
        300,
        100,
        paletteAt(paletteOffset, index + 1),
        { fontSize: 18 },
      ),
    );
  const trunk = arrowElement("hierarchy-trunk", [600, 273], [600, 330], {
    endArrowhead: null,
  });
  const branches = children.map((_child, index) =>
    arrowElement(
      `hierarchy-branch-${index + 1}`,
      [600, 330],
      [240 + index * 360, 385],
      { endArrowhead: null },
    ),
  );
  return [root, ...children, trunk, ...branches];
};

const renderUserFlow: DiagramRenderer = (spec, paletteOffset) => {
  const nodes = [
    shapeElement(
      "user-flow-entry",
      "ellipse",
      spec.nodes[0] ?? "Entry",
      45,
      300,
      220,
      105,
      paletteAt(paletteOffset, 0),
      { fontSize: 17 },
    ),
    shapeElement(
      "user-flow-action",
      "rectangle",
      spec.nodes[1] ?? "Action",
      330,
      300,
      240,
      105,
      paletteAt(paletteOffset, 1),
      { fontSize: 17 },
    ),
    shapeElement(
      "user-flow-decision",
      "diamond",
      spec.nodes[2] ?? "Decision",
      645,
      285,
      210,
      135,
      paletteAt(paletteOffset, 2),
      { fontSize: 16 },
    ),
    shapeElement(
      "user-flow-outcome",
      "ellipse",
      spec.nodes[3] ?? "Outcome",
      930,
      300,
      220,
      105,
      paletteAt(paletteOffset, 3),
      { fontSize: 17 },
    ),
  ];
  return [
    ...nodes,
    arrowElement("user-flow-arrow-1", [255, 352], [340, 352]),
    arrowElement("user-flow-arrow-2", [560, 352], [655, 352]),
    arrowElement("user-flow-arrow-3", [845, 352], [940, 352]),
    textElement("user-flow-yes", "continue", 865, 325, 14, "#adb5bd"),
  ];
};

const renderSequence: DiagramRenderer = (spec, paletteOffset) => {
  const actors = spec.actors ?? ["Caller", "System", "Evidence"];
  const actorX = [150, 500, 850];
  const actorShapes = actorX.map((x, index) =>
    shapeElement(
      `sequence-actor-${index + 1}`,
      "rectangle",
      actors[index] ?? `Actor ${index + 1}`,
      x,
      175,
      200,
      60,
      paletteAt(paletteOffset, index),
      { fontSize: 17 },
    ),
  );
  const lifelines = actorX.map((x, index) =>
    arrowElement(
      `sequence-lifeline-${index + 1}`,
      [x + 100, 235],
      [x + 100, 500],
      { endArrowhead: null, strokeStyle: "dashed" },
    ),
  );
  const messagePairs: Array<[number, number]> = [
    [0, 1],
    [1, 2],
    [2, 1],
    [1, 0],
  ];
  const messages = spec.nodes.flatMap((message, index) => {
    const pair = messagePairs[index] ?? [0, 1];
    const startX = (actorX[pair[0]] ?? 150) + 100;
    const endX = (actorX[pair[1]] ?? 500) + 100;
    const y = 270 + index * 62;
    const label = wrapText(message, 24, 2);
    const labelHeight = Math.ceil(label.split("\n").length * 15 * 1.35);
    return [
      arrowElement(`sequence-message-${index + 1}`, [startX, y], [endX, y], {
        strokeStyle: index >= 2 ? "dashed" : "solid",
      }),
      textElement(
        `sequence-message-label-${index + 1}`,
        label,
        Math.min(startX, endX) + 35,
        y - labelHeight - 8,
        15,
        "#e9ecef",
      ),
    ];
  });
  return [...actorShapes, ...lifelines, ...messages];
};

const renderEntityRelationship: DiagramRenderer = (spec, paletteOffset) => {
  const positions = [
    { x: 120, y: 190 },
    { x: 740, y: 190 },
    { x: 120, y: 380 },
    { x: 740, y: 380 },
  ];
  const entities = spec.nodes.flatMap((node, index) => {
    const position = positions[index] ?? { x: 120, y: 190 };
    const palette = paletteAt(paletteOffset, index);
    return [
      shapeElement(
        `entity-${index + 1}`,
        "rectangle",
        "",
        position.x,
        position.y,
        340,
        120,
        palette,
      ),
      textElement(
        `entity-title-${index + 1}`,
        node,
        position.x + 22,
        position.y + 18,
        19,
        palette.stroke,
      ),
      arrowElement(
        `entity-divider-${index + 1}`,
        [position.x + 18, position.y + 52],
        [position.x + 322, position.y + 52],
        { endArrowhead: null },
      ),
      textElement(
        `entity-fields-${index + 1}`,
        (spec.fields?.[index] ?? ["key", "relationship"]).join("\n"),
        position.x + 22,
        position.y + 64,
        14,
        "#adb5bd",
      ),
    ];
  });
  const links = [
    arrowElement("entity-link-1", [460, 250], [740, 250], {
      endArrowhead: null,
    }),
    arrowElement("entity-link-2", [290, 310], [290, 380], {
      endArrowhead: null,
    }),
    arrowElement("entity-link-3", [910, 310], [910, 380], {
      endArrowhead: null,
    }),
  ];
  const relationLabels = (spec.relations ?? []).map((relation, index) =>
    textElement(
      `entity-relation-${index + 1}`,
      relation,
      [555, 305, 925][index] ?? 555,
      [225, 330, 330][index] ?? 225,
      14,
      "#adb5bd",
    ),
  );
  return [...entities, ...links, ...relationLabels];
};

const renderStateMachine: DiagramRenderer = (spec, paletteOffset) => {
  const start = shapeElement("state-initial", "ellipse", "", 45, 325, 34, 34, {
    fill: "#e9ecef",
    stroke: "#e9ecef",
  });
  const states = spec.nodes.map((node, index) =>
    shapeElement(
      `state-${index + 1}`,
      index === spec.nodes.length - 1 ? "ellipse" : "rectangle",
      node,
      130 + index * 260,
      290,
      210,
      105,
      paletteAt(paletteOffset, index),
      { fontSize: 17 },
    ),
  );
  const transitions = [
    arrowElement("state-transition-start", [76, 342], [133, 342]),
    ...spec.nodes
      .slice(1)
      .map((_node, index) =>
        arrowElement(
          `state-transition-${index + 1}`,
          [337 + index * 260, 342],
          [393 + index * 260, 342],
        ),
      ),
    arrowElement("state-retry", [755, 305], [495, 305], {
      strokeStyle: "dashed",
      via: [
        [720, 235],
        [530, 235],
      ],
    }),
    textElement("state-retry-label", "retry / revise", 585, 200, 14, "#adb5bd"),
  ];
  return [start, ...states, ...transitions];
};

const renderDependencyGraph: DiagramRenderer = (spec, paletteOffset) => {
  const positions = [
    { x: 150, y: 185 },
    { x: 750, y: 185 },
    { x: 450, y: 330 },
    { x: 450, y: 450 },
  ];
  const nodes = spec.nodes.map((node, index) => {
    const position = positions[index] ?? { x: 450, y: 330 };
    return shapeElement(
      `dependency-node-${index + 1}`,
      "rectangle",
      node,
      position.x,
      position.y,
      300,
      72,
      paletteAt(paletteOffset, index),
      { fontSize: 17 },
    );
  });
  return [
    ...nodes,
    arrowElement("dependency-edge-1", [300, 257], [540, 330]),
    arrowElement("dependency-edge-2", [900, 257], [660, 330]),
    arrowElement("dependency-edge-3", [600, 402], [600, 450]),
  ];
};

const renderSwimlane: DiagramRenderer = (spec, paletteOffset) => {
  const actors = spec.actors ?? ["Actor", "System", "Evidence"];
  const laneY = [175, 285, 395];
  const lanes = laneY.flatMap((y, index) => [
    shapeElement(
      `swimlane-${index + 1}`,
      "rectangle",
      "",
      80,
      y,
      1040,
      95,
      { fill: "transparent", stroke: "#495057" },
      { strokeStyle: "dashed" },
    ),
    textElement(
      `swimlane-label-${index + 1}`,
      actors[index] ?? `Lane ${index + 1}`,
      95,
      y + 12,
      16,
      "#adb5bd",
    ),
  ]);
  const taskPositions = [
    { lane: 0, x: 275 },
    { lane: 1, x: 470 },
    { lane: 1, x: 690 },
    { lane: 2, x: 900 },
  ];
  const tasks = spec.nodes.map((node, index) => {
    const position = taskPositions[index] ?? { lane: 1, x: 470 };
    return shapeElement(
      `swimlane-task-${index + 1}`,
      "rectangle",
      node,
      position.x,
      (laneY[position.lane] ?? 285) + 30,
      180,
      52,
      paletteAt(paletteOffset, index),
      { fontSize: 14 },
    );
  });
  const arrows = spec.nodes.slice(1).map((_node, index) => {
    const from = taskPositions[index] ?? { lane: 0, x: 275 };
    const to = taskPositions[index + 1] ?? { lane: 1, x: 470 };
    return arrowElement(
      `swimlane-flow-${index + 1}`,
      [from.x + 180, (laneY[from.lane] ?? 285) + 56],
      [to.x, (laneY[to.lane] ?? 285) + 56],
    );
  });
  return [...lanes, ...tasks, ...arrows];
};

const renderSystemContext: DiagramRenderer = (spec, paletteOffset) => {
  const system = shapeElement(
    "context-system",
    "rectangle",
    spec.nodes[0] ?? "System",
    445,
    300,
    310,
    115,
    paletteAt(paletteOffset, 0),
  );
  const externals = spec.nodes.slice(1).map((node, index) => {
    const positions = [
      { x: 445, y: 175 },
      { x: 80, y: 310 },
      { x: 880, y: 310 },
    ];
    const position = positions[index] ?? { x: 80, y: 310 };
    return shapeElement(
      `context-external-${index + 1}`,
      "ellipse",
      node,
      position.x,
      position.y,
      240,
      85,
      paletteAt(paletteOffset, index + 1),
      { fontSize: 16 },
    );
  });
  return [
    system,
    ...externals,
    arrowElement("context-link-1", [565, 260], [565, 300], {
      endArrowhead: null,
    }),
    arrowElement("context-link-2", [320, 352], [445, 352], {
      endArrowhead: null,
    }),
    arrowElement("context-link-3", [755, 352], [880, 352], {
      endArrowhead: null,
    }),
  ];
};

const renderMindMap: DiagramRenderer = (spec, paletteOffset) => {
  const center = shapeElement(
    "mind-map-center",
    "ellipse",
    spec.nodes[0] ?? "Concept",
    450,
    295,
    300,
    120,
    paletteAt(paletteOffset, 0),
  );
  const positions = [
    { x: 450, y: 175 },
    { x: 90, y: 330 },
    { x: 870, y: 330 },
  ];
  const branches = spec.nodes.slice(1).map((node, index) => {
    const position = positions[index] ?? { x: 90, y: 330 };
    return shapeElement(
      `mind-map-branch-${index + 1}`,
      "ellipse",
      node,
      position.x,
      position.y,
      240,
      82,
      paletteAt(paletteOffset, index + 1),
      { fontSize: 16 },
    );
  });
  return [
    center,
    ...branches,
    arrowElement("mind-map-link-1", [570, 257], [570, 295], {
      endArrowhead: null,
    }),
    arrowElement("mind-map-link-2", [330, 371], [450, 355], {
      endArrowhead: null,
    }),
    arrowElement("mind-map-link-3", [750, 355], [870, 371], {
      endArrowhead: null,
    }),
  ];
};

const DIAGRAM_RENDERERS: Record<DiagramKind, DiagramRenderer> = {
  architecture: renderArchitecture,
  "concern-matrix": (spec, paletteOffset) =>
    renderMatrix(spec.nodes, paletteOffset),
  "decision-tree": (spec, paletteOffset) =>
    renderBranch(spec.nodes, paletteOffset),
  "dependency-graph": renderDependencyGraph,
  "entity-relationship": renderEntityRelationship,
  "evidence-funnel": (spec, paletteOffset) =>
    renderFunnel(spec.nodes, paletteOffset),
  "feedback-loop": (spec, paletteOffset) =>
    renderCycle(spec.nodes, paletteOffset),
  hierarchy: renderHierarchy,
  "layered-architecture": (spec, paletteOffset) =>
    renderLayers(spec.nodes, paletteOffset),
  lifecycle: (spec, paletteOffset) => renderCycle(spec.nodes, paletteOffset),
  "mind-map": renderMindMap,
  pipeline: (spec, paletteOffset) => renderLinear(spec.nodes, paletteOffset),
  progression: (spec, paletteOffset) =>
    renderStaircase(spec.nodes, paletteOffset),
  sequence: renderSequence,
  "state-machine": renderStateMachine,
  swimlane: renderSwimlane,
  "system-context": renderSystemContext,
  timeline: (spec, paletteOffset) => renderTimeline(spec.nodes, paletteOffset),
  "transformation-map": (spec, paletteOffset) =>
    renderBeforeAfter(spec.nodes, paletteOffset),
  "user-flow": renderUserFlow,
};

const createScene = (skill: Skill): Record<string, unknown> => {
  const spec = SKILL_DIAGRAMS[skill.name];
  if (!spec) {
    throw new Error(`Choose a semantic diagram for /${skill.name}.`);
  }
  const paletteOffset = Array.from(skill.name).reduce(
    (total, character) => total + (character.codePointAt(0) ?? 0),
    0,
  );
  const elements: SceneElement[] = [
    {
      ...elementBase("canvas", "rectangle"),
      backgroundColor: "#121212",
      fillStyle: "solid",
      height: 630,
      locked: true,
      roughness: 0,
      strokeColor: "#121212",
      strokeWidth: 1,
      width: 1200,
      x: 0,
      y: 0,
    },
    textElement("title", `/${skill.name}`, 60, 45, 34, "#e9ecef"),
    textElement(
      "description",
      wrapText(skill.description, 76, 2),
      60,
      100,
      18,
      "#adb5bd",
    ),
    textElement("map-label", DIAGRAM_LABELS[spec.kind], 900, 58, 17, "#adb5bd"),
    ...DIAGRAM_RENDERERS[spec.kind](spec, paletteOffset),
  ];

  elements.push(
    textElement(
      "footer",
      "canonical guidance → focused action → observable proof",
      60,
      535,
      20,
      "#e9ecef",
    ),
    textElement(
      "source-note",
      "Editable Excalidraw source included with this page",
      60,
      575,
      16,
      "#adb5bd",
    ),
  );

  return {
    appState: { gridSize: null, viewBackgroundColor: "#ffffff" },
    elements,
    diagramKind: spec.kind,
    source: "frontend-skills/docs-site/generate-skill-diagrams.ts",
    type: "excalidraw",
    version: 2,
  };
};

const runCli = async (...arguments_: string[]): Promise<void> => {
  const process = Bun.spawn([...CLI, ...arguments_], {
    cwd: REPOSITORY_ROOT,
    env: {
      ...Bun.env,
      EXPRESS_SERVER_URL:
        Bun.env.EXPRESS_SERVER_URL ??
        `http://127.0.0.1:${Bun.env.CONDUCTOR_PORT ?? "3000"}`,
    },
    stderr: "pipe",
    stdout: "pipe",
  });
  const [exitCode, stdout, stderr] = await Promise.all([
    process.exited,
    new Response(process.stdout).text(),
    new Response(process.stderr).text(),
  ]);
  if (exitCode !== 0) {
    throw new Error(
      `Excalidraw CLI failed: ${arguments_.join(" ")}\n${stdout}\n${stderr}`,
    );
  }
};

const addSvgTitle = async (
  path: string,
  skillName: string,
  kind: DiagramKind,
): Promise<void> => {
  const svg = await readFile(path, "utf8");
  const titled = svg.replace(
    /^(<svg[^>]*>)/,
    `$1<title>${kind.replaceAll("-", " ")} diagram for the /${skillName} skill</title>`,
  );
  await writeFile(path, titled);
};

const renderScenes = async (skills: Skill[]): Promise<void> => {
  const snapshot = `before-skill-diagrams-${Date.now()}`;
  await runCli("snapshot", "save", snapshot);
  try {
    for (const [index, skill] of skills.entries()) {
      const base = join(OUTPUT_DIRECTORY, skill.name);
      await runCli("import", `${base}.excalidraw`, "--replace");
      await runCli("screenshot", "--format", "svg", "--out", `${base}.svg`);
      const spec = SKILL_DIAGRAMS[skill.name];
      if (!spec) {
        throw new Error(`Choose a semantic diagram for /${skill.name}.`);
      }
      await addSvgTitle(`${base}.svg`, skill.name, spec.kind);
      console.log(`[${index + 1}/${skills.length}] /${skill.name}`);
    }
  } finally {
    await runCli("snapshot", "restore", snapshot);
  }
};

const skills = await loadSkills();
const skillNames = new Set(skills.map((skill) => skill.name));
const unmappedSkills = skills.filter((skill) => !SKILL_DIAGRAMS[skill.name]);
const staleDiagrams = Object.keys(SKILL_DIAGRAMS).filter(
  (skillName) => !skillNames.has(skillName),
);
if (unmappedSkills.length > 0 || staleDiagrams.length > 0) {
  throw new Error(
    `Semantic diagram map drifted. Missing: ${unmappedSkills.map((skill) => skill.name).join(", ") || "none"}. Stale: ${staleDiagrams.join(", ") || "none"}.`,
  );
}
await mkdir(OUTPUT_DIRECTORY, { recursive: true });
for (const skill of skills) {
  const output = join(OUTPUT_DIRECTORY, `${skill.name}.excalidraw`);
  await writeFile(output, `${JSON.stringify(createScene(skill), null, 2)}\n`);
}

if (Bun.argv.includes("--render")) {
  await renderScenes(skills);
} else {
  console.log(
    `Wrote ${skills.length} editable scenes. Pass --render with the Excalidraw canvas open to refresh SVGs.`,
  );
}
