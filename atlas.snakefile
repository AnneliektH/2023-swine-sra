# Init atlas with the list of samples
rule atlas_init:
    input:
        check="sra/fasterq/{sample}.check"
    output:
        check = "atlas/atlas_init.check"
    conda: 
        "atlas"
    shell:
        """
        mkdir -p atlas \
        cd ./atlas/ && \
        atlas init --db-dir ../../database_atlas/ ../reads/fastq/ \
        --assembler megahit --threads 10 && \
        touch {output.check}
        """

# Now use atlas on the files to create MAGs
# add resources mem bc of the memory problem with bbduk
# https://github.com/metagenome-atlas/atlas/issues/229
rule atlas:
    input:
        check="atlas/atlas_init.check"
    output:
        check = touch("atlas/atlas_done.check")
    conda: 
        "atlas"
    benchmark: "atlas/atlas.benchmark"
    threads: 24
    shell:
        """
        cd ./atlas && \
        atlas run all --resources mem=60
        """


        
