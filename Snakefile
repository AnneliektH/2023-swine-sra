# imports
import os
import pandas as pd

# set configfile with samplenames
configfile: "config.yaml"

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
        expand("sra/fasterq/{sample}.check", sample=SAMPLES)

# Download SRA files
rule download_sra:
    output:
        sra = "sra/{sample}"
    log:
        "logs/prefetch/{sample}.log"
    conda:
        "sra_environment.yml"
    shell:
        """
        mkdir -p ./sra/ 
        if [ ! -f "sra/fasterq/{wildcards.sample}.check" ] && [ ! -f "{output.sra}" ]; then
            aws s3 cp --quiet --no-sign-request s3://sra-pub-run-odp/sra/{wildcards.sample}/{wildcards.sample} {output.sra}
        fi
        """
# Download the whole thing, including smaller reads, as atlas will quality trim
rule fasterq_dump:
    input:
        sra_file = "sra/{sample}" 
    output:
        check = "sra/fasterq/{sample}.check",
        fastq_gz = "reads/{sample}.fastq.gz"
    log:
        "logs/fasterq_dump/{sample}.log"
    conda: 
        "sra_environment.yml"
    benchmark: "sra/fasterq/{sample}.benchmark"
    threads: 10
    shell:
        """
        fasterq-dump --threads 10 \
        --stdout --skip-technical \
        --fasta-unsorted  \
        --bufsize 1000MB --curcache 10000MB \
        {input.sra_file} >> sra/fasterq/{wildcards.sample} && \
        gzip -c sra/fasterq/{wildcards.sample} > {output.fastq_gz} && \
        rm -rf sra/fasterq/{wildcards.sample} && \
        rm -rf {input.sra_file} && \
        touch {output.check}
        """

