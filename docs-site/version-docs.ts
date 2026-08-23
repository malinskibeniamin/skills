import { existsSync } from "node:fs";
import { readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

const MAIN_REPOSITORY_LINK =
  "https://github.com/malinskibeniamin/skills/blob/main/";

export const versionIdFromArguments = (
  arguments_: string[],
): string | undefined =>
  arguments_.find((argument) => !argument.startsWith("-"));

export const pinSnapshotLinksInText = (
  source: string,
  version: string,
): string =>
  source.replaceAll(
    MAIN_REPOSITORY_LINK,
    `https://github.com/malinskibeniamin/skills/blob/${version}/`,
  );

const pinSnapshotLinks = async (
  root: string,
  version: string,
): Promise<void> => {
  const snapshotRoot = join(root, "content", version);
  const snapshotFiles = new Bun.Glob("**/*.{md,mdx}").scan({
    absolute: true,
    cwd: snapshotRoot,
  });

  for await (const snapshotFile of snapshotFiles) {
    const source = await readFile(snapshotFile, "utf8");
    const pinned = pinSnapshotLinksInText(source, version);
    if (pinned !== source) {
      await writeFile(snapshotFile, pinned);
    }
  }
};

export const runVersionDocs = async ({
  arguments_,
  blume,
  root,
}: {
  arguments_: string[];
  blume: string;
  root: string;
}): Promise<number> => {
  const version = versionIdFromArguments(arguments_);
  const validVersion = version?.match(/^[A-Za-z][A-Za-z0-9._-]*$/u);

  if (version && validVersion && existsSync(join(root, "content", version))) {
    process.stderr.write(
      '[docs:version] Snapshot already exists: "' +
        version +
        '". Archived docs are immutable; choose a new version.\n',
    );
    return 1;
  }

  const child = Bun.spawn([blume, "version", ...arguments_], {
    cwd: root,
    env: Bun.env,
    stderr: "inherit",
    stdin: "inherit",
    stdout: "inherit",
  });
  const exitCode = await child.exited;
  if (exitCode === 0 && version) {
    await pinSnapshotLinks(root, version);
  }
  return exitCode;
};

const run = async (): Promise<void> => {
  const blume = Bun.which("blume");
  if (!blume) {
    throw new Error("Blume executable not found. Run bun install first.");
  }

  process.exitCode = await runVersionDocs({
    arguments_: Bun.argv.slice(2),
    blume,
    root: import.meta.dir,
  });
};

if (import.meta.main) {
  await run();
}
