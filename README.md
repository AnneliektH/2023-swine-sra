## repo for going from raw SRA files to genome bins and vOTUs
Snakemake pipeline downloads the SRA file, coverts it into reads, then runs Atlas an Virsorter2, returning viral contigs an medium/high-quality MAGs

TO add:
- vibrant for viral AMGs
- remove/move Atlas folders of SRAs not at quality standards
- rewrite the snakefile so input/output files go places i want them to go
