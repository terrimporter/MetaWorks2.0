rule build_results:
    input:
        table=config["outdir"] + (
            "/ESV.table.filtered"
            if config["pseudogenes"]["enabled"]
            else "/ESV.table"
        ),
        taxonomy=config["outdir"] + "/taxonomy.csv",
        fasta=config["outdir"] + (
            "/final_orfs.fasta"
            if config["pseudogenes"]["enabled"]
            else "/cat.asv.sha1.fasta"
        )
    output:
        config["outdir"] + "/results_report1.csv"
    shell:
        """
        python3 scripts/python/build_results.py \
        {input.table} {input.taxonomy} {input.fasta} > {output}
        """
