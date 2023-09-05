# Init atlas with the list of samples
rule atlas_init:
    input:
        check="checks/{sample}_fasterqdump.check"
    output:
        check = "atlas/check/atlas_init_{sample}.check"
    conda: 
        "atlas"
    shell:
        """
        atlas init -w atlas/atlas_{wildcards.sample} --db-dir ../database_atlas/ ./reads/fasterq/{wildcards.sample}/ \
        --assembler megahit && \
        touch {output.check}
        """

# Now use atlas on the files to create MAGs
# add resources mem bc of the memory problem with bbduk
# https://github.com/metagenome-atlas/atlas/issues/229
rule atlas:
    input:
        check="atlas/check/atlas_init_{sample}.check"
    output:
        check = "atlas/check/atlas_done_{sample}.check",
        assem = "atlas/check/assemdone_{sample}.check"
    conda: 
        "atlas"
    benchmark: "atlas/check/atlas_{sample}.benchmark"
    shell:
        """
        atlas run all --profile cluster -w atlas/atlas_{wildcards.sample} \
        --resources mem=60 -k || true
        cp atlas/atlas_{wildcards.sample}/finished_assembly {output.assem} && \
        touch {output.check}
        """
