import { fileURLToPath } from "node:url";

import { defineConfig, type ComponentMarkdown } from "blume";

import { serializeSkillSearchMarkdown } from "./skill-search.ts";
import { createSkillSource } from "./skill-source.ts";

const repositoryRoot = fileURLToPath(new URL("../", import.meta.url));
const contentRoot = fileURLToPath(new URL("./content", import.meta.url));
const skillSearchMarkdown: ComponentMarkdown = ({ lossy, props }) => {
  if (lossy) {
    return null;
  }

  const locale = typeof props.locale === "string" ? props.locale : "en";
  return serializeSkillSearchMarkdown(props.skills, locale);
};

export default defineConfig({
  ai: {
    llmsTxt: true,
    markdownComponents: {
      SkillSearch: skillSearchMarkdown,
    },
    skills: "..",
  },
  content: {
    root: "./content",
    sources: [
      {
        source: createSkillSource({
          branch: "main",
          contentRoot,
          repositoryRoot,
          repositoryUrl: "https://github.com/malinskibeniamin/skills",
        }),
        type: "custom",
      },
    ],
  },
  description:
    "Practical skills for planning, building, testing, reviewing, and shipping software with coding agents.",
  github: {
    branch: "main",
    owner: "malinskibeniamin",
    repo: "skills",
  },
  i18n: {
    defaultLocale: "en",
    locales: [
      { code: "en", label: "English" },
      {
        code: "zh-CN",
        label: "简体中文",
        style:
          "Simplified Chinese in modern standard Mandarin, using mainland Chinese technical terminology.",
      },
      {
        code: "zh-TW",
        label: "繁體中文",
        style:
          "Traditional Chinese in modern standard Mandarin, using Taiwanese technical terminology.",
      },
      {
        code: "pl",
        label: "Polski",
        style:
          "Natural, concise Polish for professional technical documentation.",
      },
    ],
  },
  logo: {
    text: "Agent skills",
  },
  navigation: {
    sidebar: {
      display: "page",
    },
  },
  search: {
    popular: [
      {
        href: "/skills/development-lifecycle",
        icon: "workflow",
        label: "Development lifecycle",
      },
      {
        href: "/skills/review",
        icon: "scan-search",
        label: "Review",
      },
      {
        href: "/skills/tdd",
        icon: "test-tube-diagonal",
        label: "TDD",
      },
    ],
  },
  theme: {
    accent: "green",
    radius: "lg",
  },
  title: "Agent skills",
  versions: {
    archived: [{ id: "v4.38.0" }, { id: "v4.37.0" }],
    current: { badge: "Latest", label: "main" },
  },
});
