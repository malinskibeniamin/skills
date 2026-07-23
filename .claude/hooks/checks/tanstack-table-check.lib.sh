#!/bin/bash
# TanStack Table V9 checks. Source ../_hook-lib.sh before this file.

run_tanstack_table_check() {
  hook_skip_generated || return 0
  hook_filter_extensions "ts|tsx" || return 0
  hook_get_added_lines || return 0

  file_content="${file_content:-$(cat "$file_path" 2>/dev/null || true)}"
  printf '%s' "$file_content" | grep -qF "@tanstack/react-table" || return 0

  local dir package_file version installed_package resolve_installed
  resolve_installed=false
  dir=$(dirname "$file_path")
  package_file=""
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/package.json" ] && jq -e '
      .dependencies["@tanstack/react-table"]
      // .devDependencies["@tanstack/react-table"]
      // .peerDependencies["@tanstack/react-table"]
      // .optionalDependencies["@tanstack/react-table"]
    ' "$dir/package.json" >/dev/null 2>&1; then
      package_file="$dir/package.json"
      break
    fi
    dir=$(dirname "$dir")
  done
  [ -n "$package_file" ] || return 0

  version=$(jq -r '
    .dependencies["@tanstack/react-table"]
    // .devDependencies["@tanstack/react-table"]
    // .peerDependencies["@tanstack/react-table"]
    // .optionalDependencies["@tanstack/react-table"]
    // ""
  ' "$package_file")
  case "$version" in
    npm:*@*)
      version="${version##*@}"
      case "$version" in
        *[0-9]*|beta) ;;
        *) resolve_installed=true ;;
      esac
      ;;
    workspace:*)
      version="${version#workspace:}"
      case "$version" in
        *[0-9]*) ;;
        *) resolve_installed=true ;;
      esac
      ;;
    catalog:*) resolve_installed=true ;;
  esac
  version=$(printf '%s' "$version" | sed -E 's/^[[:space:]~^<>=v]*//')
  case "$version" in
    9|9.*|beta) ;;
    *)
      [ "$resolve_installed" = true ] || return 0
      while [ "$dir" != "/" ]; do
        installed_package="$dir/node_modules/@tanstack/react-table/package.json"
        if [ -f "$installed_package" ]; then
          version=$(jq -r '.version // ""' "$installed_package")
          break
        fi
        dir=$(dirname "$dir")
      done
      case "$version" in
        9|9.*) ;;
        *) return 0 ;;
      esac
      ;;
  esac

  local added_code file_code subscription_pattern
  added_code=$(printf '%s\n' "$added_lines" | perl -0pe 's{/\*.*?\*/}{}gs' |
    grep -vE '^[[:space:]]*(//|\*)' || true)
  file_code=$(printf '%s\n' "$file_content" | perl -0pe 's{/\*.*?\*/}{}gs' |
    grep -vE '^[[:space:]]*(//|\*)' || true)
  subscription_pattern='<Subscribe\b|<table\.Subscribe\b|\buseSelector[[:space:]]*\('

  if printf '%s\n' "$added_code" | grep -qE '\buseReactTable\b'; then
    hook_block "TanStack Table V9 uses useTable(), not useReactTable()."
  fi

  if printf '%s\n' "$added_code" | grep -qE \
    '\b(table|[A-Za-z_$][A-Za-z0-9_$]*Table)\.getState[[:space:]]*\('; then
    hook_block "TanStack Table V9 removed table.getState(). Render selected state from table.state; use table.store.state only for a current snapshot."
  fi

  if printf '%s\n' "$added_code" | grep -qE '\bonStateChange[[:space:]]*:' &&
    printf '%s' "$file_code" | grep -qE '\buseTable[[:space:]]*\('; then
    hook_warn "TanStack Table V9 removed aggregate onStateChange. Use per-slice on*Change handlers, external atoms, or table.store.subscribe()."
  fi

  if printf '%s\n' "$added_code" | grep -qE '\buseLegacyTable\b'; then
    hook_warn "useLegacyTable is deprecated temporary migration support. Prefer V9 useTable with explicit features."
  fi

  if printf '%s' "$file_code" | tr '\n' ' ' | grep -qE \
    "import[[:space:]]*\\{[^}]*\\b(filterFns|sortFns|aggregationFns)\\b[^}]*\\}[[:space:]]*from[[:space:]]*['\"]@tanstack/react-table['\"]" &&
    printf '%s' "$file_code" | grep -qE '\btableFeatures[[:space:]]*\(' &&
    printf '%s' "$added_code" | grep -qE '\b(filterFns|sortFns|aggregationFns|tableFeatures)\b'; then
    hook_warn "Full TanStack Table function registries defeat V9 tree-shaking. Import and register only the individual functions this table uses."
  fi

  if printf '%s' "$file_code" | grep -qE '\batoms[[:space:]]*:' &&
    printf '%s' "$file_code" | grep -qE '\btable\.reset[[:space:]]*\(' &&
    printf '%s\n' "$added_code" | grep -qE '\batoms[[:space:]]*:|\btable\.reset[[:space:]]*\('; then
    hook_warn "table.reset() does not reset external atoms. Reset each owned atom or use the feature reset API that updates it."
  fi

  if printf '%s\n' "$added_code" | grep -qE '\.baseAtoms\.[A-Za-z0-9_]+\.set[[:space:]]*\('; then
    hook_warn "Prefer the TanStack Table feature API (setSorting, setPagination, toggleSelected, resetPagination, and similar) over low-level baseAtoms writes."
  fi

  if printf '%s\n' "$added_code" | tr '\n' ' ' | grep -qE \
    '\{[[:space:]]*table\.(store\.state|atoms\.[A-Za-z0-9_]+\.get\()' &&
    ! printf '%s' "$file_code" | grep -qE "$subscription_pattern"; then
    hook_warn "table.store.state and table.atoms.*.get() are current-value reads, not a React subscription. Render through table.state, Subscribe, or useSelector."
  fi

  if printf '%s\n' "$added_code" | tr '\n' ' ' | grep -qE \
    '(const|let|var)[[:space:]]*\{[^}]*\b(get|set|reset|toggle)[A-Z][A-Za-z0-9_]*[^}]*\}[[:space:]]*=[[:space:]]*(table|row|cell|column|header)\b'; then
    hook_block "Call TanStack Table V9 instance methods on their instance; prototype methods lose their receiver when destructured."
  fi

  local indeterminate_expression
  indeterminate_expression=$(printf '%s\n' "$added_code" | tr '\n' ' ' |
    grep -oE 'indeterminate[[:space:]]*=[[:space:]]*\{[^}]*getIsSome(Page)?RowsSelected\(\)[^}]*\}' || true)
  if [ -n "$indeterminate_expression" ] &&
    printf '%s' "$indeterminate_expression" | grep -qvE 'getIsAll(Page)?RowsSelected\(\)'; then
    hook_block "TanStack Table V9 'some rows selected' means at least one. Gate indeterminate with the matching all-selected check."
  fi

  if printf '%s' "$file_code" | tr '\n' ' ' | grep -qE \
    'useTable\(.*,[[:space:]]*\([^)]*\)[[:space:]]*=>[[:space:]]*(null|\(\{[[:space:]]*\}\))' &&
    printf '%s' "$file_code" | grep -qE \
      '\.(getIs[A-Z]|getCan[A-Z]|getFilterValue\(|getSize\(|getValue\(|renderValue\()' &&
    printf '%s' "$added_code" | grep -qE \
      '\buseTable[[:space:]]*\(|\.(getIs[A-Z]|getCan[A-Z]|getFilterValue\(|getSize\(|getValue\(|renderValue\()' &&
    ! printf '%s' "$file_code" | grep -qE "$subscription_pattern"; then
    hook_warn "This useTable selector opts out of parent re-renders while the component reads reactive Table methods. Add a narrow Subscribe/useSelector boundary."
  fi

  if printf '%s' "$added_code" | grep -qE \
    '\.(getIs[A-Z]|getCan[A-Z]|getFilterValue\(|getSize\(|getValue\(|renderValue\()' &&
    ! printf '%s' "$file_code" | grep -qE '\buseTable[[:space:]]*\(' &&
    ! printf '%s' "$file_code" | grep -qE "$subscription_pattern"; then
    hook_warn "TanStack Table V9 row/cell/column/header objects are stable. Reactive method reads in extracted components need Subscribe or useSelector at this component or an ancestor."
  fi
}
