#!/usr/bin/env bash
set -euo pipefail

STEP="$1"
DADA2_INPUT="$2"

source /data/home2/ksy/260724_GutMyco_Fungal_Mock_Paper/Script/customdb_common.sh "${DADA2_INPUT}"

if [ "${STEP}" = "export" ]; then
  singularity exec --bind /data:/data,/home:/home "${QIIME_SIF}" qiime tools export --input-path "${REPSEQ_QZA}" --output-path "${DADA2_DIR}"
fi

if [ "${STEP}" = "db" ]; then
  printf "NR_121481.1\t900001\nNR_171785.1\t900002\nNR_144900.1\t900003\nNR_077145.1\t900004\nNR_130690.1\t900005\nNR_125332.1\t900006\nNR_130691.1\t900007\nNR_111475.1\t900008\nNR_111007.1\t900009\nNR_130667.1\t900010\n" > "${TAXID_MAP}"

  printf "TaxID\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\tSpecies\n900001\tFungi\tAscomycota\tEurotiomycetes\tEurotiales\tAspergillaceae\tAspergillus\tAspergillus_fumigatus\n900002\tFungi\tBasidiomycota\tTremellomycetes\tTremellales\tTremellaceae\tCryptococcus\tCryptococcus_neoformans\n900003\tFungi\tAscomycota\tEurotiomycetes\tOnygenales\tArthrodermataceae\tTrichophyton\tTrichophyton_interdigitale\n900004\tFungi\tAscomycota\tEurotiomycetes\tEurotiales\tAspergillaceae\tPenicillium\tPenicillium_chrysogenum\n900005\tFungi\tAscomycota\tSordariomycetes\tHypocreales\tNectriaceae\tFusarium\tFusarium_keratoplasticum\n900006\tFungi\tAscomycota\tSaccharomycetes\tSaccharomycetales\tDebaryomycetaceae\tCandida\tCandida_albicans\n900007\tFungi\tAscomycota\tSaccharomycetes\tSaccharomycetales\tSaccharomycetaceae\tNakaseomyces\tNakaseomyces_glabratus\n900008\tFungi\tBasidiomycota\tMalasseziomycetes\tMalasseziales\tMalasseziaceae\tMalassezia\tMalassezia_globosa\n900009\tFungi\tAscomycota\tSaccharomycetes\tSaccharomycetales\tSaccharomycetaceae\tSaccharomyces\tSaccharomyces_cerevisiae\n900010\tFungi\tBasidiomycota\tTremellomycetes\tTrichosporonales\tTrichosporonaceae\tCutaneotrichosporon\tCutaneotrichosporon_dermatis\n" > "${LINEAGE_TSV}"

  rm -f "${DB_PREFIX}.ndb" "${DB_PREFIX}.nhr" "${DB_PREFIX}.nin" "${DB_PREFIX}.nog" "${DB_PREFIX}.nos" "${DB_PREFIX}.not" "${DB_PREFIX}.nsq" "${DB_PREFIX}.ntf" "${DB_PREFIX}.nto"

  "${BLAST_BIN}/makeblastdb" -in "${REF_FASTA}" -dbtype nucl -parse_seqids -taxid_map "${TAXID_MAP}" -blastdb_version 4 -out "${DB_PREFIX}" -title mock_fungi_type_reference_ITS
fi

if [ "${STEP}" = "blast" ]; then
  "${BLAST_BIN}/blastn" -query "${QUERY_FASTA}" -db "${DB_PREFIX}" -out "${RAW_BLAST}" -outfmt "6 qacc staxids sacc evalue bitscore qcovus pident length" -task blastn -word_size 7 -dust no -max_target_seqs 10 -evalue 1000 -num_threads 8
fi

if [ "${STEP}" = "select" ]; then
  python3 /home/ksy/projects/ITSdetector/bin/select_blast_hits.py \
    --blast-raw "${RAW_BLAST}" \
    --output-dir "${OUT_DIR}" \
    --top-n 5 \
    --max-evalue 1000 \
    --min-pident 0 \
    --min-qcovus 0
fi

if [ "${STEP}" = "build" ]; then
  python3 /home/ksy/projects/ITSdetector/bin/build_blast_taxonomy.py \
    --candidates "${TOP5}" \
    --lineage "${LINEAGE_TSV}" \
    --selection-report "${SELECTION_REPORT}" \
    --output-dir "${OUT_DIR}"
fi

if [ "${STEP}" = "convert" ]; then
  python3 /data/home2/ksy/260724_GutMyco_Fungal_Mock_Paper/Script/make_customdb_taxonomy.py "${OUT_DIR}"
  head "${FINAL_TAXONOMY}"
fi

if [ "${STEP}" = "status" ]; then
  echo "[CHECK] ${REPSEQ_QZA}"
  ls -lh "${REPSEQ_QZA}" 2>/dev/null || true

  echo "[CHECK] ${QUERY_FASTA}"
  ls -lh "${QUERY_FASTA}" 2>/dev/null || true

  echo "[CHECK] ${RAW_BLAST}"
  ls -lh "${RAW_BLAST}" 2>/dev/null || true

  echo "[CHECK] ${TOP5}"
  ls -lh "${TOP5}" 2>/dev/null || true

  echo "[CHECK] ${SELECTION_REPORT}"
  ls -lh "${SELECTION_REPORT}" 2>/dev/null || true

  echo "[CHECK] ${BLAST_TAXONOMY}"
  ls -lh "${BLAST_TAXONOMY}" 2>/dev/null || true

  echo "[CHECK] ${FINAL_TAXONOMY}"
  ls -lh "${FINAL_TAXONOMY}" 2>/dev/null || true
fi
