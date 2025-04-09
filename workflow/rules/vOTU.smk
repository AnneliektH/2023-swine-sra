# snakefile to create vOTUs after the first steps of atlas 
rule virsorter2:
    input:
        check="../results/check/assemdone_{sample}.check" 
    output:
        check = "../results/check/{sample}_vs2_done.check"
    log:
        "../results/logs/virsorter2/{sample}.log"
    conda: 
        "virsorter2"
    threads: 10
    shell:
        """
        virsorter run all -w ../results/virsorter2/{wildcards.sample} \
        -d /group/jbemersogrp/databases/virsorter/ --prep-for-dramv \
        -i ../results/atlas/atlas_{wildcards.sample}/{wildcards.sample}/{wildcards.sample}_contigs.fasta \
        --min-length 5000 -j {threads} --min-score 0.5 || true && touch {output.check}
        """

# rename found vOTUs
rule bbmap_rename_viral:
    input: 
        check = "../results/check/{sample}_vs2_done.check"
    output: 
        contigs = "../results/virsorter2/contigs/{sample}_rename.fa",
        check = "../results/check/{sample}_rename.check"
    log:
        "../results/logs/virsorter2/{sample}_rename.log"
    conda: 
        "bbmap"
    shell:
        """
    if [[ ! -e ../results/virsorter2/{wildcards.sample}/final-viral-combined.fa ]] 
    then
        touch {output.contigs} 
    else
        rename.sh in=../results/virsorter2/{wildcards.sample}/final-viral-combined.fa \
        out={output.contigs} prefix=AtH2023_{wildcards.sample}_viral && touch {output.check}
    fi
        """


