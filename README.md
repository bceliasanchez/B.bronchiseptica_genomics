# Genomic Diversity of *Bordetella bronchiseptica*

## Overview

This repository contains analysis scripts and workflow notes for the manuscript:
Comparative Genomics of Human-Associated Bordetella bronchiseptica Reveals Within-Host Diversity and Close Relatedness to an Animal Vaccine Strain

The repository includes scripts for quality control, variant calling, phylogenetic analysis, and gene analysis.

The study investigates:

- Whole-genome phylogenetic relationships
- Within-host genomic diversity
- Antimicrobial resistance genes
- Virulence-associated genes
- Relationships between human-associated isolates and animal vaccine strains

## Repository Contents

```text
.
├── data/           # Input files
├── scripts/        # Analysis and visualization scripts
├── results/        # Summary tables and figures
└── README.md
```

## Data Availability

Genome sequences and associated metadata are available through the relevant public sequence repositories.

> Metadata can be found in Supplemental Table 2.

## Analysis Workflow

The analysis includes:

1. Genome quality control
2. Genome assembly or sequence preprocessing
3. SNP alignment and phylogenetic analysis
4. Within-host diversity analysis
5. Antimicrobial resistance gene detection
6. Virulence gene profiling
7. Phylogenetic visualization and interpretation

## Requirements

> sra-toolkit,version 3.4.1 (https://github.com/ncbi/sra-tools)
> seqtk,version 1.5 (https://github.com/lh3/seqtk)
> mash,version 2.3 (https://github.com/marbl/Mash)
> bowtie2,version 2.5.5 (https://github.com/BenLangmead/bowtie2)
> fastp,version 1.3.6, (https://github.com/OpenGene/fastp)
> snippy,version 4.6.0 (https://github.com/tseemann/snippy)
> snp-dists,version 0.8.2 (https://github.com/tseemann/snp-dists)
> R package pheatmap (https://CRAN.R-project.org/package=pheatmap)
> IQTree,version 3.1.0 (https://iqtree.github.io/)
> SPAdes,version 4.3.0 (https://github.com/ablab/spades)
> AMRFinderPlus (https://github.com/ncbi/amr)
> Geneious Prime,version 2026.0.2 (https://www.geneious.com/)
 

## Results

Processed results, phylogenetic trees, antimicrobial resistance profiles, virulence gene profiles, and publication figures are available in the `results/` directory.

## Reproducibility

All analyses were performed using the scripts and workflows provided in this repository. Software versions, configuration files, and input metadata should be documented to support reproducibility.

## Citation

If you use this repository or its data, please cite:

> Add the manuscript citation here.


## Contact

For questions or issues, please open a GitHub issue or email the corresponding author from the manuscript.
