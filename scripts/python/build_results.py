#!/usr/bin/env python3

import sys
import csv

esv_table = sys.argv[1]
taxonomy_file = sys.argv[2]
fasta_file = sys.argv[3]

def normalize_id(x):
    # Always return a clean SHA1
    x = x.strip()
    x = x.split(";")[0]       # remove any size annotations
    if x.startswith("COI_"):
        x = x[4:]             # remove prefix explicitly
    return x

# --------------------------------------------------
# Read taxonomy
# --------------------------------------------------

taxonomy = {}
taxonomy_fields = None

with open(taxonomy_file) as f:
    for line in f:
        if not line.strip():
            continue

        parts = line.rstrip("\n").split("\t")

        key = normalize_id(parts[0])
        values = [x.strip() for x in parts[1:]]

        if taxonomy_fields is None:
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
# Read FASTA sequences
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
            sequences[current_id] += line   # append sequence

# --------------------------------------------------
# Read OTU/ASV table and write results
# --------------------------------------------------

with open(esv_table) as f:
    header = f.readline().rstrip("\n").split("\t")
    samples = header[1:]

    writer = csv.writer(sys.stdout)
    writer.writerow(["ASV_ID", "SampleID", "Count"] + taxonomy_fields)

    for line in f:
        if not line.strip():
            continue

        parts = line.rstrip("\n").split("\t")

        raw_id = parts[0]
        clean_id = normalize_id(raw_id)   # <-- ALWAYS cleaned here

        counts = parts[1:]

        for sample, count in zip(samples, counts):
            try:
                count = int(count)
            except ValueError:
                continue

            if count == 0:
                continue

            # Enforce clean_id at output
            seq = sequences.get(clean_id, "")

            writer.writerow(
                [clean_id, sample, count, seq]
                + taxonomy.get(clean_id, ["Unclassified"] * len(taxonomy_fields))
            )
