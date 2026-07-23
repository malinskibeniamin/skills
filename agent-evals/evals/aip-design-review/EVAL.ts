import { existsSync, readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

const read = (path: string) => readFileSync(path, "utf8");

const publishedAips = [
  1, 2, 3, 8, 9, 100, 111, 121, 122, 123, 124, 126, 127, 128, 129, 130, 131,
  132, 133, 134, 135, 136, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149,
  151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165,
  180, 181, 182, 185, 190, 191, 192, 193, 194, 200, 202, 203, 205, 210, 211,
  213, 214, 215, 216, 217, 231, 233, 234, 235, 236,
];

const requiredAips = [
  111, 121, 122, 123, 127, 130, 131, 132, 133, 134, 136, 140, 142, 148, 154,
  158, 161, 180, 181, 192, 203, 214,
];

const aipRow = (review: string, aip: number) =>
  review.split("\n").find((line) => {
    const firstCell = line.split("|")[1];
    return (
      firstCell !== undefined &&
      new RegExp(`(?:AIP-)?${aip}\\b`, "i").test(firstCell)
    );
  });

describe("aip-design-review: applies the skill to an adversarial API", () => {
  it("creates both requested deliverables", () => {
    expect(existsSync("review.md")).toBe(true);
    expect(existsSync("corrected.proto")).toBe(true);
  });

  it("uses the required evidence table and exact official sources", () => {
    const review = read("review.md");
    expect(review).toMatch(
      /AIP\s*\|\s*state\s*\|\s*applicability\s*\|\s*result\s*\|\s*evidence\/exception/i,
    );
    for (const aip of requiredAips) {
      const row = aipRow(review, aip);
      expect(row, `missing evidence row for AIP-${aip}`).toBeDefined();
      expect(row).toMatch(/approved/i);
      expect(row).not.toMatch(/\|\s*not applicable\s*\|/i);
      expect(review).toContain(`https://google.aip.dev/${aip}`);
    }
  });

  it("accounts for all 72 published General AIPs", () => {
    const review = read("review.md");
    const accounted = review.split("\n").flatMap((line) => {
      const match = line.startsWith("|")
        ? line.split("|")[1]?.match(/(?:AIP-)?(\d+)\b/i)
        : undefined;
      return match?.[1] ? [Number(match[1])] : [];
    });
    expect(accounted).toHaveLength(publishedAips.length);
    expect([...accounted].sort((a, b) => a - b)).toEqual(publishedAips);
  });

  it("keeps draft and reviewing guidance advisory", () => {
    const review = read("review.md");
    for (const aip of [162, 182]) {
      const row = aipRow(review, aip);
      expect(row, `missing evidence row for AIP-${aip}`).toBeDefined();
      expect(row).toMatch(aip === 162 ? /draft/i : /reviewing/i);
      expect(row).toMatch(/advisory/i);
      expect(row).not.toMatch(/\|\s*(?:fail|blocker)\s*\|/i);
      expect(review).toContain(`https://google.aip.dev/${aip}`);
    }
    const proto = read("corrected.proto");
    expect(proto).not.toMatch(/revision_alias|BookRevision|RollbackBook/i);
    expect(proto).toMatch(/string\s+software_version\s*=/);
  });

  it("flags the stable field rename as a compatibility failure", () => {
    const row = aipRow(read("review.md"), 180);
    expect(row).toMatch(/fail|incompatible|violation/i);
    expect(read("review.md")).toMatch(
      /title.*display_name|display_name.*title/is,
    );
    const proto = read("corrected.proto");
    expect(proto).toMatch(/string\s+title\s*=\s*2\b/);
    expect(proto).not.toMatch(/string\s+display_name\s*=\s*2\b/);
  });

  it("classifies the data plane instead of blindly applying resource methods", () => {
    const review = read("review.md");
    expect(review).toMatch(/EventIngressService|PublishEvent/i);
    expect(review).toMatch(/data[- ]plane/i);
    expect(review).toMatch(/not applicable|conditional|exception/i);
    expect(read("corrected.proto")).toMatch(/rpc\s+PublishEvent\s*\(/);
  });

  it("corrects resource identity and freshness semantics", () => {
    const proto = read("corrected.proto");
    expect(proto).toMatch(
      /string\s+name\s*=\s*1\s*\[[^\]]*field_behavior[^\]]*=\s*IDENTIFIER[^\]]*\]\s*;/s,
    );
    expect(proto).not.toMatch(
      /string\s+name\s*=\s*1\s*\[[^\]]*field_behavior[^\]]*=\s*OUTPUT_ONLY/s,
    );
    expect(proto).toMatch(/string\s+etag\s*=\s*\d+\s*;/);
    expect(proto).not.toMatch(
      /string\s+etag\s*=\s*\d+\s*\[[^\]]*field_behavior/s,
    );
  });

  it("keeps update_mask optional with current omission semantics", () => {
    const proto = read("corrected.proto");
    const mask = proto.match(
      /google\.protobuf\.FieldMask\s+update_mask\s*=\s*\d+[\s\S]*?;/,
    )?.[0];
    expect(mask).toBeDefined();
    expect(mask).not.toMatch(/field_behavior\)\s*=\s*REQUIRED/);
    expect(read("review.md")).toMatch(/omitt?ed|omission|populated fields/i);
  });

  it("adds create identity and list pagination contracts", () => {
    const proto = read("corrected.proto");
    expect(proto).toMatch(/rpc\s+GetBook\s*\(/);
    if (/google\.api\.method_signature/.test(proto)) {
      expect(proto).toMatch(/import\s+"google\/api\/client\.proto"\s*;/);
    }
    expect(proto).toMatch(/string\s+book_id\s*=\s*\d+/);
    expect(proto).toMatch(/int32\s+page_size\s*=\s*\d+/);
    expect(proto).toMatch(/string\s+page_token\s*=\s*\d+/);
    expect(proto).toMatch(/string\s+next_page_token\s*=\s*\d+/);
    const listRequest = proto.slice(
      proto.indexOf("message ListBooksRequest"),
      proto.indexOf("message ListBooksResponse"),
    );
    const createRequest = proto.slice(
      proto.indexOf("message CreateBookRequest"),
      proto.indexOf("message UpdateBookRequest"),
    );
    for (const request of [listRequest, createRequest]) {
      expect(request).toMatch(
        /resource_reference[\s\S]*(?:child_type\s*(?::|=)\s*"library\.example\.com\/Book"|type\s*(?::|=)\s*"library\.example\.com\/Publisher")/,
      );
    }
    for (const field of ["page_size", "page_token"]) {
      expect(listRequest).toMatch(
        new RegExp(
          `(?:int32|string)\\s+${field}\\s*=\\s*\\d+\\s*\\[[^\\]]*OPTIONAL`,
          "s",
        ),
      );
    }
  });

  it("annotates request resource names with their resource type", () => {
    const proto = read("corrected.proto");
    const getRequest = proto.slice(
      proto.indexOf("message GetBookRequest"),
      proto.indexOf("message ListBooksRequest"),
    );
    expect(getRequest).toMatch(
      /string\s+name\s*=\s*\d+[\s\S]*resource_reference[\s\S]*type\s*(?::|=)\s*"library\.example\.com\/Book"/,
    );
  });

  it("documents every public proto declaration", () => {
    const lines = read("corrected.proto").split("\n");
    const declaration =
      /^(?:message|service|rpc)\s|^(?:repeated\s+)?[A-Za-z][\w.<>]*\s+\w+\s*=/;
    for (const [index, line] of lines.entries()) {
      if (!declaration.test(line.trim())) continue;
      let previous = index - 1;
      while (previous >= 0 && lines[previous]?.trim() === "") previous--;
      expect(
        lines[previous]?.trim(),
        `missing comment before: ${line.trim()}`,
      ).toMatch(/^\/\//);
    }
  });

  it("uses the standard expiration shape", () => {
    const proto = read("corrected.proto");
    expect(proto).toMatch(/oneof\s+expiration\s*\{/);
    expect(proto).toMatch(/google\.protobuf\.Timestamp\s+expire_time\s*=/);
    expect(proto).not.toMatch(
      /google\.protobuf\.Timestamp\s+expire_time\s*=\s*\d+\s*\[[^\]]*OUTPUT_ONLY/s,
    );
    expect(proto).toMatch(
      /google\.protobuf\.Duration\s+ttl\s*=\s*\d+\s*\[[^\]]*field_behavior\)\s*=\s*INPUT_ONLY[^\]]*\]/s,
    );
    expect(proto).not.toMatch(/int64\s+ttl_seconds/);
  });

  it("runs api-linter without treating it as proof of conformance", () => {
    const results = JSON.parse(read("__agent_eval__/results.json"));
    const shell = (results.o11y?.shellCommands ?? [])
      .map((entry: { command: string }) => entry.command)
      .join("\n");
    expect(shell).toMatch(/api-linter\s+candidate\.proto/);
    expect(read("review.md")).toMatch(/api-linter/i);
    expect(read("review.md")).toMatch(
      /floor|no evidentiary weight|not\W+(?:be cited as\W+)?(?:proof|evidence of conformance)|manual(?:ly)? review|manually reading/i,
    );
  });

  it("actually consults every reported applicable official AIP page", () => {
    const review = read("review.md");
    const results = JSON.parse(read("__agent_eval__/results.json"));
    const web = (results.o11y?.webFetches ?? [])
      .map((entry: { url: string }) => entry.url)
      .join("\n");
    const shell = (results.o11y?.shellCommands ?? [])
      .map((entry: { command: string }) => entry.command)
      .join("\n");
    const observations = `${web}\n${shell}`;
    const reportedAips = review
      .split("\n")
      .filter(
        (line) =>
          line.startsWith("|") &&
          line.split("|").length >= 7 &&
          !/\|\s*not applicable\s*\|/i.test(line),
      )
      .flatMap((line) => {
        const match = line.split("|")[1]?.match(/(?:AIP-)?(\d+)\b/i);
        return match?.[1] ? [Number(match[1])] : [];
      });
    expect(reportedAips.length).toBeGreaterThan(0);
    for (const aip of new Set(reportedAips)) {
      expect(
        observations,
        `official AIP-${aip} page was not consulted`,
      ).toMatch(new RegExp(`google\\.aip\\.dev/${aip}\\b`));
    }
  });
});
