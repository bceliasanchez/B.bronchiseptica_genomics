#if sequences are contaminated with phiX, run the following
#get phiX from NCBI
curl -O https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/705/GCF_000009705.1_ASM970v1/GCF_000009705.1_ASM970v1_genomic.fna.gz

gunzip GCF_000009705.1_ASM970v1_genomic.fna.gz

# optionally extract the phiX scaffold or rename to phix.fasta
cp GCF_000009705.1_ASM970v1_genomic.fna phix.fasta

#remove phiX by mapping then re-run fastp for cleanup
module load bowtie2

# build index (only once)
bowtie2-build phix.fasta phix_index

#create loop for aligning reads
#!/usr/bin/env bash
set -euo pipefail

for r1 in *_1.fastq.gz; do
  # derive sample base name by stripping the suffix
  sample="${r1%_1.fastq.gz}"
  r2="${sample}_2.fastq.gz"

  # skip if the mate file does not exist
  if [[ ! -e "$r2" ]]; then
    printf "Skipping %s: mate file %s not found\n" "$r1" "$r2" >&2
    continue
  fi

  printf "Processing sample: %s\n" "$sample"

  bowtie2 -x phix_index \
    -1 "$r1" -2 "$r2" \
    --very-sensitive \
    --un-conc-gz "${sample}_phix_unmapped_%.fastq.gz" \
    -S /dev/null

  printf "Done: %s\n\n" "$sample"
done

#create loop for running fastp on unmapped reads with >q30
module load fastp
module load pigz

pigz *.fastq
mkdir -p filtered_q30; for r1 in *_phix_unmapped_1.fastq.gz; do sample="${r1%_phix_unmapped_1.fastq.gz}"; r2="${sample}_phix_unmapped_2.fastq.gz"; if [[ ! -e "$r2" ]]; then printf "Skipping %s: mate %s not found\n" "$r1" "$r2" >&2; continue; fi; fastp --in1 "$r1" --in2 "$r2" --out1 "filtered_q30/${sample}_1.final.fastq.gz" --out2 "filtered_q30/${sample}_2.final.fastq.gz" --detect_adapter_for_pe --qualified_quality_phred 30 --length_required 30 --html "filtered_q30/${sample}_fastp.html" --json "filtered_q30/${sample}_fastp.json"; done

