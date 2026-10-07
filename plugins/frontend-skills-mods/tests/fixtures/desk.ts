import type { On, RenderPropsOf } from "claude-code";

export const paneProps: RenderPropsOf["Pane"] = {
  title: "Harness",
  isFocused: true,
  bodyColumns: 80,
  placement: "dock",
  scroll: { offset: 0, bodyRows: 20 },
  view: {},
};

export function deskFixture(on: On) {
  const git = {
    hash: "a".repeat(40),
    available: true,
    truncated: false,
    fileCount: 1,
    untracked: false,
    isLink: false,
    size: 100,
  };
  const opened: string[] = [];
  const commands: string[] = [];
  on("session.start", (_$, e) => ({ cwd: e.cwd }));
  on("session.cwd", () => ({ value: "/work" }));
  on("session.usage", () => ({
    value: { startedAt: 0, context: { window: 200_000 }, rateLimits: [] },
  }));
  on("command.register", (_$, e) => {
    commands.push(e.name);
    return { value: { command: e.name } };
  });
  on("ui.open", (_$, e) => {
    opened.push(e.id);
    return { value: { isPlaced: true } };
  });
  on("ui.close", () => ({ value: undefined }));
  on("process.run", (_$, e) => ({
    value: {
      exitCode: git.available ? 0 : 1,
      stdout: e.argv.includes("--show-toplevel")
        ? "/work\n"
        : e.argv.includes("rev-parse")
          ? `${"0".repeat(40)}\n`
          : e.argv.includes("--diff-filter=D")
            ? ""
            : e.argv.includes("--name-only")
              ? Array.from(
                  { length: git.fileCount },
                  (_, i) => `src/app-${i}.ts\0`,
                ).join("")
              : e.argv.includes("hash-object")
                ? `${git.hash}\n`.repeat(
                    git.fileCount + (git.untracked ? 1 : 0),
                  )
                : git.untracked
                  ? "new.ts\0"
                  : "",
      stderr: "",
      isStdoutTruncated: git.truncated,
      isStderrTruncated: false,
    },
  }));
  on("fs.stat", () => ({
    value: { kind: "file", size: git.size, mtimeMs: 0, isLink: git.isLink },
  }));
  return { git, opened, commands };
}
