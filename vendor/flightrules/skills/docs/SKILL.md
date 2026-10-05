---
name: docs
description: "Scientific, fact-based documentation writing in Simplified Technical English (ASD-STE100): outcome-first introductions, every claim verifiable, short sentences, one word one meaning, every document dated. Use when writing or reviewing ANY non-code document: a design spec, a research teardown, a runbook, a README, a note. If it is prose, this skill reviews it."
---

# docs

Write and review documentation so that a reader gets an accurate, outcome-first
answer that they can trust and reproduce. The one overriding rule: documentation
is **scientific and fact-based**, never marketing.

## Scope

**When to use: any document that is not code.** This skill reviews all prose: a
design spec, a research teardown, a runbook, a README, a note, or a comment
block long enough to read as prose.

## Core principle 0: open with an ELI5

Every document under `docs/` carries a labeled `## ELI5` (explain like I'm 5)
section near the top: 2–4 plain sentences that say what the document is and why
it matters. The body uses no jargon, no acronyms, and no math. `## ELI5` is the
one allowed acronym, expanded here. Keep that exact heading. Do not expand or
rename it.

Place the `## ELI5` after the `# H1` title and any metadata or provenance block
(a date line, a `**Source:**` block), and above the outcome-first introduction.

```
top of every doc/ file
  │
  ├─ # Title      the H1
  ├─ metadata     date / source / provenance block, if any
  │
  ├─ ## ELI5      2–4 plain sentences, no jargon — anyone can follow
  │               "what is this, why does it matter"
  │
  └─ intro        outcome-first, technical lead (principle 2)
```

The ELI5 and the introduction are different sections, and both are required. The
ELI5 is plain language for any reader. The introduction (principle 2) is the
technical lead for the systems engineer.

The ELI5 simplifies, but it never lies. It obeys principle 1: it states only
what the body backs, with no marketing tone. Simple English is not a lower
standard of truth.

Scope. A new document carries the `## ELI5` from its first commit. An older
document gets its `## ELI5` the next time a change touches it, not in a bulk
retrofit. At that moment, the §7.8 documentation gate binds the document to this
skill.

The fixed canonical files that `## Naming` exempts from the date prefix also
need no `## ELI5`: `README.md`, `STYLE.md`, and any `CLAUDE.md` (under `docs/`,
that is `docs/CLAUDE.md`). They are instruction or index files for agents and
tools, not reader documents.

## Core principle 1: scientific and fact-based

Documentation states what is true and lets the reader verify it. It is a record,
not a pitch.

- **Every claim is verifiable.** State only what you can source, measure, or
  point at in the code. If you cannot back a claim, cut it or mark it explicitly
  as a hypothesis.
- **Cite the source for every number** (a version, a limit, a benchmark, a
  latency, a byte count). Label it: `measured` (ran it), `arithmetic` (computed
  from exact quantities), or `estimated` (a proxy). Never present an estimate as
  a measurement.
- **Quantify instead of adjectival hand-waving.** Write "Cuts p99 request
  latency ~30% (measured, 8 cores, 1 client)", not "much faster". Ban
  unfalsifiable superlatives and filler: "blazing fast", "seamless",
  "world-class", "robust", "powerful", "simply", "just", "of course",
  "leverage", "utilize", "it is worth noting that". Cut the word, or give the
  measurable property. The ban also covers phrases that add no fact: "not just
  X, it is Y", a decorative list of three, "studies show" with no named source,
  and a closing "in conclusion" paragraph that restates the body.
- **Reproducible.** When you state a result, give the reader the command,
  configuration, and hardware to reproduce it. A number with no recipe is an
  anecdote.
- **Describe current behavior, not aspiration.** Use the present tense for what
  the code does today. Call roadmap items "planned", and keep them out of the
  description of present behavior. Never state a planned feature as if it ships.
- **Correct over confident.** Prefer "we have not measured X" to a guessed X. A
  confident wrong statement costs the reader far more than an admitted gap.
- **Name which resource a bound is against.** A system can have more than one
  memory: host DRAM, the memory of an accelerator, and caches, plus disk and
  network. Never write a bare "memory-bound", "memory bandwidth", or "bytes
  read". Say **which** memory: "bound by host DRAM bandwidth", "read from
  accelerator memory", or "served from the page cache". For any bound, name the
  resource that limits it (compute, host DRAM, accelerator memory, disk, bus,
  network).

## Core principle 2: lead with outcomes, not features

Every introduction paragraph leads with outcomes. State what the reader can
accomplish, or what problem the feature solves, before you explain how it works.
This is What–Why–How ordering, and it applies the style guide's "focus on facts,
real user tasks, and real user benefits".

## Core principle 3: draw the structure (diagrams are mandatory)

The reader is a visual learner. This is the strongest rule in the skill, from
`STYLE.md` and `CLAUDE.md`. When you explain anything with **structure** (a
memory layout, a bit packing, a data flow, a state machine, a pipeline, a
hierarchy, a request path), you **MUST** draw it as a labeled ASCII diagram with
boxes and arrows. This rule is not optional. A paragraph that describes a layout
where a diagram can show it is a defect, in docs and in code comments.

```
request ──▶ listener ──queue──▶ worker pool ──▶ handler()
   ▲       (I/O thread)  (SPSC)   (N threads)       |
   └──────────── mailbox ◀── events ◀───────────────┘
                 (one per request)
```

Rules for every diagram:

- **Draw the diagram instead of the paragraph, not in addition to it.** If a
  diagram carries the structure, cut the prose that restated it.
- **Label the parts, and put units on the labels** (bytes, bits, requests, ns).
- **Show direction with arrows** wherever data or control moves.
- **Keep it inside 79 columns** so it survives Markdown/terminal wrap.
- **Implemented paths only.** Draw the diagram when the path ships, never for
  speculative or future work. A path that does not run yet gets one line
  ("future, not yet implemented" + a pointer) and no diagram. Speculative
  diagrams rot and lie.

## Core principle 4: name the thing, not its slot in a plan

A document outlives the workflow that produced it. A reader a year later has no
memory of the pull-request stack, the ticket board, or the order of the work. To
that reader, scaffolding references are noise, and often already wrong. Every
non-code document obeys these rules:

- **ZERO scaffolding breadcrumbs. None. Not in prose, not in a title, not in a
  heading.** This rule is absolute. A single "PR 2", "stage 3", "lever F", "as
  we said in the last PR", or "this PR adds" fails the review. A pointer whose
  meaning is a position in a plan, not a thing in the system, is banned. Name
  the thing itself: "the retry queue", not "the A.5 queue in PR 3", and "the
  in-memory index cache", not "cache P in PR 4". Point at a companion document
  by its descriptive title or path, never by its plan slot. One breadcrumb means
  the document is not done.

- **No opaque internal labels as reader-facing references**, such as a benchmark
  log tag (`[stage-a]`, `[stage-b-ens]`), an internal enum, a build-target
  codename, or a debug print label. They mean nothing to a reader who has not
  read that source. Describe in plain English what the line or symbol reports.
  Give the **real formula** for any quantity (`amplification = bytes to disk /
  bytes from client = 4.70×`), not a pointer to where a number was printed. If a
  reproduce recipe needs a grep anchor, introduce the tag with a plain-English
  description of what it prints. Never give the tag bare.

  ```
  opaque / breadcrumb (banned)       descriptive (required)
    "## PR 2 result"                   "## Amplification cut: a measured NO-GO"
    "the fix from PR 1"                "the gap decomposition (see <doc>)"
    "PR 4 attacks this next"           "the index cache attacks this next"
    "Stage B (the 32-node cluster)"    "the 32-node cluster"
    "read the [stage-b] lines"         "read the per-node 32-vs-16-node
                                        timings (lines begin `[stage-b]`)"
    "1.31× (from [stage-a])"           "1.31× (batched writes vs single writes)"
  ```

- **Titles and section headings describe their content.** A heading is a promise
  about what the section says. "PR 2 result" promises nothing that a reader can
  act on. "Amplification cut: a measured NO-GO" gives the subject and the
  verdict before the reader starts the section. A heading that names a plan
  slot, a date, or a bare noun ("Results", "Notes") fails. Rewrite it to the
  claim or the subject that it covers.

The one exception is a document whose subject _is_ the process, such as a
release runbook or a migration plan that sequences real deploy steps. It can
name the steps, but by what each step does, not by an opaque ordinal.

## Core principle 5: write in Simplified Technical English (ASD-STE100)

Sentence mechanics follow ASD-STE100, the controlled-language standard of
aerospace maintenance manuals. A reader outside the field gets one meaning on
one read. The rules here paraphrase the Plain mode of the
[AminBlg/SimpleEnglish](https://github.com/AminBlg/SimpleEnglish) skill (MIT
license). Classify every passage first.

```
every passage you write
  │
  ├─ a step the reader performs    procedural (imperative, ≤20 words)
  └─ an explanation                descriptive (simple tense, ≤25 words)
```

**Procedural text** (a step the reader performs): imperative mood, one
instruction per sentence, 20 words per sentence at most. State a required
condition before the command, separated by a comma: "If the build fails, read
the log." A warning names the command or condition first, then the risk that it
carries, never the reverse: "Do not run this migration against production. It
drops the `events` table with no backup." Name the host, flag, or prior step
that a command depends on: not "Restart the service" but "Restart the `sync`
service on the host that runs the job."

**Descriptive text** (an explanation): simple tenses, one new fact per sentence,
25 words per sentence at most, one topic per paragraph, six sentences per
paragraph at most.

Grammar and vocabulary rules that apply to both:

- **Rewrite the prose, never the artifacts.** Do not change an artifact to fit
  these rules. Artifacts are code blocks, identifiers, commands, flags, file
  paths, quoted errors, product names, and facts. If the source gives no number
  or cause, keep the general statement. Do not invent one.
- **Simple tenses, active voice, a named actor.** No present perfect ("has
  completed" becomes "completed"). No "-ing" verb after a comma: split it into a
  new sentence. Say who acts: "you run the migration," not "the migration gets
  run."
- **Three modals only: can, will, must.** The table below gives the replacement
  for every other modal.
- **One word, one meaning, for the whole document.** Pick one term per concept
  and hold it. Use `configuration` throughout, not `config` in one section and
  `settings` in the next. Break a noun chain over three words with a
  preposition: not "the connection pool timeout configuration value" but "the
  timeout value for the connection pool".
- **Complete grammar, not telegraph style.** No contractions. Keep articles
  (the, a, an) and keep "that". A short sentence comes from cutting words that
  carry no fact, never from dropping grammar: "Make sure that the file exists
  before you run the command," not "Ensure file exists before running."
- **A split never adds words.** When you split a long sentence, cut its
  connectives ("thus", "it also", "this means") and its repeated subject. Use a
  list when three or more sentences share one subject. A rewrite to these rules
  ends shorter than the original.
- **No semicolons.** As with em dashes (see below), write two sentences, or name
  the relation ("because", "but", "for example").
- **Define a concept term at its first use, in under ten words, one definition
  per sentence.** Do not define a product name, a standard name (Postgres, S3,
  HTTP), or the tool that the document is about. "The reader" below says what
  this reader already knows.
- **A vertical list needs three or more parallel items.** Colon on the lead-in,
  uppercase start on each item, one instruction or one fact per item, never a
  mix of the two, no nesting.

The modal ladder:

| You wrote                 | Write instead                               |
| ------------------------- | ------------------------------------------- |
| should (a requirement)    | must                                        |
| should (a recommendation) | delete it, or state it as fact              |
| may / might / could       | can                                         |
| would (a hypothetical)    | can, or a real conditional ("if X, then Y") |

This principle governs sentence mechanics. It does not replace principle 3: a
layout, a flow, or a state machine still gets a diagram. Principle 1 governs
what a sentence can claim, and principle 4 governs what it can name. All three
apply together.

## Naming: date every document

Name every document that you create with its creation date as a `YYYY-MM-DD-`
prefix, so that a directory listing reads as a timeline:

```
docs/<area>/YYYY-MM-DD-<kebab-case-name>.md
  docs/research/storage/2026-08-04-disk-roofline.md
  docs/design/2026-08-04-task-planner.md
```

- The date is the day that you **create** the document, in ISO `YYYY-MM-DD`. It
  never changes on later edits.
- `<name>` is kebab-case and describes the content. Put no date words in it.
- Fixed, well-known files that tooling or readers find by an exact path keep
  their canonical names: `README.md`, `STYLE.md`, `CLAUDE.md`.

**Evergreen documents use `0000-00-00-`.** A document with no single creation
moment stays current: we rewrite it as the system changes, and no newer dated
file replaces it. It takes the `0000-00-00-` prefix, which sorts to the top. The
all-zero date marks the living page: read it as the present state, not as a
dated snapshot.

```
docs/public/0000-00-00-getting-started.md     living page, kept current
docs/design/2026-08-04-task-planner.md        dated snapshot of that day
```

## Links: every reference resolves, with zero dangling links

Every internal link in a document must resolve to a file that exists. A dangling
link is a factual error: it claims that a document exists when it does not, so
it fails the scientific bar like a wrong number.

- Every Markdown `.md` link (relative or repository-relative) points at a real
  file. When you rename or move a document, update every reference to it in the
  same change.
- Verify links with a tool, not by eye. Resolve every `.md` link target across
  the tracked documents. Confirm zero dangling links before you call the change
  done.
- External links (`http(s)://`, other-repo paths) are out of scope for the
  resolver, but they must still be correct.

## Quick reference: introduction length by page type

| Page type           | Length                           | Pattern                                                |
| ------------------- | -------------------------------- | ------------------------------------------------------ |
| **concepts**        | 4–5 sentences, ~100 words        | What it does, how it works, scope, outcomes, standards |
| **how-to**          | 1–2 sentences, ~30–50 words      | What you accomplish and why, no implementation         |
| **overview**        | 2 paragraphs, ~80–100 words      | Problem statement, then solution and capabilities      |
| **tutorial**        | 1–2 sentences, ~25–40 words      | What you will build or learn                           |
| **best-practices**  | 1–2 sentences, ~15–30 words      | Imperative, outcome-focused                            |
| **troubleshooting** | 1 sentence, ~15–25 words         | Scope of problems covered                              |
| **cookbook**        | 1 sentence + xrefs, ~20–30 words | Scenarios covered + related links                      |
| **reference**       | 1 sentence, ~10–20 words         | Scope of reference                                     |
| **lab**             | 1–2 sentences, ~25–40 words      | What you will explore and learn                        |

## Style-guide rules that apply to intros

1. **Lead with value** (What–Why–How): what the reader accomplishes, then why it
   matters, then how.
2. **Active voice, strong verbs:** avoid
   "is/are/has/have/do/does/provide/support".
3. **Second person:** use "you" for instructions.
4. **Present tense:** describe current behavior.
5. **No em dashes:** use commas, parentheses, or separate sentences.
6. **Clear and direct:** name concrete operations, not vague timeframes.

## Detailed patterns and examples

The core principles above are the authoritative source. Do not defer to any
external style guide.

## The reader

The reader is a systems engineer who will try to reproduce your claim. This
reader expects numbers with sources, commands to reproduce, and a labeled
diagram for any structure (the visual-learner mandate in `CLAUDE.md`). This
reader notices a number without a recipe.

## Quick check

The document is ready when:

- [ ] It carries a `## ELI5` section after the H1 and any metadata, above the
      intro: 2–4 plain sentences, a body free of jargon and acronyms, still
      accurate (the fixed canonical files README/STYLE/CLAUDE are exempt)
- [ ] It starts with value or capability, not implementation
- [ ] Every claim is verifiable, and every number is sourced and labeled
      (measured / arithmetic / estimated)
- [ ] It has no unfalsifiable superlatives and no marketing tone
- [ ] Every structure (layout, flow, state machine, pipeline, path) is a labeled
      ASCII diagram, ≤79 cols, drawn instead of described in prose
- [ ] A stated result carries the recipe to reproduce it
- [ ] Every internal `.md` link and cross-reference resolves, with zero dangling
      links (verified with a tool, not by eye)
- [ ] It uses active voice, strong verbs, second person, and present tense
- [ ] It has no em dashes, no semicolons, and no weak verbs
- [ ] It has no scaffolding breadcrumbs ("PR 1/2/N", "stage N", "lever X", "this
      PR adds") in prose or titles
- [ ] It has no opaque internal labels (bench tags like `[stage-b]`, enums,
      codenames) as reader-facing references, only plain English plus the real
      formula
- [ ] Every title and heading describes its content or claim, not a plan slot, a
      date, or a bare noun
- [ ] It is specific, not vague, and matches the length target for the page type
- [ ] The filename carries the `YYYY-MM-DD-` creation-date prefix (documents
      under `docs/`)
- [ ] Simplified Technical English: procedural sentences ≤20 words and one
      instruction each, descriptive sentences ≤25 words, condition before
      command, only "can/will/must" as modals, no contractions, one word per
      meaning, no noun chain over three words
- [ ] Every concept term is defined at first use in under ten words (product
      names, standard names, and the document's own subject tool are exempt)
- [ ] Mechanical pass done: count the words in the three longest sentences, then
      search the prose (not code blocks) for `'`, `has been`, `should`, `may`,
      `would`, `;`, `, making`, `config`, `verify`, and fix each hit
- [ ] Code blocks, commands, identifiers, quoted errors, and product names are
      byte-for-byte unchanged by the edit
