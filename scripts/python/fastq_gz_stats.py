import gzip
import sys

file = sys.argv[1]

count = 0

with gzip.open(file, "rt") as f:
    for i, line in enumerate(f):
        if i % 4 == 0:
            count += 1

print(f"{file}\t{count}")
