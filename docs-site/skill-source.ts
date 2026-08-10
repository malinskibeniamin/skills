import { randomUUID } from "node:crypto";
import { existsSync, watch as watchFiles } from "node:fs";
import {
  mkdir,
  readFile,
  readdir,
  rename,
  rm,
  writeFile,
} from "node:fs/promises";
import { basename, dirname, join, relative } from "node:path";

import { filesystemSource } from "#blume-filesystem";

interface SkillSourceOptions {
  branch: string;
  contentRoot: string;
  repositoryRoot: string;
  repositoryUrl: string;
}

interface SkillDocument {
  body: string;
  description: string;
  name: string;
  sourcePath: string;
}

interface SourceEntry {
  body: { format: "md" | "mdx"; text: string };
  data: PageData;
  editUrl?: string;
  raw?: string;
  ref: string;
  slug?: string;
}

interface PageData {
  [key: string]: unknown;
  description: string;
  sidebar?: { label: string };
  title: string;
  type: "doc" | "skill";
}

const FRONTMATTER = /^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/;
const HEADING = /^\s*#\s+[^\n]+\r?\n+/;
const MARKDOWN_LINK = /(!?\[[^\]]*\]\()([^\s)]+)([^)]*\))/g;
const REMOTE_OR_ROOT_LINK = /^(?:[a-z][a-z\d+.-]*:|#|\/)/i;

const readYamlString = (frontmatter: string, field: string): string => {
  const match = frontmatter.match(new RegExp(`^${field}:[\\t ]*(.+)$`, "m"));
  const raw = match?.[1]?.trim();

  if (!raw) {
    throw new Error(`Skill frontmatter requires a non-empty ${field}.`);
  }
  if (raw.startsWith('"')) {
    try {
      const parsed: unknown = JSON.parse(raw);
      if (typeof parsed === "string" && parsed.length > 0) {
        return parsed;
      }
    } catch (error) {
      throw new Error(`Skill frontmatter has invalid ${field}.`, {
        cause: error,
      });
    }
  }
  if (raw.startsWith("'") && raw.endsWith("'")) {
    return raw.slice(1, -1).replaceAll("''", "'");
  }
  return raw;
};

const parseSkill = (source: string, sourcePath: string): SkillDocument => {
  const frontmatter = source.match(FRONTMATTER);
  if (!frontmatter?.[1]) {
    throw new Error(`${sourcePath} requires YAML frontmatter.`);
  }

  return {
    body: source.slice(frontmatter[0].length).replace(HEADING, ""),
    description: readYamlString(frontmatter[1], "description"),
    name: readYamlString(frontmatter[1], "name"),
    sourcePath,
  };
};

const rewriteRelativeLinks = (
  body: string,
  skill: SkillDocument,
  options: SkillSourceOptions,
): string => {
  const sourceDirectory = basename(dirname(skill.sourcePath));
  let inFence = false;

  return body
    .split("\n")
    .map((line) => {
      if (/^\s*(```|~~~)/.test(line)) {
        inFence = !inFence;
        return line;
      }
      if (inFence) {
        return line;
      }

      return line.replace(
        MARKDOWN_LINK,
        (fullLink, opening: string, target: string, closing: string) => {
          if (REMOTE_OR_ROOT_LINK.test(target)) {
            return fullLink;
          }
          const repositoryPath = join(sourceDirectory, target).replaceAll(
            "\\",
            "/",
          );
          return `${opening}${options.repositoryUrl}/blob/${options.branch}/${repositoryPath}${closing}`;
        },
      );
    })
    .join("\n");
};

const serializePage = (data: PageData, body: string): string => `---
title: ${JSON.stringify(data.title)}
description: ${JSON.stringify(data.description)}
type: ${data.type}
${
  data.sidebar
    ? `sidebar:\n  label: ${JSON.stringify(data.sidebar.label)}\n`
    : ""
}---
${body}`;

const skillDiagram = (skillName: string): string => {
  const diagramBase = `/diagrams/skills/${skillName}`;

  return `![Diagram of the /${skillName} skill](${diagramBase}.svg)

[Open the editable Excalidraw source](${diagramBase}.excalidraw)

`;
};

const loadSkills = async (
  options: SkillSourceOptions,
): Promise<SkillDocument[]> => {
  const directories = await readdir(options.repositoryRoot, {
    withFileTypes: true,
  });
  const skillFiles = directories
    .filter((entry) => entry.isDirectory())
    .map((entry) => join(options.repositoryRoot, entry.name, "SKILL.md"))
    .filter((path) => existsSync(path));

  const skills = await Promise.all(
    skillFiles.map(async (sourcePath) =>
      parseSkill(await readFile(sourcePath, "utf8"), sourcePath),
    ),
  );
  skills.sort((left, right) => left.name.localeCompare(right.name));

  const uniqueNames = new Set(skills.map((skill) => skill.name));
  if (uniqueNames.size !== skills.length) {
    throw new Error("Skill names must be unique before docs can be built.");
  }
  return skills;
};

const landingBody = (skills: SkillDocument[]): string => {
  const searchableSkills = skills.map((skill) => ({
    description: skill.description,
    name: skill.name,
  }));

  return `The frontend-skills harness combines focused instructions with deterministic hooks, so agents can use the right guidance without loading the entire repository into context.

:::tip
Most work starts with an outcome, constraints, verification, and the endpoint. The harness chooses specialist guidance only when the task needs it.
:::

## Find a skill

Browse all ${skills.length} skills. Filter by skill name, technology, or task. Each page is rendered from its canonical \`SKILL.md\`, so the site never drifts from what agents actually use.

<SkillSearch locale="en" skills={${JSON.stringify(searchableSkills)}} />
`;
};

const createEntries = async (
  options: SkillSourceOptions,
): Promise<SourceEntry[]> => {
  const skills = await loadSkills(options);
  const landingData: PageData = {
    description:
      "Practical skills for planning, building, testing, reviewing, and shipping software with coding agents.",
    title: "Agent skills",
    type: "doc",
  };
  const landing = landingBody(skills);
  const landingEntry: SourceEntry = {
    body: { format: "mdx", text: landing },
    data: landingData,
    editUrl: `${options.repositoryUrl}/edit/${options.branch}/docs-site/skill-source.ts`,
    raw: serializePage(landingData, landing),
    ref: "index.mdx",
  };

  return [
    landingEntry,
    ...skills.map((skill): SourceEntry => {
      const data: PageData = {
        description: skill.description,
        sidebar: { label: `/${skill.name}` },
        title: `/${skill.name}`,
        type: "skill",
      };
      const body = `${skillDiagram(skill.name)}${rewriteRelativeLinks(skill.body, skill, options)}`;
      const repositoryPath = relative(
        options.repositoryRoot,
        skill.sourcePath,
      ).replaceAll("\\", "/");

      return {
        body: { format: "md", text: body },
        data,
        editUrl: `${options.repositoryUrl}/edit/${options.branch}/${repositoryPath}`,
        raw: serializePage(data, body),
        ref: `skills/${skill.name}.md`,
        slug: `skills/${skill.name}`,
      };
    }),
  ];
};

const atomicWriteIfChanged = async (
  targetPath: string,
  content: string,
): Promise<void> => {
  if (
    existsSync(targetPath) &&
    (await readFile(targetPath, "utf8")) === content
  ) {
    return;
  }

  await mkdir(dirname(targetPath), { recursive: true });
  const temporaryPath = `${targetPath}.${randomUUID()}.tmp`;
  try {
    await writeFile(temporaryPath, content);
    await rename(temporaryPath, targetPath);
  } finally {
    await rm(temporaryPath, { force: true });
  }
};

const materializeDefaultContent = async (
  options: SkillSourceOptions,
): Promise<void> => {
  const entries = await createEntries(options);
  const expectedSkillFiles = new Set<string>();

  for (const entry of entries) {
    if (!entry.raw) {
      throw new Error(
        `Generated docs entry ${entry.ref} requires raw Markdown.`,
      );
    }
    const targetPath = join(options.contentRoot, entry.ref);
    await atomicWriteIfChanged(targetPath, entry.raw);
    if (entry.ref.startsWith("skills/")) {
      expectedSkillFiles.add(basename(targetPath));
    }
  }

  const skillsDirectory = join(options.contentRoot, "skills");
  for (const entry of await readdir(skillsDirectory, { withFileTypes: true })) {
    if (
      entry.isFile() &&
      entry.name.endsWith(".md") &&
      !expectedSkillFiles.has(entry.name)
    ) {
      await rm(join(skillsDirectory, entry.name));
    }
  }
};

const editUrlFor = (ref: string, options: SkillSourceOptions): string => {
  const normalizedRef = ref.replaceAll("\\", "/");
  const defaultSkill = normalizedRef.match(/^skills\/([^/]+)\.md$/);
  if (defaultSkill) {
    return `${options.repositoryUrl}/edit/${options.branch}/${defaultSkill[1]}/SKILL.md`;
  }
  if (normalizedRef === "index.mdx") {
    return `${options.repositoryUrl}/edit/${options.branch}/docs-site/skill-source.ts`;
  }

  const contentPath = relative(
    options.repositoryRoot,
    join(options.contentRoot, ref),
  ).replaceAll("\\", "/");
  return `${options.repositoryUrl}/edit/${options.branch}/${contentPath}`;
};

const localizeSkillSearch = async (
  entries: Awaited<
    ReturnType<ReturnType<typeof filesystemSource>["load"]>
  >["entries"],
  options: SkillSourceOptions,
): Promise<boolean> => {
  const defaultSkillCount = entries.filter((entry) =>
    entry.ref.startsWith("skills/"),
  ).length;
  const skillsByLocale = new Map<
    string,
    { description: string; name: string }[]
  >();

  for (const entry of entries) {
    const match = entry.ref
      .replaceAll("\\", "/")
      .match(/^([^/]+)\/skills\/([^/]+)\.md$/);
    const description = entry.data.description;
    if (!(match?.[1] && match[2] && typeof description === "string")) {
      continue;
    }
    const skills = skillsByLocale.get(match[1]) ?? [];
    skills.push({ description, name: match[2] });
    skillsByLocale.set(match[1], skills);
  }

  let changed = false;
  for (const [locale, skills] of skillsByLocale) {
    if (skills.length !== defaultSkillCount) {
      continue;
    }
    skills.sort((left, right) => left.name.localeCompare(right.name));
    const targetPath = join(options.contentRoot, locale, "index.mdx");
    if (!existsSync(targetPath)) {
      continue;
    }
    const source = await readFile(targetPath, "utf8");
    const lines = source.split("\n");
    const componentLine = lines.findIndex((line) =>
      line.startsWith("<SkillSearch "),
    );
    if (componentLine === -1) {
      continue;
    }
    lines[componentLine] =
      `<SkillSearch locale="${locale}" skills={${JSON.stringify(skills)}} />`;
    const localized = lines.join("\n");
    if (localized !== source) {
      await atomicWriteIfChanged(targetPath, localized);
      changed = true;
    }
  }
  return changed;
};

export const createSkillSource = (
  sourceOptions: SkillSourceOptions,
): ReturnType<typeof filesystemSource> => {
  const options = {
    ...sourceOptions,
    repositoryUrl: sourceOptions.repositoryUrl.replace(/\/$/, ""),
  };
  const filesystem = filesystemSource({
    exclude: [],
    include: ["**/*.md", "**/*.mdx"],
    name: "skills-harness",
    projectRoot: options.repositoryRoot,
    root: options.contentRoot,
  });

  return {
    ...filesystem,
    load: async () => {
      await materializeDefaultContent(options);
      let result = await filesystem.load();
      if (await localizeSkillSearch(result.entries, options)) {
        result = await filesystem.load();
      }
      return {
        ...result,
        entries: result.entries.map((entry) => ({
          ...entry,
          editUrl: editUrlFor(entry.ref, options),
        })),
      };
    },
    validate: () => {
      if (!existsSync(options.repositoryRoot)) {
        throw new Error(`Repository root not found: ${options.repositoryRoot}`);
      }
      filesystem.validate();
    },
    watch: (onChange) => {
      let timeout: ReturnType<typeof setTimeout> | undefined;
      const notify = () => {
        clearTimeout(timeout);
        timeout = setTimeout(onChange, 50);
      };
      const stopContentWatcher = filesystem.watch(notify);
      const watcher = watchFiles(
        options.repositoryRoot,
        { recursive: true },
        (_event, filename) => {
          if (!filename?.toString().endsWith("SKILL.md")) {
            return;
          }
          notify();
        },
      );
      return () => {
        clearTimeout(timeout);
        stopContentWatcher();
        watcher.close();
      };
    },
  };
};
