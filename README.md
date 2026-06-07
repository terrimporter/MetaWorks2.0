
# MetaWorks 2.0

MetaWorks 2.0 is a Dockerized pipeline for processing DNA metabarcoding data, supporting both ASV and OTU workflows with optional pseudogene filtering.

This version is a complete redesign of the original MetaWorks pipeline, with improved reproducibility, simplified outputs, and a fully containerized environment.

---

## Features

- ASV and OTU workflows
- Optional pseudogene removal (methods 1 & 2)
- Standardized outputs across all modes
- Fully reproducible Docker environment
- Built-in test harness

---

## Current Scope

MetaWorks 2.0 currently supports:

- **COI (protein-coding marker)** workflows

Support for additional marker types will be added in future releases:

- ITS (fungal and plant barcodes)
- rRNA markers (prokaryote and eukaryote)
- Additional sequencing platforms (e.g. NextSeq, MinION)

---

## Requirements

- Docker

---

## Quick Start

### 1. Clone repository

```bash
git clone https://github.com/terrimporter/MetaWorks2.0.git
cd MetaWorks2.0
