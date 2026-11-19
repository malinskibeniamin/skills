#!/usr/bin/env bun
import { runWikiCli } from "../../../wiki/scripts/wiki.ts";
import { doctor } from "./doctor.ts";

const help = `Usage: bao <command>

Commands:
  wiki     Initialize, ingest, search, read, or lint local wiki pages
  repo     Add or list local repository pointers
  doctor   Check the local Codex installation and sign-in without starting a turn

Examples:
  bao wiki --home .context/wiki-home search "home repo"
  bao repo --home .context/wiki-home list
  bao doctor --json

Coding runs are not available in this release.`;

const [command, ...args] = Bun.argv.slice(2);

if (command === undefined || command === "--help" || command === "-h") {
  console.log(help);
} else if (command === "wiki") {
  await runWikiCli(args, "bao wiki");
} else if (command === "repo") {
  if (args.length === 0 || args[0] === "--help" || args[0] === "-h") {
    console.log(`Usage: bao repo --home <path> <add|list>

Examples:
  bao repo --home .context/wiki-home list
  bao repo --home .context/wiki-home add app --path /path/to/app --summary "App"
`);
  } else {
    await runWikiCli(["repo", ...args], "bao wiki");
  }
} else if (command === "doctor") {
  if (args.length === 1 && ["--help", "-h"].includes(args[0] ?? "")) {
    console.log("Usage: bao doctor [--json]\n\nExample: bao doctor --json");
  } else if (args.length === 0 || (args.length === 1 && args[0] === "--json")) {
    const result = await doctor();
    console.log(args[0] === "--json" ? JSON.stringify(result) : result.message);
    if (!result.ok) process.exitCode = 1;
  } else {
    console.error("Usage: bao doctor [--json]");
    process.exitCode = 2;
  }
} else {
  console.error(`bao: unknown command '${command}'. Run bao --help.`);
  process.exitCode = 2;
}
