# extract_all_fitment.py

import pdfplumber
import re
import csv

PDF_PATH = "3267-Model Accessory Price List February 20_V2.pdf"
OUT_CSV  = "all_model_fitment.csv"

records = []

with pdfplumber.open(PDF_PATH) as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        if not text:
            continue
        # clean and split lines
        lines = [line.strip() for line in text.splitlines() if line.strip()]
        
        # Model name is usually on first non-empty line
        model = lines[0]
        
        # 1) find the line with your variants (at least two tokens like '2.5i', '3.6R', etc.)
        variant_line = None
        for line in lines:
            variants = re.findall(r"\d+\.\d+\w*", line)
            if len(variants) >= 2:
                variant_line = line
                break
        if not variant_line:
            continue
        
        # parse the variants in their order
        variants = re.findall(r"\d+\.\d+\w*", variant_line)
        
        # 2) parse each subsequent part line
        for line in lines:
            # skip lines that are the model or variant headers
            if line == model or line == variant_line:
                continue
            
            parts = line.split()
            # must start with a valid part number
            if not re.match(r"^[A-Z0-9#]{3,}", parts[0]):
                continue
            
            # find the two monetary fields ($...)
            money_idxs = [i for i, tok in enumerate(parts) if tok.startswith("$")]
            if len(money_idxs) < 2:
                continue
            _, idx_rrp_fitted = money_idxs[:2]
            
            pn = parts[0]
            # everything between RRP_Fitted and the final fitting-time token are markers
            markers = parts[idx_rrp_fitted+1:-1]
            # right-align markers under variants
            missing = len(variants) - len(markers)
            marks_full = [""] * missing + markers
            
            for var, mark in zip(variants, marks_full):
                if mark.upper() == "STD":
                    avail = "Standard"
                elif mark in {"•", "."}:
                    avail = "Yes"
                else:
                    avail = "No"
                
                records.append({
                    "Model": model,
                    "ModelVariant": var,
                    "PartNumber": pn,
                    "Availability": avail
                })

# write out combined CSV
with open(OUT_CSV, "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["Model","ModelVariant","PartNumber","Availability"])
    writer.writeheader()
    writer.writerows(records)

print(f"✔ Extracted {len(records)} rows into {OUT_CSV}")
