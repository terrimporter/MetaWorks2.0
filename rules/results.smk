############################################
# RESULTS MODULE
############################################

############################################
# Helper: choose correct FASTA source
############################################

def get_final_fasta():
    return (
        config["outdir"] + "/final_orfs.fasta"
        if config["pseudogenes"]["enabled"]
        else config["outdir"] + "/cat.asv.sha1.fasta"
    )

############################################
# STEP 1: Standard taxonomy (method 1 path)
############################################

rule filter_rdp:
    input:
        fasta = get_final_fasta(),
        rdp   = config["outdir"] + "/rdp.out.tmp"
    output:
        config["outdir"] + "/taxonomy.tmp.csv"
    shell:
        """
        python3 scripts/python/filter_rdp_taxonomy.py \
        {input.fasta} {input.rdp} {config[marker]} > {output}
        """

############################################
# STEP 2: Choose taxonomy source (CRITICAL)
############################################

rule rewrite_taxonomy:
    input:
        lambda wc: (
            config["outdir"] + "/taxonomy_ORF.tsv"
            if config["pseudogenes"]["enabled"] and config["pseudogenes"]["method"] == 2
            else config["outdir"] + "/taxonomy.tmp.csv"
        )
    output:
        config["outdir"] + "/taxonomy.csv"
    shell:
        "cp {input} {output}"


############################################
# STEP 3: Filter ESV table
############################################

if config["pseudogenes"]["enabled"]:
    rule filter_ESV_table:
        input:
            table=config["outdir"] + "/ESV.table",
            fasta=get_final_fasta()
        output:
            config["outdir"] + "/ESV.table.filtered"
        shell:
            """
            python3 scripts/python/filter_ESV_table.py \
            {input.table} {input.fasta} > {output}
            """

############################################
# STEP 4: Cleanup
############################################

rule cleanup_longest_orfs:
    input:
        config["outdir"] + (
            "/results_report1.csv"
            if config["report"]["type"] == 1
            else "/results_report2.csv"
        )
    output:
        touch(config["outdir"] + "/.cleanup_orfs_done")
    shell:
        """
        rm -f {config[outdir]}/longest.orfs.fasta
        rm -f {config[outdir]}/cat.asv.sha1.fasta
        """

rule build_final_sequences:
    input:
        fasta = get_final_fasta()
    output:
        config["outdir"] + "/final_sequences.fasta"
    shell:
        """
        cp {input.fasta} {output}
        """
