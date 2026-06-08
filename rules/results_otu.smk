rule build_otu_results:
    input:
        table = config["outdir"] + "/OTU.table.prefixed",
        taxonomy = config["outdir"] + "/otu.taxonomy.csv",
        fasta = config["outdir"] + "/otu.fasta"
    output:
        config["outdir"] + "/otu.results.csv"
    shell:
        """
        python3 scripts/python/build_otu_results.py \
        {input.table} {input.taxonomy} {input.fasta} > {output}
        """

rule cleanup_prefixed_table:
    input:
        config["outdir"] + "/otu.results.csv"
    output:
        touch(config["outdir"] + "/.cleanup_done")
    shell:
        """
        rm -f {config[outdir]}/OTU.table.prefixed
        """
