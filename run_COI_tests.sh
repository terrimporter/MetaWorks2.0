#!/bin/bash
set -e

CONFIG="config/config_COI_ASV.yaml"
CONFIG_OTU="config/config_COI_OTU.yaml"

RESULTS_DIR="COITestResults"

# ---- setup results folder ----
rm -rf $RESULTS_DIR
mkdir -p $RESULTS_DIR

SUMMARY="$RESULTS_DIR/summary.tsv"

# ---- header ----
printf "Test\tReportType\tPseudogeneRemoval\tPseudogeneRemovalType\tNumASVs\tNumOTUs\n" > $SUMMARY

run_test () {

    NAME=$1
    REPORT=$2
    ENABLED=$3
    METHOD=$4

    echo ""
    echo "======================================"
    echo "Running $NAME"
    echo "report=$REPORT pseudogenes=$ENABLED method=$METHOD"
    echo "======================================"

    # ---- reset config ----
    cp config/bak/config_COI_ASV.yaml $CONFIG

    # ---- update config ----
    sed -i "s/type: [12]/type: $REPORT/" $CONFIG
    sed -i "s/enabled: .*/enabled: $ENABLED/" $CONFIG
    sed -i "s/method: .*/method: $METHOD/" $CONFIG

    # ---- clean outputs ----
    rm -rf COI_ASV COI_OTU

    # ---- run ASV ----
    snakemake -s Snakefile_ASV --configfile $CONFIG --cores 4

    # ---- run OTU ----
    snakemake -s Snakefile_OTU --configfile $CONFIG_OTU --cores 4

    # ---- count sequences ----
    ASV_COUNT=$(grep -c "^>" COI_ASV/final_sequences.fasta || echo 0)
    OTU_COUNT=$(grep -c "^>" COI_OTU/otu.fasta || echo 0)

    # ---- method display logic ----
    if [ "$ENABLED" = "false" ]; then
        METHOD_DISPLAY="N/A"
    else
        METHOD_DISPLAY="$METHOD"
    fi

    # ---- write summary ----
    printf "%s\t%s\t%s\t%s\t%s\t%s\n" \
        "$NAME" "$REPORT" "$ENABLED" "$METHOD_DISPLAY" "$ASV_COUNT" "$OTU_COUNT" \
        >> $SUMMARY

    # ---- save outputs ----
    mkdir -p $RESULTS_DIR/$NAME
    mv COI_ASV $RESULTS_DIR/$NAME/
    mv COI_OTU $RESULTS_DIR/$NAME/

    echo "$NAME finished"
}

############################################
# TESTS 1 to 3 (report type 1)
############################################

run_test Test1 1 false 1
run_test Test2 1 true 1
run_test Test3 1 true 2

############################################
# TESTS 4 to 6 (report type 2)
############################################

run_test Test4 2 false 1
run_test Test5 2 true 1
run_test Test6 2 true 2

echo ""
echo "ALL TESTS COMPLETED"
echo "Summary file: $SUMMARY"
