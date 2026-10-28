# Validation and executable annotations

## Follow constraints to enforcement

Protobuf types constrain representation, not every business invariant. A
`google.api.field_behavior` annotation documents API behavior; it does not install a
validator. Likewise, a Protovalidate rule needs an executing runtime/interceptor at the
authoritative server boundary. Client validation improves feedback, not authorization.

Trace changed rules through generated descriptors, runtime registration, request handling
and error mapping. Distinguish caller violations from invalid rule definitions, missing
descriptors and validator runtime failures; none of those failures is a valid request.
Check every relevant RPC path, not only a happy-path form submission.

Sources: [field behavior semantics](https://google.aip.dev/203),
[Protovalidate integrations](https://protovalidate.com/quickstart/connect-go/).

## Presence, rules and CEL

- Match `required`/ignore behavior to actual field presence. For a presence-tracking
  field, present-but-empty is different from absent; repeated/map fields do not gain
  element presence just by annotating them.
- Prefer standard constraints for formats/ranges/collections; use field CEL for a local
  invariant and message CEL for relationships across fields. Read custom/predefined
  extensions and their transitive descriptor dependencies before judging the rule.
- Guard optional accesses and branches. Validate list/map entries and oneof selection
  where the contract needs them. Check CEL types, numeric precision, timestamp/duration
  comparisons, regex support and extension availability in the deployed runtimes.
- Separate structural validation from stateful policy: uniqueness, permissions, remote
  existence and transactional checks still belong to authoritative application logic.
- Tightening validation can reject previously accepted or persisted values without a
  wire break. Require a compatibility/rollout explanation for the actual affected users.

Sources: [Protovalidate rules and presence](https://github.com/bufbuild/protovalidate/blob/main/proto/protovalidate/buf/validate/validate.proto),
[custom CEL rules](https://protovalidate.com/schemas/custom-rules/).

## Evidence to seek

Exercise unset, explicit default, valid boundary and invalid values; a cross-field
counterexample; and a credible validator failure. Verify server rejection and useful
error paths, including nested lists/maps/oneofs. Compile and run relevant rules in each
supported runtime before claiming parity. For partial updates, verify validation respects
the update contract rather than treating every omitted field as a full-create request.
