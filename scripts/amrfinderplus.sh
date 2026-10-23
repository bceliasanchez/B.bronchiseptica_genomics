#install amrfinderplus using conda
conda create --prefix ~/envs/amrfinder -c conda-forge -c bioconda ncbi-amrfinderplus

# To activate this environment, use
conda activate /path/to/amrfinder

#run amrfinderplus in a loop

for contigs in fastq/spades/*.dir/contigs.fasta; do
    sample=$(basename "$(dirname "$contigs")" .dir)

    amrfinder \
        -n "$contigs" \
        -o "fastq/spades/${sample}_amr_results.txt"
done

