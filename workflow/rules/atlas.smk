# Init atlas with the list of samples
rule atlas_init:
    input:
        check="../results/check/{sample}_fasterqdump.check"
    output:
        check = "../results/check/atlas_init_{sample}.check"
    log:
        "../results/logs/{sample}_init.log"
    conda: 
        "atlas"
    shell:
        """
        atlas init --db-dir /home/amhorst/database_atlas/ \
        -w ../results/atlas/atlas_{wildcards.sample} \
        ../results/reads/fasterq/{wildcards.sample}/ \
        --assembler megahit && touch {output.check}
        """
# break into 3 bc the QC needs way more mem than assembly
# https://github.com/metagenome-atlas/atlas/issues/676
rule atlas_qc:
    input:
        check="../results/check/atlas_init_{sample}.check"
    output:
        qc = "../results/check/qc_{sample}.check"
    log:
        "../results/logs/{sample}_qc.log"
    conda: 
        "atlas"
    shell:
        """
        atlas run qc --profile cluster -w ../results/atlas/atlas_{wildcards.sample} \
        --configfile config/atlas_config.yaml \
        --default-resources mem_mb=70000 \
        --latency-wait 30000 -k && \
        touch {output.qc} && \
        rm -r ../results/reads/fasterq/{wildcards.sample}/
        """

# Now use atlas on the files to create MAGs
# add resources mem bc of the memory problem with bbduk
# https://github.com/metagenome-atlas/atlas/issues/229
rule atlas_assembly:
    input:
        check="../results/check/qc_{sample}.check"
    output:
        assem = "../results/check/assemdone_{sample}.check"
    log:
        "../results/logs/{sample}_assembly.log"
    conda: 
        "atlas"
    shell:
        """
        atlas run assembly --configfile config/atlas_config.yaml --profile cluster \
        -w ../results/atlas/atlas_{wildcards.sample} \
        --latency-wait 30000 --default-resources mem_mb=60000 -k && \
        cp ../results/atlas/atlas_{wildcards.sample}/finished_assembly {output.assem}
        """

# Separate binning from assembly
rule atlas_binning:
    input:
        check="../results/check/assemdone_{sample}.check"
    output:
        check = "../results/check/bin_{sample}.check"
    log:
        "../results/logs/{sample}_bin.log"
    conda: 
        "atlas"
    shell:
        """
        atlas run genomes --configfile config/atlas_config.yaml \
        --profile cluster -w ../results/atlas/atlas_{wildcards.sample} \
        --default-resources mem_mb=80000 --latency-wait 30000 \
        -k && touch {output.check}
        """
