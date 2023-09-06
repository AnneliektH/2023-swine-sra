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
        --min-length 10000 -j {threads} --min-score 0.9 && touch {output.check}
        """

# # rename found vOTUs
# rule bbmap_rename:
#     input: 
#         check = "virsorter2/check/{sample}_vs2_done.check"
#     output: 