# run the snakefile
mamba activate snakemake

snakemake --use-conda --cluster-config cluster_snake.json --resources mem=50 -p --rerun-triggers mtime -k \
--jobs 30 --latency-wait 30000 --cluster \
"sbatch --partition {cluster.partition} \
--ntasks {cluster.ntasks} -N {cluster.nodes} \
--job-name {cluster.job_name} \
-t {cluster.time} --account {cluster.account} \
-e {cluster.error} -o {cluster.output} --parsable"


# create a sourmash zip and rerun
# srun for smash
srun -p bmm -J pigs_smash -t 9:00:00 -c 8 --mem=50gb --pty bash

mamba activate sourmash 
cd atlas/MAGs/genomes/
mkdir all_fasta
mv */*.fasta all_fasta

# We want to sketch individually bc otherwise 1 signature per contig, not per MAG
cd all_fasta
module load parallel
for i in $(find . -name "*.fasta") ; do echo sourmash sketch dna -p k=21,scaled=1000 $i ; done | parallel -j 8

# Concatenate all signatures
sourmash sig cat *.sig -o ../all-MAGs_21.zip

# then run snakemake for this
