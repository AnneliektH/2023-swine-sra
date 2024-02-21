# imports
import os
import pandas as pd

# include snakefiles
include: "snakefiles/sra_download.smk"
include: "snakefiles/fasterq_dump.smk"
include: "snakefiles/atlas.smk"
include: "snakefiles/vOTU.smk"
include: "snakefiles/mv_mags.smk"
include: "snakefiles/sourmash_gather.smk"

# set configfile with samplenames
configfile: "config.yaml"

# define output atlas dir
atlas_dir = 'atlas'

# Load the metadata file
metadata = pd.read_csv(config['metadata_file_path'], usecols=['Run'])


# Create a list of run ids
samples = metadata['Run'].tolist()

# Define samples
SAMPLES = config.get('samples', samples)

wildcard_constraints:
    sample='\w+',

rule all:
    input:
        expand("atlas/check/move_{sample}.check", sample=SAMPLES,), 
        expand("virsorter2/check/{sample}_rename.check", sample=SAMPLES)
       # expand("sourmash/fastgather-vir/{sample}.csv", sample=SAMPLES),
       # expand("sourmash/vir/{sample}.csv", sample=SAMPLES)
       # expand("sourmash/MAGs_gtdbk-reps-sub/{sample}.csv", sample=SAMPLES)
