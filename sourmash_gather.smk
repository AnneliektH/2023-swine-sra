# fastgather
rule fastgather:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig"
    output: 
        csv = "sourmash/fastgather/{sample}.csv"
    resources:
        # limit to one fastgather with --resources rayon_exclude=1
        rayon_exclude=1,
        mem_mb=7000
    log:
        "logs/sourmash/{sample}_fg.log"
    conda: 
        "branchwater"
    shell:
        """
        sourmash scripts fastgather {input.sig} \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-k21.zip -k 21 \
        --scaled 10000 -o {output.csv} -c 32
        """

# fastgather
rule fastgather_MAG:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig"
    output: 
        csv = "sourmash/fastgather_MAG/{sample}.csv"
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
        sourmash/db-cover/list.mags-gtdb-r214.k21.cover.txt -k 21 \
        --scaled 10000 -o {output.csv} -c 32
        """
# Sourmash with only gtdbk
rule sourmash_gather_orig:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig",
        picklist = "sourmash/fastgather/{sample}.csv"
    output: 
        csv = "sourmash/only_gtdbk/{sample}.csv"
    log:
        "logs/sourmash/{sample}_gtdbk.log"
    resources:
        mem_mb=20000
    conda: 
        "sourmash"
    shell:
        """
        sourmash gather {input.sig} \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-k21.zip -k 21 \
        --scaled 10000 -o {output.csv} --picklist {input.picklist}:match_name:ident
        """

# # smash with gtdbk and mags
# rule sourmash_gather_MAG:
#     input: 
#         sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig"
#         #picklist = "sourmash/fastgather_MAG/{sample}.csv"
#     output: 
#         csv = "sourmash/MAGs_gtdbk/{sample}.csv"
#     log:
#         "logs/sourmash/{sample}_mag.log"
#     resources:
#         mem_mb=25000
#     conda: 
#         "sourmash"
#     shell:
#         """
#         sourmash gather {input.sig} atlas/MAGs/genomes/all-MAGs_21.zip \
#         /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-k21.zip -k 21 \
#         --scaled 10000 -o {output.csv} 
#         """
# fastgather
rule fastgather_reps:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig"
    output: 
        csv = "sourmash/fastgather-reps/{sample}.csv"
    resources:
        # limit to one fastgather with --resources rayon_exclude=1
        rayon_exclude=1,
        mem_mb=7000
    log:
        "logs/sourmash/{sample}_fg-r.log"
    conda: 
        "branchwater"
    shell:
        """
        sourmash scripts fastgather {input.sig} \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-reps.k21.zip -k 21 \
        --scaled 10000 -o {output.csv} -c 32
        """
# Sourmash with only gtdbk
rule sourmash_gather_reps:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig",
        picklist = "sourmash/fastgather-reps/{sample}.csv"
    output: 
        csv = "sourmash/only_gtdbk-reps/{sample}.csv"
    log:
        "logs/sourmash/{sample}_gtdbk-r.log"
    resources:
        mem_mb=20000
    conda: 
        "sourmash"
    shell:
        """
        sourmash gather {input.sig} \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-reps.k21.zip -k 21 \
        --scaled 10000 -o {output.csv} --picklist {input.picklist}:match_name:ident
        """

# smash with gtdbk and mags
rule sourmash_gather_MAG:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig"
        #picklist = "sourmash/fastgather_MAG/{sample}.csv"
    output: 
        csv = "sourmash/MAGs_gtdbk-reps/{sample}.csv"
    log:
        "logs/sourmash/{sample}_mag-r.log"
    resources:
        mem_mb=25000
    conda: 
        "sourmash"
    shell:
        """
        sourmash gather {input.sig} atlas/MAGs/genomes/all-MAGs_21.zip \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-reps.k21.zip -k 21 \
        --scaled 10000 -o {output.csv} 
        """