# fastgather MAGS : MAKING A PICKLIST WORKS BUT YOU NEED A MANIFEST 
# FOR THE INPUT DB
rule fastgather_MAG:
    input: 
        sig = "/home/ctbrown/scratch2/2023-swine-usda/outputs.swine-x-reps/{sample}.subtract.sig.gz"
    output: 
        csv = "sourmash/fastgather/MAG/{sample}.csv"
    resources:
        # limit to one fastgather with --resources rayon_exclude=1
        rayon_exclude=1,
        mem_mb=7000
    log:
        "logs/sourmash/{sample}_fg_mag.log"
    conda: 
        "branchwater"
    shell:
        """
        sourmash scripts fastgather {input.sig} \
        /atlas/MAGs/all-MAGs_21.zip -k 21 \
        --scaled 10000 -o {output.csv} -c 32
        """
rule fastgather_vir:
    input: 
        sig = "/home/ctbrown/scratch2/2023-swine-usda/outputs.swine-x-reps/{sample}.subtract.sig.gz"
    output: 
        csv = "sourmash/fastgather/vir/{sample}.csv"
    resources:
        # limit to one fastgather with --resources rayon_exclude=1
        rayon_exclude=1,
        mem_mb=7000
    log:
        "logs/sourmash/{sample}_fg_mag.log"
    conda: 
        "branchwater"
    shell:
        """
        sourmash scripts fastgather {input.sig} \
        /votu_smash/all-votu_21.zip -k 21 \
        --scaled 10000 -o {output.csv} -c 32
        """

# concatenate output of MAG fastgather with fastgather titus gtdb
rule fastgather_concat:
    input: 
        fg_MAG = "sourmash/fastgather/MAG/{sample}.csv",
        fg_vir = "sourmash/fastgather/vir/{sample}.csv",
        fg_gtdb = "/home/ctbrown/scratch2/2023-swine-usda/swine8000/{sample}.sig.gather.csv"
    output: 
        csv_concat = "sourmash/fastgather/concat/{sample}.csv"
    conda: 
        "csvtk"
    shell:
        """
        csvtk concat {input.fg_MAG} {input.fg_vir} {input.fg_gtdb} > {output.csv_concat}
        """

# then normal gather using this. 
rule sourmash_gather_all:
    input: 
        sig = "/home/ctbrown/scratch2/2023-swine-usda/outputs.swine-x-reps/{sample}.subtract.sig.gz",
        picklist = "sourmash/fastgather/concat/{sample}.csv"
    output: 
        csv = "sourmash/gather_out/MAGs_gtdbk_vir/{sample}.csv"
    resources:
        mem_mb=25000
    conda: 
        "sourmash"
    shell:
        """
        sourmash gather {input.sig} atlas/MAGs/all-MAGs_21.zip \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-k21.zip \
        /virsorter2/all-votu_21.zip 
        -k 21 --scaled 10000 -o {output.csv} \
        --picklist {input.picklist}:match_md5:md5
        """

# gather only gdtb. 
rule sourmash_gather_gtdb:
    input: 
        sig = "/home/ctbrown/scratch2/2023-swine-usda/outputs.swine-x-reps/{sample}.subtract.sig.gz",
        picklist = "sourmash/fastgather/concat/{sample}.csv"
    output: 
        csv = "sourmash/gather_out/gtdb/{sample}.csv"
    resources:
        mem_mb=25000
    conda: 
        "sourmash"
    shell:
        """
        sourmash gather {input.sig} \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-k21.zip 
        -k 21 --scaled 10000 -o {output.csv} \
        --picklist {input.picklist}:match_md5:md5
        """

# gather only microbe 
rule sourmash_gather_microbe:
    input: 
        sig = "/home/ctbrown/scratch2/2023-swine-usda/outputs.swine-x-reps/{sample}.subtract.sig.gz",
        picklist = "sourmash/fastgather/concat/{sample}.csv"
    output: 
        csv = "sourmash/gather_out/MAGs_gtdbk/{sample}.csv"
    resources:
        mem_mb=25000
    conda: 
        "sourmash"
    shell:
        """
        sourmash gather {input.sig} atlas/MAGs/all-MAGs_21.zip \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-k21.zip \
        -k 21 --scaled 10000 -o {output.csv} \
        --picklist {input.picklist}:match_md5:md5
        """