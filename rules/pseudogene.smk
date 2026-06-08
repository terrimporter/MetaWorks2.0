############################################
# PSEUDOGENE FILTERING MODULE
############################################

############################################
# STEP 1: subset by taxonomy
############################################

rule subset_taxonomy:
    input:
        config["outdir"] + "/rdp.out.tmp"
    output:
        config["outdir"] + "/taxon.zotus"
    params:
        mode=config["tax_filter"]["mode"],
        taxon1=config["tax_filter"]["include"],
        taxon2=config["tax_filter"]["exclude"]
    shell:
        """
        if [ {params.mode} -eq 1 ]; then
            grep -e "{params.taxon1}" {input} | \
            cut -f1 | cut -d ';' -f1 > {output} || true
        else
            grep -e "{params.taxon1}" {input} | \
            grep -v "{params.taxon2}" | \
            cut -f1 | cut -d ';' -f1 > {output} || true
        fi
        """

############################################
# STEP 1B: clean FASTA IDs
############################################

rule clean_fasta_ids:
    input:
        config["outdir"] + "/cat.denoised.nonchimeras"
    output:
        config["outdir"] + "/cat.clean.fasta"
    shell:
        """
        awk '/^>/ {{sub(/;.*/, "", $0)}}1' {input} > {output}
        """

############################################
# STEP 1C: subset FASTA
############################################

rule subset_ESVs:
    input:
        tax=config["outdir"] + "/taxon.zotus",
        fasta=config["outdir"] + "/cat.clean.fasta"
    output:
        config["outdir"] + "/filtered_by_taxon.fasta"
    shell:
        """
        python3 scripts/python/get_taxon_only.py \
        {input.tax} {input.fasta} > {output}
        """

############################################
# STEP 2: ORF detection (NT)
############################################

rule call_orfs_nt:
    input:
        config["outdir"] + "/cat.zotu.fasta"
    output:
        config["outdir"] + "/orfs.fasta.nt"
    params:
        g=config["orfs"]["genetic_code"],
        s=config["orfs"]["start_mode"],
        ml=config["orfs"]["min_length"],
        n=str(config["orfs"]["no_nested"]).lower(),
        strand=config["orfs"]["strand"]
    shell:
        """
        ORFfinder \
          -in {input} \
          -g {params.g} \
          -s {params.s} \
          -ml {params.ml} \
          -n {params.n} \
          -strand {params.strand} \
          -outfmt 1 > {output}
        """

############################################
# STEP 2B: ORF length filtering
############################################

if config["pseudogenes"]["method"] == 1:

    rule get_longest_orfs:
        input:
            config["outdir"] + "/orfs.fasta.nt"
        output:
            config["outdir"] + "/longest.orfs.fasta"
        shell:
            """
            python3 scripts/python/parse_orfs3.py {input} {output}
            """

############################################
# STEP 3: HMM-based filtering (COI)
############################################

if config["pseudogenes"]["method"] == 2 and config["marker"] == "COI":

    rule call_orfs_aa:
        input:
            config["outdir"] + "/cat.zotu.fasta"
        output:
            config["outdir"] + "/orfs.fasta.aa"
        params:
            g=config["orfs"]["genetic_code"],
            s=config["orfs"]["start_mode"],
            ml=config["orfs"]["min_length"],
            n=str(config["orfs"]["no_nested"]).lower(),
            strand=config["orfs"]["strand"]
        shell:
            """
            ORFfinder \
              -in {input} \
              -g {params.g} \
              -s {params.s} \
              -ml {params.ml} \
              -n {params.n} \
              -strand {params.strand} \
              -outfmt 0 > {output}
            """

    ############################################
    # ORF matching filter
    ############################################

    rule filter_orfs:
        input:
            nt=config["outdir"] + "/orfs.fasta.nt",
            aa=config["outdir"] + "/orfs.fasta.aa"
        output:
            nt=config["outdir"] + "/orfs.fasta.nt.filtered",
            aa=config["outdir"] + "/orfs.fasta.aa.filtered"
        shell:
            """
            python3 scripts/python/parse_orfs4.py \
            {input.nt} {input.aa} {output.nt} {output.aa}
            """

############################################
# STEP 3B: Choose final ORF set
############################################

rule select_final_orfs:
    input:
        lambda wc: (
            config["outdir"] + "/longest.orfs.fasta"
            if config["pseudogenes"]["method"] == 1
            else config["outdir"] + "/orfs.fasta.nt.filtered"
        )
    output:
        config["outdir"] + "/final_orfs.fasta"
    shell:
        "cp {input} {output}"

############################################
# STEP 4: Final filtered FASTA
############################################

rule finalize_filtered_fasta:
    input:
        config["outdir"] + "/final_orfs.fasta"
    output:
        config["outdir"] + "/final_filtered.fasta"
    shell:
        "cp {input} {output}"

############################################
# STEP 5: Final filtered FASTA stats
############################################

rule final_fasta_stats:
    input:
        config["outdir"] + "/final_filtered.fasta"
    output:
        config["outdir"] + "/stats/final_fasta.stats"
    shell:
        """
        grep -c '^>' {input} > {output}
        """








