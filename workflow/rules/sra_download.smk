# Download SRA files
rule download_sra:
    output:
        sra = temporary("../results/sra/{sample}")
    log:
        "../results/logs/prefetch.{sample}.log"
    conda:
        "envs/sra_environment.yml"
    shell:
        """
        mkdir -p ../results/sra/
        if [ ! -f "../results/check/{wildcards.sample}_fasterqdump.check" ] && [ ! -f "{output.sra}" ]; then
            aws s3 cp --quiet --no-sign-request s3://sra-pub-run-odp/sra/{wildcards.sample}/{wildcards.sample} {output.sra}
        fi &> {log}
        """
        