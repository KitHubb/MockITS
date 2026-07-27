import sys
import pandas as pd
from pathlib import Path

out_dir = Path(sys.argv[1])

infile = out_dir / "blast_taxonomy.tsv"
outfile = out_dir / "taxonomy.tsv"
evidence_out = out_dir / "taxonomy_customdb_evidence.tsv"

df = pd.read_csv(infile, sep="\t", dtype=str, keep_default_na=False)

rank_cols = [
    "BLAST_Top1_Kingdom",
    "BLAST_Top1_Phylum",
    "BLAST_Top1_Class",
    "BLAST_Top1_Order",
    "BLAST_Top1_Family",
    "BLAST_Top1_Genus",
    "BLAST_Top1_Species",
]

prefix = {
    "BLAST_Top1_Kingdom": "k__",
    "BLAST_Top1_Phylum": "p__",
    "BLAST_Top1_Class": "c__",
    "BLAST_Top1_Order": "o__",
    "BLAST_Top1_Family": "f__",
    "BLAST_Top1_Genus": "g__",
    "BLAST_Top1_Species": "s__",
}

def make_taxon(row):
    parts = []
    for col in rank_cols:
        val = str(row.get(col, "")).strip()
        if val:
            parts.append(prefix[col] + val)
    return "; ".join(parts) if parts else "Unassigned"

tax = pd.DataFrame({
    "Feature ID": df["ASV"],
    "Taxon": df.apply(make_taxon, axis=1),
    "Confidence": df["BLAST_Top1_Pident"],
})

tax.to_csv(outfile, sep="\t", index=False)

evidence = df.copy()
evidence["CustomDB_Taxon"] = tax["Taxon"]
evidence["CustomDB_Confidence"] = tax["Confidence"]
evidence.to_csv(evidence_out, sep="\t", index=False)

print("[INFO] Wrote QIIME/Nextflow-style taxonomy.tsv")
print(outfile)
print("[INFO] Wrote evidence table")
print(evidence_out)
