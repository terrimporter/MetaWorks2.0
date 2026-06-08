############################################
# PSEUDOGENE FILTERING MODULE (ASV)
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
            grep -e "{params.taxon1}" {input} | cut -f1 | cut -d ';' -f1 > {output} || true
        else
            grep -e "{params.taxon1}" {input} | grep -v "{params.taxon2}" | cut -f1 | cut -d ';' -f1 > {output} || true
        fi
        """

############################################
# STEP 2: ORF detection (NT)
############################################

rule call_orfs_nt:
    input:
        config["outdir"] + "/cat.asv.sha1.fasta"
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
# METHOD 1: Longest ORF
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
# METHOD 2: HMM-based filtering (FIXED)
############################################

if config["pseudogenes"]["method"] == 2 and config["marker"] == "COI":

    rule call_orfs_aa:
        input:
            config["outdir"] + "/cat.asv.sha1.fasta"
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

    rule hmmscan:
        input:
            orf=config["outdir"] + "/orfs.fasta.aa.filtered",
            hmm=config["pseudogenes"]["hmm"]
        output:
            config["outdir"] + "/hmm.txt"
        shell:
            """
            hmmscan --tblout {output} {input.hmm} {input.orf}
            """

    rule apply_hmm_filter:
        input:
            hmmer=config["outdir"] + "/hmm.txt",
            orfs=config["outdir"] + "/orfs.fasta.nt.filtered",
            rdp=config["outdir"] + "/rdp.out.tmp"
        output:
            taxonomy=config["outdir"] + "/taxonomy_ORF.tsv",
            fasta=config["outdir"] + "/final_orfs.fasta.tmp"        
        shell:
            """
            python3 scripts/python/filter_rdp_hmm.py \
            {input.hmmer} {input.orfs} {input.rdp} > {output.taxonomy}
            """

############################################
# STEP 4: Select final ORFs (FIXED)
############################################

rule select_final_orfs:
    input:
        lambda wc: (
            config["outdir"] + "/longest.orfs.fasta"
            if config["pseudogenes"]["method"] == 1
            else (
                config["outdir"] + "/final_orfs.fasta.tmp"
            )
        )
    output:
        config["outdir"] + "/final_orfs.fasta"
    shell:
        "cp {input} {output}"
