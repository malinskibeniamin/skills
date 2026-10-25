import routing from "../config/model-routing.json";

const usage = "Usage: bun run codex:presets [--slots 7,8,9]";
const args = Bun.argv.slice(2);
if (args.length === 1 && args[0] === "--help") {
  console.log(usage);
  process.exit(0);
}

const slots = args.length === 0 ? ["7", "8", "9"] : args[1]?.split(",");
if (
  (args.length !== 0 && (args.length !== 2 || args[0] !== "--slots")) ||
  !slots ||
  slots.length !== 3 ||
  slots.some((slot) => !/^[0-9]$/.test(slot)) ||
  new Set(slots).size !== 3
) {
  console.error(`Choose 3 distinct slots from 0 to 9.\n${usage}`);
  process.exit(1);
}

const presets = [
  {
    label: "Review",
    input:
      "Use the installed frontend-skills review skill to review the current branch against its actual PR base. Work inline in this session. Return evidence-backed, actionable findings with file and line references; do not edit files, commit, push, open a PR, merge, or delegate.",
  },
  {
    label: "Fix locally",
    input:
      "Address the actionable findings from the preceding review in this session using the installed frontend-skills tdd and dogfood skills. Reproduce each defect with a failing public-contract test, make the smallest justified fix, and verify it. Explain unsupported findings and anything not fixed. Stop with local changes: do not commit, push, open a PR, merge, or delegate.",
  },
  {
    label: "Review model",
    input: `/model ${routing.quality_first.review.primary.model} --reasoning=${routing.quality_first.review.primary.effort}`,
  },
];

console.log(
  [
    "# Codex CLI 0.164.0+. Merge only into unused tui.presets slots.",
    "# Preview only: this command does not read or write your Codex config.",
    // Quote numeric table keys for Bun 1.3.14's TOML parser.
    ...presets.map(
      (preset, index) =>
        `\n[tui.presets."${slots[index]}"]\nlabel = ${JSON.stringify(preset.label)}\ninput = ${JSON.stringify(preset.input)}`,
    ),
  ].join("\n"),
);
