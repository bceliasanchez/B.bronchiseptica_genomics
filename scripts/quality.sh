#!/usr/bin/env bash
set -euo pipefail

ACCESSION_FILE="accessions.clean.txt"   # one SRR ID per line
OUTDIR="./q30_summaries"
LOG="./q30_run.log"

mkdir -p "$OUTDIR"
: > "$LOG"

while IFS= read -r line; do
  # trim whitespace and skip empty lines
  acc="$(echo "$line" | awk '{$1=$1; print}')"
  [ -z "$acc" ] && continue

  out="$OUTDIR/${acc}q30_summary.txt"
  echo "$(date --iso-8601=seconds) - ${acc}: starting" | tee -a "$LOG"

  if fasterq-dump "$acc" --split-spot --stdout 2>>"$LOG" | \
     seqtk fqchk -q 30 - 2>>"$LOG" | \
     grep -v '^#' > "$out"; then
    echo "$(date --iso-8601=seconds) - ${acc}: DONE" | tee -a "$LOG"
  else
    echo "$(date --iso-8601=seconds) - ${acc}: FAILED" | tee -a "$LOG"
    rm -f "$out"
  fi
done < "$ACCESSION_FILE"
