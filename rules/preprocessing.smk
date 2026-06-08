############################################
# PREPROCESSING MODULE
############################################

############################################
# Raw read statistics
############################################

rule raw_forward_stats:
    input:
        lambda wc: config["raw_dir"] + "/" + config["pattern"].format(sample=wc.sample, read="1")
    output:
        config["outdir"] + "/stats/{sample}.R1stats"
    shell:
        """
        python3 scripts/python/fastq_gz_stats.py {input} >> {output}
        """

rule raw_reverse_stats:
    input:
        lambda wc: config["raw_dir"] + "/" + config["pattern"].format(sample=wc.sample, read="2")
    output:
        config["outdir"] + "/stats/{sample}.R2stats"
    shell:
        """
        python3 scripts/python/fastq_gz_stats.py {input} >> {output}
        """

############################################
# OPTIONAL: read pre-filtering (e.g., Chopper)
############################################

if config.get("use_chopper", False):

    rule filter_forward_reads:
        input:
            lambda wc: config["raw_dir"] + "/" + config["pattern"].format(sample=wc.sample, read="1")
        output:
            config["outdir"] + "/filtered/{sample}_R1.fastq.gz"
        shell:
            """
            zcat {input} | chopper \
                -q {config[cutadapt][quality]} \
                -l {config[cutadapt][min_length]} \
            | gzip > {output}
            """

rule filter_reverse_reads:
    input:
        lambda wc: config["raw_dir"] + "/" + config["pattern"].format(sample=wc.sample, read="2")
    output:
        config["outdir"] + "/filtered/{sample}_R2.fastq.gz"
    shell:
        """
        zcat {input} | chopper \
            -q {config[chopper][q]} \
            -l {config[chopper][l]} \
        | gzip > {output}
        """
