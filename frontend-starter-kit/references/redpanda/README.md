# Redpanda frontend profile

Run `/frontend-starter-kit redpanda` to apply the full profile plus Redpanda-specific
registry paths, terminology checks, and import restrictions.

## Configure

1. Add the Redpanda UI directory and terminology profile to the session environment:

   ```bash
   echo "export UI_LIB_DIRS=components/ui|redpanda-ui" >> "$CLAUDE_ENV_FILE"
   echo "export REDPANDA_KIT=1" >> "$CLAUDE_ENV_FILE"
   ```

   `UI_LIB_DIRS` marks registry-owned files. `REDPANDA_KIT=1` enables canonical product-name
   checks in `/ux-copy`; it does not enable orchestration or registry nudges.

2. Extend Biome `noRestrictedImports` with:
   - `@chakra-ui/react` -> use `@/components/ui/`
   - `@redpanda-data/ui` -> use `@/components/redpanda-ui/`

3. Use `/registry-workflow` only when maintaining registry taxonomy or synchronizing a
   consumer with its upstream registry.

## Verify

- [ ] `UI_LIB_DIRS` and `REDPANDA_KIT` are exported by the session environment
- [ ] `bun run lint` rejects both legacy UI imports
- [ ] `/ux-copy` recognizes canonical Redpanda product names
- [ ] Registry consumers document their upstream registry path
