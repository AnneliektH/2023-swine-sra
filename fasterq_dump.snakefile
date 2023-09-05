# Download the whole thing, including smaller reads, as atlas will quality trim
rule fasterq_dump:
    input:
        sra_file = "sra/{sample}"
    output:
        check = touch("checks/{sample}_fasterqdump.check")
    log:
        "logs/fasterq_dump/{sample}.log"
    conda: 
        "envs/sra_environment.yml"
    benchmark: "logs/fasterq_dump/{sample}.benchmark"
    threads: 10
    shell:
        """
        fasterq-dump {input.sra_file} --threads 10 \
        -O ./reads/fasterq/{wildcards.sample} --skip-technical \
        --bufsize 1000MB --curcache 10000MB
        """