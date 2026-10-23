#!/usr/bin/env bash
set -euo pipefail

ACC_FILE="accessions.clean.txt"
OUTDIR="mash"
mkdir -p "$OUTDIR"

while IFS= read -r raw; do
  acc="$(echo "$raw" | awk '{$1=$1; print}')"   # trim whitespace
  [ -z "$acc" ] && continue

  out="$OUTDIR/${acc}.fastq"
  if [ -f "$out" ]; then
    echo "$acc: output exists, skipping"
    continue
  fi

  f1="${acc}_1.fastq"
  f2="${acc}_2.fastq"

  if [ -f "$f1" ] && [ -f "$f2" ]; then
    echo "$acc: concatenating $f1 + $f2 -> $out"
    cat "$f1" "$f2" > "$out"
  else
    echo "$acc: PAIR MISSING - tried $f1 and $f2" >&2
  fi
done < "$ACC_FILE"

