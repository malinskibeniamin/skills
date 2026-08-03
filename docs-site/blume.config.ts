import { fileURLToPath } from "node:url";

import { defineConfig } from "blume";

import { createSkillSource } from "./skill-source.ts";

const repositoryRoot = fileURLToPath(new URL("../", import.meta.url));

export default defineConfig({
  ai: {
    llmsTxt: true,
  },
  content: {
    sources: [
      {
        source: createSkillSource({
          branch: "main",
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
});
