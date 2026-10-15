import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { describe, expect, test } from "bun:test";

interface DiagramElement {
  id: string;
  type: string;
  height: number;
  width: number;
  x: number;
  y: number;
  points?: Array<[number, number]>;
  startBinding?: { elementId: string; gap: number } | null;
  endBinding?: { elementId: string; gap: number } | null;
  containerId?: string | null;
}
interface DiagramScene {
  elements: DiagramElement[];
}
const diagramDirectory = join(import.meta.dir, "public", "diagrams", "skills");
const loadScene = async (name: string): Promise<DiagramScene> =>
  JSON.parse(
    await readFile(join(diagramDirectory, `${name}.excalidraw`), "utf8"),
  );
const requireElement = (scene: DiagramScene, id: string): DiagramElement => {
  const element = scene.elements.find((candidate) => candidate.id === id);
  if (!element) throw new Error(`Missing diagram element: ${id}`);
  return element;
};
const absoluteArrowPoints = (
  element: DiagramElement,
): Array<[number, number]> => {
  if (!element.points) throw new Error(`${element.id} is not an arrow.`);
  return element.points.map(([x, y]) => [element.x + x, element.y + y]);
};

// Independent contour oracle: the endpoint must sit just outside the visible
// outline. A binding alone could pass with a disconnected or crossing arrow.
const expectContourContact = (
  shape: DiagramElement,
  point: [number, number],
) => {
  const dx = Math.abs(point[0] - shape.x - shape.width / 2);
  const dy = Math.abs(point[1] - shape.y - shape.height / 2);
  const x = dx / (shape.width / 2);
  const y = dy / (shape.height / 2);
  const contour =
    shape.type === "diamond"
      ? x + y
      : shape.type === "ellipse"
        ? Math.hypot(x, y)
        : Math.max(x, y);
  expect(contour).toBeGreaterThanOrEqual(1);
  expect(contour).toBeLessThanOrEqual(
    1 + 12 / Math.min(shape.width, shape.height),
  );
};
const expectConnection = (
  scene: DiagramScene,
  id: string,
  from: string,
  to: string,
) => {
  const arrow = requireElement(scene, id);
  const points = absoluteArrowPoints(arrow);
  expect(arrow.startBinding?.elementId).toBe(from);
  expect(arrow.endBinding?.elementId).toBe(to);
  expectContourContact(requireElement(scene, from), points[0] ?? [NaN, NaN]);
  expectContourContact(requireElement(scene, to), points.at(-1) ?? [NaN, NaN]);
};

describe("skill diagram layout regressions", () => {
  test("editable Excalidraw overview retains native bound labels", async () => {
    const scene = await loadScene("excalidraw-diagram");
    for (const id of [
      "sequence-actor-1",
      "sequence-actor-2",
      "sequence-actor-3",
    ]) {
      expect(scene.elements.some((element) => element.containerId === id)).toBe(
        true,
      );
    }
  });
  test("Excalidraw overview documents the official local-render workflow", async () => {
    const source = await readFile(
      join(diagramDirectory, "excalidraw-diagram.svg"),
      "utf8",
    );
    for (const label of [
      "Git files",
      "Official CLI",
      "Edit native scene",
      "Render local PNG",
      "Return PNG preview",
      "Inspect + maintain docs",
    ])
      expect(source).toContain(label);
    expect(source).not.toContain("Canvas server");
  });
  test.each(["efficient-frontier", "steelman"])(
    "%s decision edges bind to visible contours",
    async (name) => {
      const scene = await loadScene(name);
      expectConnection(
        scene,
        "branch-arrow-input",
        "branch-input",
        "branch-decision",
      );
      for (const i of [1, 2])
        expectConnection(
          scene,
          `branch-arrow-${i}`,
          "branch-decision",
          `branch-outcome-${i}`,
        );
    },
  );
  test("sequence message labels stay clear of their arrows", async () => {
    const scene = await loadScene("handoff");
    for (const i of [1, 2, 3, 4]) {
      const arrow = requireElement(scene, `sequence-message-${i}`);
      const label = requireElement(scene, `sequence-message-label-${i}`);
      expect(label.y + label.height).toBeLessThanOrEqual(arrow.y - 8);
    }
  });
  test.each([
    "plow-ahead",
    "resolve-pr-feedback",
    "stay-within-limits",
    "tdd",
    "triage",
  ])(
    "%s retry connects state three to two without crossing them",
    async (name) => {
      const scene = await loadScene(name);
      expectConnection(scene, "state-retry", "state-3", "state-2");
      const points = absoluteArrowPoints(requireElement(scene, "state-retry"));
      expect(points.length).toBeGreaterThanOrEqual(4);
      expect(
        points.every(([, y]) => y < requireElement(scene, "state-2").y),
      ).toBe(true);
    },
  );
  test("state transitions touch each connected node contour", async () => {
    const scene = await loadScene("tanstack-router");
    expectConnection(
      scene,
      "state-transition-start",
      "state-initial",
      "state-1",
    );
    for (const i of [1, 2, 3])
      expectConnection(
        scene,
        `state-transition-${i}`,
        `state-${i}`,
        `state-${i + 1}`,
      );
  });
  test("user-flow arrows touch the diamond contour", async () => {
    const scene = await loadScene("visual-review");
    expectConnection(
      scene,
      "user-flow-arrow-2",
      "user-flow-action",
      "user-flow-decision",
    );
    expectConnection(
      scene,
      "user-flow-arrow-3",
      "user-flow-decision",
      "user-flow-outcome",
    );
  });
});
