rule atlas_move_MAGs:
    input: 
        check = "atlas/check/bin_{sample}.check"
    output:
       check = "atlas/check/{exp}/move_{sample}.check"
    log: 
        "logs/atlas/{exp}/{sample}_move.log"
    shell:
        """
        mkdir -p atlas/MAGs/genomes/{wildcards.exp}/{wildcards.sample} && \
        mkdir -p atlas/MAGs/genome_qual/{wildcards.exp}/ && \
        mkdir -p atlas/MAGs/taxonomy/{wildcards.exp}/ && \

        if [[ ! -d "atlas/atlas_{wildcards.sample}/genomes/genomes/" ]] 
        then
            touch atlas/MAGs/genomes/{wildcards.exp}/{wildcards.sample}/no_MAGs.txt
        else
            cp -r atlas/atlas_{wildcards.sample}/genomes/genomes/* \
            atlas/MAGs/genomes/{wildcards.exp}/{wildcards.sample}/ 
        fi 
        if [[ ! -e atlas/atlas_{wildcards.sample}/genomes/genome_quality.tsv ]] 
        then
            touch atlas/MAGs/genome_qual/{wildcards.exp}/noMAGS_{wildcards.sample}.txt
        else
            cp atlas/atlas_{wildcards.sample}/genomes/genome_quality.tsv \
            atlas/MAGs/genome_qual/{wildcards.exp}/genome_quality_{wildcards.sample}.tsv
        fi      
        if [[ ! -e atlas/atlas_{wildcards.sample}/genomes/taxonomy/gtdb_taxonomy.tsv ]] 
        then
            touch atlas/MAGs/taxonomy/{wildcards.exp}/noMAGs_{wildcards.sample}.txt
        else
            cp atlas/atlas_{wildcards.sample}/genomes/taxonomy/gtdb_taxonomy.tsv \
            atlas/MAGs/taxonomy/{wildcards.exp}/gtdb_taxonomy_{wildcards.sample}.tsv 
        fi && \
        touch {output.check}
        """

