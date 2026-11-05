from pathlib import Path

from docx import Document
from docx.enum.style import WD_STYLE_TYPE
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor

folder = Path(__file__).resolve().parent
doc = Document()
section = doc.sections[0]
section.page_width = Cm(21)
section.page_height = Cm(29.7)
section.top_margin = Cm(2.3)
section.bottom_margin = Cm(2.3)
section.left_margin = Cm(2.3)
section.right_margin = Cm(2.3)

for name in ["Normal", "Body Text", "First Paragraph"]:
    if name not in doc.styles:
        doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
    style = doc.styles[name]
    style.font.name = "Times New Roman"
    style.font.size = Pt(11)
    style.paragraph_format.line_spacing = 1.15
    style.paragraph_format.space_after = Pt(6)

for name, size in [("Title", 17), ("Heading 1", 13), ("Heading 2", 11.5)]:
    style = doc.styles[name]
    style.font.name = "Times New Roman"
    style.font.size = Pt(size)
    style.font.bold = True
    style.font.color.rgb = RGBColor(0, 0, 0)
    style.paragraph_format.keep_with_next = True

for name in ["Caption", "Image Caption", "Table Caption"]:
    if name not in doc.styles:
        doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
    doc.styles[name].font.name = "Times New Roman"
    doc.styles[name].font.size = Pt(9)

if "Table" not in doc.styles:
    doc.styles.add_style("Table", WD_STYLE_TYPE.TABLE)
doc.styles["Table"].font.name = "Times New Roman"
doc.styles["Table"].font.size = Pt(9)

header = section.header.paragraphs[0]
header.text = "SampleSizeCalc | SoftwareX working draft"
header.runs[0].font.size = Pt(9)
header.runs[0].font.color.rgb = RGBColor(90, 90, 90)
footer = section.footer.paragraphs[0]
footer.alignment = WD_ALIGN_PARAGRAPH.RIGHT
run = footer.add_run("Working draft | ")
run.font.size = Pt(9)
field = OxmlElement("w:fldSimple")
field.set(qn("w:instr"), "PAGE")
footer._p.append(field)

doc.core_properties.title = "SampleSizeCalc SoftwareX draft style reference"
doc.core_properties.author = "Portos (Yishan) Wang; Bingxin Cai"
doc.save(folder / "reference.docx")
print("Created reference.docx")
