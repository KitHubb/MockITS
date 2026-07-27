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

mkdir -p "${DB_DIR}"
mkdir -p "${OUT_DIR}"

echo "[INFO] DADA2 input directory: ${DADA2_DIR}"
echo "[INFO] Run directory: ${RUN_DIR}"
echo "[INFO] Preprocess directory: ${PREPROCESS_DIR}"
echo "[INFO] Read directory: ${READ_DIR}"
echo "[INFO] CustomDB output directory: ${OUT_DIR}"
echo "[INFO] ITSdetector bin directory: ${ITSDETECTOR_DIR}/bin"

if [ ! -f "${REPSEQ_QZA}" ]; then
  echo "[ERROR] repseq.qza not found: ${REPSEQ_QZA}" >&2
  exit 1
fi

if [ ! -f "${REF_FASTA}" ]; then
  echo "[ERROR] Reference FASTA not found: ${REF_FASTA}" >&2
  exit 1
fi

if [ ! -f "${ITSDETECTOR_DIR}/bin/select_blast_hits.py" ]; then
  echo "[ERROR] select_blast_hits.py not found: ${ITSDETECTOR_DIR}/bin/select_blast_hits.py" >&2
  exit 1
fi

if [ ! -f "${ITSDETECTOR_DIR}/bin/build_blast_taxonomy.py" ]; then
  echo "[ERROR] build_blast_taxonomy.py not found: ${ITSDETECTOR_DIR}/bin/build_blast_taxonomy.py" >&2
  exit 1
fi

printf "NR_121481.1\t900001\nNR_171785.1\t900002\nNR_144900.1\t900003\nNR_077145.1\t900004\nNR_130690.1\t900005\nNR_125332.1\t900006\nNR_130691.1\t900007\nNR_111475.1\t900008\nNR_111007.1\t900009\nNR_130667.1\t900010\n" > "${DB_DIR}/mock_fungi_type_reference_taxid_map.tsv"

printf "TaxID\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\tSpecies\n900001\tFungi\tAscomycota\tEurotiomycetes\tEurotiales\tAspergillaceae\tAspergillus\tAspergillus_fumigatus\n900002\tFungi\tBasidiomycota\tTremellomycetes\tTremellales\tTremellaceae\tCryptococcus\tCryptococcus_neoformans\n900003\tFungi\tAscomycota\tEurotiomycetes\tOnygenales\tArthrodermataceae\tTrichophyton\tTrichophyton_interdigitale\n900004\tFungi\tAscomycota\tEurotiomycetes\tEurotiales\tAspergillaceae\tPenicillium\tPenicillium_chrysogenum\n900005\tFungi\tAscomycota\tSordariomycetes\tHypocreales\tNectriaceae\tFusarium\tFusarium_keratoplasticum\n900006\tFungi\tAscomycota\tSaccharomycetes\tSaccharomycetales\tDebaryomycetaceae\tCandida\tCandida_albicans\n900007\tFungi\tAscomycota\tSaccharomycetes\tSaccharomycetales\tSaccharomycetaceae\tNakaseomyces\tNakaseomyces_glabratus\n900008\tFungi\tBasidiomycota\tMalasseziomycetes\tMalasseziales\tMalasseziaceae\tMalassezia\tMalassezia_globosa\n900009\tFungi\tAscomycota\tSaccharomycetes\tSaccharomycetales\tSaccharomycetaceae\tSaccharomyces\tSaccharomyces_cerevisiae\n900010\tFungi\tBasidiomycota\tTremellomycetes\tTrichosporonales\tTrichosporonaceae\tCutaneotrichosporon\tCutaneotrichosporon_dermatis\n" > "${DB_DIR}/mock_fungi_type_reference_lineage.tsv"

singularity exec --bind /data:/data,/home:/home "${QIIME_SIF}" qiime tools export --input-path "${REPSEQ_QZA}" --output-path "${DADA2_DIR}"

if [ ! -f "${QUERY_FASTA}" ]; then
  echo "[ERROR] QIIME2 exported FASTA not found: ${QUERY_FASTA}" >&2
  exit 1
fi

rm -f "${DB_PREFIX}.ndb"
rm -f "${DB_PREFIX}.nhr"
rm -f "${DB_PREFIX}.nin"
rm -f "${DB_PREFIX}.nog"
rm -f "${DB_PREFIX}.nos"
rm -f "${DB_PREFIX}.not"
rm -f "${DB_PREFIX}.nsq"
rm -f "${DB_PREFIX}.ntf"
rm -f "${DB_PREFIX}.nto"

"${BLAST_BIN}/makeblastdb" -in "${REF_FASTA}" -dbtype nucl -parse_seqids -taxid_map "${DB_DIR}/mock_fungi_type_reference_taxid_map.tsv" -blastdb_version 4 -out "${DB_PREFIX}" -title mock_fungi_type_reference_ITS

"${BLAST_BIN}/blastn" -query "${QUERY_FASTA}" -db "${DB_PREFIX}" -out "${OUT_DIR}/custom_mock_blast_raw.tsv" -outfmt "6 qacc staxids sacc evalue bitscore qcovus pi

python3 "${ITSDETECTOR_DIR}/bin/select_blast_hi

python3 "${ITSDETECTOR_DIR}/bin/build_blast_taxonomy.py" --candi

python3 "${PROJECT_DIR}/Script/make_customdb_taxonomy.py" "

echo "[INFO] Final CustomDB taxonomy:"
echo "${OUT_DIR}/taxonomy.tsv"

head "${OUT_DIR}/t
