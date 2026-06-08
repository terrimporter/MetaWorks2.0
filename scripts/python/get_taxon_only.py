import sys

taxon_file = sys.argv[1]
fasta_file = sys.argv[2]

# Load taxon IDs
taxa = set()
with open(taxon_file) as f:
    for line in f:
        tax = line.strip()
        if tax:
            taxa.add(tax)

# Parse FASTA into dictionary
fasta = {}
current_id = None
current_seq = []

with open(fasta_file) as f:
    for line in f:
        line = line.strip()

        if line.startswith(">"):
            # Save previous entry
            if current_id:
                fasta[current_id] = "".join(current_seq)

            # Start new entry
            current_id = line[1:]  # remove >
            current_seq = []
        else:
            current_seq.append(line)

    # Save last entry
    if current_id:
        fasta[current_id] = "".join(current_seq)

# Output only matching sequences
for zotu, seq in fasta.items():
    if zotu in taxa:
        print(f">{zotu}")
        print(seq)
