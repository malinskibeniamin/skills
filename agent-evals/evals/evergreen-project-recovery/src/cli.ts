import { readFileSync } from "node:fs";
import { z } from "zod";
import { projectHealth } from "./health";

const ISO_DATE_PATTERN = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z$/;
const IsoDateSchema = z
  .string()
  .regex(ISO_DATE_PATTERN)
  .refine((value) => !Number.isNaN(Date.parse(value)), {
    message: "expected an ISO date",
  });
const ProjectFixtureSchema = z.object({
  name: z.string().min(1),
  cutoff: IsoDateSchema,
  items: z.array(
    z.object({
      status: z.enum(["active", "blocked", "completed"]),
      updatedAt: IsoDateSchema,
    }),
  ),
});

const fixturePath = process.argv[2];
if (fixturePath === undefined) {
  throw new Error("usage: bun run src/cli.ts <fixture>");
}

const fixture = ProjectFixtureSchema.parse(
  JSON.parse(readFileSync(fixturePath, "utf8")),
);
console.log(`${fixture.name}: ${projectHealth(fixture.items, fixture.cutoff)}`);
