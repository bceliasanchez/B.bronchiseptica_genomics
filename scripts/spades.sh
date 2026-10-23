#Need to run spades to create contigs to blast

for file in *_1.fastq.gz
do
strain=${file%%_1.fastq.gz}
echo '#!/bin/bash' > scripts/${strain}_spades.sh
echo "#$ -N ${strain}_spades " >> scripts/${strain}_spades.sh
echo "#$ -cwd" >> scripts/${strain}_spades.sh
echo "#$ -pe smp 8" >> scripts/${strain}_spades.sh
echo "#$ -l h_rt=8:00:00" >> scripts/${strain}_spades.sh
echo "#$ -q long.q" >> scripts/${strain}_spades.sh
echo "#$ -l h_vmem=100G" >> scripts/${strain}_spades.sh
echo "#$ -o logs/${strain}_spades.out" >> scripts/${strain}_spades.sh
echo "#$ -e logs/${strain}_spades.err" >> scripts/${strain}_spades.sh
echo "source /etc/profile" >> scripts/${strain}_spades.sh
echo "ml spades" >> scripts/${strain}_spades.sh
echo "spades.py --careful --trusted-contigs GCF_000195675.1_ASM19567v1_genomic.fa --cov-cutoff auto -1 ${strain}_1.fastq.gz -2 ${strain}_2.fastq.gz -o spades/${strain}.dir" >> scripts/${strain}_spades.sh
chmod 755 scripts/${strain}_spades.sh
qsub scripts/${strain}_spades.sh
done

