#!/usr/bin/env python3

import sys

table_file = sys.argv[1]
filter_file = sys.argv[2]

good_ids = set()

with open(filter_file) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue

        if line.startswith(">"):
            # IMPORTANT: strip everything after first semicolon
            seq_id = line[1:].split(";")[0]
            good_ids.add(seq_id)
        else:
            seq_id = line.split()[0]
            good_ids.add(seq_id)

# process table safely
with open(table_file) as f:
    try:
        header = next(f)
    except StopIteration:
        # empty file → nothing to do
        sys.exit(0)

    print(header.strip())

    for line in f:
        parts = line.strip().split("\t")
        seq_id = parts[0]

        if seq_id in good_ids:
            print(line.strip())
