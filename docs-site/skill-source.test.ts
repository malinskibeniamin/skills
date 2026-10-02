import { describe, expect, test } from "bun:test";
import { execFileSync } from "node:child_process";
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
  test("dates generated pages from canonical git history, preserving authored dates", async () => {
    const repositoryRoot = await mkdtemp(join(tmpdir(), "skill-history-"));
    const contentRoot = join(repositoryRoot, "docs-site", "content");
    let committedDate = "2026-01-15T12:00:00Z";
    const git = (...args: string[]) =>
      execFileSync("git", ["-C", repositoryRoot, ...args], {
        env: {
          ...Object.fromEntries(
            Object.entries(process.env).filter(
              ([key]) =>
                ![
                  "GIT_COMMON_DIR",
                  "GIT_DIR",
                  "GIT_INDEX_FILE",
                  "GIT_OBJECT_DIRECTORY",
                  "GIT_PREFIX",
                  "GIT_WORK_TREE",
                ].includes(key),
            ),
          ),
          GIT_AUTHOR_DATE: committedDate,
          GIT_COMMITTER_DATE: committedDate,
          GIT_AUTHOR_NAME: "Docs test",
          GIT_AUTHOR_EMAIL: "docs@example.com",
          GIT_COMMITTER_NAME: "Docs test",
          GIT_COMMITTER_EMAIL: "docs@example.com",
        },
        stdio: "pipe",
      });

    try {
      await mkdir(join(repositoryRoot, "sample-skill"));
      await mkdir(join(contentRoot, "pl", "skills"), { recursive: true });
      await writeFile(
        join(repositoryRoot, "sample-skill", "SKILL.md"),
        "---\nname: sample-skill\ndescription: Sample guidance.\n---\n# Sample\n\nGuidance.\n",
      );
      await writeFile(
        join(repositoryRoot, "docs-site", "skill-source.ts"),
        "// Canonical landing and directory source.\n",
      );
      await writeFile(
        join(contentRoot, "pl", "skills", "sample-skill.md"),
        '---\ntitle: Sample\ndescription: Translated guidance.\nlastModified: "2025-12-01"\n---\nGuidance.\n',
      );
      git("init", "--quiet");
      git("add", ".");
      git(
        "-c",
        "core.hooksPath=/dev/null",
        "commit",
        "--quiet",
        "-m",
        "fixture",
      );
      committedDate = "2026-02-02T12:00:00Z";
      await writeFile(
        join(repositoryRoot, "sample-skill", "SKILL.md"),
        "---\nname: sample-skill\ndescription: Updated guidance.\n---\n# Sample\n\nUpdated guidance.\n",
      );
      git("add", "sample-skill/SKILL.md");
      git(
        "-c",
        "core.hooksPath=/dev/null",
        "commit",
        "--quiet",
        "-m",
        "update",
      );
      await writeFile(
        join(contentRoot, "untracked.md"),
        "---\ntitle: Untracked\n---\nNot committed yet.\n",
      );

      const source = createSkillSource({
        branch: "main",
        contentRoot,
        repositoryRoot,
        repositoryUrl: REPOSITORY_URL,
      });
      const { entries } = await source.load();
      expect(
        entries.find((entry) => entry.ref === "skills/sample-skill.md")
          ?.lastModified,
      ).toBe(committedDate);
      for (const ref of ["index.mdx", "skills/index.mdx"]) {
        expect(entries.find((entry) => entry.ref === ref)?.lastModified).toBe(
          "2026-01-15T12:00:00Z",
        );
      }
      expect(
        entries.find((entry) => entry.ref === "pl/skills/sample-skill.md")?.data
          .lastModified,
      ).toBe("2025-12-01");
      expect(
        entries.find((entry) => entry.ref === "untracked.md")?.lastModified,
      ).toBeUndefined();
      expect(
        entries.find((entry) => entry.ref === "skills/sample-skill.md")
          ?.sourcePath,
      ).toBe(join(contentRoot, "skills", "sample-skill.md"));
    } finally {
      await rm(repositoryRoot, { force: true, recursive: true });
    }
  });

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
      contentRoot: join(import.meta.dir, "content"),
      repositoryRoot,
      repositoryUrl: REPOSITORY_URL,
    });

    const { diagnostics, entries } = await source.load();
    const skillEntries = entries.filter(
      (entry) => entry.ref.startsWith("skills/") && entry.data.type === "skill",
    );
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
    expect(landing?.body.text).toContain('<SkillSearch locale="en" skills={');
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
        contentRoot: join(repositoryRoot, "docs-site", "content"),
        repositoryRoot,
        repositoryUrl: REPOSITORY_URL,
      });
      const { entries } = await source.load();
      const page = entries.find(
        (entry) => entry.ref === "skills/sample-skill.md",
      );

      expect(page?.data).toEqual({
        description: 'Use it when a plan needs "proof".',
        related: [],
        search: { boost: 1, keywords: ["sample skill"] },
        sidebar: { label: "/sample-skill" },
        title: "/sample-skill",
        type: "skill",
      });
      expect(page?.sourcePath).toBe(
        join(
          repositoryRoot,
          "docs-site",
          "content",
          "skills",
          "sample-skill.md",
        ),
      );
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

  test("keeps shared include snippets out of published pages", async () => {
    const repositoryRoot = await mkdtemp(join(tmpdir(), "skill-partials-"));
    const contentRoot = join(repositoryRoot, "docs-site", "content");
    try {
      await mkdir(join(repositoryRoot, "sample-skill"));
      await writeFile(
        join(repositoryRoot, "sample-skill", "SKILL.md"),
        "---\nname: sample-skill\ndescription: Sample guidance.\n---\n# Sample\n\nGuidance.\n",
      );
      await mkdir(join(contentRoot, "_snippets"), { recursive: true });
      await writeFile(
        join(contentRoot, "_snippets", "install.md"),
        "Shared commands.\n",
      );
      const { entries } = await createSkillSource({
        branch: "main",
        contentRoot,
        repositoryRoot,
        repositoryUrl: REPOSITORY_URL,
      }).load();

      expect(entries.map((entry) => entry.ref)).not.toContain(
        "_snippets/install.md",
      );
      expect(
        await Bun.file(join(contentRoot, "_snippets", "install.md")).text(),
      ).toBe("Shared commands.\n");
    } finally {
      await rm(repositoryRoot, { force: true, recursive: true });
    }
  });

  test("publishes useful search terms and only existing related skills", async () => {
    const repositoryRoot = await mkdtemp(join(tmpdir(), "skill-discovery-"));
    try {
      for (const name of ["tdd", "review"]) {
        await mkdir(join(repositoryRoot, name));
        await writeFile(
          join(repositoryRoot, name, "SKILL.md"),
          `---\nname: ${name}\ndescription: Guidance for ${name}.\n---\n# ${name}\n\nCanonical ${name} guidance.\n`,
        );
      }
      const source = createSkillSource({
        branch: "main",
        contentRoot: join(repositoryRoot, "docs-site", "content"),
        repositoryRoot,
        repositoryUrl: REPOSITORY_URL,
      });
      const { entries, diagnostics } = await source.load();
      const page = entries.find((entry) => entry.ref === "skills/tdd.md");

      expect(diagnostics).toEqual([]);
      expect(page?.data.search).toEqual({
        boost: 3,
        keywords: ["tdd", "test driven development", "red green refactor"],
      });
      expect(page?.data.related).toEqual(["/skills/review"]);
      expect(page?.raw).toContain('related: ["/skills/review"]');
      expect(page?.body.text).toContain("Canonical tdd guidance.");
      const directory = entries.find(
        (entry) => entry.ref === "skills/index.mdx",
      );
      expect(directory?.editUrl).toBe(
        `${REPOSITORY_URL}/edit/main/docs-site/skill-source.ts`,
      );
      expect(directory?.data.mode).toBe("wide");
      expect(directory?.body.text).toContain("filter skills by name and task");
      expect(page?.data.related).not.toContain("/skills/development-lifecycle");
    } finally {
      await rm(repositoryRoot, { force: true, recursive: true });
    }
  });

  test("materializes translatable filesystem pages from canonical skills", async () => {
    const repositoryRoot = await mkdtemp(join(tmpdir(), "skill-docs-"));
    const contentRoot = join(repositoryRoot, "docs-site", "content");

    try {
      await mkdir(join(repositoryRoot, "sample-skill"), { recursive: true });
      await mkdir(join(contentRoot, "pl", "skills"), { recursive: true });
      await writeFile(
        join(repositoryRoot, "sample-skill", "SKILL.md"),
        `---
name: sample-skill
description: Use it to prove one source of truth.
---
# Sample skill

Canonical guidance.
`,
      );
      await writeFile(
        join(contentRoot, "pl", "skills", "sample-skill.md"),
        `---
description: "Użyj jej, aby potwierdzić jedno źródło prawdy."
sidebar:
  label: "/sample-skill"
title: "/sample-skill"
type: "skill"
---
# Przykładowa umiejętność

Kanoniczne wskazówki.
`,
      );
      await writeFile(
        join(contentRoot, "pl", "index.mdx"),
        `---
title: Umiejętności agentów
description: Praktyczne umiejętności dla agentów programistycznych.
type: doc
---
## Znajdź umiejętność

<SkillSearch locale="en" skills={[{"description":"English description.","name":"sample-skill"}]} />
`,
      );

      const source = createSkillSource({
        branch: "main",
        contentRoot,
        repositoryRoot,
        repositoryUrl: REPOSITORY_URL,
      });
      const { entries } = await source.load();
      const defaultPage = entries.find(
        (entry) => entry.ref === "skills/sample-skill.md",
      );
      const polishPage = entries.find(
        (entry) => entry.ref === "pl/skills/sample-skill.md",
      );

      expect(source.staged).toBe(false);
      expect(source.contentRoot).toBe(contentRoot);
      expect(defaultPage?.sourcePath).toBe(
        join(contentRoot, "skills", "sample-skill.md"),
      );
      expect(
        await Bun.file(join(contentRoot, "skills", "sample-skill.md")).text(),
      ).toContain("Canonical guidance.");
      expect(polishPage?.body.text).toContain("Kanoniczne wskazówki.");
      expect(
        await Bun.file(join(contentRoot, "pl", "index.mdx")).text(),
      ).toContain(
        '<SkillSearch locale="pl" skills={[{"description":"Użyj jej, aby potwierdzić jedno źródło prawdy.","name":"sample-skill"}]} />',
      );
    } finally {
      await rm(repositoryRoot, { force: true, recursive: true });
    }
  });
});
