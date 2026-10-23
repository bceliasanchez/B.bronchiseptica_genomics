#Need to extract resistance genes from each of the spades directories
module load seqkit

for asm in ../fastq/spades/*/contigs.fasta; do
    sample=$(basename "$(dirname "$asm")")
    hits=blast_results/"$sample"_best_hits.tsv
    out=extracted_genes/"$sample"_genes.fna

    seqkit faidx "$asm"
    > "$out"

    while read gene contig pident length qlen qstart qend sstart send evalue bitscore; do

        if [ "$sstart" -lt "$send" ]; then
            start="$sstart"
            end="$send"
            strand="+"

            seqkit faidx "$asm" "${contig}:${start}-${end}" \
            | sed "s/^>.*/>${sample}|${gene}|${contig}:${start}-${end}|strand=${strand}|pident=${pident}/" \
            >> "$out"

        else
            start="$send"
            end="$sstart"
            strand="-"

            seqkit faidx "$asm" "${contig}:${start}-${end}" \
            | seqkit seq -r -p \
            | sed "s/^>.*/>${sample}|${gene}|${contig}:${start}-${end}|strand=${strand}|pident=${pident}/" \
            >> "$out"
        fi

    done < "$hits"
done


# run this check
wc -l gene_list.txt
head gene_list.txt
ls extracted_genes/*_genes.fna | head
grep -m 3 '^>' extracted_genes/*_genes.fna

#run to get genes.fna with all the sequences in it
rm -rf per_gene_fastas
mkdir -p per_gene_fastas

cat gene_list.txt | tr -d '\r' | while read gene; do
    [ -z "$gene" ] && continue

    awk -v gene="$gene" '
        /^>/ {
            split($0, a, "|")
            keep = (a[2] == gene)
        }
        keep { print }
    ' extracted_genes/*_genes.fna > "per_gene_fastas/${gene}.fna"
done

find per_gene_fastas -type f -size 0 -delete


#check that it worked
ls per_gene_fastas | head
grep -c '^>' per_gene_fastas/*.fna
