############################################
# FULL PIPELINE STATS SUMMARY
############################################

rule combine_sample_stats:
    input:
        r1=config["outdir"] + "/stats/{sample}.R1stats",
        r2=config["outdir"] + "/stats/{sample}.R2stats",
        merged=config["outdir"] + "/stats/{sample}.merged.stats",
        trimmed=config["outdir"] + "/stats/{sample}.trimmed.stats"
    output:
        config["outdir"] + "/stats/{sample}.pipeline.stats"
    run:
        def read_count(path):
            with open(path) as f:
                return f.readline().strip().split("\t")[1]

        r1 = read_count(input.r1)
        r2 = read_count(input.r2)
        merged = read_count(input.merged)
        trimmed = read_count(input.trimmed)

        sample = wildcards.sample

        with open(output[0], "w") as out:
            out.write(f"{sample}\t{r1}\t{r2}\t{merged}\t{trimmed}\n")

rule combine_all_stats:
    input:
        expand(config["outdir"] + "/stats/{sample}.pipeline.stats", sample=SAMPLES_UNIQUE)
    output:
        config["outdir"] + "/stats/pipeline_stats.tsv"
    shell:
        """
        echo -e "sample\traw_R1\traw_R2\tmerged\ttrimmed" > {output}
        cat {input} >> {output}
        """
