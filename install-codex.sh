#!/usr/bin/env bash
# Устанавливает skills Runewright напрямую для локальной разработки без marketplace.
# По умолчанию — глобально в ~/.agents/skills; --project <dir> — в <dir>/.agents/skills.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
TARGET="$HOME/.agents/skills"

usage() {
  echo "Usage: $0 [--project <dir>]"
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--project" ]]; then
  [[ -n "${2:-}" && -z "${3:-}" ]] || { usage >&2; exit 2; }
  TARGET="$(cd "$2" && pwd)/.agents/skills"
elif [[ -n "${1:-}" ]]; then
  usage >&2
  exit 2
fi

[[ -d "$SRC_DIR" ]] || { echo "ERROR: skills directory not found: $SRC_DIR" >&2; exit 1; }

mkdir -p "$TARGET"
installed=0
skipped=0
for skill in "$SRC_DIR"/*/; do
  name="$(basename "$skill")"
  dest="$TARGET/$name"
  if [[ -L "$dest" ]]; then
    ln -sfn "${skill%/}" "$dest"
    installed=$((installed+1))
  elif [[ -e "$dest" ]]; then
    echo "CONFLICT $name: $dest существует и не является симлинком" >&2
    skipped=$((skipped+1))
  else
    ln -s "${skill%/}" "$dest"
    installed=$((installed+1))
  fi
done

echo "Готово: $installed симлинков в $TARGET (пропущено: $skipped)."
if (( skipped > 0 )); then
  echo "Установка неполная: устраните конфликты и запустите скрипт повторно." >&2
  exit 1
fi

echo "Проверка: запустите Codex и выполните /skills — скиллы skill-brief, skill-generator,"
echo "subagent-generator, skill-audit, runewright-blueprint должны быть в списке."
