import pdfplumber

PDF_PATH = "3267-Model Accessory Price List February 20_V2.pdf"

with pdfplumber.open(PDF_PATH) as pdf:
    for i, page in enumerate(pdf.pages[:10], start=1):
        tbl = page.extract_table()
        if tbl:
            print(f"Page {i} header row:", tbl[0])
        else:
            print(f"Page {i} has no table.extract_table() output")
