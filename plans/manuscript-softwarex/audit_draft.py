"""Check the generated draft and create a compact PDF layout preview."""
from pathlib import Path
import csv
import hashlib
import json
import re

from docx import Document
from docx.oxml.ns import qn
import pymupdf
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parent
stem = "SampleSizeCalc_SoftwareX_draft"
word = Document(root / f"{stem}.docx")
paragraphs = [p.text for p in word.paragraphs]
all_word_text = "\n".join(paragraphs)
assert "Sample size planning requires researchers" in all_word_text
assert "5 November 2026" in all_word_text
assert len(word.inline_shapes) == 2
assert len(word.tables) == 4
assert not re.search(r"\[@|@(?:machin|zhou|julious|phillips)\d", all_word_text)

for heading in [
    "Motivation and significance", "Software description", "Illustrative examples",
    "Verification and reproducibility", "Impact and limitations", "Conclusions",
    "Code metadata and availability", "Author declarations", "References",
]:
    assert heading in paragraphs, heading

blocks = []
for item in word.element.body:
    if item.tag == qn("w:p"):
        blocks.append("".join(t.text or "" for t in item.iter(qn("w:t"))))
    elif item.tag == qn("w:tbl"):
        for row in item.iter(qn("w:tr")):
            blocks.append(" ".join("".join(t.text or "" for t in cell.iter(qn("w:t")))
                                   for cell in row.iter(qn("w:tc"))))

start = blocks.index("Motivation and significance")
end = blocks.index("Code metadata and availability")
count_words = lambda text: len(re.findall(r"\b[\w]+(?:[-'][\w]+)*\b", text))
main_words = count_words("\n".join(blocks[start:end]))
assert main_words < 4000
abstract = paragraphs[paragraphs.index("Abstract") + 1]

with (root / "tables/validation-full.csv").open(encoding="utf-8", newline="") as handle:
    comparisons = list(csv.DictReader(handle))
assert len(comparisons) == 12
assert all(float(row["Difference"]) == 0 for row in comparisons)
verification = json.loads((root / "evidence/verification.json").read_text(encoding="utf-8"))
assert verification["legal_combinations"] == 46
assert verification["design_identifiers"] == 24
assert verification["numerical_comparisons"] == 12
assert verification["comparisons_agree"] is True
source_archive = root / "evidence/SampleSizeCalc_3.1.1.tar.gz"
source_hash = hashlib.sha256(source_archive.read_bytes()).hexdigest()
assert source_hash == verification["archive_sha256"]

pdf = pymupdf.open(root / f"{stem}.pdf")
pdf_text = "\n".join(page.get_text() for page in pdf)
assert "1,061" in pdf_text
assert "TO COMPLETE" in pdf_text
assert "Sample size planning requires researchers" in pdf_text
assert "5 November 2026" in pdf_text
assert not re.search(r"\[@|@(?:machin|zhou|julious|phillips)\d", pdf_text)

preview = root / "evidence/layout-preview"
preview.mkdir(exist_ok=True)
thumbs = []
for page in pdf:
    pixmap = page.get_pixmap(matrix=pymupdf.Matrix(0.55, 0.55), alpha=False)
    thumbs.append(Image.frombytes("RGB", (pixmap.width, pixmap.height), pixmap.samples))
width = max(image.width for image in thumbs) + 16
height = max(image.height for image in thumbs) + 30
contact = Image.new("RGB", (width * 3, height * ((len(thumbs) + 2) // 3)), "#dddddd")
drawing = ImageDraw.Draw(contact)
for index, image in enumerate(thumbs):
    x, y = (index % 3) * width + 8, (index // 3) * height
    contact.paste(image, (x, y + 22))
    drawing.text((x, y + 5), f"Page {index + 1}", fill="black")
contact.save(preview / "contact-sheet.png")

summary = {
    "draft": "0.1", "draft_date": "2026-11-05", "pdf_pages": len(pdf),
    "docx_figures": len(word.inline_shapes), "docx_tables": len(word.tables),
    "main_body_approximate_words_including_tables": main_words,
    "abstract_approximate_words": count_words(abstract),
    "word_count_method": "Regex token count over DOCX main body and tables, excluding abstract, code metadata, declarations and references; publisher/Word counts may differ.",
    "legal_combinations": 46, "design_identifiers": 24,
    "numerical_comparisons": 12, "all_selected_integer_comparisons_agree": True,
    "source_archive_sha256": source_hash,
    "author_completion_markers_in_paragraphs": all_word_text.count("TO COMPLETE"),
    "citation_markers_resolved_in_docx_and_pdf": True,
    "layout_preview": "evidence/layout-preview/contact-sheet.png",
}
(root / "evidence/draft-audit.json").write_text(
    json.dumps(summary, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
)
print(json.dumps(summary, indent=2, ensure_ascii=False))
