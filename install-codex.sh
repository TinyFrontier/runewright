#!/usr/bin/env bash
# Устанавливает скиллы runewright для Codex (стандарт Agent Skills) симлинками.
# По умолчанию — глобально в ~/.agents/skills; с флагом --project <dir> — в <dir>/.agents/skills.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
TARGET="$HOME/.agents/skills"

if [[ "${1:-}" == "--project" ]]; then
  [[ -n "${2:-}" ]] || { echo "Usage: $0 [--project <dir>]"; exit 1; }
  TARGET="$(cd "$2" && pwd)/.agents/skills"
elif [[ -n "${1:-}" ]]; then
  echo "Usage: $0 [--project <dir>]"; exit 1
fi

mkdir -p "$TARGET"
installed=0 skipped=0
for skill in "$SRC_DIR"/*/; do
  name="$(basename "$skill")"
  dest="$TARGET/$name"
  if [[ -L "$dest" ]]; then
    ln -sfn "${skill%/}" "$dest"; installed=$((installed+1))
  elif [[ -e "$dest" ]]; then
    echo "SKIP $name: $dest существует и не является симлинком — разберитесь вручную"
    skipped=$((skipped+1))
  else
    ln -s "${skill%/}" "$dest"; installed=$((installed+1))
  fi
done

echo "Готово: $installed симлинков в $TARGET (пропущено: $skipped)."
echo "Проверка: запустите Codex и выполните /skills — скиллы skill-brief, skill-generator,"
echo "subagent-generator, skill-audit, runewright-blueprint должны быть в списке."
