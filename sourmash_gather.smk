# rename found vOTUs
rule sourmash_gather:
    input: 
        sig = "/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{sample}.sig"
    output: 
        csv = "sourmash/{sample}.csv"
    log:
        "logs/sourmash/{sample}.log"
    conda: 
        "sourmash"
    shell:
        """
        sourmash gather {input.sig} sourmash_test/all-MAGs_21.zip \
        /group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-k21.zip -k 21 
        -o {output.csv}
        """
