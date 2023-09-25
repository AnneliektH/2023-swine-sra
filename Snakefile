# imports
import os
import pandas as pd

# include snakefiles
include: "sra_download.snakefile"
include: "fasterq_dump.snakefile"
include: "atlas.snakefile"
include: "vOTU.snakefile"
include: "mv_mags.snakefile"

# set configfile with samplenames
configfile: "config.yaml"

# define output atlas dir
atlas_dir = 'atlas'

# Load the metadata file
metadata = pd.read_csv(config['metadata_file_path'], usecols=['Run', 'perc_sourm'])

# create dict 
DICT = metadata.to_dict(orient='index')
project_run ={each['perc_sourm']: {each['Run']} for each in DICT.values()}

print(project_run)

wildcard_constraints:
    sample='\w+',

for each in DICT.values():
    project = each['perc_sourm']
    run = each['Run']
    project_run[project] |= {run}

wildcard_constraints:
    sample='\w+',

atlas_out = [
    expand(
        f"atlas/check/{project}/move_{run}.check"
        )
    for project, sample_list in project_run.items() for run in sample_list]

virsorter_out = [
    expand(
        f"virsorter2/contigs/{project}/{run}_rename.fa"
        )
    for project, sample_list in project_run.items() for run in sample_list]

rule all:
    input:
        atlas_out,
        virsorter_out