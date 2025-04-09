import os.path
SAMPLE, = glob_wildcards('mgmanysearch/fastmultigather.votu.10kb/{sample}.gather.csv')

# fastmultigather already done: from there go to picklist ->  mgmanysearch.
rule all:
    input:
        expand('mgmanysearch/vOTUs/{sample}.{dedup}.csv', sample=SAMPLE, dedup=DEDUP),

# map reads to vOTUs to create accumulation curve
rule bowtie: 
    input:
        fw_read = "atlas/atlas_{sample}/{sample}/sequence_quality_control/{sample}_QC_R1.fastq.gz", 
        rv_read = "atlas/atlas_{sample}/{sample}/sequence_quality_control/{sample}_QC_R2.fastq.gz",
    output:
        samfile = temporary("bowtie2/mapping/{sample}.sam"),
    conda: 
        "coverm"
    shell:
        """
        bowtie2 --threads 12 \
        -x ./bowtie2/240108allvir
        -1  {input.fw_read} -2 {input.rv_read} \
        -S {output.samfile} --no-unal --sensitive
        """
rule sam2bam:
    input:
        samfile = "bowtie2/mapping/{sample}.sam"
    output:
        bamfile = "bowtie2/mapping/{sample}.bam",
        check = "bowtie2/check/{sample}_done.txt"
    conda: 
        "samtools"
    shell:
        """
        samtools view -@ 12 -F 4 -bS {input.samfile} | samtools sort > {output.bamfile} && \
        samtools index {output.bamfile} && touch {output.check}
        """