def rdp_command(input_file, output_file):
    return f"""
    java {config['rdp']['memory']} -jar {config['rdp']['jar']} classify \
        -t {config['rdp']['classifier']} \
        -o {output_file} \
        {input_file}
    """

rule taxonomic_assignment:
    input:
        config["outdir"] + "/cat.asv.sha1.fasta"
    output:
        config["outdir"] + "/rdp.out.tmp"
    shell:
        rdp_command(input[0], output[0])

