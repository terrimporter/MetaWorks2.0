#!/usr/bin/env python3

import sys
from collections import defaultdict


def read_fasta(filepath):
    sequences = {}
    current_id = None
    seq_lines = []

    with open(filepath) as f:
        for line in f:
            line = line.strip()
            if line.startswith(">"):
                if current_id:
                    sequences[current_id] = "".join(seq_lines)

                header = line[1:]
                header = header.replace("lcl|", "")
                header = header.split()[0]
                header = header.split(";")[0]  # remove ;size=...

                current_id = header
                seq_lines = []
            else:
                seq_lines.append(line)

        if current_id:
            sequences[current_id] = "".join(seq_lines)

    return sequences


def main():
    nt_file = sys.argv[1]
    aa_file = sys.argv[2]

    out_nt = nt_file + ".filtered"
    out_aa = aa_file + ".filtered"

    nt_seqs = read_fasta(nt_file)
    aa_seqs = read_fasta(aa_file)

    # keep only IDs in BOTH files
    common_ids = set(nt_seqs.keys()) & set(aa_seqs.keys())

    if not common_ids:
        print("WARNING: No matching ORFs found", file=sys.stderr)

    with open(out_nt, "w") as f_nt, open(out_aa, "w") as f_aa:
        for seq_id in common_ids:
            f_nt.write(f">{seq_id}\n{nt_seqs[seq_id]}\n")
            f_aa.write(f">{seq_id}\n{aa_seqs[seq_id]}\n")


if __name__ == "__main__":
    main()

