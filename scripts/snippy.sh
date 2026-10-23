#copy filtered files to a snippy directory
cp fastq/filtered_q30/* snippy/
#rename any files to match this format: accession_1.fastq.gz or accession_2.fastq.gz
bash -c 'shopt -s nullglob; for f in *_1.final.fastq.gz *_2.final.fastq.gz; do [ -e "$f" ] || continue; new="${f/.final.fastq.gz/.fastq.gz}"; if [ -e "$new" ]; then echo "Skipping $f -> $new (target exists)"; else mv -- "$f" "$new"; fi; done'

#run snippy on filtered isolates for paired reads
REF="GCF_000195675.1_ASM19567v1_genomic.fna"; for sample in $(ls *_1.fastq.gz | sed 's/_1.fastq.gz//'); do echo "Running snippy for sample: $sample"; snippy --cpus 8 --outdir "${sample}_snippy" --ref "$REF" --R1 "${sample}_1.fastq.gz" --R2 "${sample}_2.fastq.gz"; done
	
#produce core alignment from snippy outputs
snippy-core --ref GCF_000195675.1_ASM19567v1_genomic.fna --prefix core_out snippy/*_snippy

#rename isolates in snippy alignment
awk '/^>/{sub(/_snippy(\b|$)/,"",$0)} {print}' core_out.full.aln > core_out.full.rename.aln


