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
srun --account=ctbrowngrp -p med2 -J smash -t 48:00:00 -c 36 --mem=30gb --pty bash
srun --account=ctbrowngrp -p bmm -J bin -t 4:00:00 -c 12 --mem=50gb --pty bash
srun --account=ctbrowngrp -p med2 -J smash -t 3:00:00 -c 1 --mem=30gb --pty bash
srun --account=ctbrowngrp -p bmm -J prodigal -t 36:00:00 -c 1 --mem=30gb --pty bash

# run atlas ins creen
atlas run genomes --configfile ../../atlas_config.yaml \
-w . --default-resources mem_mb=70000 -j 12

# to run the smash pipeline
srun --account=ctbrowngrp -p med2 -J readsig -t 6:00:00 -c 32 --mem=50gb --pty bash
snakemake --use-conda --resources mem_mb=50000 --rerun-triggers mtime -c 32 --rerun-incomplete -k --latency-wait 30

mamba activate snakemake
snakemake --use-conda --resources mem_mb=75000 --rerun-triggers mtime -c 100 --rerun-incomplete -k 


snakemake --use-conda -s Snakefile_gather --resources mem_mb=20000 --rerun-triggers mtime -c --rerun-incomplete -k
snakemake --resources mem_mb=25000 --rerun-triggers mtime -c 6 --rerun-incomplete -k

mamba activate sourmash 
cd atlas/MAGs/genomes/
mkdir all_fasta
mv */*.fasta all_fasta

<!-- # We want to sketch individually bc otherwise 1 signature per contig, not per MAG
cd all_fasta
module load parallel
for i in $("*.fasta") ; do echo sourmash sketch dna -p k=21,scaled=1000 $i ; done | parallel -j 32  -->

# I think I forgot to give each of the sketches a name : In gather no MAG names
# re do the sketches 
module load parallel
mamba activate branchwater

for f in *.fasta
do
echo sourmash sketch dna -p k=21,scaled=1000,k=31,scaled=1000,k=51,scaled=1000 $f --name ${f%.fasta*} -o ../sigs/${f%.fasta*}.zip
done | parallel -j 32

# Concatenate all signatures
sourmash sig cat *.zip -o ../../../all-MAGs_21.zip && \
sourmash sig collect *.zip -o ../../../all-MAGs_21.sqlmf

# for viral sigs make individual fasta files too
# Do with the deduplicated vOTUs 
cd votu_smash
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' ../../virsorter2/240108_all_viralcontigs.sorted.cluster.fa

cd virsorter2/contigs
cat *.fa > all_virus.fa
cd individ_contigs
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' ../all_virus.fa

module load parallel
mamba activate branchwater

for f in *.fa
do
echo sourmash sketch dna -p k=21,scaled=100,k=31,scaled=100,k=51,scaled=100 $f --name ${f%.fa*} -o ../sigs/${f%.fa*}.zip
done | parallel -j 32

# Concatenate all signatures
sourmash sig cat sigs/*.zip -o ../all-votu_21.zip && \
sourmash sig collect sigs/*.zip -o ../all-votu_21.sqlmf

# check number of contigs
# viral
cd virsorter2/contigs
grep -c '>' *.fa > 2023_num_contigs.txt

# MAG  
cd atlas
for i in atlas_*/genomes/genomes; do echo $i: $(ls "$i" | wc -l); done > ./MAGs/240108_num_genomes.tsv

# For one set of MAGs: Data deleted and taxonomy files lost. 
# Installed gtdbtk as to not re-run all of atlas
srun --account=ctbrowngrp -p med2 -J smash -t 6:00:00 -c 16 --mem=60gb --pty bash
cd atlas_ERR1135187/
mamba activate gtdbtk
gtdbtk classify_wf --cpus 16 --genome_dir ./genomes/genomes/ --extension fasta \
--outdir ./genomes/taxonomy/ 


<!-- # Probably easier to make a list of the db to use
python /home/ctbrown/scratch/2022-database-covers/make-db-cover.py \
/group/ctbrowngrp2/scratch/annie/2023-swine-sra/atlas/MAGs/all-MAGs_21.zip \
-o mags.k21.cover.zip --scaled=10000 -k 21 -->
<!-- 
mkdir -p mags.k21.cover.d
cd mags.k21.cover.d 
sourmash sig split ../mags.k21.cover.zip -E .sig.gz
cd ..
find $(pwd)/mags.k21.cover.d -type f > list.mags.k21.cover.txt
cat list.mags.k21.cover.txt /home/ctbrown/scratch/2022-database-covers/list.gtdb-rs214.k21.cover.txt >> list.mags-gtdb-r214.k21.cover.txt -->

# remove carrots from header files
sed 's/[>]//g' file.txt > filenocar.txt

# remove the word fasta
 sed 's/[.fasta]//g' 

 # move/copy files from a list into a new folder
 for f in $(cat MAGs.txt); do mv $f.fasta /folder/; done

 for f in $(cat ../../../genome_stats/240214_cdhit_votus.95.nc.txt)
 do
 mv $f.zip ./95/
 done

cd 95
sourmash sig cat *.zip -o ../../signatures_concat/

mv *.zip ../
cd ..
mkdir 99
 for f in $(cat ../../../genome_stats/240214_cdhit_votus.99.nc.txt)
 do
 echo $f
 mv $f.zip ./99/
 done
cd 99
sourmash sig cat *.zip -o ../../signatures_concat/

mv *.zip ../
cd ..


## Rename the csv files with viral scores
for f in */final-viral-combined.fa
do 
echo $f
grep -e '>' $f > header_files/oldhead/${f%/*}.csv
echo ${f%/*}
done
grep -e '>' $f > 

for f in *rename*.fa
do
echo $f
grep -e '>' $f > ../../header_files/newhead/${f%_rename*}.csv
echo ${f%_rename*}.csv
done

for f in *.csv
do
sed 's/[<>,]//g' $f > ../oldheadclean/$f
done

for f in *.csv
do
sed 's/[<>,]//g' $f > ../newheadclean/$f
done 

for f in *.csv
do
paste -d "\t" $f ../newheadclean/$f > ../concathead/$f
done

# add header
for f in *.csv
do
csvtk add-header -t $f -n seqname,newname > $f.newname
done

# concat all
csvtk concat -t *.newname > ../all_headkeys.tsv

# join the final csvs
csvtk join -t -f seqname all_viralscore.tsv all_headkeys.tsv > renamed_viralscore.tsv

 # cdhit the viral sequences. 
 keep only the ones with a score and remove duplicate sequences
seqkit rmdup -s < all_viswithscore.fa > 240206_all_viral_seqs.fa

 # first sort by lenght
 mamba activate bbmap
 sortbyname.sh in=240206_all_viral_seqs.fa \
 out=240206_all_viral_seqs.sorted.fa length descending

mamba activate cdhit
cd-hit-est -i 240214_allvOTUs_highq.sort.fasta \
-o 240214_allvOTUs_highq.95.sorted.cluster.fa \
-c 0.95 -aS 0.85 -M 70000 -T 32 && \
cd-hit-est -i 240214_allvOTUs_highq.sort.fasta \
-o 240214_allvOTUs_highq.99.sorted.cluster.fa \
-c 0.99 -aS 0.85 -M 70000 -T 32

# in atlas/MAGs/genomes/all_fasta/fastafiles/
for f in *.fasta
do
sourmash sketch dna \
-p k=21,scaled=1000,k=31,scaled=1000,k=51,scaled=1000 \
$f --name ${f%.fasta*} -o \
../../../../../sourmash/sig_files/MAGs/${f%.fasta*}.zip && mv $f ./smashsig_complete/
done | parallel -j 32

# for votus
module load parallel
mamba activate branchwater

for f in *.fa
do
echo sourmash sketch dna \
-p k=21,scaled=1000,k=31,scaled=1000 \
$f --name ${f%.fa*} \
-o ../sketch_vOTUs/${f%.fa*}.zip && mv $f ./smashsig_complete/
done | parallel -j 32

# Do an mgmanysearch for abundance of vOTUs and MAGs in samples
# sourmash mgsearch, one metag per file, only flat sigs 
# change the source code to do the ksize and scale i want
in /home/amhorst/mambaforge/envs/sourmash/lib/python3.10/site-packages/sourmash_plugin_containment_search.py
sourmash scripts mgsearch ERR3211994_0.k15.sig ERR3211994.abund.k15.reads.sig.gz \
-k 15 --scaled 100

sourmash scripts mgmanysearch --queries ERR3211994.contigs.single.k15.sig.gz \
--against ERR3211994.R1.abund.k15.reads.sig.gz -k 15 --scaled 100 -o mgmanysearch.abund.csv

