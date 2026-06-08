############################################
# MERGING MODULE (fastp)
############################################

rule merge_reads:
    input:
        r1=lambda wc: config["raw_dir"] + "/" + config["pattern"].format(sample=wc.sample, read="1"),
        r2=lambda wc: config["raw_dir"] + "/" + config["pattern"].format(sample=wc.sample, read="2")
    output:
        config["outdir"] + "/merged/{sample}.fastq.gz"
    threads: config["fastp"]["threads"]
    params:
        q=config["fastp"]["qualified_quality_phred"],
        u=config["fastp"]["unqualified_percent_limit"],
        overlap=config["fastp"]["overlap_len_require"],
        length_arg=(
            f"--length_required {config['fastp']['length_required']}"
            if "length_required" in config["fastp"]
            else ""
        ),
        html=config["outdir"] + "/qc/{sample}.fastp.html",
        json=config["outdir"] + "/qc/{sample}.fastp.json"
    shell:
        """
        mkdir -p {config[outdir]}/qc

        fastp \
          --merge \
          -i {input.r1} \
          -I {input.r2} \
          --merged_out {output} \
          --qualified_quality_phred {params.q} \
          --unqualified_percent_limit {params.u} \
          --overlap_len_require {params.overlap} \
          {params.length_arg} \
          --html {params.html} \
          --json {params.json} \
          --thread {threads}
        """


############################################
# Stats on merged reads
############################################

rule merged_stats:
    input:
        config["outdir"] + "/merged/{sample}.fastq.gz"
    output:
        config["outdir"] + "/stats/{sample}.merged.stats"
    shell:
        """
        python3 scripts/python/fastq_gz_stats.py {input} >> {output}
        """

############################################
# Convert merged FASTQ to FASTA and
# add sample ID to headers (MetaWorks invariant)
############################################

rule merged_fastq_to_fasta_with_sample:
    input:
        config["outdir"] + "/merged/{sample}.fastq.gz"
    output:
        config["outdir"] + "/merged/{sample}.renamed.fasta"
    shell:
        """
        python3 - << 'EOF'
import sys, gzip

sample = "{wildcards.sample}"
with gzip.open("{input}", "rt") as fh, open("{output}", "w") as out:
    i = 0
    for line in fh:
        if i % 4 == 0:  # header
            out.write(">" + sample + "_" + line[1:])
        elif i % 4 == 1:  # sequence
            out.write(line)
        i += 1
EOF
        """
