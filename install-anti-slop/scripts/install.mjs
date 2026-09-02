#!/usr/bin/env node
import {
  cpSync,
  existsSync,
  mkdirSync,
  readFileSync,
  realpathSync,
  rmSync,
} from "node:fs";
import { dirname, isAbsolute, join, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

const skillRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const profiles = {
  biome: {
    destination: "tools/biome/anti-slop",
    marker: "no-chained-type-assertions.grit",
    source: resolve(skillRoot, "assets/biome"),
  },
  oxlint: {
    destination: "tools/oxlint/anti-slop",
    marker: "index.ts",
    source: resolve(skillRoot, "assets/anti-slop"),
  },
};

function isOutside(root, candidate) {
  const relativeCandidate = relative(root, candidate);
  return (
    relativeCandidate === ".." ||
    relativeCandidate.startsWith(`..${sep}`) ||
    isAbsolute(relativeCandidate)
  );
}

function isAntiSlopInstallation(target, marker) {
  const markerPath = join(target, marker);
  if (!existsSync(markerPath)) return false;
  return readFileSync(markerPath, "utf8").includes("anti-slop");
}

/**
 * Copy a curated anti-slop profile into a repository.
 *
 * @param {{ cwd?: string; destination?: string; force?: boolean; linter?: "biome" | "oxlint" }} [options]
 * @returns {string} Absolute installed path.
 */
export function installAntiSlop({
  cwd = process.cwd(),
  destination,
  force = false,
  linter = "oxlint",
} = {}) {
  if (linter !== "biome" && linter !== "oxlint") {
    throw new Error(`Unsupported anti-slop linter: ${linter}`);
  }
  const profile = profiles[linter];
  const root = realpathSync(resolve(cwd));
  const target = resolve(root, destination ?? profile.destination);
  const relativeTarget = relative(root, target);
  let existingParent = dirname(target);
  while (!existsSync(existingParent)) existingParent = dirname(existingParent);

  if (
    relativeTarget === "" ||
    isOutside(root, target) ||
    isOutside(root, realpathSync(existingParent))
  ) {
    throw new Error(
      "Anti-slop must be installed inside the target repository.",
    );
  }
  if (existsSync(target)) {
    if (!force) {
      throw new Error(
        `Refusing to overwrite ${target}. Re-run with --force only after reviewing the existing files.`,
      );
    }
    if (!isAntiSlopInstallation(target, profile.marker)) {
      throw new Error(
        `${target} does not look like an anti-slop installation.`,
      );
    }
    rmSync(target, { recursive: true });
  }

  mkdirSync(dirname(target), { recursive: true });
  cpSync(profile.source, target, { recursive: true, force });
  return target;
}

const invokedPath =
  process.argv[1] === undefined ? null : resolve(process.argv[1]);
if (invokedPath === fileURLToPath(import.meta.url)) {
  const arguments_ = process.argv.slice(2);
  const destination = arguments_.find((argument) => !argument.startsWith("--"));
  const linter = arguments_.includes("--biome") ? "biome" : "oxlint";
  try {
    const target = installAntiSlop({
      destination,
      force: arguments_.includes("--force"),
      linter,
    });
    console.log(`Copied the anti-slop profile to ${target}`);
    console.log(
      linter === "biome"
        ? `Configure Biome plugins from: ${target}`
        : `Configure Oxlint with: ${target}/index.ts`,
    );
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  }
}
