rule atlas_move_MAGs:
    input: 
        check = "../results/check/bin_{sample}.check"
    output:
       check = "../results/check/move_{sample}.check"
    log: 
        "../results/logs/atlas/{sample}_move.log"
    shell:
        """
        mkdir -p ../results/atlas/MAGs/genomes/{wildcards.sample} && \
        mkdir -p ../results/atlas/MAGs/genome_qual/ && \
        mkdir -p ../results/atlas/MAGs/taxonomy/ && \

        if [[ ! -d "../results/atlas/atlas_{wildcards.sample}/genomes/genomes/" ]] 
        then
            touch ../results/atlas/MAGs/genomes/{wildcards.sample}/no_MAGs.tsv
        else
            cp -r ../results/atlas/atlas_{wildcards.sample}/genomes/genomes/* \
            ../results/atlas/MAGs/genomes/{wildcards.sample}/ 
        fi 
        if [[ ! -e ../results/atlas/atlas_{wildcards.sample}/genomes/genome_quality.tsv ]] 
        then
            touch ../results/atlas/MAGs/genome_qual/noMAGS_{wildcards.sample}.tsv
        else
            cp ../results/atlas/atlas_{wildcards.sample}/genomes/genome_quality.tsv \
            ../results/atlas/MAGs/genome_qual/genome_quality_{wildcards.sample}.tsv
        fi      
        if [[ ! -e ../results/atlas/atlas_{wildcards.sample}/genomes/taxonomy/gtdb_taxonomy.tsv ]] 
        then
            touch ../results/atlas/MAGs/taxonomy/noMAGs_{wildcards.sample}.tsv
        else
            cp ../results/atlas/atlas_{wildcards.sample}/genomes/taxonomy/gtdb_taxonomy.tsv \
            ../results/atlas/MAGs/taxonomy/gtdb_taxonomy_{wildcards.sample}.tsv 
        fi && \
        touch {output.check}
        """

