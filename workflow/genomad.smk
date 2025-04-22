# imports
import os
import pandas as pd

# Load the metadata file
metadata = pd.read_csv('config/atlas_done_nocontigsrm.txt', usecols=['Run'])
# Create a list of run ids
samples = metadata['Run'].tolist()
# Define samples
SAMPLES = config.get('samples', samples)

rule all:
    input:
        expand("../results/genomad/check/{sample}.check", sample=SAMPLES),
        expand("../results/genomad/viral/{sample}_viral_rename.fa", sample=SAMPLES),
        expand("../results/genomad/plasmid/{sample}_plasmid_rename.fa", sample=SAMPLES),

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

# rule_filter_score:
#     input: 
#         check = "../results/genomad/check/{sample}.check",
#         filter_file = "/group/ctbrowngrp2/amhorst/2025-pigparadigm/results/viral/high_virus_score_seqs.txt",
#     output: 
#         contigs_viral = "../results/genomad/viral/{sample}_viral_highscore.fa",
#         contigs_plasmid = "../results/genomad/plasmid/{sample}_plasmid_highscore.fa",
#     conda: 
#         "bbmap"
#     shell:
#         """
#         filterbyname.sh in=../results/genomad/{wildcards.sample}/{wildcards.sample}_contigs_summary/{wildcards.sample}_contigs_virus.fna \
#         out={output.contigs_viral} names={input.filter_file} include=t && \
#         filterbyname.sh in=../results/genomad/{wildcards.sample}/{wildcards.sample}_contigs_summary/{wildcards.sample}_contigs_plasmid.fna \
#         out={output.contigs_plasmid} names={input.filter_file} include=t
#         """
rule scorefilter:
    input: 
        check = "../results/genomad/check/{sample}.check",
        names_viral = "/group/ctbrowngrp2/amhorst/2025-pigparadigm/results/viral/high_virus_score_seqs.txt",
        names_plasmid = "/group/ctbrowngrp2/amhorst/2025-pigparadigm/results/plasmids/high_plasmid_score_seqs.txt",
    output: 
        contigs_viral = "../results/genomad/viral/{sample}_viral_score.fa",
        contigs_plasmid = "../results/genomad/plasmid/{sample}_plasmid_score.fa",
    conda: 
        "bbmap"
    shell:
        """
        filterbyname.sh \
        in=../results/genomad/{wildcards.sample}/{wildcards.sample}_contigs_summary/{wildcards.sample}_contigs_virus.fna \
        out={output.contigs_viral} names={input.names_viral} include=t && \
        filterbyname.sh in=../results/genomad/{wildcards.sample}/{wildcards.sample}_contigs_summary/{wildcards.sample}_contigs_plasmid.fna \
        out={output.contigs_plasmid} names={input.names_plasmid} include=t
        """

rule bbmap_rename_viral:
    input: 
        contigs_viral = "../results/genomad/viral/{sample}_viral_score.fa",
        contigs_plasmid = "../results/genomad/plasmid/{sample}_plasmid_score.fa",
    output: 
        contigs_viral = "../results/genomad/viral/{sample}_viral_rename.fa",
        contigs_plasmid = "../results/genomad/plasmid/{sample}_plasmid_rename.fa",
    conda: 
        "bbmap"
    shell:
        """
        rename.sh in={input.contigs_viral} \
        out={output.contigs_viral} prefix=AtH2025_{wildcards.sample}_viral && \
        rename.sh in={input.contigs_plasmid} \
        out={output.contigs_plasmid} prefix=AtH2025_{wildcards.sample}_plasmid
        """
