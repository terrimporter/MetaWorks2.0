#!/usr/bin/env python3

import sys
from collections import defaultdict


def parse_header(header):
    """
    Extract:
    - ORF ID (e.g., ORF1, ORF2)
    - base sequence ID (without coordinates or prefixes)
    """

    header = header.replace("lcl|", "")
    header = header.split()[0]
    header = header.split(";")[0]

    # Example: ORF1_M00828:...:0:588
    if "_" in header:
        orf_part, rest = header.split("_", 1)
    else:
        orf_part = "ORF1"
        rest = header

    # Remove trailing coordinates like :0:588
    parts = rest.split(":")
    if len(parts) > 5:
        base_id = ":".join(parts[:5])
    else:
        base_id = rest

    return orf_part, base_id


def read_fasta(filepath):
    records = []

    with open(filepath) as f:
        header = None
        seq = []

        for line in f:
            line = line.strip()

            if line.startswith(">"):
                if header:
                    records.append((header, "".join(seq)))
                header = line[1:]
                seq = []
            else:
                seq.append(line)

        if header:
            records.append((header, "".join(seq)))

    return records


def build_orf_dict(records):
    """
    Returns:
    dict[base_id][orf_id] = (length, sequence)
    """
    d = defaultdict(dict)

    for header, seq in records:
        orf_id, base_id = parse_header(header)
        d[base_id][orf_id] = (len(seq), seq)

    return d


def main():
    nt_file = sys.argv[1]
    aa_file = sys.argv[2]

    nt_records = read_fasta(nt_file)
    aa_records = read_fasta(aa_file)

    nt_dict = build_orf_dict(nt_records)
    aa_dict = build_orf_dict(aa_records)

    out_nt = nt_file + ".filtered"
    out_aa = aa_file + ".filtered"

    with open(out_nt, "w") as f_nt, open(out_aa, "w") as f_aa:

        for base_id in nt_dict:

            # ✅ only keep sequences present in BOTH NT and AA
            if base_id not in aa_dict:
                continue

            nt_orfs = nt_dict[base_id]
            aa_orfs = aa_dict[base_id]

            # ✅ find ORFs present in BOTH
            common_orfs = set(nt_orfs.keys()) & set(aa_orfs.keys())

            if not common_orfs:
                continue

            # ✅ choose longest ORF (based on NT length, as in Perl)
            best_orf = max(common_orfs, key=lambda o: nt_orfs[o][0])

            nt_seq = nt_orfs[best_orf][1]
            aa_seq = aa_orfs[best_orf][1]

            f_nt.write(f">{base_id}\n{nt_seq}\n")
            f_aa.write(f">{base_id}\n{aa_seq}\n")


if __name__ == "__main__":
    main()
