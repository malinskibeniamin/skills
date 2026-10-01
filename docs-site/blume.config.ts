import { fileURLToPath } from "node:url";

import { defineConfig, type ComponentMarkdown } from "blume";
import { custom } from "blume/sources";

import { serializeSkillSearchMarkdown } from "./skill-search.ts";
import { createSkillSource } from "./skill-source.ts";

const repositoryRoot = fileURLToPath(new URL("../", import.meta.url));
const contentRoot = fileURLToPath(new URL("./content", import.meta.url));
// Optional canonical origin; Blume validates the URL before building.
const siteUrl = process.env.BLUME_SITE_URL;
const skillSearchMarkdown: ComponentMarkdown = ({ lossy, props }) => {
  if (lossy) {
    return null;
  }

  const locale = typeof props.locale === "string" ? props.locale : "en";
  return serializeSkillSearchMarkdown(props.skills, locale);
};

export default defineConfig({
  ...(siteUrl ? { deployment: { site: siteUrl } } : {}),
  agents: {
    llmsTxt: true,
    markdownComponents: {
      SkillSearch: skillSearchMarkdown,
    },
    skills: "..",
  },
  content: {
    sources: [
      custom(
        createSkillSource({
          branch: "main",
          contentRoot,
          repositoryRoot,
          repositoryUrl: "https://github.com/malinskibeniamin/skills",
        }),
      ),
    ],
  },
  description:
    "Practical skills for planning, building, testing, reviewing, and shipping software with coding agents.",
  github: {
    branch: "main",
    owner: "malinskibeniamin",
    repo: "skills",
  },
  footer: {
    links: [
      {
        href: "/getting-started",
        label: {
          en: "Get started",
          "zh-CN": "开始使用",
          "zh-TW": "開始使用",
          pl: "Pierwsze kroki",
        },
      },
      {
        href: "https://github.com/malinskibeniamin/skills/issues",
        label: {
          en: "Report an issue",
          "zh-CN": "报告问题",
          "zh-TW": "回報問題",
          pl: "Zgłoś problem",
        },
      },
    ],
  },
  i18n: {
    defaultLocale: "en",
    routeByBrowserLanguage: true,
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
  markdown: {
    code: { wrap: true },
  },
  narration: true,
  navigation: {
    cta: {
      href: "/getting-started",
      label: {
        en: "Get started",
        "zh-CN": "开始使用",
        "zh-TW": "開始使用",
        pl: "Pierwsze kroki",
      },
    },
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
  seo: {
    metatags: { "application-name": "Agent skills" },
  },
  theme: {
    accent: "green",
    radius: "lg",
  },
  title: "Agent skills",
  variables: {
    marketplace: "malinskibeniamin/skills",
    "repository-url": "https://github.com/malinskibeniamin/skills",
  },
  versions: {
    archived: [{ id: "v4.39.0" }, { id: "v4.38.0" }, { id: "v4.37.0" }],
    current: { badge: "Latest", label: "main" },
  },
});
