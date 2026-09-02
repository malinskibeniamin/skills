import { eslintCompatPlugin } from "@oxlint/plugins";

import { noChainedTypeAssertionsRule } from "./rules/no-chained-type-assertions.ts";
import { noUnknownTypeAliasesRule } from "./rules/no-unknown-type-aliases.ts";
import { noWidenThenAssertRule } from "./rules/no-widen-then-assert.ts";

/** Anti-slop rules that reject type-evidence laundering. */
const antiSlopPlugin = eslintCompatPlugin({
  meta: { name: "anti-slop" },
  rules: {
    "no-chained-type-assertions": noChainedTypeAssertionsRule,
    "no-unknown-type-aliases": noUnknownTypeAliasesRule,
    "no-widen-then-assert": noWidenThenAssertRule,
  },
});

export default antiSlopPlugin;
