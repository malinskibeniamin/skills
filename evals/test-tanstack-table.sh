# Evals for TanStack Table V9 guidance and enforcement.

HOOK="$REPO_ROOT/.claude/hooks/tanstack-table-check.sh"
SKILL_DIR="$REPO_ROOT/tanstack-table"
TMP_ROOT=$(mktemp -d)
trap 'rm -rf "$TMP_ROOT"' EXIT

run_table_hook_eval() {
  local file="$1"
  local expected_exit="$2"
  local description="$3"
  local expected_pattern="${4:-}"
  local content

  if [ ! -x "$HOOK" ]; then
    echo "  FAIL  $description (hook missing or not executable)"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
    return
  fi

  content=$(cat "$file")
  run_hook_eval "$HOOK" \
    "$(jq -nc --arg path "$file" --arg content "$content" \
      '{tool_name:"Write",tool_input:{file_path:$path,content:$content}}')" \
    "$expected_exit" "$description" "$expected_pattern"
}

run_table_hook_eval_without() {
  local file="$1"
  local forbidden_pattern="$2"
  local description="$3"
  local content output actual_exit=0

  if [ ! -x "$HOOK" ]; then
    echo "  FAIL  $description (hook missing or not executable)"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
    return
  fi

  content=$(cat "$file")
  output=$(jq -nc --arg path "$file" --arg content "$content" \
    '{tool_name:"Write",tool_input:{file_path:$path,content:$content}}' |
    "$HOOK" 2>&1) || actual_exit=$?
  if [ "$actual_exit" -eq 0 ] && ! printf '%s' "$output" | grep -qF -- "$forbidden_pattern"; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description"
    echo "        unexpected exit=$actual_exit or pattern: $forbidden_pattern"
    echo "        output: $output"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi
}

mkdir -p "$TMP_ROOT/v9/src"
cat > "$TMP_ROOT/v9/package.json" <<'JSON'
{"dependencies":{"@tanstack/react-table":"^9.0.0-beta.49"}}
JSON
cat > "$TMP_ROOT/v9/src/table.tsx" <<'TSX'
import { useReactTable } from '@tanstack/react-table'

export function PeopleTable() {
  const table = useReactTable({ data: [], columns: [] })
  return <div>{table.getRowCount()}</div>
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/table.tsx" 2 \
  "blocks the V8 useReactTable API in a V9 project" "useTable"

cat > "$TMP_ROOT/v9/src/commented-migration.tsx" <<'TSX'
import { useTable } from '@tanstack/react-table'

export function PeopleTable({ data, columns }: Props) {
  // V8 called useReactTable(); V9 does not.
  const table = useTable({ features, data, columns })
  return <div>{table.getRowCount()}</div>
}
TSX

run_table_hook_eval_without "$TMP_ROOT/v9/src/commented-migration.tsx" \
  "uses useTable" "ignores V8 API names in comments"

mkdir -p "$TMP_ROOT/v8/src"
cat > "$TMP_ROOT/v8/package.json" <<'JSON'
{"dependencies":{"@tanstack/react-table":"^8.21.3"}}
JSON
cp "$TMP_ROOT/v9/src/table.tsx" "$TMP_ROOT/v8/src/table.tsx"

run_table_hook_eval "$TMP_ROOT/v8/src/table.tsx" 0 \
  "does not apply V9 rules to a V8 project"

mkdir -p "$TMP_ROOT/v8-beta/src"
cat > "$TMP_ROOT/v8-beta/package.json" <<'JSON'
{"dependencies":{"@tanstack/react-table":"8.0.0-beta.9"}}
JSON
cp "$TMP_ROOT/v9/src/table.tsx" "$TMP_ROOT/v8-beta/src/table.tsx"

run_table_hook_eval "$TMP_ROOT/v8-beta/src/table.tsx" 0 \
  "does not mistake an old V8 beta version for V9"

mkdir -p "$TMP_ROOT/beta-tag/src"
cat > "$TMP_ROOT/beta-tag/package.json" <<'JSON'
{"dependencies":{"@tanstack/react-table":"beta"}}
JSON
cp "$TMP_ROOT/v9/src/table.tsx" "$TMP_ROOT/beta-tag/src/table.tsx"

run_table_hook_eval "$TMP_ROOT/beta-tag/src/table.tsx" 2 \
  "recognizes the V9 beta dist-tag" "useTable"

cat > "$TMP_ROOT/v9/src/destructured-row.tsx" <<'TSX'
import type { Row } from '@tanstack/react-table'

export function PersonName({ row }: { row: Row<unknown, Person> }) {
  const { getValue } = row
  return <span>{getValue('name')}</span>
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/destructured-row.tsx" 2 \
  "blocks destructuring V9 prototype methods from table objects" "instance method"

cat > "$TMP_ROOT/v9/src/get-state.tsx" <<'TSX'
import type { ReactTable } from '@tanstack/react-table'

export function TableState({ table }: { table: ReactTable<unknown, Person, null> }) {
  return <pre>{JSON.stringify(table.getState())}</pre>
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/get-state.tsx" 2 \
  "blocks the removed V8 getState API in V9" "table.state"

cat > "$TMP_ROOT/v9/src/named-table-get-state.tsx" <<'TSX'
import type { ReactTable } from '@tanstack/react-table'

export function TableState({ peopleTable }: { peopleTable: ReactTable<unknown, Person, null> }) {
  return <pre>{JSON.stringify(peopleTable.getState())}</pre>
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/named-table-get-state.tsx" 2 \
  "blocks getState on named V9 table instances" "table.state"

cat > "$TMP_ROOT/v9/src/unrelated-get-state.tsx" <<'TSX'
import type { ColumnDef } from '@tanstack/react-table'

export function Status({ notable }: { notable: StateStore }) {
  return <pre>{JSON.stringify(notable.getState())}</pre>
}
TSX

run_table_hook_eval_without "$TMP_ROOT/v9/src/unrelated-get-state.tsx" \
  "table.state" "does not treat unrelated names ending in table as table instances"

cat > "$TMP_ROOT/v9/src/on-state-change.tsx" <<'TSX'
import { useTable } from '@tanstack/react-table'

export function PeopleTable({ data, columns }: Props) {
  const [state, setState] = useState({})
  const table = useTable({
    features,
    data,
    columns,
    state,
    onStateChange: setState,
  })
  return <div>{table.getRowCount()}</div>
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/on-state-change.tsx" 0 \
  "warns on the removed aggregate onStateChange option" "per-slice"

cat > "$TMP_ROOT/v9/src/select-all.tsx" <<'TSX'
import type { ReactTable } from '@tanstack/react-table'

export function SelectAll({ table }: { table: ReactTable<unknown, Person, null> }) {
  return (
    <Checkbox
      checked={table.getIsAllRowsSelected()}
      indeterminate={table.getIsSomeRowsSelected()}
    />
  )
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/select-all.tsx" 2 \
  "blocks V8 indeterminate row-selection semantics in V9" "all-selected"

cat > "$TMP_ROOT/v9/src/select-all-correct.tsx" <<'TSX'
import type { ReactTable } from '@tanstack/react-table'

export function SelectAll({ table }: { table: ReactTable<unknown, Person, null> }) {
  return (
    <Checkbox
      checked={table.getIsAllRowsSelected()}
      indeterminate={
        table.getIsSomeRowsSelected() && !table.getIsAllRowsSelected()
      }
    />
  )
}
TSX

run_table_hook_eval_without "$TMP_ROOT/v9/src/select-all-correct.tsx" \
  "'some rows selected' means at least one" "accepts gated indeterminate selection"

cat > "$TMP_ROOT/v9/src/row-checkbox.tsx" <<'TSX'
import type { Row } from '@tanstack/react-table'

export function RowCheckbox({ row }: { row: Row<unknown, Person> }) {
  return (
    <Checkbox
      checked={row.getIsSelected()}
      onCheckedChange={row.getToggleSelectedHandler()}
    />
  )
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/row-checkbox.tsx" 0 \
  "warns when an extracted component hides reactive reads behind a stable row" "Subscribe"

cat > "$TMP_ROOT/v9/src/subscribed-row-checkbox.tsx" <<'TSX'
import { Subscribe, type ReactTable, type Row } from '@tanstack/react-table'

export function RowCheckbox({
  row,
  table,
}: {
  row: Row<unknown, Person>
  table: ReactTable<unknown, Person, null>
}) {
  return (
    <Subscribe
      source={table.atoms.rowSelection}
      selector={(selection) => selection[row.id]}
    >
      {(selected) => <Checkbox checked={Boolean(selected)} />}
    </Subscribe>
  )
}
TSX

run_table_hook_eval_without "$TMP_ROOT/v9/src/subscribed-row-checkbox.tsx" \
  "objects are stable" "accepts an explicit subscription boundary"

cat > "$TMP_ROOT/v9/src/no-parent-subscription.tsx" <<'TSX'
import { useTable } from '@tanstack/react-table'

export function PeopleTable({ data, columns }: Props) {
  const table = useTable({ features, data, columns }, () => null)
  return <Checkbox checked={table.getIsAllRowsSelected()} />
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/no-parent-subscription.tsx" 0 \
  "warns when useTable opts out without adding a lower subscription boundary" "opts out"

cat > "$TMP_ROOT/v9/src/default-subscription.tsx" <<'TSX'
import { useTable } from '@tanstack/react-table'

export function PeopleTable({ data, columns }: Props) {
  const table = useTable({ features, data, columns })
  return <Checkbox checked={table.getIsAllRowsSelected()} />
}
TSX

run_table_hook_eval_without "$TMP_ROOT/v9/src/default-subscription.tsx" \
  "opts out" "accepts useTable's correctness-first default subscription"

cat > "$TMP_ROOT/v9/src/legacy-table.tsx" <<'TSX'
import { useLegacyTable } from '@tanstack/react-table/legacy'

export function PeopleTable({ data, columns }: Props) {
  const table = useLegacyTable({ data, columns })
  return <div>{table.getRowCount()}</div>
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/legacy-table.tsx" 0 \
  "warns that useLegacyTable is temporary migration debt" "deprecated"

cat > "$TMP_ROOT/v9/src/broad-registries.tsx" <<'TSX'
import {
  rowSortingFeature,
  sortFns,
  tableFeatures,
  useTable,
} from '@tanstack/react-table'

const features = tableFeatures({ rowSortingFeature, sortFns })

export function PeopleTable({ data, columns }: Props) {
  const table = useTable({ features, data, columns })
  return <div>{table.getRowCount()}</div>
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/broad-registries.tsx" 0 \
  "warns when full function registries defeat V9 tree-shaking" "individual functions"

cat > "$TMP_ROOT/v9/src/individual-registry.tsx" <<'TSX'
import {
  rowSortingFeature,
  sortFn_alphanumeric,
  tableFeatures,
} from '@tanstack/react-table'

export const features = tableFeatures({
  rowSortingFeature,
  sortFns: { alphanumeric: sortFn_alphanumeric },
})
TSX

run_table_hook_eval_without "$TMP_ROOT/v9/src/individual-registry.tsx" \
  "Full TanStack Table function registries" "accepts individually registered functions"

cat > "$TMP_ROOT/v9/src/external-atoms-reset.tsx" <<'TSX'
import { useCreateAtom } from '@tanstack/react-store'
import { useTable } from '@tanstack/react-table'

export function PeopleTable({ data, columns }: Props) {
  const pagination = useCreateAtom({ pageIndex: 0, pageSize: 25 })
  const table = useTable({
    features,
    data,
    columns,
    atoms: { pagination },
  })
  return <Button onClick={() => table.reset()}>Reset</Button>
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/external-atoms-reset.tsx" 0 \
  "warns that table.reset does not reset externally owned atoms" "external atoms"

cat > "$TMP_ROOT/v9/src/base-atom-write.tsx" <<'TSX'
import type { ReactTable } from '@tanstack/react-table'

export function ResetPagination({ table }: { table: ReactTable<unknown, Person, null> }) {
  return (
    <Button
      onClick={() =>
        table.baseAtoms.pagination.set({ pageIndex: 0, pageSize: 25 })
      }
    >
      Reset
    </Button>
  )
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/base-atom-write.tsx" 0 \
  "warns on low-level baseAtoms writes" "feature API"

cat > "$TMP_ROOT/v9/src/snapshot-read.tsx" <<'TSX'
import type { ReactTable } from '@tanstack/react-table'

export function PageNumber({ table }: { table: ReactTable<unknown, Person, null> }) {
  return <span>{table.store.state.pagination.pageIndex + 1}</span>
}
TSX

run_table_hook_eval "$TMP_ROOT/v9/src/snapshot-read.tsx" 0 \
  "warns when JSX treats a snapshot read as a subscription" "not a React subscription"

run_file_eval "$SKILL_DIR/SKILL.md" "TanStack Table skill exists"
run_content_eval "$SKILL_DIR/SKILL.md" "^name: tanstack-table" "skill has the correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "/read-the-damn-docs" "skill checks the current beta API"
run_content_eval "$SKILL_DIR/SKILL.md" "tanstack-table-v9-reactivity" \
  "skill links the V9 reactivity source article"
run_content_eval "$SKILL_DIR/SKILL.md" "snapshot.*subscription|subscription.*snapshot" \
  "skill distinguishes current-value reads from subscriptions"
run_content_eval "$SKILL_DIR/SKILL.md" "Subscribe.*useSelector|useSelector.*Subscribe" \
  "skill teaches React subscription boundaries"
run_content_eval "$SKILL_DIR/SKILL.md" "external atoms.*reset|reset.*external atoms" \
  "skill covers external atom ownership and reset"
run_content_eval "$SKILL_DIR/SKILL.md" "individual.*(filter|sort|aggregation)" \
  "skill preserves V9 tree-shaking"
run_content_eval "$REPO_ROOT/.claude/hooks/post-tool-batch.sh" "tanstack-table-check" \
  "Claude batch dispatcher runs the Table check"
run_content_eval "$REPO_ROOT/skill-manifest.json" "tanstack-table-check.sh" \
  "Codex per-call manifest includes the Table check"
