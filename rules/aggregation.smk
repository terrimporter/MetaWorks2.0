rule concatenate_fasta:
    input:
        expand(
            config["outdir"] + "/trimmed/{sample}.renamed.fasta",
            sample=SAMPLES_UNIQUE
        )
    output:
        config["outdir"] + "/cat.fasta"
    shell:
        "cat {input} > {output}"

rule compress_fasta:
    input:
        config["outdir"] + "/cat.fasta"
    output:
        config["outdir"] + "/cat.fasta.gz"
    shell:
        "gzip -c {input} > {output}"

rule hash_asv_fasta:
    input:
        fasta = config["outdir"] + "/cat.denoised.nonchimeras"
    output:
        fasta = config["outdir"] + "/cat.asv.sha1.fasta"
    shell:
        """
        python3 scripts/python/hash_asv_fasta.py \
        {input.fasta} > {output.fasta}
        """

rule rewrite_esv_table_with_hashes:
    input:
        table = config["outdir"] + "/ESV.table.tmp",
        fasta = config["outdir"] + "/cat.asv.sha1.fasta"
    output:
        table = config["outdir"] + "/ESV.table"
    shell:
        """
        python3 scripts/python/rename_esv_table_with_hashes.py \
        {input.table} {input.fasta} > {output.table}
        """
