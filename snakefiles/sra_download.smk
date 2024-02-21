# Download SRA files
rule download_sra:
    output:
        sra = temporary("sra/{sample}")
    log:
        "logs/prefetch/{sample}.log"
    conda:
        "envs/sra_environment.yml"
    shell:
        """
        mkdir -p sra/
        if [ ! -f "checks/{wildcards.sample}_fasterqdump.check" ] && [ ! -f "{output.sra}" ]; then
            aws s3 cp --quiet --no-sign-request s3://sra-pub-run-odp/sra/{wildcards.sample}/{wildcards.sample} {output.sra}
        fi &> {log}
        """
        