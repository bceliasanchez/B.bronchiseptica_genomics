#!/usr/bin/env bash
set -euo pipefail

REFDB="refseq.genomes.k21s1000.msh"
OUTDIR="mash_results"
THREADS=4
RETRIES=2          # number of retries on failure
SORT_RESULTS=1     # set to 1 to create <acc>.screen.sorted
SORT_DESC=1        # 1 = sort descending (highest identity first), 0 = ascending

cd mash

pigz *.fastq

mkdir -p "$OUTDIR"

shopt -s nullglob
files=( *.fastq.gz )
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
  echo "No *.fastq.gz files found in current directory" >&2
  exit 0
fi

for fq in "${files[@]}"; do
  base="$(basename "$fq")"
  acc="${base%%.*}"                # strip extension(s) to get accession/name
  out_tmp="$OUTDIR/${acc}.screen.tmp"
  out="$OUTDIR/${acc}.screen"
  log="$OUTDIR/${acc}.log"

  if [ -f "$out" ]; then
    echo "$(date --iso-8601=seconds) $acc: already exists, skipping"
    continue
  fi

  echo "$(date --iso-8601=seconds) $acc: starting mash screen" | tee "$log"
  attempt=0
  success=0
  while [ $attempt -le $RETRIES ]; do
    attempt=$((attempt+1))
    if mash screen -p "$THREADS" "$REFDB" "$fq" > "$out_tmp" 2>> "$log"; then
      mv "$out_tmp" "$out"
      echo "$(date --iso-8601=seconds) $acc: done (attempt $attempt)" | tee -a "$log"
      success=1
      break
    else
      echo "$(date --iso-8601=seconds) $acc: attempt $attempt FAILED" | tee -a "$log"
      rm -f "$out_tmp"
      sleep $((attempt * 2))
    fi
  done

  if [ $success -ne 1 ]; then
    echo "$(date --iso-8601=seconds) $acc: FAILED after $RETRIES retries (see $log)" >&2
    continue
  fi

  if [ "$SORT_RESULTS" -eq 1 ]; then
    sorted="$OUTDIR/${acc}.screen.sorted"
    # choose sort flags: numeric, on field 2; reverse if SORT_DESC=1
    if [ "$SORT_DESC" -eq 1 ]; then
      sort_flags='-k2,2nr'
    else
      sort_flags='-k2,2n'
    fi

    # preserve single header line if present (lines starting with '#'), else sort all
    if head -n1 "$out" | grep -q '^#'; then
      { head -n1 "$out"; tail -n +2 "$out" | sort $sort_flags; } > "$sorted"
    else
      sort $sort_flags "$out" > "$sorted"
    fi

    echo "$(date --iso-8601=seconds) $acc: sorted -> $(basename "$sorted")" | tee -a "$log"
  fi
done

