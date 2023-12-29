# run the snakefile
mamba activate snakemake

snakemake --use-conda --cluster-config cluster_snake.json --resources mem=50G -p --rerun-triggers mtime -k \
--jobs 30 --latency-wait 30000 --cluster \
"sbatch --partition {cluster.partition} \
--ntasks {cluster.ntasks} -N {cluster.nodes} \
--job-name {cluster.job_name} --mem {cluster.mem} \
-t {cluster.time} --account {cluster.account} \
-e {cluster.error} -o {cluster.output} --parsable"

# when using mem limits stated in .json (for smash)
snakemake --use-conda --cluster-config cluster_snake.json -p --rerun-triggers mtime -k \
--jobs 30 --latency-wait 30000 --cluster \
"sbatch --partition {cluster.partition} \
--ntasks {cluster.ntasks} -N {cluster.nodes} \
--job-name {cluster.job_name} --mem {cluster.mem} \
-t {cluster.time} --account {cluster.account} \
-e {cluster.error} -o {cluster.output} --parsable" -n

# also run gather for all these with just gtdbk
# create a sourmash zip and rerun
# srun for smash
srun -p bmm -J smashdb -t 8:00:00 -c 1 --mem=50gb --pty bash
srun -p bmm -J smashdb -t 8:00:00 -c 1 --mem=50gb --pty bash

srun -p med2 -J atlgen -t 3:00:00 -c 8 --mem=50gb --pty bash

mamba activate snakemake
snakemake --use-conda --resources mem_mb=50000 --rerun-triggers mtime -c 24 

mamba activate sourmash 
cd atlas/MAGs/genomes/
mkdir all_fasta
mv */*.fasta all_fasta

# We want to sketch individually bc otherwise 1 signature per contig, not per MAG
cd all_fasta
module load parallel
for i in $("*.fasta") ; do echo sourmash sketch dna -p k=21,scaled=1000 $i ; done | parallel -j 32 

# I think I forgot to give each of teh sketches a name : In gather no MAG names
# re do the sketches 
module load parallel
mamba activate branchwater

for f in *.fasta
do
echo $f
echo ${f%_*}
echo sourmash sketch dna -p k=21,scaled=1000 $f --name ${f%.fasta*} -o ${f%.fasta*}.sig
done | parallel -j 32

# Concatenate all signatures
sourmash sig cat *.sig -o ../../all-MAGs_21.zip
sourmash sig collect *.sig -o ../../all-MAGs_21.sqlmf

# for viral sigs make individual fasta files too
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' ../all_virus.fa
module load parallel
for f in *.fa
do
echo $f
echo ${f%.fa*}
echo sourmash sketch dna -p k=21,scaled=1000 $f --name ${f%.fa*} -o ./sigs/${f%.fa*}.sig
done | parallel -j 32
# Concatenate all signatures
sourmash sig cat sigs/*.sig -o ../all-votu_21.zip
sourmash sig collect sigs/*.sig -o ../all-votu_21.sqlmf

# Probably easier to make a list of the db to use
python /home/ctbrown/scratch/2022-database-covers/make-db-cover.py \
/group/ctbrowngrp2/scratch/annie/2023-swine-sra/atlas/MAGs/all-MAGs_21.zip \
-o mags.k21.cover.zip --scaled=10000 -k 21

mkdir -p mags.k21.cover.d
cd mags.k21.cover.d 
sourmash sig split ../mags.k21.cover.zip -E .sig.gz
cd ..
find $(pwd)/mags.k21.cover.d -type f > list.mags.k21.cover.txt
cat list.mags.k21.cover.txt /home/ctbrown/scratch/2022-database-covers/list.gtdb-rs214.k21.cover.txt >> list.mags-gtdb-r214.k21.cover.txt
