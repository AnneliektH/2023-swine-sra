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
        "envs/sra_environment.yml"
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