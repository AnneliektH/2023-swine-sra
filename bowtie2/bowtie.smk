# map reads to vOTUs to create accumulation curve
rule bowtie:
    input:
        fw_read = "../atlas/atlas_{sample}/{sample}/sequence_quality_control/{sample}_QC_R1.fastq.gz", 
        rv_read = "../atlas/atlas_{sample}/{sample}/sequence_quality_control/{sample}_QC_R2.fastq.gz",
    output:
        samfile = temporary("mapping/{sample}.sam"),
    conda: 
        "bowtie2"
    shell:
        """
        bowtie2 --threads 4 \
        -x ./240108allvir \
        -1  {input.fw_read} -2 {input.rv_read} \
        -S {output.samfile} --no-unal --sensitive
        """
rule sam2bam:
    input:
        samfile = "mapping/{sample}.sam"
    output:
        bamfile = "mapping/{sample}.bam",
        check = "check/{sample}_done.txt"
    conda: 
        "samtools"
    shell:
        """
        samtools view -@ 4 -F 4 -bS {input.samfile} | samtools sort > {output.bamfile} && \
        samtools index {output.bamfile} && touch {output.check}
        """