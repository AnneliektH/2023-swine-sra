# imports
import os
import pandas as pd

# include snakefiles
include: "sra_download.snakefile"
include: "fasterq_dump.snakefile"
include: "atlas.snakefile"
include: "vOTU.snakefile"

# set configfile with samplenames
configfile: "config.yaml"

# define output atlas dir
atlas_dir = 'atlas'

# Load the metadata file
metadata = pd.read_csv(config['metadata_file_path'], usecols=['Run'])

# Create a list of run ids
sra_runs = metadata['Run'].tolist()

# Define samples
SAMPLES = config.get('samples', sra_runs)

wildcard_constraints:
    sample='\w+',

rule all:
    input:
        expand("atlas/check/atlas_done_{sample}_bin.check", sample=SAMPLES),
        expand("virsorter2/contigs/{sample}_rename.fa", sample=SAMPLES)
       


