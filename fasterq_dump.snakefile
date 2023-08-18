# Download the whole thing, including smaller reads, as atlas will quality trim
rule fasterq_dump:
    input:
        sra_file = "sra/{sample}" 
    output:
        check = "checks/{sample}_fasterqdump.check",
        #fastq_gz = "reads/{sample}.fastq.gz"
    log:
        "logs/fasterq_dump/{sample}.log"
    conda: 
        "envs/sra_environment.yml"
    benchmark: "reads/fastq/{sample}.benchmark"
    threads: 10
    shell:
        """
        fasterq-dump {input.sra_file} --threads 10 \
        -O ./reads/fasterq/{wildcards.sample}_fq --skip-technical \
        --bufsize 1000MB --curcache 10000MB && \
        mv ./reads/fasterq/{wildcards.sample}_fq/{wildcards.sample}_* ./reads/fastq/ && \
        touch {output.check}
        """