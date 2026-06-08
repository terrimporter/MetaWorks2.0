rule ITS_extraction:
    input:
        config["outdir"] + "/cat.denoised.nonchimeras"
    output:
        config["outdir"] + "/ITSx_out.fasta"
    shell:
        "ITSx -i {input} -o {output}"
``
