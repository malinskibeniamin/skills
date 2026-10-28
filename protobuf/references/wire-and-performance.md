# Wire diagnosis and performance

Read for changed encodings, parsers or large-payload optimization; do not impose a wire
tuning exercise on ordinary schema reviews.

## Diagnose with the schema

Use repository-owned `buf convert`/runtime tools with the correct descriptor set and
top-level message type. Protoscope can inspect framing without them, but length-delimited
bytes alone do not identify strings, nested messages or packed values. A plausible dump
is not proof of a valid message. Keep raw fixtures bounded/redacted; JSON inspection tools
can also lose integer precision.

Sources: [Buf conversion](https://buf.build/docs/reference/cli/buf/convert/),
[diagnosis example](https://buf.build/blog/totw-7-scoping-it-out).

## Optimize without rewriting a deployed contract

- Tag value is `(field_number << 3) | wire_type`. Fields 1–15 use one-byte tags;
  16–2047 use two. Choose low tags for frequent NEW fields; never renumber deployed
  fields for size. Keep reserved/system tag ranges intact.
- Pick new integer types for domain range, negative-value distribution and generated
  language representation. Negative `int32`/`int64` values use ten-byte varints;
  `sint32`/`sint64` ZigZag small signed values efficiently. Fixed-width can suit wide,
  uniformly distributed values. Shared wire type does not guarantee semantic equivalence.
- For ordered numeric sequences, consider compression before a custom delta scheme.
  Delta encoding needs an explicit baseline, signed deltas, overflow handling, ordering,
  aligned-series rules and random-access/recovery costs. Keep it an optional measured
  design, not a default RPC representation.

Sources: [encoding reference](https://protobuf.dev/programming-guides/encoding/),
[integer tradeoffs](https://buf.build/blog/choosing-the-right-protobuf-integer-type),
[delta design](https://buf.build/blog/delta-encoding-in-protobuf).

Measure the changed consumer's end-to-end workload: size before/after realistic
compression, cold descriptor/codec construction, warm parse, field access, validation,
allocation and serialization as relevant. A lazy parser's parse-only win can move work
to access; borrowed buffers add lifetime obligations. Reuse supported compiled parsers
outside hot paths, while respecting mutability/concurrency rules. Exercise deployed native
and fallback configurations when both are shipped. Blog/conformance results justify an
experiment, not a claimed speedup, runtime replacement or unsafe decoding mode.

Sources: [dynamic parsing tradeoffs](https://buf.build/blog/hyperpb),
[Python runtime/acceleration](https://buf.build/blog/protobuf-py),
[TS codecs and CSP](https://buf.build/blog/protobuf-es-performance).
