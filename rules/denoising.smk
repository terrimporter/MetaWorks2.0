rule dereplicate:
    input:
        config["outdir"] + "/cat.fasta.gz"
    output:
        config["outdir"] + "/cat.uniques"
    shell:
        """
        gunzip -c {input} | vsearch \
        --derep_fulllength - \
        --output {output} \
        --sizeout
        """

rule denoise:
    input:
        config["outdir"] + "/cat.uniques"
    output:
        config["outdir"] + "/cat.denoised"
    shell:
        "vsearch --cluster_unoise {input} --centroids {output}"

rule chimera_removal:
    input:
        config["outdir"] + "/cat.denoised"
    output:
        config["outdir"] + "/cat.denoised.nonchimeras"
    shell:
        "vsearch --uchime3_denovo {input} --nonchimeras {output}"

rule build_ESV_table:
    input:
        reads=config["outdir"] + "/cat.fasta.gz",
        db=config["outdir"] + "/cat.asv.sha1.fasta"
    output:
        config["outdir"] + "/ESV.table.tmp"
    threads: config["table"]["threads"]
    shell:
        """
        gunzip -c {input.reads} | \
        vsearch \
          --threads {threads} \
          --fastx_filter - \
          --fastaout /dev/stdout | \
        vsearch \
          --threads {threads} \
          --search_exact - \
          --db {input.db} \
          --otutabout {output}
        """
