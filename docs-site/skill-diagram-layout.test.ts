import { readFile } from "node:fs/promises";
import { join } from "node:path";

import { describe, expect, test } from "bun:test";

interface DiagramElement {
  height?: number;
  id: string;
  points?: Array<[number, number]>;
  width?: number;
  x?: number;
  y?: number;
}

interface DiagramScene {
  elements: DiagramElement[];
}

const diagramDirectory = join(import.meta.dir, "public", "diagrams", "skills");

const loadScene = async (name: string): Promise<DiagramScene> =>
  JSON.parse(
    await readFile(join(diagramDirectory, `${name}.excalidraw`), "utf8"),
  ) as DiagramScene;

const requireElement = (scene: DiagramScene, id: string): DiagramElement => {
  const element = scene.elements.find((candidate) => candidate.id === id);
  if (!element) {
    throw new Error(`Missing diagram element: ${id}`);
  }
  return element;
};

const absoluteArrowPoints = (
  element: DiagramElement,
): Array<[number, number]> => {
  if (element.x === undefined || element.y === undefined || !element.points) {
    throw new Error(`${element.id} is not a positioned arrow.`);
  }
  const originX = element.x;
  const originY = element.y;
  return element.points.map(([x, y]) => [originX + x, originY + y]);
};

describe("skill diagram layout regressions", () => {
  test.each(["efficient-frontier", "steelman"])(
    "%s decision-tree edges visibly overlap their connected node borders",
    async (name) => {
      const scene = await loadScene(name);
      const input = requireElement(scene, "branch-input");
      const decision = requireElement(scene, "branch-decision");
      const firstOutcome = requireElement(scene, "branch-outcome-1");
      const secondOutcome = requireElement(scene, "branch-outcome-2");
      const inputArrow = absoluteArrowPoints(
        requireElement(scene, "branch-arrow-input"),
      );
      const firstBranch = absoluteArrowPoints(
        requireElement(scene, "branch-arrow-1"),
      );
      const secondBranch = absoluteArrowPoints(
        requireElement(scene, "branch-arrow-2"),
      );

      expect(inputArrow[0]?.[0]).toBeLessThan(
        (input.x ?? 0) + (input.width ?? 0),
      );
      expect(inputArrow.at(-1)?.[0]).toBeGreaterThan(decision.x ?? 0);
      expect(firstBranch[0]?.[0]).toBeLessThan(
        (decision.x ?? 0) + (decision.width ?? 0),
      );
      expect(firstBranch.at(-1)?.[0]).toBeGreaterThan(firstOutcome.x ?? 0);
      expect(secondBranch.at(-1)?.[0]).toBeGreaterThan(secondOutcome.x ?? 0);
    },
  );

  test("sequence message labels stay clear of their arrows", async () => {
    const scene = await loadScene("handoff");

    for (const index of [1, 2, 3, 4]) {
      const arrow = requireElement(scene, `sequence-message-${index}`);
      const label = requireElement(scene, `sequence-message-label-${index}`);
      expect((label.y ?? 0) + (label.height ?? 0)).toBeLessThanOrEqual(
        (arrow.y ?? 0) - 8,
      );
    }
  });

  test.each([
    "plow-ahead",
    "resolve-pr-feedback",
    "stay-within-limits",
    "tdd",
    "triage",
  ])(
    "%s retry arrow connects the third state back to the second",
    async (name) => {
      const scene = await loadScene(name);
      const source = requireElement(scene, "state-3");
      const target = requireElement(scene, "state-2");
      const points = absoluteArrowPoints(requireElement(scene, "state-retry"));
      const first = points[0];
      const last = points.at(-1);

      expect(points.length).toBeGreaterThanOrEqual(4);
      expect(first?.[1]).toBeGreaterThanOrEqual((source.y ?? 0) + 12);
      expect(first?.[1]).toBeLessThan((source.y ?? 0) + (source.height ?? 0));
      expect(first?.[0]).toBeGreaterThan(source.x ?? 0);
      expect(first?.[0]).toBeLessThan((source.x ?? 0) + (source.width ?? 0));
      expect(last?.[1]).toBeGreaterThanOrEqual((target.y ?? 0) + 12);
      expect(last?.[1]).toBeLessThan((target.y ?? 0) + (target.height ?? 0));
      expect(last?.[0]).toBeGreaterThan(target.x ?? 0);
      expect(last?.[0]).toBeLessThan((target.x ?? 0) + (target.width ?? 0));
      expect(points.slice(1, -1).every(([, y]) => y < (target.y ?? 0))).toBe(
        true,
      );
    },
  );

  test("state-machine transitions visibly overlap both connected nodes", async () => {
    const scene = await loadScene("tanstack-router");
    const connections = [
      ["state-initial", "state-1", "state-transition-start"],
      ["state-1", "state-2", "state-transition-1"],
      ["state-2", "state-3", "state-transition-2"],
      ["state-3", "state-4", "state-transition-3"],
    ] as const;

    for (const [sourceId, targetId, arrowId] of connections) {
      const source = requireElement(scene, sourceId);
      const target = requireElement(scene, targetId);
      const points = absoluteArrowPoints(requireElement(scene, arrowId));
      const firstX = points[0]?.[0] ?? 0;
      const lastX = points.at(-1)?.[0] ?? 0;

      expect(firstX).toBeGreaterThan(source.x ?? 0);
      expect(firstX).toBeLessThan((source.x ?? 0) + (source.width ?? 0));
      expect(lastX).toBeGreaterThan(target.x ?? 0);
      expect(lastX).toBeLessThan((target.x ?? 0) + (target.width ?? 0));
    }
  });

  test("user-flow edges visibly overlap both sides of the diamond node", async () => {
    const scene = await loadScene("visual-review");
    const decision = requireElement(scene, "user-flow-decision");
    const incoming = absoluteArrowPoints(
      requireElement(scene, "user-flow-arrow-2"),
    );
    const outgoing = absoluteArrowPoints(
      requireElement(scene, "user-flow-arrow-3"),
    );

    expect(incoming.at(-1)?.[0]).toBeGreaterThanOrEqual((decision.x ?? 0) + 10);
    expect(outgoing[0]?.[0]).toBeLessThanOrEqual(
      (decision.x ?? 0) + (decision.width ?? 0) - 10,
    );
  });
});
