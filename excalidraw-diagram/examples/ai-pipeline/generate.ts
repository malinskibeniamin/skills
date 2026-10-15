import { join } from "node:path";

interface Binding {
  elementId: string;
  focus: number;
  gap: number;
}
interface Element {
  id: string;
  type: "rectangle" | "text" | "arrow";
  x: number;
  y: number;
  width: number;
  height: number;
  angle: number;
  strokeColor: string;
  backgroundColor: string;
  fillStyle: "solid";
  strokeWidth: number;
  strokeStyle: string;
  roughness: number;
  opacity: number;
  seed: number;
  version: number;
  versionNonce: number;
  updated: number;
  isDeleted: boolean;
  groupIds: string[];
  frameId: null;
  link: null;
  locked: boolean;
  roundness: { type: number } | null;
  boundElements: Array<{ id: string; type: "text" | "arrow" }>;
  text?: string;
  originalText?: string;
  containerId?: string | null;
  fontFamily?: number;
  fontSize?: number;
  lineHeight?: number;
  textAlign?: string;
  verticalAlign?: string;
  autoResize?: boolean;
  points?: Point[];
  startBinding?: Binding;
  endBinding?: Binding;
  startArrowhead?: null;
  endArrowhead?: "arrow";
}
type Point = [number, number];
const elements: Element[] = [];
const base = (
  id: string,
  type: Element["type"],
  x: number,
  y: number,
  width: number,
  height: number,
): Element => ({
  id,
  type,
  x,
  y,
  width,
  height,
  angle: 0,
  strokeColor: "#e9ecef",
  backgroundColor: "transparent",
  fillStyle: "solid",
  strokeWidth: 2,
  strokeStyle: "solid",
  roughness: 1,
  opacity: 100,
  seed:
    Array.from(id).reduce(
      (hash, ch) => (hash * 31 + (ch.codePointAt(0) ?? 0)) >>> 0,
      1,
    ) % 2147483647,
  version: 1,
  versionNonce: 1,
  updated: Date.parse("2026-08-05T00:00:00Z"),
  isDeleted: false,
  groupIds: [],
  frameId: null,
  link: null,
  locked: false,
  roundness: null,
  boundElements: [],
});
const text = (
  id: string,
  value: string,
  x: number,
  y: number,
  size = 20,
): Element => {
  const element = base(
    id,
    "text",
    x,
    y,
    Math.ceil(
      Math.max(...value.split("\n").map((line) => line.length)) * size * 0.65,
    ),
    value.split("\n").length * size * 1.25,
  );
  Object.assign(element, {
    text: value,
    originalText: value,
    containerId: null,
    fontFamily: 5,
    fontSize: size,
    lineHeight: 1.25,
    textAlign: "left",
    verticalAlign: "top",
    autoResize: true,
  });
  elements.push(element);
  return element;
};
const box = (
  id: string,
  label: string,
  x: number,
  y: number,
  width: number,
  height: number,
  stroke = "#495057",
  fill = "#121212",
): Element => {
  const shape = base(id, "rectangle", x, y, width, height);
  Object.assign(shape, {
    strokeColor: stroke,
    backgroundColor: fill,
    roundness: { type: 3 },
  });
  elements.push(shape);
  if (label) {
    const caption = text(`${id}-label`, label, 0, 0);
    Object.assign(caption, {
      x: x + (width - caption.width) / 2,
      y: y + (height - caption.height) / 2,
      textAlign: "center",
      verticalAlign: "middle",
      containerId: id,
    });
    shape.boundElements.push({ id: caption.id, type: "text" });
  }
  return shape;
};
const center = (shape: Element): Point => [
  shape.x + shape.width / 2,
  shape.y + shape.height / 2,
];
const border = (shape: Element, toward: Point): Point => {
  const [cx, cy] = center(shape);
  const dx = toward[0] - cx;
  const dy = toward[1] - cy;
  const scale = Math.max(
    Math.abs(dx) / (shape.width / 2),
    Math.abs(dy) / (shape.height / 2),
  );
  const distance = Math.hypot(dx, dy);
  return [
    cx + dx / scale + (dx / distance) * 4,
    cy + dy / scale + (dy / distance) * 4,
  ];
};
const connect = (
  id: string,
  source: Element,
  target: Element,
  bend = 0,
): void => {
  const from = center(source);
  const to = center(target);
  const midpoint: Point = [(from[0] + to[0]) / 2, (from[1] + to[1]) / 2 + bend];
  const a = border(source, bend ? midpoint : to);
  const b = border(target, bend ? midpoint : from);
  const points: Point[] = bend ? [a, midpoint, b] : [a, b];
  const arrow = base(
    id,
    "arrow",
    a[0],
    a[1],
    Math.max(...points.map(([x]) => x)) - Math.min(...points.map(([x]) => x)),
    Math.max(...points.map(([, y]) => y)) -
      Math.min(...points.map(([, y]) => y)),
  );
  Object.assign(arrow, {
    points: points.map(([x, y]) => [x - a[0], y - a[1]]),
    roundness: { type: 2 },
    startArrowhead: null,
    endArrowhead: "arrow",
    startBinding: { elementId: source.id, focus: 0, gap: 4 },
    endBinding: { elementId: target.id, focus: 0, gap: 4 },
  });
  source.boundElements.push({ id, type: "arrow" });
  target.boundElements.push({ id, type: "arrow" });
  elements.push(arrow);
};

const canvas = box("canvas", "", 0, 0, 1600, 1300, "#121212", "#121212");
Object.assign(canvas, { roughness: 0, roundness: null, locked: true });
for (const boundary of [
  box("pipeline", "", 460, 150, 520, 1020),
  box("workflow", "", 520, 370, 400, 570),
]) {
  Object.assign(boundary, {
    strokeStyle: "dashed",
    backgroundColor: "transparent",
  });
}
text("skill-name", "/excalidraw-diagram", 60, 40, 30);
text(
  "skill-note",
  "One native source, from authoring to visual proof.",
  60,
  85,
  18,
).strokeColor = "#adb5bd";
const prompt = box(
  "prompt",
  "Natural-language\nprompt",
  520,
  210,
  400,
  110,
  "#4dabf7",
  "#1c4f73",
);
const route = box(
  "route",
  "Choose generation\nroute",
  570,
  420,
  300,
  110,
  "#f08c00",
  "#402f00",
);
const build = box(
  "build",
  "Generate native\nExcalidraw elements",
  570,
  600,
  300,
  110,
  "#4dabf7",
  "#1c4f73",
);
const verify = box(
  "verify",
  "Render, inspect,\ncorrect",
  570,
  780,
  300,
  110,
  "#40c057",
  "#0b4f1c",
);
const output = box(
  "output",
  "Editable source +\nrendered assets",
  520,
  1000,
  400,
  110,
  "#40c057",
  "#0b4f1c",
);
const callouts = [
  box("prompt-callout", "Prompt\nDescribe the visual", 60, 210, 320, 130),
  box("mermaid-callout", "Mermaid mode\nFlows + sequences", 60, 420, 320, 130),
  box(
    "direct-callout",
    "Direct elements\nArt-directed layout",
    1120,
    600,
    400,
    130,
  ),
  box(
    "qa-callout",
    "Render / inspect / fix\nRepeat until clean",
    60,
    780,
    320,
    130,
  ),
  box(
    "output-callout",
    "Source stays editable\nPNG + SVG exports",
    1120,
    1000,
    400,
    130,
  ),
];
const stages = [prompt, route, build, verify, output];
for (let i = 1; i < stages.length; i++) {
  const previous = stages[i - 1];
  const next = stages[i];
  if (previous && next) connect(`flow-${i}`, previous, next);
}
for (const [i, id] of [
  "prompt-arrow",
  "mermaid-arrow",
  "direct-arrow",
  "qa-arrow",
  "output-arrow",
].entries()) {
  const callout = callouts[i];
  const stage = stages[i];
  if (callout && stage) connect(id, callout, stage, i % 2 ? 35 : -35);
}
text(
  "source-note",
  "Git stays authoritative. Keep native source and explicit exports together.",
  60,
  1230,
  18,
).strokeColor = "#adb5bd";
const description =
  "A prompt selects Mermaid or direct-element authoring, then native elements are rendered, inspected and corrected before exporting editable source, PNG and SVG.";
const path = join(import.meta.dir, "ai-pipeline");
await Bun.write(
  `${path}.excalidraw`,
  `${JSON.stringify({ type: "excalidraw", version: 2, source: "frontend-skills/excalidraw-diagram/examples/ai-pipeline/generate.ts", diagramKind: "pipeline", diagramDescription: description, elements, appState: { viewBackgroundColor: "#121212", gridSize: null }, files: {} }, null, 2)}\n`,
);
if (Bun.argv.includes("--render")) {
  for (const command of [
    [
      "bunx",
      "mcp-excalidraw-server@2.1.2",
      "render",
      `${path}.excalidraw`,
      "--format",
      "svg",
      "--padding",
      "0",
      "--out",
      `${path}.svg`,
    ],
    [
      "bunx",
      "@excalidraw/cli@0.2.0",
      "render",
      `${path}.excalidraw`,
      "--out",
      `${path}.png`,
    ],
  ]) {
    const process = Bun.spawn(command, {
      stdout: "inherit",
      stderr: "inherit",
      env: { ...Bun.env, EXCALIDRAW_NO_UPDATE_NOTIFIER: "1" },
    });
    if ((await process.exited) !== 0)
      throw new Error(
        "Example export failed; keep the valid native source and report the missing export.",
      );
  }
  const svg = await Bun.file(`${path}.svg`).text();
  await Bun.write(
    `${path}.svg`,
    svg.replace(
      /^(<svg[^>]*>)/,
      `$1<title>Native Excalidraw authoring pipeline</title><desc>${description}</desc>`,
    ),
  );
}
