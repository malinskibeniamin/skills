import { spawnSync } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";

const checks = ["test", "lint:fix", "type:check"].map((check) => {
  const result = spawnSync("bun", ["run", check], { stdio: "inherit" });
  return { check, status: result.status === 0 ? "passed" : "failed" };
});
const receipt = {
  checks,
  local: checks.every((check) => check.status === "passed")
    ? "passed"
    : "failed",
  live: "blocked",
  reason: "Live application is not provisioned in this workspace.",
};
mkdirSync(".verification", { recursive: true });
writeFileSync(".verification/receipt.json", JSON.stringify(receipt, null, 2));
console.log(JSON.stringify(receipt, null, 2));
process.exit(receipt.local === "failed" ? 1 : 2);
