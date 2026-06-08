#!/usr/bin/env python3

"""
Build sample-aware OTU results table by joining:

- OTU.table (OTU x sample abundance)
- otu.taxonomy.csv (OTU-level taxonomy)
- otu.fasta (to add sequence column)

Output:
  otu.results.csv (long format):
    OTU_ID,SampleID,Count,Sequence,<taxonomy fields>
"""

import sys
import csv

# --------------------------------------------------
# Inputs
# --------------------------------------------------

otu_table = sys.argv[1]
taxonomy_file = sys.argv[2]
fasta_file = sys.argv[3]

# --------------------------------------------------
# Helper function
# --------------------------------------------------

def normalize_id(x):
    x = x.strip()
    x = x.split(";")[0]
    if x.startswith("COI_"):
        x = x[4:]
    return x

# --------------------------------------------------
# Read OTU taxonomy
# --------------------------------------------------

taxonomy = {}
taxonomy_fields = []

with open(taxonomy_file, newline="") as f:
    reader = csv.reader(f, delimiter="\t")

    for row in reader:
        if not row:
            continue

        key = normalize_id(row[0])
        values = [x.strip() for x in row[1:]]

        if not taxonomy_fields:
            taxonomy_fields = [
                "Strand",
                "Root", "RootRank",
                "Superkingdom", "SuperkingdomRank",
                "Kingdom", "KingdomRank",
                "Phylum", "PhylumRank",
                "Class", "ClassRank",
                "Order", "OrderRank",
                "Family", "FamilyRank",
                "Genus", "GenusRank",
                "Species", "SpeciesRank"
            ][:len(values)]

        taxonomy[key] = values

# --------------------------------------------------
# Read OTU FASTA sequences
# --------------------------------------------------

sequences = {}

with open(fasta_file) as f:
    current_id = None
    for line in f:
        line = line.strip()

        if not line:
            continue

        if line.startswith(">"):
            current_id = normalize_id(line[1:])
            sequences[current_id] = ""   # initialize
        else:
            sequences[current_id] += line   # append, not overwrite

# --------------------------------------------------
# Read OTU table and write results
# --------------------------------------------------

with open(otu_table) as f:
    header = f.readline().rstrip("\n").split("\t")
    samples = header[1:]

    writer = csv.writer(sys.stdout)

    # Write header
    writer.writerow(
        ["OTU_ID", "SampleID", "Count", "Sequence"] + taxonomy_fields
    )

    # Process rows
    for line in f:
        line = line.rstrip("\n")
        if not line:
            continue

        parts = line.split("\t")

        raw_id = parts[0]
        clean_id = normalize_id(raw_id)

        counts = parts[1:]

        for sample, count in zip(samples, counts):
            try:
                count = int(count)
            except ValueError:
                continue

            # skip zero counts
            if count == 0:
                continue

            # direct lookup (IDs already match FASTA)
            seq = sequences.get(clean_id, "")

            writer.writerow(
                [clean_id, sample, count, seq]
                + taxonomy.get(
                    clean_id,
                    ["Unclassified"] * len(taxonomy_fields)
                )
            )
