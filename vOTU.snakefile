# snakefile to create vOTUs after the first steps of atlas 
rule virsorter2:
    input:
        check="atlas/check/assemdone_{sample}.check" 
    output:
        check = "virsorter2/check/{sample}_vs2_done.check"
    log:
        "logs/virsorter2/{sample}.log"
    conda: 
        "virsorter2"
    threads: 6
    shell:
        """
        virsorter run all -w virsorter2/{wildcards.sample} \
        -i atlas/atlas_{wildcards.sample}/{wildcards.sample}/{wildcards.sample}_contigs.fasta \
        --min-length 5000 -j {threads} --min-score 0.5 && touch {output.check}
        """

# rename found vOTUs
rule bbmap_rename_viral:
    input: 
        check = "virsorter2/check/{sample}_vs2_done.check"
    output: 
        contigs = "virsorter2/contigs/{sample}_rename.fa"
    log:
        "logs/virsorter2/{sample}_rename.log"
    conda: 
        "bbmap"
    shell:
        """
        rename.sh in=virsorter2/{wildcards.sample}/final-viral-combined.fa \
        out={output.contigs} prefix={wildcards.sample}_viral --latency-wait 30000
        """