#!/usr/bin/env bash
set -euo pipefail

INPUT="assets/HN00276571_samplesheet.csv"
PARAM_DIR="params/figure4"
OUT_BASE="results/figure4"

while IFS=$'\t' read -r run_label params_file outdir preprocess_method analysis_mode blast_refseq_enabled; do
    if [[ "$run_label" == "run_label" ]]; then
        continue
    fi

    echo "============================================================"
    echo "Running: $run_label"
    echo "============================================================"

    nextflow run main.nf \
        -params-file "$params_file" \
        --input "$INPUT" \
        --outdir "$outdir"

done < "${PARAM_DIR}/figure4_run_manifest.tsv"
