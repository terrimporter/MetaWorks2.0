import sys
import re

input_file = sys.argv[1]
output_file = sys.argv[2]


# ----------------------------
# Parse ORF header
# ----------------------------
def parse_header(line):
    # Example:
    # >lcl|Otu1:2:310 ORF1_Otu1:1:309

    parts = line.split()
    orf_part = parts[1]

    # ORF1_Otu1:1:309
    orf_name, coords = orf_part.split("_")
    otu = coords.split(":")[0]

    start, stop = map(int, coords.split(":")[1:])
    length = stop - start + 1

    return orf_name, otu, length


# ----------------------------
# Parse FASTA
# ----------------------------
nt_length = {}
nt_seq = {}

current_orf = None
current_otu = None
current_seq = []

with open(input_file) as f:
    for line in f:
        line = line.strip()

        if line.startswith(">"):
            # Save previous
            if current_otu:
                nt_seq.setdefault(current_otu, {})[current_orf] = "".join(current_seq)

            # Parse new header
            current_orf, current_otu, length = parse_header(line[1:])
            nt_length.setdefault(current_otu, {})[current_orf] = length
            current_seq = []

        else:
            current_seq.append(line)

    # Save last sequence
    if current_otu:
        nt_seq.setdefault(current_otu, {})[current_orf] = "".join(current_seq)


# ----------------------------
# Get longest ORF per OTU
# ----------------------------
longest_lengths = []
longest_seqs = {}

for otu in nt_length:
    orfs = nt_length[otu]
    longest_orf = max(orfs, key=orfs.get)

    length = orfs[longest_orf]
    seq = nt_seq[otu][longest_orf]

    longest_seqs[otu] = (longest_orf, length, seq)
    longest_lengths.append(length)


# ----------------------------
# Percentile function
# ----------------------------
def percentile(values, p):
    values = sorted(values)
    index = int(len(values) * (p / 100))
    return values[index]


# ----------------------------
# Calculate IQR cutoffs
# ----------------------------
q1 = percentile(longest_lengths, 25)
q3 = percentile(longest_lengths, 75)
iqr = q3 - q1

min_len = q1 - (1.5 * iqr)
max_len = q3 + (1.5 * iqr)


# ----------------------------
# Filter + output
# ----------------------------
with open(output_file, "w") as out:
    for otu, (orf, length, seq) in longest_seqs.items():
        if min_len <= length <= max_len:
            out.write(f">{otu}\n{seq}\n")
