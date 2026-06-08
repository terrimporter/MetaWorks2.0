#!/usr/bin/env python3

import sys

in_fasta = sys.argv[1]
sample = sys.argv[2]
out_fasta = sys.argv[3]

with open(out_fasta, "w") as out:
    for line in open(in_fasta):
        if line.startswith(">"):
            out.write(f">{sample}_{line[1:]}")
        else:
            out.write(line)
