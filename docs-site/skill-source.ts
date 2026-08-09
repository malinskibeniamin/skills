import { existsSync, watch as watchFiles } from "node:fs";
import { readFile, readdir } from "node:fs/promises";
import { basename, dirname, join, relative } from "node:path";

interface SkillSourceOptions {
  branch: string;
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

interface SkillContentSource {
  load: () => Promise<{ diagnostics: never[]; entries: SourceEntry[] }>;
  name: string;
  read: (ref: string) => Promise<string>;
  staged: true;
  validate: () => void;
  watch: (onChange: () => void) => () => void;
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

<SkillSearch skills={${JSON.stringify(searchableSkills)}} />
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

export const createSkillSource = (
  sourceOptions: SkillSourceOptions,
): SkillContentSource => {
  const options = {
    ...sourceOptions,
    repositoryUrl: sourceOptions.repositoryUrl.replace(/\/$/, ""),
  };

  return {
    load: async () => ({
      diagnostics: [],
      entries: await createEntries(options),
    }),
    name: "skills-harness",
    read: async (ref) => {
      const entry = (await createEntries(options)).find(
        (candidate) => candidate.ref === ref,
      );
      if (!entry) {
        throw new Error(`Unknown skill docs entry: ${ref}`);
      }
      return entry.raw ?? entry.body.text;
    },
    staged: true,
    validate: () => {
      if (!existsSync(options.repositoryRoot)) {
        throw new Error(`Repository root not found: ${options.repositoryRoot}`);
      }
    },
    watch: (onChange) => {
      let timeout: ReturnType<typeof setTimeout> | undefined;
      const watcher = watchFiles(
        options.repositoryRoot,
        { recursive: true },
        (_event, filename) => {
          if (!filename?.toString().endsWith("SKILL.md")) {
            return;
          }
          clearTimeout(timeout);
          timeout = setTimeout(onChange, 50);
        },
      );
      return () => {
        clearTimeout(timeout);
        watcher.close();
      };
    },
  };
};
