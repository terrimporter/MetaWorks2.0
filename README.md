
# MetaWorks 2.0

MetaWorks 2.0 is a Dockerized pipeline for processing DNA metabarcoding data, supporting both ASV and OTU workflows with optional pseudogene filtering.

This version is a complete redesign of the original MetaWorks pipeline, with improved reproducibility, simplified outputs, and a fully containerized environment.

Reference data is included in the Docker container and not stored in the repository.

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

Clone the repository and enter the directory:

git clone https://github.com/terrimporter/MetaWorks2.0.git
cd MetaWorks2.0

Pull the pre-built Docker image:

docker pull terrimporter/metaworks2:latest

Run the container:

docker run --platform=linux/amd64 -it terrimporter/metaworks2:latest

For reproducibility, use a fixed version:

docker pull terrimporter/metaworks2:2.0.0
docker run --platform=linux/amd64 -it terrimporter/metaworks2:2.0.0

To run on your own data:

docker run --platform=linux/amd64 -it -v $(pwd):/data terrimporter/metaworks2:latest
cd /data

Apple Silicon (M1/M2/M3) users must include:

--platform=linux/amd64
