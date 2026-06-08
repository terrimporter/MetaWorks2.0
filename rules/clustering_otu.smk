rule cluster_otus:
    input:
        fasta = config["esv_dir"] + "/final_sequences.fasta"
    output:
        fasta = config["outdir"] + "/otu.fasta",
        map = config["outdir"] + "/otu.uc"
    threads: config["threads"]["vsearch"]
    shell:
        """
        vsearch \
          --cluster_fast {input.fasta} \
          --id {config[otu][identity]} \
          --centroids {output.fasta} \
          --uc {output.map} \
          --threads {threads}
        """

rule build_otu_table:
    input:
        uc = config["outdir"] + "/otu.uc",
        esv_table = config["esv_dir"] + (
            "/ESV.table.filtered"
            if config.get("pseudogenes", {}).get("enabled", False)
            else "/ESV.table"
        )
    output:
        config["outdir"] + "/otu.table"
    shell:
        """
        python3 scripts/python/map_esv_to_otu_table.py \
        {input.uc} {input.esv_table} > {output}
        """

rule prefix_otu_ids:
    input:
        config["outdir"] + "/otu.table"
    output:
        config["outdir"] + "/OTU.table.prefixed"
    params:
        prefix = config["otu"]["prefix"]
    shell:
        """
        awk 'NR==1 {{print; next}} {{print "{params.prefix}"$0}}' {input} > {output}
        """
