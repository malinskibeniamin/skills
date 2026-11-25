# Google Chrome Modern Web Guidance

Source: [GoogleChrome/modern-web-guidance v1.0.2](https://github.com/GoogleChrome/modern-web-guidance/tree/v1.0.2),
commit [`2b4aa13a72dd47cd135b06ce5abfccd92e19b24f`](https://github.com/GoogleChrome/modern-web-guidance/tree/2b4aa13a72dd47cd135b06ce5abfccd92e19b24f).
The snapshot contains the complete `skills/modern-web-guidance/` directory and
the upstream [Apache-2.0 license](chrome-modern-web-guidance/LICENSE), unchanged.
Per the [pinned upstream license notice](https://github.com/GoogleChrome/modern-web-guidance/blob/2b4aa13a72dd47cd135b06ce5abfccd92e19b24f/README.md#L661-L667),
the guides are [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
Credit to the GoogleChrome Modern Web Guidance contributors; portions derive from
[MDN Web Docs](https://developer.mozilla.org/) by Mozilla contributors and from
[W3C](https://www.w3.org/), [WHATWG](https://whatwg.org/) and [IETF](https://www.ietf.org/) specifications.
The snapshot does not include the CLI, sibling skills, or upstream plugin configuration.

The [host contract](../shared/AGENT-BROWSER.md#modern-web-guidance) combines this
source with the existing browser-verification workflow under one skill name.

## Refresh and verify

From the harness root, export the reviewed full commit from a trusted separate
upstream checkout. Review the upstream licensing and the inventory before replacing
the snapshot. Only non-executable Markdown files and the root license are expected;
new file types or changed modes need review.

```bash
set -euo pipefail
upstream=/path/to/modern-web-guidance
revision=2b4aa13a72dd47cd135b06ce5abfccd92e19b24f
stage=$(mktemp -d)
mkdir "$stage/source"
git -C "$upstream" ls-tree -r "$revision" -- LICENSE skills/modern-web-guidance
git -C "$upstream" archive "$revision" LICENSE skills/modern-web-guidance | tar -xf - -C "$stage/source"
(cd "$stage/source" && find LICENSE skills/modern-web-guidance -type f | LC_ALL=C sort | xargs shasum -a 256) > "$stage/sha256"
```

To verify the current snapshot:

```bash
diff -r vendor/chrome-modern-web-guidance "$stage/source"
diff -u vendor/chrome-modern-web-guidance.sha256 "$stage/sha256"
bash evals/run.sh agent-browser-vendored-skills
```

For a refresh, replace the snapshot and checksum manifest with the scratch
copies, update the commit, release, and host CLI recipe together, then run the
eval. Remove the scratch directory when finished. The offline eval checks local
bytes, inventory, modes and discovery; the export additionally checks against
the committed upstream source.
