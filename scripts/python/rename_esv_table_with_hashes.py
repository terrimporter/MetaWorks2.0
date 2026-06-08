#!/usr/bin/env python3

import sys
from Bio import SeqIO

table_file = sys.argv[1]
fasta_file = sys.argv[2]

# Map original Zotu ID -> SHA1
id_map = {}

for record in SeqIO.parse(fasta_file, "fasta"):
    sha1 = record.id
    # description looks like: "<sha1> Zotu123"
    parts = record.description.split()
    if len(parts) > 1:
        original_id = parts[1]
        id_map[original_id] = sha1

with open(table_file) as f:
    for line in f:
        line = line.rstrip("\n")
        if not line:
            continue

        parts = line.split("\t")
        old_id = parts[0]

        if old_id in id_map:
            parts[0] = id_map[old_id]

        print("\t".join(parts))
