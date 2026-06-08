#!/usr/bin/env python3

"""
Map ESV abundances to OTUs using a VSEARCH .uc file.

Usage:
    map_esv_to_otu_table.py otu.uc ESV.table > OTU.table
"""

import sys
from collections import defaultdict

if len(sys.argv) != 3:
    sys.stderr.write(
        "Usage: map_esv_to_otu_table.py otu.uc ESV.table\n"
    )
    sys.exit(1)

uc_file = sys.argv[1]
esv_table = sys.argv[2]

# --------------------------------------------------
# Parse UC file: map ESV -> OTU (centroid)
# --------------------------------------------------

esv_to_otu = {}

with open(uc_file) as f:
    for line in f:
        if line.startswith("#"):
            continue

        parts = line.rstrip().split("\t")
        record_type = parts[0]

        if record_type == "S":
            # Seed (centroid)
            esv = parts[8]
            esv_to_otu[esv] = esv

        elif record_type == "H":
            # Hit (cluster member)
            esv = parts[8]
            otu = parts[9]
            esv_to_otu[esv] = otu

# --------------------------------------------------
# Read ESV table and aggregate counts by OTU
# --------------------------------------------------

otu_counts = defaultdict(lambda: defaultdict(int))

with open(esv_table) as f:
    header = f.readline().strip().split("\t")
    samples = header[1:]

    for line in f:
        parts = line.strip().split("\t")
        esv = parts[0]

        if esv not in esv_to_otu:
            continue

        otu = esv_to_otu[esv]

        for sample, count in zip(samples, parts[1:]):
            otu_counts[otu][sample] += int(count)

# --------------------------------------------------
# Write OTU table
# --------------------------------------------------

print("\t".join(["OTU"] + samples))

for otu in sorted(otu_counts):
    row = [otu] + [str(otu_counts[otu][s]) for s in samples]
    print("\t".join(row))
