import { describe, expect, test } from "bun:test";
import { mkdtemp, mkdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { createSkillSource } from "./skill-source.ts";

const REPOSITORY_URL = "https://github.com/malinskibeniamin/skills";

const diagramLayoutSignature = (source: string): string => {
  const scene: unknown = JSON.parse(source);
  if (
    typeof scene !== "object" ||
    scene === null ||
    !("elements" in scene) ||
    !Array.isArray(scene.elements)
  ) {
    throw new Error("Excalidraw scene requires an elements array.");
  }

  return JSON.stringify(
    scene.elements.flatMap((element) => {
      if (
        typeof element !== "object" ||
        element === null ||
        !("type" in element) ||
        element.type === "text" ||
        ("id" in element && element.id === "canvas")
      ) {
        return [];
      }
      return [
        {
          height: "height" in element ? element.height : undefined,
          type: element.type,
          width: "width" in element ? element.width : undefined,
          x: "x" in element ? element.x : undefined,
          y: "y" in element ? element.y : undefined,
        },
      ];
    }),
  );
};

const diagramKind = (source: string): string => {
  const scene: unknown = JSON.parse(source);
  if (
    typeof scene !== "object" ||
    scene === null ||
    !("diagramKind" in scene) ||
    typeof scene.diagramKind !== "string"
  ) {
    throw new Error("Excalidraw scene requires a semantic diagram kind.");
  }
  return scene.diagramKind;
};

const diagramArrowsStartAtOrigin = (source: string): boolean => {
  const scene: unknown = JSON.parse(source);
  if (
    typeof scene !== "object" ||
    scene === null ||
    !("elements" in scene) ||
    !Array.isArray(scene.elements)
  ) {
    throw new Error("Excalidraw scene requires an elements array.");
  }

  return scene.elements
    .filter(
      (element): element is Record<string, unknown> =>
        typeof element === "object" &&
        element !== null &&
        "type" in element &&
        element.type === "arrow",
    )
    .every(
      (arrow) =>
        "points" in arrow &&
        Array.isArray(arrow.points) &&
        Array.isArray(arrow.points[0]) &&
        arrow.points[0][0] === 0 &&
        arrow.points[0][1] === 0,
    );
};

describe("skill docs source", () => {
  test("keeps the ux-copy skill product-neutral", async () => {
    const source = await Bun.file(
      join(import.meta.dir, "..", "ux-copy", "SKILL.md"),
    ).text();

    expect(source).not.toMatch(/redpanda/i);
  });

  test("publishes every canonical skill from its existing SKILL.md", async () => {
    const repositoryRoot = join(import.meta.dir, "..");
    const source = createSkillSource({
      branch: "main",
      repositoryRoot,
      repositoryUrl: REPOSITORY_URL,
    });

    const { diagnostics, entries } = await source.load();
    const skillEntries = entries.filter((entry) => entry.ref !== "index.mdx");
    const diagramKinds = new Set<string>();
    const diagramLayouts = new Map<string, number>();
    const skillNames = skillEntries.map((entry) => entry.data.title);
    const canonicalSkillFiles = await Array.fromAsync(
      new Bun.Glob("*/SKILL.md").scan({
        cwd: repositoryRoot,
        onlyFiles: true,
      }),
    );

    expect(diagnostics).toEqual([]);
    expect(skillNames).toContain("/accessibility");
    expect(skillNames).toContain("/writing-for-agents");
    expect(skillNames).toHaveLength(canonicalSkillFiles.length);
    expect(new Set(skillNames).size).toBe(skillNames.length);

    const landing = entries.find((entry) => entry.ref === "index.mdx");
    expect(landing?.data.type).toBe("doc");
    expect(landing?.body.text).toContain(
      `Browse all ${canonicalSkillFiles.length} skills`,
    );
    expect(landing?.body.text).toContain("<SkillSearch skills={");
    for (const entry of skillEntries) {
      expect(entry.data.type).toBe("skill");
      expect(landing?.body.text).toContain(
        `"name":"${String(entry.data.title).slice(1)}"`,
      );
      expect(entry.data.description).toBeString();
      expect(entry.data.description).not.toHaveLength(0);
      expect(entry.raw).not.toMatch(/^---[\s\S]*?\n---\s*# /);

      const skillName = String(entry.data.title).slice(1);
      const diagramBase = `/diagrams/skills/${skillName}`;
      expect(entry.body.text).toContain(
        `![Diagram of the /${skillName} skill](${diagramBase}.svg)`,
      );
      expect(entry.body.text).toContain(
        `[Open the editable Excalidraw source](${diagramBase}.excalidraw)`,
      );
      const renderedDiagram = Bun.file(
        join(repositoryRoot, "docs-site", "public", `${diagramBase}.svg`),
      );
      const editableDiagram = Bun.file(
        join(
          repositoryRoot,
          "docs-site",
          "public",
          `${diagramBase}.excalidraw`,
        ),
      );
      expect(await renderedDiagram.exists()).toBe(true);
      expect(await editableDiagram.exists()).toBe(true);
      const editableSource = await editableDiagram.text();
      expect(editableSource).toContain(`"text": "/${skillName}"`);
      expect(diagramArrowsStartAtOrigin(editableSource)).toBe(true);
      const kind = diagramKind(editableSource);
      diagramKinds.add(kind);
      if (kind === "entity-relationship") {
        expect(editableSource).not.toContain(
          `"text": "identity\\nrelationships"`,
        );
      }
      expect(await renderedDiagram.text()).toContain(
        `<title>${kind.replaceAll("-", " ")} diagram for the /${skillName} skill</title>`,
      );
      const signature = diagramLayoutSignature(editableSource);
      diagramLayouts.set(signature, (diagramLayouts.get(signature) ?? 0) + 1);
    }
    expect(diagramLayouts.size).toBeGreaterThanOrEqual(12);
    expect(Math.max(...diagramLayouts.values())).toBeLessThanOrEqual(12);
    expect([...diagramKinds]).toEqual(
      expect.arrayContaining([
        "architecture",
        "dependency-graph",
        "entity-relationship",
        "hierarchy",
        "sequence",
        "state-machine",
        "swimlane",
        "user-flow",
      ]),
    );
  });

  test("keeps quoted metadata and points relative references at GitHub", async () => {
    const repositoryRoot = await mkdtemp(join(tmpdir(), "skill-docs-"));

    try {
      const skillDirectory = join(repositoryRoot, "sample-skill");
      await mkdir(skillDirectory);
      await writeFile(
        join(skillDirectory, "SKILL.md"),
        `---
name: sample-skill
description: "Use it when a plan needs \\"proof\\"."
---
# Sample skill

Read [REFERENCE.md](REFERENCE.md) before acting.
`,
      );

      const source = createSkillSource({
        branch: "next",
        repositoryRoot,
        repositoryUrl: REPOSITORY_URL,
      });
      const { entries } = await source.load();
      const page = entries.find((entry) => entry.ref !== "index.mdx");

      expect(page?.data).toEqual({
        description: 'Use it when a plan needs "proof".',
        sidebar: { label: "/sample-skill" },
        title: "/sample-skill",
        type: "skill",
      });
      expect(page?.slug).toBe("skills/sample-skill");
      expect(page?.body.text).toContain(
        `${REPOSITORY_URL}/blob/next/sample-skill/REFERENCE.md`,
      );
      expect(page?.editUrl).toBe(
        `${REPOSITORY_URL}/edit/next/sample-skill/SKILL.md`,
      );
    } finally {
      await rm(repositoryRoot, { force: true, recursive: true });
    }
  });
});
