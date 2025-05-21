import pdfplumber
import pandas as pd
import re
# from ace_tools import display_dataframe_to_user

# 1) Open the PDF
pdf = pdfplumber.open("/mnt/data/3267-Model Accessory Price List February 20_V2.pdf")

entries = []
part_id = 1

for page in pdf.pages[5:]:  # pages start at 0; accessory guide begins on page 6
    text = page.extract_text() or ""
    lines = text.split("\n")
    
    current_model = None
    current_category = None
    variant_names = None
    
    for idx, line in enumerate(lines):
        s = line.strip()
        
        # -- New model section starts with "MY20 <ModelName>"
        if s.startswith("MY20 "):
            current_model = s.replace("MY20 ", "").title()
            current_category = None
            variant_names = None
            continue
        
        # -- Category headings are FULL-CAPS, no digits, no $
        if s.isupper() and not any(ch.isdigit() for ch in s) and "$" not in s and "RRP" not in s:
            current_category = s.title()
            continue
        
        # -- Variant header (may be single or two-line)
        if "FITTED" in s and "TIME" in s:
            # grab just between "FITTED" and "TIME"
            raw = s.split("FITTED", 1)[1].split("TIME", 1)[0]
            raw_tokens = raw.split()
            
            # if the very next line also looks like the second half of the header, zip them
            next_line = lines[idx+1].strip() if idx+1 < len(lines) else ""
            next_tokens = next_line.split()
            
            if any(tok.isalpha() for tok in next_tokens) and len(raw_tokens) > 1:
                # e.g. raw_tokens = ["1.6","1.6","2.0","2.0","STI"]
                # next_tokens = ["GT","GT-P","GT-S","Sport"]
                n = min(len(raw_tokens), len(next_tokens))
                variant_names = [f"{raw_tokens[i]} {next_tokens[i]}" for i in range(n)]
            else:
                # single-line (Liberty / Outback)
                variant_names = raw_tokens
            
            continue
        
        # -- wait until we've seen the variants
        if not variant_names:
            continue
        
        # -- skip non-data rows
        if (not s or
            s.startswith(("Accessory Guide","PART","DESCRIPTION","NUMBER"))):
            continue
        
        tokens = s.split()
        price_idx = [i for i,t in enumerate(tokens) if t.startswith("$")]
        if len(price_idx) < 2:
            continue
        
        i1, i2 = price_idx[0], price_idx[1]
        part_number   = tokens[0]
        part_desc     = " ".join(tokens[1:i1])
        try:
            rrp         = float(tokens[i1].replace("$","").replace(",",""))
            rrp_fitted  = float(tokens[i2].replace("$","").replace(",",""))
        except:
            continue
        
        # fitting time is the last token if numeric
        if re.fullmatch(r"\d+(\.\d+)?", tokens[-1]):
            fitting_time = float(tokens[-1])
            markers = tokens[i2+1:-1]
        else:
            fitting_time = None
            markers = tokens[i2+1:]
        
        # pad markers so we can zip
        markers += [""] * (len(variant_names) - len(markers))
        
        # build one entry per variant
        for j, var in enumerate(variant_names):
            mark = markers[j]
            if mark == "•":
                avail = "Yes"
            elif mark.upper() == "STD":
                avail = "Standard"
            else:
                avail = "No"
            
            entries.append({
                "PartID":        part_id,
                "Brand":         "Subaru",
                "ModelVariant":  f"{current_model} {var}",
                "Category":      current_category,
                "PartNumber":    part_number,
                "PartDescription": part_desc,
                "RRP":           rrp,
                "RRP_Fitted":    rrp_fitted,
                "FittingTime":   fitting_time,
                "Availability":  avail
            })
            part_id += 1

# 2) Build DataFrame and display
df = pd.DataFrame(entries)
print(df)
