# Init atlas with the list of samples
rule atlas_init:
    input:
        check="checks/{sample}_fasterqdump.check"
    output:
        check = touch("atlas/check/atlas_init_{sample}.check")
    conda: 
        "atlas"
    shell:
        """
        atlas init -w atlas/atlas_{wildcards.sample} --db-dir ../database_atlas/ ./reads/fasterq/{wildcards.sample}/ \
        --assembler megahit
        """

# Now use atlas on the files to create MAGs
# add resources mem bc of the memory problem with bbduk
# https://github.com/metagenome-atlas/atlas/issues/229
rule atlas_assembly:
    input:
        check="atlas/check/atlas_init_{sample}.check"
    output:
        assem = "atlas/check/assemdone_{sample}.check"
    conda: 
        "atlas"
    benchmark: "atlas/check/atlas_{sample}_assem.benchmark"
    shell:
        """
        atlas run assembly --profile cluster -w atlas/atlas_{wildcards.sample} \
        --resources mem=60 -k && \
        cp atlas/atlas_{wildcards.sample}/finished_assembly {output.assem}
        """

# Separate binning from assembly
rule atlas_binning:
    input:
        check="atlas/check/assemdone_{sample}.check"
    output:
        check = touch("atlas/check/atlas_done_{sample}.check")
    conda: 
        "atlas"
    benchmark: "atlas/check/atlas_{sample}_bin.benchmark"
    shell:
        """
        atlas run binning --profile cluster -w atlas/atlas_{wildcards.sample} \
        --resources mem=60 -k
        """
