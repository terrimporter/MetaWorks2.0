import sys

nt_file = sys.argv[1]
aa_file = sys.argv[2]
nt_out = sys.argv[3]
aa_out = sys.argv[4]


# ----------------------------
# Parse NT header
# ----------------------------
def parse_nt_header(line):
    parts = line.split()
    orf_part = parts[1]

    # ORF1_KR389058:0:588
    pieces = orf_part.split(":")

    if "BOLD" in orf_part:
        # ORF1_BOLD:AAE3122:0:86
        orf_accession = pieces[0] + ":" + pieces[1]
        start = int(pieces[2])
        stop = int(pieces[3])
    else:
        orf_accession = pieces[0]
        start = int(pieces[1])
        stop = int(pieces[2])

    length = stop - start + 1

    orf, otu = orf_accession.split("_", 1)

    return orf, otu, length


# ----------------------------
# Parse AA header
# ----------------------------
def parse_aa_header(line):
    parts = line.split()
    main = parts[0]

    pieces = main.split(":")

    if "BOLD" in main:
        # >lcl|ORF1_BOLD:AAE3122:0:86
        orf_accession = pieces[0].replace(">lcl|", "") + ":" + pieces[1]
        start = int(pieces[2])
        stop = int(pieces[3])
    else:
        # >lcl|ORF1_KR389058:0:587
        orf_accession = pieces[0].replace(">lcl|", "")
        start = int(pieces[1])
        stop = int(pieces[2])

    length = stop - start + 1

    orf, otu = orf_accession.split("_", 1)

    return orf, otu, length


# ----------------------------
# Parse FASTA into nested dict
# ----------------------------
def parse_fasta(file, header_parser):
    lengths = {}
    seqs = {}

    current_orf = None
    current_otu = None
    current_seq = []

    with open(file) as f:
        for line in f:
            line = line.strip()

            if line.startswith(">"):
                if current_otu:
                    seqs.setdefault(current_otu, {})[current_orf] = "".join(current_seq)

                current_orf, current_otu, length = header_parser(line)

                lengths.setdefault(current_otu, {})[current_orf] = length
                current_seq = []
            else:
                current_seq.append(line)

        if current_otu:
            seqs.setdefault(current_otu, {})[current_orf] = "".join(current_seq)

    return lengths, seqs


# ----------------------------
# Parse both files
# ----------------------------
nt_length, nt_seq = parse_fasta(nt_file, parse_nt_header)
aa_length, aa_seq = parse_fasta(aa_file, parse_aa_header)


# ----------------------------
# Find matching ORFs
# ----------------------------
matches = {}

for otu in nt_length:
    for orf in nt_length[otu]:
        if otu in aa_length and orf in aa_length[otu]:
            matches.setdefault(otu, {})[orf] = nt_length[otu][orf]


# ----------------------------
# Select longest matching ORF per OTU
# ----------------------------
results = {}

for otu in matches:
    best_orf = max(matches[otu], key=matches[otu].get)
    results[otu] = best_orf


# ----------------------------
# Write outputs
# ----------------------------
with open(nt_out, "w") as out_nt, open(aa_out, "w") as out_aa:
    for otu, orf in results.items():
        nt_sequence = nt_seq[otu][orf]
        aa_sequence = aa_seq[otu][orf]

        out_nt.write(f">{otu}\n{nt_sequence}\n")
        out_aa.write(f">{otu}\n{aa_sequence}\n")
