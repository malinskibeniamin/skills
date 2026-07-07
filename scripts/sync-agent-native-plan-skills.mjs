#!/usr/bin/env node
import { cp, mkdir, readdir, readFile, stat, unlink, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptPath = fileURLToPath(import.meta.url);
const repoRoot = path.resolve(path.dirname(scriptPath), "..");
const defaultFrameworkPath = path.resolve(repoRoot, "../agent-native/framework");
const args = process.argv.slice(2);
const check = args.includes("--check");
const sourceArg = args.find((arg) => arg !== "--check");
const requestedSource =
  sourceArg ||
  process.env.AGENT_NATIVE_PLAN_SKILLS_SOURCE ||
  process.env.AGENT_NATIVE_FRAMEWORK_PATH ||
  defaultFrameworkPath;

function normalizeMarkdown(text) {
  return text
    .replaceAll("—", "--")
    .replaceAll("–", "-")
    .replaceAll("→", "->")
    .replaceAll("←", "<-")
    .replaceAll("…", "...")
    .replaceAll("‘", "'")
    .replaceAll("’", "'")
    .replaceAll("“", "\"")
    .replaceAll("”", "\"");
}

function hasSkill(dir) {
  return existsSync(path.join(dir, "SKILL.md"));
}

function resolveSources(sourcePath) {
  const source = path.resolve(sourcePath);
  const candidates = [
    {
      label: "direct skills directory",
      visualPlan: path.join(source, "visual-plan"),
      visualRecap: path.join(source, "visual-recap"),
    },
    {
      label: "repo skills directory",
      visualPlan: path.join(source, "skills", "visual-plan"),
      visualRecap: path.join(source, "skills", "visual-recap"),
    },
    {
      label: "Agent-Native visual plans plugin",
      visualPlan: path.join(source, ".agents/plugins/agent-native-visual-plans/skills/visual-plan"),
      visualRecap: path.join(source, ".agents/plugins/agent-native-visual-plans/skills/visual-recap"),
    },
    {
      label: "legacy framework skills",
      visualPlan: path.join(source, "skills", "visual-plans"),
      visualRecap: path.join(source, "skills", "visual-recap"),
    },
  ];

  const match = candidates.find(
    (candidate) => hasSkill(candidate.visualPlan) && hasSkill(candidate.visualRecap),
  );
  if (!match) {
    const checked = candidates
      .map((candidate) => `- ${candidate.label}: ${candidate.visualPlan} and ${candidate.visualRecap}`)
      .join("\n");
    throw new Error(`Could not find visual-plan and visual-recap from ${source}.\nChecked:\n${checked}`);
  }
  return match;
}

async function listFiles(dir, prefix = "") {
  if (!existsSync(dir)) return [];
  const out = [];
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const rel = prefix ? `${prefix}/${entry.name}` : entry.name;
    const abs = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...(await listFiles(abs, rel)));
    else if (entry.isFile()) out.push(rel);
  }
  return out.sort();
}

async function clearMarkdownFiles(dir) {
  if (!existsSync(dir)) return;
  for (const rel of await listFiles(dir)) {
    if (rel.endsWith(".md")) await unlink(path.join(dir, rel));
  }
}

function destinationFor(name) {
  const referenceName = name === "visual-plan" ? "agent-native-plan.md" : "agent-native-recap.md";
  return {
    root: path.join(repoRoot, name),
    refs: path.join(repoRoot, name, "references"),
    upstreamSkill: path.join(repoRoot, name, "references", referenceName),
  };
}

async function syncSkill(name, sourceDir) {
  const destination = destinationFor(name);
  const sourceRefs = path.join(sourceDir, "references");
  await mkdir(destination.refs, { recursive: true });
  await clearMarkdownFiles(destination.refs);
  await writeFile(
    destination.upstreamSkill,
    normalizeMarkdown(await readFile(path.join(sourceDir, "SKILL.md"), "utf8")),
  );
  if (existsSync(sourceRefs)) {
    for (const rel of await listFiles(sourceRefs)) {
      const from = path.join(sourceRefs, rel);
      const to = path.join(destination.refs, rel);
      await mkdir(path.dirname(to), { recursive: true });
      await writeFile(to, normalizeMarkdown(await readFile(from, "utf8")));
    }
  }
  console.log(`Synced ${name} upstream references`);
}

async function assertCurrent(name, sourceDir) {
  const destination = destinationFor(name);
  if (!existsSync(destination.upstreamSkill)) throw new Error(`${name} upstream reference missing`);
  const sourceSkill = normalizeMarkdown(await readFile(path.join(sourceDir, "SKILL.md"), "utf8"));
  const destinationSkill = await readFile(destination.upstreamSkill, "utf8");
  if (sourceSkill !== destinationSkill) throw new Error(`${name} upstream SKILL reference is out of sync`);

  const sourceRefs = path.join(sourceDir, "references");
  const sourceFiles = existsSync(sourceRefs) ? await listFiles(sourceRefs) : [];
  const destFiles = (await listFiles(destination.refs)).filter(
    (rel) => rel !== path.basename(destination.upstreamSkill),
  );
  if (sourceFiles.join("\n") !== destFiles.join("\n")) {
    throw new Error(`${name} reference file list is out of sync`);
  }
  for (const rel of sourceFiles) {
    const sourceStat = await stat(path.join(sourceRefs, rel));
    if (!sourceStat.isFile()) continue;
    const [sourceBody, destinationBody] = await Promise.all([
      readFile(path.join(sourceRefs, rel), "utf8").then(normalizeMarkdown),
      readFile(path.join(destination.refs, rel), "utf8"),
    ]);
    if (sourceBody !== destinationBody) throw new Error(`${name}/references/${rel} is out of sync`);
  }
  console.log(`${name} upstream references are current`);
}

try {
  const sources = resolveSources(requestedSource);
  console.log(`Using ${sources.label}`);
  if (check) {
    await assertCurrent("visual-plan", sources.visualPlan);
    await assertCurrent("visual-recap", sources.visualRecap);
  } else {
    await syncSkill("visual-plan", sources.visualPlan);
    await syncSkill("visual-recap", sources.visualRecap);
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
