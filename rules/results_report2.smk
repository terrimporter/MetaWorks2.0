rule build_manifest:
    output:
        config["outdir"] + "/results_report2.csv"
    run:
        table_name = (
            "ESV.table.filtered"
            if config["pseudogenes"]["enabled"]
            else "ESV.table"
        )

        with open(output[0], "w") as f:
            f.write("file,type,description\n")
            f.write(f"{table_name},abundance,ESV abundance table\n")
            f.write("taxonomy.csv,taxonomy,RDP classification output\n")
            f.write("final_sequences.fasta,sequence,Final ASV sequences used for taxonomic assignment\n")
