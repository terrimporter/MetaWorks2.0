# --------------------------------------------------
# Base image
# --------------------------------------------------
FROM mambaorg/micromamba:latest

ENV DEBIAN_FRONTEND=noninteractive

# --------------------------------------------------
# System dependencies
# --------------------------------------------------

USER root

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    bzip2 \
    ca-certificates \
    git \
    build-essential \
    vim \
    default-jre \
    zlib1g \
    libelf1 \
    libdw1 \
    libuv1 \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------
# Install bioinformatics stack
# --------------------------------------------------

RUN micromamba install -y -n base \
    -c conda-forge -c bioconda \
    python=3.11 \
    snakemake \
    fastp \
    chopper \
    "vsearch<2.28" \
    seqkit \
    cutadapt \
    hmmer \
    biopython \
    pandas \
    && micromamba clean --all --yes

# --------------------------------------------------
# Install ORFfinder (NCBI)
# --------------------------------------------------
RUN mkdir -p /opt/orffinder && \
    cd /opt/orffinder && \
    wget https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/ORFfinder/linux-i64/ORFfinder.gz && \
    gunzip ORFfinder.gz && \
    chmod +x ORFfinder && \
    ln -s /opt/orffinder/ORFfinder /usr/local/bin/ORFfinder

# --------------------------------------------------
# Copy pipeline into container
# --------------------------------------------------
WORKDIR /data

COPY . /data

# --------------------------------------------------
# Make scripts executable
# --------------------------------------------------
RUN chmod +x run_COI_tests.sh

# --------------------------------------------------
# Set default working directory for users
# --------------------------------------------------
WORKDIR /data

# --------------------------------------------------
# Default command
# --------------------------------------------------

# add nicer ls output
RUN echo 'alias ls="ls --color=auto -F"' >> /root/.bashrc

CMD ["bash"]
