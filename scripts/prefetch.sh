#!/usr/bin/env bash
set -euo pipefail

ACCESSION_FILE="accessions.clean.txt"
SRA_DIR="/path/to/sra/directory"    # change to your local sra directory
LOG="prefetch.log"

mkdir -p "$SRA_DIR"
: > "$LOG"   # truncate log

while IFS= read -r acc_raw; do
  acc="$(echo "$acc_raw" | awk '{$1=$1; print}')"
  [ -z "$acc" ] && continue

  sra_path="$SRA_DIR/${acc}.sra"
  if [ -f "$sra_path" ]; then
    printf "%s: already present, skipping\n" "$acc" | tee -a "$LOG"
    continue
  fi

  printf "%s: prefetching...\n" "$acc" | tee -a "$LOG"
  if prefetch --output-directory "$SRA_DIR" "$acc"; then
    printf "%s: success\n" "$acc" | tee -a "$LOG"
  else
    printf "%s: FAILED\n" "$acc" | tee -a "$LOG"
  fi
done < "$ACCESSION_FILE"

