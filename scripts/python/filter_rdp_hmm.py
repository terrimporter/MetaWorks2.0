#!/usr/bin/env python3

import sys
import os
import numpy as np

# -----------------------------
# INPUT FILES
# -----------------------------
hmm_file = sys.argv[1]
orf_file = sys.argv[2]
rdp_file = sys.argv[3]

# -----------------------------
# STEP 1: Parse HMM output
# -----------------------------
scores = []
hmm_scores = {}

with open(hmm_file) as f:
    for line in f:
        if line.startswith("#"):
            continue
        parts = line.strip().split()
        if len(parts) < 6:
            continue
        seq_id = parts[2]
        score = float(parts[5])
        scores.append(score)
        hmm_scores[seq_id] = score

# -----------------------------
# STEP 2: IQR filtering
# -----------------------------
q25 = np.percentile(scores, 25)
q75 = np.percentile(scores, 75)
iqr = q75 - q25

lower = q25 - (1.5 * iqr)
upper = q75 + (1.5 * iqr)

good_ids = {
    seq_id for seq_id, score in hmm_scores.items()
    if lower <= score <= upper
}

# -----------------------------
# STEP 3: Parse ORF fasta
# -----------------------------
orfs = {}

with open(orf_file) as f:
    current_id = None
    for line in f:
        line = line.strip()
        if line.startswith(">"):
            current_id = line[1:]
        else:
            orfs[current_id] = line

# -----------------------------
# STEP 4: Write filtered FASTA
# -----------------------------
outdir = os.path.dirname(orf_file)
fasta_out = os.path.join(outdir, "final_orfs.fasta.tmp")

with open(fasta_out, "w") as out:
    for seq_id in good_ids:
        seq = orfs.get(seq_id)
        if seq:
            out.write(f">{seq_id}\n{seq}\n")

# -----------------------------
# STEP 5: Filter RDP output
# -----------------------------


with open(rdp_file) as f:
    for line in f:
        line = line.rstrip("\n")
        if not line:
            continue

        cols = line.split("\t")
        seq_id = cols[0]

        # REMOVE original strand column (cols[1])
        rest = "\t".join(cols[2:])

        if seq_id in good_ids:
            seq = orfs.get(seq_id)
            if seq:
                print(f"{seq_id}\tNA\t{rest}")

