rule otu_taxonomy:
    input:
        fasta = config["outdir"] + "/otu.fasta"
    output:
        config["outdir"] + "/otu.taxonomy.csv"
    params:
        memory = config["taxonomy"]["memory"],
        jar = config["taxonomy"]["jar"],
        classifier = config["taxonomy"]["classifier"]
    shell:
        """
        java {params.memory} -jar {params.jar} classify \
          -t {params.classifier} \
          -o {output} \
          {input.fasta}
        """
