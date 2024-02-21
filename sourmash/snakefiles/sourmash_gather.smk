# fastgather MAGS : MAKING A PICKLIST WORKS BUT YOU NEED A MANIFEST 
# FOR THE INPUT DB

## Maybe chance treshold bp --threshold-bp

rule fastgather_MAG:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig"
    output: 
        csv = "fastgather/MAG/{sample}.csv"
    resources:
        # limit to one fastgather with --resources rayon_exclude=1
        rayon_exclude=1,
        mem_mb=15000
    conda: 
        "branchwater"
    shell:
        """
        sourmash scripts fastgather {input.sig} \
        ../atlas/MAGs/all-MAGs_21.zip -k 21 \
        --scaled 10000 -o {output.csv} -c 10
        """

rule fastgather_vir:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig"
    output: 
        csv = "fastgather/vir/{sample}.csv"
    resources:
        # limit to one fastgather with --resources rayon_exclude=1
        rayon_exclude=1,
        mem_mb=15000
    conda: 
        "branchwater"
    shell:
        """
        sourmash scripts fastgather {input.sig} \
        ../votu_smash/all-votu_21.zip -k 21 \
        --scaled 10000 -o {output.csv} -c 10
        """
# Titus picklists are in /home/ctbrown/scratch2/2023-swine-usda/swine8000/
rule fastgather_gtdb:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig"
    output: 
        csv = "fastgather/gtdb/{sample}.csv"
    resources:
        # limit to one fastgather with --resources rayon_exclude=1
        rayon_exclude=1,
        mem_mb=15000
    conda: 
        "branchwater"
    shell:
        """
        sourmash scripts fastgather {input.sig} \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-k21.zip -k 21 \
        --scaled 10000 -o {output.csv} -c 10
        """


# concatenate output of MAG fastgather with fastgather titus gtdb
rule fastgather_concat:
    input: 
        fg_MAG = "fastgather/MAG/{sample}.csv",
        fg_vir = "fastgather/vir/{sample}.csv",
        fg_gtdb = "fastgather/gtdb/{sample}.csv"
    output: 
        csv_concat = "fastgather/concat/{sample}.csv"
    conda: 
        "csvtk"
    shell:
        """
        csvtk concat {input.fg_MAG} {input.fg_vir} {input.fg_gtdb} > {output.csv_concat}
        """

# then normal gather using this. 
rule sourmash_gather_all:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig",
        picklist = "fastgather/concat/{sample}.csv"
    output: 
        csv = "gather_out/MAGs_gtdbk_vir/{sample}.csv"
    resources:
        mem_mb=25000
    conda: 
        "sourmash"
    shell:
        """
        sourmash gather {input.sig} ../atlas/MAGs/all-MAGs_21.zip \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-k21.zip \
        ../votu_smash/all-votu_21.zip \
        -k 21 --scaled 10000 -o {output.csv} \
        --picklist {input.picklist}:match_md5:md5
        """

# gather only gdtb. 
rule sourmash_gather_gtdb:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig",
        picklist = "fastgather/concat/{sample}.csv"
    output: 
        csv = "gather_out/gtdb/{sample}.csv"
    resources:
        mem_mb=25000
    conda: 
        "sourmash"
    shell:
        """
        sourmash gather {input.sig} \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-k21.zip \
        -k 21 --scaled 10000 -o {output.csv} \
        --picklist {input.picklist}:match_md5:md5
        """

# gather only microbe 
rule sourmash_gather_microbe:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig",
        picklist = "fastgather/concat/{sample}.csv"
    output: 
        csv = "gather_out/MAGs_gtdbk/{sample}.csv"
    resources:
        mem_mb=25000
    conda: 
        "sourmash"
    shell:
        """
        sourmash gather {input.sig} ../atlas/MAGs/all-MAGs_21.zip \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-k21.zip \
        -k 21 --scaled 10000 -o {output.csv} \
        --picklist {input.picklist}:match_md5:md5
        """
