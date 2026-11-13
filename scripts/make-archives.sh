#!/usr/bin/env bash
# Quarto post-render hook: pack each code/NN_name/ folder into
# <output>/code/NN_name.tar.gz so students can fetch an exercise with wget.
set -euo pipefail
out="${QUARTO_PROJECT_OUTPUT_DIR:-_book}"
mkdir -p "$out/code"
for d in code/*/; do
  name=$(basename "$d")
  COPYFILE_DISABLE=1 tar --exclude='.DS_Store' -czf "$out/code/$name.tar.gz" -C code "$name"
done
