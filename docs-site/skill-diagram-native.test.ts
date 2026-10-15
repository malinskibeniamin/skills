import { describe, expect, test } from "bun:test";
import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";

interface Element {
  id: string;
  type: string;
  fontFamily?: number;
  fontSize?: number;
  text?: string;
  containerId?: string | null;
  boundElements?: Array<{ id: string; type: string }>;
  label?: unknown;
  x: number;
  y: number;
  width: number;
  height: number;
  backgroundColor?: string;
  points?: Array<[number, number]>;
  startBinding?: { elementId: string } | null;
  endBinding?: { elementId: string } | null;
}

const directory = join(import.meta.dir, "public/diagrams/skills");
const files = [
  ...(await readdir(directory)).filter((file) => file.endsWith(".excalidraw")),
  "../../../../excalidraw-diagram/examples/ai-pipeline/ai-pipeline.excalidraw",
];

describe("published editable diagram contract", () => {
  test("archived skill pages retain their diagram downloads", async () => {
    const references = new Set<string>();
    const pages = new Bun.Glob("content/**/skills/*.md");
    for await (const file of pages.scan({
      cwd: import.meta.dir,
      absolute: true,
    })) {
      const markdown = await readFile(file, "utf8");
      for (const match of markdown.matchAll(
        /\]\((\/diagrams\/skills\/[a-z0-9-]+\.(?:svg|excalidraw))\)/g,
      )) {
        if (match[1]) references.add(match[1]);
      }
    }
    expect(references.size).toBeGreaterThan(0);
    for (const asset of references) {
      const exists = await Bun.file(
        join(import.meta.dir, "public", asset),
      ).exists();
      expect({ asset, exists }).toEqual({ asset, exists: true });
    }
  });
  test("every catalog scene has readable native labels and editable connections", async () => {
    const violations: string[] = [];
    for (const file of files) {
      const scene: { elements: Element[] } = JSON.parse(
        await readFile(join(directory, file), "utf8"),
      );
      const byId = new Map(
        scene.elements.map((element) => [element.id, element]),
      );
      if (byId.size !== scene.elements.length)
        violations.push(`${file}: duplicate IDs`);
      for (const element of scene.elements) {
        const prefix = `${file}:${element.id}`;
        if (element.type === "arrow") {
          for (const binding of [element.startBinding, element.endBinding]) {
            const target = binding && byId.get(binding.elementId);
            if (
              !target?.boundElements?.some(
                (bound) => bound.id === element.id && bound.type === "arrow",
              )
            ) {
              violations.push(`${prefix}: missing native arrow binding`);
            }
          }
        }
        if (element.label !== undefined)
          violations.push(`${prefix}: shorthand`);
        if (element.type !== "text") continue;
        if (element.fontFamily !== 5)
          violations.push(`${prefix}: not Excalifont`);
        const minimum = element.containerId ? 18 : 16;
        if ((element.fontSize ?? 0) < minimum)
          violations.push(`${prefix}: small text`);
        if (element.containerId) {
          const container = byId.get(element.containerId);
          if (
            !container?.boundElements?.some((bound) => bound.id === element.id)
          ) {
            violations.push(`${prefix}: missing reciprocal binding`);
          }
        }
      }
    }
    expect(violations).toEqual([]);
  });
  test("labels stay inside containers and arrows avoid unrelated nodes", async () => {
    const violations: string[] = [];
    for (const file of files) {
      const scene: { elements: Element[] } = JSON.parse(
        await readFile(join(directory, file), "utf8"),
      );
      const byId = new Map(
        scene.elements.map((element) => [element.id, element]),
      );
      for (const element of scene.elements) {
        if (element.containerId) {
          const box = byId.get(element.containerId);
          if (
            !box ||
            element.x < box.x + 5 ||
            element.y < box.y + 5 ||
            element.x + element.width > box.x + box.width - 5 ||
            element.y + element.height > box.y + box.height - 5
          )
            violations.push(`${file}:${element.id}: clipped label`);
        }
        if (element.type !== "arrow" || !element.points) continue;
        const points = element.points.map(
          ([x, y]) => [x + element.x, y + element.y] as const,
        );
        const unrelated = scene.elements.filter(
          (node) =>
            ["rectangle", "diamond", "ellipse"].includes(node.type) &&
            node.id !== "canvas" &&
            node.backgroundColor !== "transparent" &&
            ![
              element.startBinding?.elementId,
              element.endBinding?.elementId,
            ].includes(node.id),
        );
        for (let i = 1; i < points.length; i++) {
          const a = points[i - 1];
          const b = points[i];
          if (!a || !b) continue;
          for (let t = 0; t <= 1; t += 0.025) {
            const x = a[0] + (b[0] - a[0]) * t;
            const y = a[1] + (b[1] - a[1]) * t;
            for (const node of unrelated) {
              const dx = Math.abs(
                (x - node.x - node.width / 2) / (node.width / 2),
              );
              const dy = Math.abs(
                (y - node.y - node.height / 2) / (node.height / 2),
              );
              const inside =
                node.type === "ellipse"
                  ? dx * dx + dy * dy < 0.95
                  : node.type === "diamond"
                    ? dx + dy < 0.95
                    : Math.max(dx, dy) < 0.95;
              if (inside)
                violations.push(`${file}:${element.id}: crosses ${node.id}`);
            }
          }
        }
      }
    }
    expect([...new Set(violations)]).toEqual([]);
  });
  test("pipeline example callouts use editable curves", async () => {
    const scene: { elements: Element[] } = JSON.parse(
      await readFile(
        join(
          import.meta.dir,
          "../excalidraw-diagram/examples/ai-pipeline/ai-pipeline.excalidraw",
        ),
        "utf8",
      ),
    );
    const callouts = scene.elements.filter((element) =>
      [
        "prompt-arrow",
        "mermaid-arrow",
        "direct-arrow",
        "qa-arrow",
        "output-arrow",
      ].includes(element.id),
    );
    expect(callouts).toHaveLength(5);
    for (const arrow of callouts) {
      const [a, b, c] = arrow.points ?? [];
      expect(a && b && c).toBeDefined();
      if (!a || !b || !c)
        throw new Error(`${arrow.id}: missing curve control point`);
      expect(
        Math.abs((b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])),
      ).toBeGreaterThan(1);
    }
  });
});
