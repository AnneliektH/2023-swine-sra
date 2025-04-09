import os
import csv
import sys

if len(sys.argv) != 3:
    print("Usage: python script.py <input_directory> <output_file>")
    sys.exit(1)

base_dir = os.path.abspath(sys.argv[1])  # Input directory as base
output_file = sys.argv[2]  # Output file path

genomes_dir = os.path.join(base_dir, "genomes")
taxonomy_dir = os.path.join(base_dir, "taxonomy")
quality_dir = os.path.join(base_dir, "genome_quality")

with open(output_file, "w", newline="") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["Folder", "Num_Items", "Taxonomy_Exists", "Quality_Exists"])
    
    for subfolder in sorted(os.listdir(genomes_dir)):
        subfolder_path = os.path.join(genomes_dir, subfolder)
        
        if os.path.isdir(subfolder_path):
            num_items = len(os.listdir(subfolder_path))
            taxonomy_file = os.path.join(taxonomy_dir, f"gtdb_taxonomy_{subfolder}.tsv")
            quality_file = os.path.join(quality_dir, f"genome_quality_{subfolder}.tsv")
            
            taxonomy_exists = os.path.exists(taxonomy_file)
            quality_exists = os.path.exists(quality_file)
            
            writer.writerow([subfolder, num_items, taxonomy_exists, quality_exists])

print(f"CSV saved as {output_file}")
