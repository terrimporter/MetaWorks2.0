#!/usr/bin/env python3

import sys
import shutil

taxonomy_file = sys.argv[1]

# ASV workflow: taxonomy.tmp.csv already contains correct ASV_IDs
# No rewriting required — just pass through unchanged
shutil.copyfile(taxonomy_file, sys.stdout.name)
