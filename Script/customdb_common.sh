#!/usr/bin/env bash
set -euo pipefail

DADA2_DIR="$(readlink -f "$1")"

PROJECT_DIR="/data/home2/ksy/260724_GutMyco_Fungal_Mock_Paper"
ITSDETECTOR_DIR="/home/ksy/projects/ITSdetector"
QIIME_SIF="/data/software/singularity/qiime2_amplicon_2025.7.sif"
BLAST_BIN="/data/software/blast-2.16/ncbi-blast-2.16.0+/bin"

REF_FASTA="${PROJECT_DIR}/Input/Mock_ATCC_typestrain/mock_fungi_type_reference_ITS.fasta"
DB_DIR="${PROJECT_DIR}/Database/mock_type_reference_blast"
DB_PREFIX="${DB_DIR}/mock_fungi_type_reference_ITS"

REPSEQ_QZA="${DADA2_DIR}/repseq.qza"
QUERY_FASTA="${DADA2_DIR}/dna-sequences.fasta"

RUN_DIR="$(echo "${DADA2_DIR}" | sed -E 's#/dada2/.*$##')"
PREPROCESS_DIR="$(echo "${DADA2_DIR}" | awk -F'/dada2/' '{print $2}' | cut -d'/' -f1)"
READ_DIR="$(echo "${DADA2_DIR}" | awk -F'/dada2/' '{print $2}' | cut -d'/' -f2)"

OUT_DIR="${RUN_DIR}/taxonomy_blast/${PREPROCESS_DIR}/${READ_DIR}/CustomDB"

TAXID_MAP="${DB_DIR}/mock_fungi_type_reference_taxid_map.tsv"
LINEAGE_TSV="${DB_DIR}/mock_fungi_type_reference_lineage.tsv"

RAW_BLAST="${OUT_DIR}/custom_mock_blast_raw.tsv"
TOP5="${OUT_DIR}/blast_candidates_top5.tsv"
SELECTION_REPORT="${OUT_DIR}/blast_selection_report.tsv"
BLAST_TAXONOMY="${OUT_DIR}/blast_taxonomy.tsv"
FINAL_TAXONOMY="${OUT_DIR}/taxonomy.tsv"

mkdir -p "${DB_DIR}"
mkdir -p "${OUT_DIR}"

echo "[INFO] DADA2 input directory: ${DADA2_DIR}"
echo "[INFO] Run directory: ${RUN_DIR}"
echo "[INFO] Preprocess directory: ${PREPROCESS_DIR}"
echo "[INFO] Read directory: ${READ_DIR}"
echo "[INFO] CustomDB output directory: ${OUT_DIR}"
