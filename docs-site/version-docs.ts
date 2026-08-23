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

const pinSnapshotLinks = async (version: string): Promise<void> => {
  const snapshotRoot = join(import.meta.dir, "content", version);
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

const run = async (): Promise<void> => {
  const arguments_ = Bun.argv.slice(2);
  const blume = Bun.which("blume");
  if (!blume) {
    throw new Error("Blume executable not found. Run bun install first.");
  }

  const version = versionIdFromArguments(arguments_);
  const child = Bun.spawn([blume, "version", ...arguments_], {
    cwd: import.meta.dir,
    env: Bun.env,
    stderr: "inherit",
    stdin: "inherit",
    stdout: "inherit",
  });
  const exitCode = await child.exited;
  if (exitCode === 0 && version) {
    await pinSnapshotLinks(version);
  }
  process.exitCode = exitCode;
};

if (import.meta.main) {
  await run();
}
