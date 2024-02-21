rule atlas_move_MAGs:
    input: 
        check = "atlas/check/bin_{sample}.check"
    output:
       check = "atlas/check/move_{sample}.check"
    log: 
        "logs/atlas/{sample}_move.log"
    shell:
        """
        mkdir -p atlas/MAGs/genomes/{wildcards.sample} && \
        mkdir -p atlas/MAGs/genome_qual/ && \
        mkdir -p atlas/MAGs/taxonomy/ && \

        if [[ ! -d "atlas/atlas_{wildcards.sample}/genomes/genomes/" ]] 
        then
            touch atlas/MAGs/genomes/{wildcards.sample}/no_MAGs.tsv
        else
            cp -r atlas/atlas_{wildcards.sample}/genomes/genomes/* \
            atlas/MAGs/genomes/{wildcards.sample}/ 
        fi 
        if [[ ! -e atlas/atlas_{wildcards.sample}/genomes/genome_quality.tsv ]] 
        then
            touch atlas/MAGs/genome_qual/noMAGS_{wildcards.sample}.tsv
        else
            cp atlas/atlas_{wildcards.sample}/genomes/genome_quality.tsv \
            atlas/MAGs/genome_qual/genome_quality_{wildcards.sample}.tsv
        fi      
        if [[ ! -e atlas/atlas_{wildcards.sample}/genomes/taxonomy/gtdb_taxonomy.tsv ]] 
        then
            touch atlas/MAGs/taxonomy/noMAGs_{wildcards.sample}.tsv
        else
            cp atlas/atlas_{wildcards.sample}/genomes/taxonomy/gtdb_taxonomy.tsv \
            atlas/MAGs/taxonomy/gtdb_taxonomy_{wildcards.sample}.tsv 
        fi && \
        touch {output.check}
        """

