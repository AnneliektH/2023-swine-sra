# imports
import os
import pandas as pd

# include snakefiles
include: "sra_download.smk"
include: "fasterq_dump.smk"
include: "atlas.smk"
include: "vOTU.smk"
include: "mv_mags.smk"
include: "sourmash_gather.smk"

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
       # expand("atlas/check/move_{sample}.check", sample=SAMPLES,), 
       # expand("virsorter2/contigs/{sample}_rename.fa", sample=SAMPLES),
        expand("sourmash/only_gtdbk-reps-sub/{sample}.csv", sample=SAMPLES),
       # expand("sourmash/fastgather-reps-sub/{sample}.csv", sample=SAMPLES)
        expand("sourmash/MAGs_gtdbk-reps-sub/{sample}.csv", sample=SAMPLES)


# virsorter_out = [
#     expand(
#         f"virsorter2/contigs/{project}/{run}_rename.fa"
#         )
#     for project, sample_list in project_run.items() for run in sample_list]

# sourmash_out = [
#     expand(
#         f"sourmash/{run}.csv"
#         )
#     for project, sample_list in project_run.items() for run in sample_list] 

# rule all:
#     input:
#         sourmash_out