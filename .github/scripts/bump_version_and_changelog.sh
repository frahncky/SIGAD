#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Uso: $0 <version-sem-v> [release-notes]"
  exit 1
fi

TARGET_VERSION="$1"
RELEASE_NOTES="${2:-}"
DATE_TODAY="$(date +%Y-%m-%d)"

if [[ ! "$TARGET_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Versao invalida: $TARGET_VERSION (esperado X.Y.Z)"
  exit 1
fi

if [ ! -f pubspec.yaml ] || [ ! -f CHANGELOG.md ]; then
  echo "Execute o script na raiz do repositorio."
  exit 1
fi

CURRENT_BUILD="$(grep -E '^version:' pubspec.yaml | sed -E 's/version:[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+\+([0-9]+)/\1/' || true)"
if [[ -z "$CURRENT_BUILD" || ! "$CURRENT_BUILD" =~ ^[0-9]+$ ]]; then
  CURRENT_BUILD=1
else
  CURRENT_BUILD=$((CURRENT_BUILD + 1))
fi

sed -i -E "s/^version:[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+/version: ${TARGET_VERSION}+${CURRENT_BUILD}/" pubspec.yaml

if grep -q "## \[v${TARGET_VERSION}\]" CHANGELOG.md; then
  echo "CHANGELOG ja contem v${TARGET_VERSION}."
  exit 1
fi

TMP_CHANGELOG="$(mktemp)"
{
  head -n 3 CHANGELOG.md
  echo
  echo "## [v${TARGET_VERSION}] - ${DATE_TODAY}"
  echo
  echo "### Adicionado"
  echo "- "
  echo
  echo "### Alterado"
  echo "- "
  echo
  echo "### Corrigido"
  echo "- "
  if [ -n "$RELEASE_NOTES" ]; then
    echo
    echo "### Notas"
    echo "- ${RELEASE_NOTES}"
  fi
  echo
  tail -n +4 CHANGELOG.md
} > "$TMP_CHANGELOG"

mv "$TMP_CHANGELOG" CHANGELOG.md

echo "Versao atualizada para ${TARGET_VERSION}+${CURRENT_BUILD} e changelog preparado."
