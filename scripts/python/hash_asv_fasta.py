#!/usr/bin/env python3

import sys
import hashlib
from Bio import SeqIO

in_fasta = sys.argv[1]

for record in SeqIO.parse(in_fasta, "fasta"):
    seq = str(record.seq).upper()
    sha1 = hashlib.sha1(seq.encode("utf-8")).hexdigest()

    # New ID is SHA1 only
    record.id = sha1
    record.name = sha1
    record.description = ""

    SeqIO.write(record, sys.stdout, "fasta")
