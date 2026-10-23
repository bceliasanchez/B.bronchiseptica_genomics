#run fastp on all other sequences with >q30

module load fastp
module load pigz

pigz *.fastq
mkdir -p filtered_q30; for r1 in *_1.fastq.gz; do sample="${r1%_1.fastq.gz}"; r2="${sample}_2.fastq.gz"; if [[ ! -e "$r2" ]]; then printf "Skipping %s: mate %s not found\n" "$r1" "$r2" >&2; continue; fi; fastp --in1 "$r1" --in2 "$r2" --out1 "filtered_q30/${sample}_1.final.fastq.gz" --out2 "filtered_q30/${sample}_2.final.fastq.gz" --detect_adapter_for_pe --qualified_quality_phred 30 --length_required 30 --html "filtered_q30/${sample}_fastp.html" --json "filtered_q30/${sample}_fastp.json"; done

