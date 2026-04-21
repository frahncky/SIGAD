#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

violations=0

report_violations() {
  local title="$1"
  local pattern="$2"
  local include_glob="$3"

  mapfile -t files < <(find lib/features -type f -name "*.dart" -path "$include_glob")
  if [ "${#files[@]}" -eq 0 ]; then
    return 0
  fi

  local output
  output=$(grep -nE "$pattern" "${files[@]}" || true)
  if [ -n "$output" ]; then
    echo "[Layer boundary] $title"
    echo "$output"
    echo
    violations=1
  fi
}

# Domain nao deve importar data/presentation/flutter.
report_violations \
  "domain nao pode importar data/presentation" \
  "^import '.*\/(data|presentation)\/.*';" \
  "*/domain/*"

report_violations \
  "domain nao deve depender de Flutter" \
  "^import 'package:flutter\/.*';" \
  "*/domain/*"

# Data nao deve importar presentation.
report_violations \
  "data nao pode importar presentation" \
  "^import '.*\/presentation\/.*';" \
  "*/data/*"

if [ "$violations" -ne 0 ]; then
  echo "Falha: regras de arquitetura por camada violadas."
  exit 1
fi

echo "Layer boundaries: OK"
