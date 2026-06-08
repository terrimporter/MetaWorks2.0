rule trim_adapters:
    input:
        config["outdir"] + "/merged/{sample}.fastq.gz"
    output:
        config["outdir"] + "/trimmed/{sample}.fastq.gz"
    shell:
        """
        cutadapt \
            -a file:{config[cutadapt][adapters]} \
            -m {config[cutadapt][min_length]} \
            -q {config[cutadapt][quality]} \
            -o {output} \
            {input}
        """

rule trimmed_stats:
    input:
        config["outdir"] + "/trimmed/{sample}.fastq.gz"
    output:
        config["outdir"] + "/stats/{sample}.trimmed.stats"
    shell:
        """
        python3 scripts/python/fastq_gz_stats.py {input} >> {output}
        """

rule fastq_to_fasta:
    input:
        config["outdir"] + "/trimmed/{sample}.fastq.gz"
    output:
        config["outdir"] + "/trimmed/{sample}.fasta.gz"
    shell:
        """
        gunzip -c {input} | \
        awk 'NR%4==1 {{print ">" substr($0,2)}} NR%4==2 {{print}}' | \
        gzip > {output}
        """

rule add_sample_to_fasta_headers:
    input:
        fasta = config["outdir"] + "/trimmed/{sample}.fasta.gz"
    output:
        config["outdir"] + "/trimmed/{sample}.renamed.fasta"
    shell:
        """
        python3 - << 'EOF'
import gzip
import re

raw_sample = "{wildcards.sample}"
safe_sample = re.sub(r'[^A-Za-z0-9]', '', raw_sample)

read_counter = 0
with gzip.open("{input.fasta}", "rt") as fh, open("{output}", "w") as out:
    for line in fh:
        if line.startswith(">"):
            read_counter += 1
            out.write(">" + safe_sample + "|read" + str(read_counter) + "\\n")
        else:
            out.write(line)
EOF
        """
