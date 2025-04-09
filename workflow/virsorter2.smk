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
        expand("../results/virsorter2/check/{sample}_vs2_done.check", sample=SAMPLES),

rule virsorter2:
    input:
        fa="../results/atlas/atlas_{sample}/{sample}/{sample}_contigs.fasta" 
    output:
        check = "../results/virsorter2/check/{sample}_vs2_done.check"
    conda: 
        "virsorter2"
    threads: 12
    shell:
        """
        virsorter run all -w ../results/virsorter2/{wildcards.sample} \
        -d /group/jbemersogrp/databases/virsorter/ --prep-for-dramv \
        -i {input.fa} \
        --min-length 5000 -j {threads} --min-score 0.5 || true && touch {output.check}
        """