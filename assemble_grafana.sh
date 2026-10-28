#!/usr/bin/env bash
# Собирает исходный архив из частей в каталоге parts/ и проверяет SHA-256.
set -euo pipefail

cd "$(dirname "$0")"

NAME="grafana_13.3.0_40412481033_linux_amd64.tar.gz"
PARTS_DIR="parts"
OUT="${1:-$NAME}"
EXPECTED="$(awk '{print $1}' "$PARTS_DIR/$NAME.sha256")"

shopt -s nullglob
parts=("$PARTS_DIR/$NAME.part-"*)
shopt -u nullglob

if [ "${#parts[@]}" -eq 0 ]; then
    echo "Не найдены части: $PARTS_DIR/$NAME.part-*" >&2
    exit 1
fi

echo "Собираю $OUT из ${#parts[@]} частей..."
cat "${parts[@]}" > "$OUT"

if command -v sha256sum >/dev/null 2>&1; then
    ACTUAL="$(sha256sum "$OUT" | awk '{print $1}')"
else
    ACTUAL="$(shasum -a 256 "$OUT" | awk '{print $1}')"
fi

if [ "$ACTUAL" != "$EXPECTED" ]; then
    echo "ОШИБКА: контрольная сумма не совпала!" >&2
    echo "  ожидалось: $EXPECTED" >&2
    echo "  получено:  $ACTUAL" >&2
    exit 1
fi

echo "Готово: $OUT"
echo "SHA-256 совпала: $ACTUAL"
