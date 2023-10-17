# Init atlas with the list of samples
rule atlas_init:
    input:
        check="reads/check/{sample}_fasterqdump.check"
    output:
        check = "atlas/check/atlas_init_{sample}.check"
    log:
        "logs/atlas/{sample}_init.log"
    conda: 
        "atlas"
    shell:
        """
        atlas init --db-dir /home/amhorst/database_atlas \
        -w atlas/atlas_{wildcards.sample} \
        ./reads/fasterq/{wildcards.sample}/ \
        --assembler megahit && touch {output.check}
        """
# break into 3 bc the QC needs way more mem than assembly
# https://github.com/metagenome-atlas/atlas/issues/676
rule atlas_qc:
    input:
        check="atlas/check/atlas_init_{sample}.check"
    output:
        qc = "atlas/check/qc_{sample}.check"
    log:
        "logs/atlas/{sample}_qc.log"
    conda: 
        "atlas"
    benchmark: "atlas/benchmark/atlas_{sample}_qc.benchmark"
    shell:
        """
        atlas run qc --profile cluster -w atlas/atlas_{wildcards.sample} \
        --default-resources mem_mb=60000 --latency-wait 30000 -k && \
        touch {output.qc} && \
        rm -r ./reads/fasterq/{wildcards.sample}/
        """

# Now use atlas on the files to create MAGs
# add resources mem bc of the memory problem with bbduk
# https://github.com/metagenome-atlas/atlas/issues/229
rule atlas_assembly:
    input:
        check="atlas/check/qc_{sample}.check"
    output:
        assem = "atlas/check/assemdone_{sample}.check"
    log:
        "logs/atlas/{sample}_assembly.log"
    conda: 
        "atlas"
    benchmark: "atlas/benchmark/atlas_{sample}_assem.benchmark"
    shell:
        """
        atlas run assembly --profile cluster -w atlas/atlas_{wildcards.sample} \
        --latency-wait 30000 --default-resources mem_mb=60000 -k && \
        cp atlas/atlas_{wildcards.sample}/finished_assembly {output.assem}
        """

# Separate binning from assembly
rule atlas_binning:
    input:
        check="atlas/check/assemdone_{sample}.check"
    output:
        check = "atlas/check/bin_{sample}.check"
    log:
        "logs/atlas/{sample}_bin.log"
    conda: 
        "atlas"
    benchmark: "atlas/benchmark/atlas_{sample}_bin.benchmark"
    shell:
        """
        atlas run genomes --profile cluster -w atlas/atlas_{wildcards.sample} \
        --default-resources mem_mb=30000 --latency-wait 30000 -k && touch {output.check}
        """
