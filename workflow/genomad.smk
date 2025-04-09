# imports
import os
import pandas as pd

# Load the metadata file
metadata = pd.read_csv('config/atlas_done.txt', usecols=['Run'])
# Create a list of run ids
samples = metadata['Run'].tolist()
# Define samples
SAMPLES = config.get('samples', samples)

rule all:
    input:
        expand("../results/genomad/check/{sample}.check", sample=SAMPLES),

rule genomad:
    input:
        fa="../results/atlas/atlas_{sample}/{sample}/{sample}_contigs.fasta" 
    output:
        check = "../results/genomad/check/{sample}.check"
    conda: 
        "genomad"
    threads: 20
    shell:
        """
        genomad end-to-end --threads {threads} --enable-score-calibration \
        --cleanup {input.fa} ../results/genomad/{wildcards.sample} \
        /home/amhorst/databases/genomad/genomad_db && touch {output.check}
        """

rule rename:
rule bbmap_rename_viral:
    input: 
        check = "../results/genomad/check/{sample}.check"
    output: 
        contigs_viral = "../results/genomad/viral/{sample}_viral_rename.fa",
        contigs_plasmid = "../results/genomad/plasmid/{sample}_plasmid_rename.fa",
    conda: 
        "bbmap"
    shell:
        """
        rename.sh in=../results/genomad/{wildcards.sample}/{wildcards.sample}_contigs_summary/{wildcards.sample}_contigs_virus.fna \
        out={output.contigs} prefix=AtH2025_{wildcards.sample}_viral && \
        rename.sh in=../results/genomad/{wildcards.sample}/{wildcards.sample}_contigs_summary/{wildcards.sample}_contigs_plasmid.fna \
        out={output.contigs} prefix=AtH2025_{wildcards.sample}_plasmid

        """
