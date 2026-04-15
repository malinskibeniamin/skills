# UX Copy Reference

## ux-copy-check.sh

> Script: [`scripts/ux-copy-check.sh`](scripts/ux-copy-check.sh)

## Escape Hatch

```tsx
// allow: ux-copy — legacy string from external API
const message = "Operation completed successfully!"
```

Hook checks `// allow: ux-copy` anywhere in file. Reason required for code review. Legacy format `// allow-ux-copy:` also works.

## Capitalization

Sentence-style caps all UI text: titles, headings, buttons, menu items, fields, tooltips. Capitalize first word only.

| Good | Bad |
|------|-----|
| Maximum number of topics | Maximum Number of Topics |
| How to connect | How To Connect |
| Enable mTLS for Schema Registry | Enable mTLS for Schema registry |

Exceptions:
- Redpanda product names: Admin API, Redpanda Console, Schema Registry, HTTP Proxy, Dedicated Cloud, BYOC
- Acronyms: ID, TLS, mTLS, SASL, OIDC, VPC, CIDR
- Side pane nav items use heading-style caps

## Toast Messages

Completed tasks: subject + past tense verb.
Long-running tasks: gerund (verb + ing).

| Good | Bad |
|------|-----|
| Topic created | Topic has been created |
| Client deleted | Client deleted successfully |
| Creating cluster | Cluster setup in progress |
| Reconciling the organization | Triggered reconciliation |

## Error Messages

State problem clearly. Provide solution. No blame.

| Good | Bad |
|------|-----|
| Choose a password with at least 8 characters. | Oops! That password is too short. |
| No results found. | Couldn't return any results. |
| Could not save changes. Check your connection. | Something went wrong! |

## Button Labels

- 1-4 words max
- Start with verb if more than one word
- No "Yes"/"No" — use clear action verbs
- No articles (a, an, the)

| Good | Bad |
|------|-----|
| Delete cluster | Yes |
| Save changes | OK |
| Add tag | Add a new tag |

## Empty States

Explain why page empty, what user can do next. Include button or link to next step when appropriate.

Running tasks: use gerund ("Creating cluster" not "Cluster creation in progress").

## Tooltips

- Brief — lengthy content not tip
- Period for full sentences, no period for short phrases
- No interactive elements (links, buttons)
- No redundant text ("Click to..." on button)

## Numbers and Measurements

- Always numerals, including 0-9 ("3 topics" not "three topics")
- Thousands: K, millions: M, billions: B, no space (33K)
- Measurements: abbreviations with space (10 MB, 75 MBps)
- Time: 12-hour clock, AM/PM caps (2:30 PM)

## Links

- Descriptive text — never "click here" or bare "here"
- "Learn more" always after descriptive text, never inline
- Capitalize first word only: "Learn more" (not "Learn More")
- External link icon for links leaving product
- One link per sentence max

## Possessive Pronouns

Avoid "my" and "your" in page names, menu names, titles. OK in instructional text.

| Good | Bad |
|------|-----|
| Settings | My Settings |
| Workspaces | Your Workspaces |
| Enter the ID token from your identity provider. | (OK in help text) |

## Language

- American English (behavior not behaviour)
- Present tense, active voice
- Natural contractions (don't, can't, it's)
- Serial commas (Mo, Ivana, and Michele)
- No exclamation points
- No idioms (text should translate easily)

## Terms to Use Sparingly

Use only to acknowledge errors or interactions particularly inconvenient:
- please
- sorry
- thank you

## Inclusive Terminology

| Banned | Use Instead |
|--------|-------------|
| whitelist | allowlist |
| blacklist | denylist |
| master | leader, primary |
| slave | follower, secondary |

## Directional Language

Don't reference physical position in UI or page — layouts change.

| Bad | Good |
|-----|------|
| "See above" | "See the Prerequisites section" |
| "Click the button on the right" | "Click Save" |
| "In the example below" | "In the following example" |

## Sentence Structure

- **No "There is/are" starters** — subject first: "3 options are available" not "There are 3 options"
- **Conditional phrases first** — "If using Kubernetes, configure..." not "Configure... if using Kubernetes"
- **No future tense** — present tense: "The cluster restarts" not "The cluster will restart"
- **No "and/or"** — use "and", "or", or "A, B, or both"

## Words to Avoid in UI Text

| Avoid | Use Instead |
|-------|-------------|
| etc. | List specific items, or "such as X and Y" |
| e.g. | for example |
| i.e. | that is |
| via | through, using, with |
| please | (omit, or use only for significant inconvenience) |
| config | configuration |
| foo, bar, baz | Contextual meaningful names |

## Placeholder Format

Placeholder values in UI: descriptive lowercase-with-dashes in angle brackets:

| Good | Bad |
|------|-----|
| `<topic-name>` | `<value>` |
| `<cluster-id>` | `<my-cluster>` |
| `<broker-address>` | `<replace-with-address>` |

## Em Dashes

Don't use em dashes. Use parentheses, commas, or separate sentences.

## Common Agent Excuses

| Excuse | Counter |
|---|---|
| "The exclamation adds energy" | Adds noise. Product UI should be calm and informative. |
| "'successfully' confirms the action" | Toast itself confirms. "Topic created" sufficient. |
| "'click here' is clear" | Meaningless without context. Describe destination. |
| "'Oops' is friendly" | Patronizing. State problem and solution directly. |
| "Title Case looks professional" | Inconsistent, harder to scan. Sentence case standard. |
| "'My Settings' is user-centric" | Ambiguous in multi-user contexts. Just "Settings". |