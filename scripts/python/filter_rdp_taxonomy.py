# Teresita M. Porter, August 18, 2022
# Modified: ensure ASV-level IDs and tab-delimited output

import pandas as pd
import sys
from Bio import SeqIO

# args
fasta_file = sys.argv[1]
rdp_file = sys.argv[2]
marker = sys.argv[3]

# read FASTA headers (ASV IDs)
headers = []
with open(fasta_file) as fh:
    for record in SeqIO.parse(fh, "fasta"):
        headers.append(record.id)

# read RDP output (tab-delimited, no header)
df = pd.read_csv(rdp_file, sep="\t", header=None, dtype=str, keep_default_na=False)

# filter RDP output to ASVs present in FASTA
df_filtered = df[df[0].isin(headers)]

# marker-specific column layouts
orf3_tax4_abund12 = ["COI", "rbcL_landPlant", "rbcL_eukaryota"]
orf3_tax4_abund11 = ["rbcL_diatom"]

if marker in orf3_tax4_abund12:
    df_filtered.columns = [
        "ASV_ID","Strand","Root","RootRank","rBP",
        "SuperKingdom","SuperKingdomRank","skBP",
        "Kingdom","KingdomRank","kBP",
        "Phylum","PhylumRank","pBP",
        "Class","ClassRank","cBP",
        "Order","OrderRank","oBP",
        "Family","FamilyRank","fBP",
        "Genus","GenusRank","gBP",
        "Species","SpeciesRank","sBP"
    ]

elif marker in orf3_tax4_abund11:
    df_filtered.columns = [
        "ASV_ID","Strand","Root","RootRank","rBP",
        "Domain","DomainRank","dBP",
        "Kingdom","KingdomRank","kBP",
        "SubKingdom","SubKingdomRank","skBP",
        "Phylum","PhylumRank","pBP",
        "Class","ClassRank","cBP",
        "Order","OrderRank","oBP",
        "Family","FamilyRank","fBP",
        "Genus","GenusRank","gBP",
        "Species","SpeciesRank","sBP"
    ]

elif marker == "ITS_fungi":
    df_filtered.columns = [
        "ASV_ID","Strand","Root","RootRank","rBP",
        "Kingdom","KingdomRank","kBP",
        "Phylum","PhylumRank","pBP",
        "Class","ClassRank","cBP",
        "Order","OrderRank","oBP",
        "Family","FamilyRank","fBP",
        "Genus","GenusRank","gBP",
        "Species","SpeciesRank","sBP"
    ]

# IMPORTANT: write TAB-delimited output
sys.stdout.write(df_filtered.to_csv(index=False, header=True, sep="\t"))
