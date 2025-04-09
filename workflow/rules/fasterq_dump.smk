# Download the whole thing, including smaller reads, as atlas will quality trim
rule fasterq_dump:
    input:
        sra_file = "../results/sra/{sample}"
    output:
        check = "../results/check/{sample}_fasterqdump.check"
    log:
        "../results/logs/fasterq_dump.{sample}.log"
    conda: 
        "envs/sra_environment.yml"
    benchmark: "../results/logs/fasterq_dump.{sample}.benchmark"
    threads: 10
    shell:
        """
        fasterq-dump {input.sra_file} --threads {threads} \
        -O ../results/reads/fasterq/{wildcards.sample} --skip-technical \
        --bufsize 1000MB --curcache 10000MB && \
        pigz -f -p {threads} ../results/reads/fasterq/{wildcards.sample}/*.fastq && \
        touch {output.check}
        """
