# Version 1 of the reviewer event contract. Slurp exactly one report; the caller
# supplies the dispatched reviewer identity. Unknown extension fields are allowed.
def nonempty: type == "string" and test("\\S");
def member($choices): . as $value | $choices | index($value) != null;
def strings: type == "array" and all(.[]; nonempty);
def finding:
  type == "object"
  and (.title | nonempty)
  and (.severity | member(["P0", "P1", "P2", "P3"]))
  and (.file | nonempty)
  and (.line | type == "number" and . > 0 and floor == .)
  and (.category | member(["security", "type-safety", "error-handling", "accessibility", "testing", "maintainability", "performance", "simplification", "documentation"]))
  and (.why_it_matters | nonempty)
  and (.scenario | nonempty)
  and (.evidence | nonempty)
  and (.verification | nonempty)
  and (.autofix_class | member(["safe_auto", "gated_auto", "manual", "advisory"]))
  and has("suggested_fix")
  and (if .suggested_fix == null then
    .autofix_class | member(["manual", "advisory"])
  else .suggested_fix | nonempty end)
  and (.pre_existing | type == "boolean")
  and (.confidence | type == "number" and . >= 0 and . <= 1);
def blocking_finding:
  .pre_existing == false and (.severity | member(["P0", "P1"]));
def checks:
  if has("karpathy_checks") then
    .karpathy_checks | type == "object" and all(.[]; member(["pass", "fail", "n/a"]))
  else true end;
def critical_failure:
  .karpathy_checks as $checks
  | any(["hallucinated-api", "confident-wrong-types", "ssrf-url-fetch"][]; $checks[.] == "fail");
def completed:
  (.testing_gaps | strings)
  and (.simplification_opportunities | strings)
  and all(.findings[]; finding)
  and checks
  and (if any(.findings[]; blocking_finding) or critical_failure then
    .status == "NEEDS_CHANGES"
  else true end);

length == 1 and (.[0] |
  type == "object"
  and .schema_version == 1
  and .reviewer == $reviewer
  and (.reviewer | member(["self-reviewer", "code-reviewer", "adversarial-reviewer"]))
  and (.findings | type == "array")
  and (if .status | member(["APPROVED", "CONCERNS", "NEEDS_CHANGES"]) then
    completed
  elif .status | member(["SKIPPED", "UNAVAILABLE", "FAILED"]) then
    .findings == [] and (.reason | nonempty)
  else false end)
)
