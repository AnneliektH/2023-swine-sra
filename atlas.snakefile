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
        atlas init -w atlas/atlas_{wildcards.sample} \
        --db-dir ../database_atlas/ ./reads/fasterq/{wildcards.sample}/ \
        --assembler megahit && touch {output.check}
        """

# Now use atlas on the files to create MAGs
# add resources mem bc of the memory problem with bbduk
# https://github.com/metagenome-atlas/atlas/issues/229
rule atlas_assembly:
    input:
        check="atlas/check/atlas_init_{sample}.check"
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
        --resources mem=60 -k || true && \
        cp atlas/atlas_{wildcards.sample}/finished_assembly {output.assem}
        """

# Separate binning from assembly
rule atlas_binning:
    input:
        check="atlas/check/assemdone_{sample}.check"
    output:
        check = "atlas/check/atlas_done_{sample}_bin.check"
    log:
        "logs/atlas/{sample}_bin.log"
    conda: 
        "atlas"
    benchmark: "atlas/benchmark/atlas_{sample}_bin.benchmark"
    shell:
        """
        atlas run binning --profile cluster -w atlas/atlas_{wildcards.sample} \
        --resources mem=60 -k && touch {output.check}
        """
