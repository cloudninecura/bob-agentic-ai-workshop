---
name: ppt-template-slide-workflow
description: Generate polished PowerPoint decks from an existing visual template by selecting relevant source slides and replacing/editing content with direct Open XML replacement and validation. Use whenever asked to create, edit, adapt, automate, or regenerate a PPT/PPTX/deck/slides from template slides, especially IBM Consulting decks. This skill preserves design while requiring direct slide XML edits so template text is replaced or intentionally cleared. Includes IBM Consulting Offerings template with 117 pre-designed slides.
---

# PowerPoint Template Slide Workflow

## Default Template

This skill includes the **IBM Consulting Offerings Template** (v1.0, January 2025):
- **Path**: `.bob/skills/ppt-template-slide-workflow/template/Example_layouts_IBM_Consulting_Offerings_template_v_1_0_011025.pptx`
- **Slides**: 117 professionally designed slides with various layouts
- **Size**: 158.55 MB
- **Style**: IBM Carbon design system with IBM Plex Sans typography, IBM Blue accents, and consistent visual hierarchy

This template provides a comprehensive library of slide layouts for business presentations, technical decks, and client engagements.

### IBM Carbon Design System Compliance

**CRITICAL**: All slides in this template follow the IBM Carbon Design System as documented in `DESIGN.md` at the repository root.

**Design Standards** (see `DESIGN.md` for complete specifications):
- **Typography**: IBM Plex Sans exclusively (weight 300 for display, 400 for body, 600 for emphasis)
- **Colors**: IBM Blue `#0f62fe` as the only accent color, white canvas, charcoal text
- **Geometry**: Flat design with 0px border-radius (square corners only)
- **Spacing**: 4px base unit grid alignment
- **Letter Spacing**: 0.16px on body text (Carbon precision detail)

**When using this skill**:
1. **Before selecting slides**: Review `DESIGN.md` to understand design requirements
2. **During text replacement**: Preserve all formatting - fonts, weights, colors, spacing
3. **Never modify**: Typography, colors, geometry, or spacing that deviates from Carbon
4. **Validation**: Verify output maintains IBM Carbon compliance

**Reference**: See `DESIGN.md` lines 6-502 for complete IBM Carbon Design System specifications, including color palette, typography hierarchy, component definitions, and Do's/Don'ts.

## Template Immutability

**CRITICAL**: The source template file must NEVER be modified directly. The template is an immutable visual library that serves as a reference for all generated presentations.

**Enforcement**:
- The template file is read-only and should remain unchanged
- All deck generation must work from a copy of the template
- Never write to or modify the template file path
- Never save changes back to the template location
- All edits happen on the output `.pptx` file only

**Workflow**:
```text
✅ CORRECT: template.pptx (read-only) → copy → output.pptx (edit) → validate
❌ WRONG:   template.pptx (edit in place) → save
```

**Why this matters**:
- Preserves the visual library for all future generations
- Prevents accidental corruption of the design system
- Ensures consistency across all generated presentations
- Allows rollback and regeneration with confidence
- Maintains IBM Carbon design system compliance

If you need to update the template itself (rare), create a new template version with a new filename and update the default path in this skill documentation.

## Sample Scripts

This skill includes two reference implementations:

1. **`scripts/direct_xml_replace_sample.py`** - Text replacement using direct Open XML
   - Use for: Replacing text content in slides
   - Pattern: Join paragraph text nodes, replace, update XML
   - **Note**: This is for TEXT replacement only, not slide deletion

2. **`scripts/direct_xml_replace_sample.py`** - Complete working example
   - Use for: Full generation workflow (slide deletion + text replacement)
   - Pattern: python-pptx for slide deletion, direct XML for text replacement
   - **Recommended**: Use this as your starting template for new generators

**Critical Distinction**:
- **Slide Deletion**: Use python-pptx API (`delete_slide()`, `keep_only_slides()`)
- **Text Replacement**: Use direct Open XML replacement (join paragraph nodes)

Run the sample from the repository root:

```bash
uv run python .bob/skills/ppt-template-slide-workflow/scripts/direct_xml_replace_sample.py
```

### Why Direct XML Replacement for Text?

**Problem with python-pptx approach**: Template text is often fragmented across multiple XML text nodes within a single paragraph. The visible text "Step 1: Data Collection - We need to..." might be stored as separate nodes: `"Step 1: Data Collection"` + `" - We need to..."`. Simple string replacement on shape.text or paragraph.text will fail to match.

**Solution**: Direct XML replacement joins all text nodes within each paragraph before matching, ensuring reliable text replacement regardless of how PowerPoint has fragmented the text internally.

## Scope

Use this skill to create a new PowerPoint deck from an existing template deck by:

- Treating the source `.pptx` as an immutable visual template.
- Analyzing user requirements and selecting appropriate slides from the template using `.bob/skills/ppt-template-slide-workflow/template_map.json` or `.bob/skills/ppt-template-slide-workflow/TEMPLATE_MAP.md`.
- Creating a new output `.pptx` with the selected slides.
- **CRITICAL**: Replacing text using direct Open XML replacement (editing `ppt/slides/slideN.xml` directly).
- Preserving theme, typography, slide masters, layouts, imagery, and geometry.
- Creating a per-run folder under the repo's `slides/` directory.


## Critical Implementation Requirements

### Slide Deletion: Use python-pptx API Only

**CRITICAL**: Slide deletion MUST use python-pptx's built-in API. Manual XML manipulation will fail silently.

**Required Pattern**:
```python
from pptx import Presentation

def delete_slide(prs: Presentation, slide_index: int) -> None:
    """Delete slide by zero-based index using python-pptx package API."""
    slide_id_list = prs.slides._sldIdLst
    slide_id = slide_id_list[slide_index]
    rel_id = slide_id.rId
    prs.part.drop_rel(rel_id)
    slide_id_list.remove(slide_id)

def keep_only_slides(prs: Presentation, selected_slide_numbers: list[int]) -> None:
    """Keep only 1-based slide numbers from source deck."""
    selected_indexes = {slide_number - 1 for slide_number in selected_slide_numbers}
    for index in reversed(range(len(prs.slides))):
        if index not in selected_indexes:
            delete_slide(prs, index)

# Usage
prs = Presentation(template_path)
keep_only_slides(prs, [12, 33, 72])  # Keep only these slides
prs.save(output_path)
```

**Why This Matters**:
- Manual XML editing doesn't update all internal relationships
- Slides appear deleted but remain in the presentation
- Results in presentations with all 117 slides instead of selected slides
- Bug is not caught by basic ZIP integrity checks

**Reference Implementation**: See `scripts/direct_xml_replace_sample.py` for a working example.

### Text Replacement: Use Direct Open XML

**Required for text replacement** (not slide deletion):
- Use direct Open XML replacement for text content
- Follow the pattern in `scripts/direct_xml_replace_sample.py`
- Join text nodes at paragraph level before matching

**Why**: Template text is often fragmented across multiple XML text nodes. Direct XML replacement handles this correctly.

### Validation: Load Actual Presentation

**Required validation steps**:
1. Verify file exists
2. Check ZIP integrity
3. **Load presentation and count slides** (catches slide deletion bugs)
4. Extract text to verify replacements
5. Generate thumbnails for visual check

**Minimum validation**:
```python
from pptx import Presentation

# After generation
prs = Presentation(output_path)
actual_count = len(prs.slides)
expected_count = len(selected_slides)

if actual_count != expected_count:
    raise ValueError(f"Slide count mismatch: expected {expected_count}, got {actual_count}")
```

**Important Slide Ordering**: When slides are selected (e.g., [3, 24, 9]), they maintain their original template order in the output. The visible order will be: slide 3, slide 9, slide 24 (sorted by template position, not selection order). When creating replacement maps, map to the actual visible slide order (1, 2, 3) not the template slide numbers.

Non-goals:

- Do not redesign the template unless the user explicitly asks.
- Do not modify the original source template in place.
- Do not execute embedded macros or external content from an untrusted deck.

## Inputs to collect

Required:

- Source template `.pptx` path (defaults to the included IBM Consulting Offerings template at `.bob/skills/ppt-template-slide-workflow/template/Example_layouts_IBM_Consulting_Offerings_template_v_1_0_011025.pptx`).
- Desired output `.pptx` path or deck/topic name.
- Slide-selection criteria, such as slide numbers, example slide range, or a content/layout goal.
- Replacement content or topic to generate content for.

Optional defaults:

- If source template is omitted, use the included IBM Consulting Offerings template.
- If output path is omitted, use `slides/<deck-or-topic-slug>/generated_<topic>_deck.pptx` (saved inside the workspace folder).
- If exact slides are omitted, inspect slide text and layouts, then choose the closest matching template slides.
- If content mapping is needed, store it in a JSON file inside the workspace folder, such as `slides/<deck-or-topic-slug>/content_map.json`.
- If no slide workspace is specified, create `slides/<deck-or-topic-slug>/` and then create one child folder per generated slide, such as `slides/<deck-or-topic-slug>/slide-01-ibm-business/`.

## Template Map for Slide Selection

The IBM Consulting Offerings template includes a comprehensive content map to help you select the right slides:

### Available Resources

1. **Visual Content Maps** (10 JPG thumbnail grids)
   - Location: `.bob/skills/ppt-template-slide-workflow/template/template-content-map/`
   - Files: `ibm-consulting-template-content-map-1.jpg` through `ibm-consulting-template-content-map-10.jpg`
   - Each grid shows ~12 slides with slide numbers for visual reference

2. **template_map.json** (Structured metadata)
   - Location: `.bob/skills/ppt-template-slide-workflow/template_map.json`
   - Contains for each slide:
     - `slide_number`: Slide number (1-117)
     - `layout_name`: Layout type (e.g., "Brand, section divider")
     - `category`: Auto-categorized (Section Header, Picture/Image, Title + Content, Blank, Other)
     - `use_cases`: Suggested use cases (e.g., "Topic transition", "Visual showcase")
     - `text_content`: All text extracted from the slide
     - `title`: Slide title if present
     - `shapes`: Detailed shape information
     - `placeholders`: Placeholder types and content

3. **TEMPLATE_MAP.md** (Human-readable documentation)
   - Location: `.bob/skills/ppt-template-slide-workflow/TEMPLATE_MAP.md`
   - Quick reference by category with slide numbers
   - Detailed information for each slide with text previews

### Using the Template Map in Planning Phase

When a user requests a presentation, follow this workflow:

1. **Understand Requirements**
   - Analyze the user's request for presentation purpose, content, and audience
   - Identify key topics and sections needed

2. **Query Template Map**
   - Load `template_map.json` to search for appropriate slides
   - Filter by:
     - **Category**: "Section Header" for dividers, "Picture/Image" for visual slides
     - **Use cases**: "Visual showcase" for image-focused slides, "Key points" for content slides
     - **Layout name**: "imagery" for visual slides, "content" for text-heavy slides
     - **Text content**: Search for keywords relevant to the topic

3. **Visual Verification**
   - Reference the JPG content maps to visually verify slide layouts
   - Tell the user which content map image to check (e.g., "Check ibm-consulting-template-content-map-3.jpg for slides 25-36")
   - Ensure selected slides have compatible visual styles

4. **Compile Slide Selection**
   - Create a list of slide numbers that match the requirements
   - Organize slides in logical presentation order
   - Document the rationale for each slide selection

5. **Present Plan to User**
   - Show selected slide numbers with descriptions
   - Reference content map images for visual confirmation
   - Explain why each slide was chosen (category, use case, layout)
   - Wait for user approval before proceeding to generation

### Example Planning Workflow

```
User: "Create a 5-slide presentation about IBM AI strategy"

Bob's Planning Process:
1. Query template_map.json for:
   - Section Header slides (for opening)
   - Title + Content slides (for strategy points)
   - Picture/Image slides (for visual impact)

2. Find matching slides:
   - Slide 2: Section Header - "L1 (Halo)" for opening
   - Slide 28: Title + Content for strategy overview
   - Slide 15: Picture/Image for AI visualization
   - Slide 37: Title + Content for implementation
   - Slide 23: Section Header for closing

3. Visual verification:
   - "Check ibm-consulting-template-content-map-1.jpg for slides 2 and 15"
   - "Check ibm-consulting-template-content-map-3.jpg for slides 23, 28, and 37"

4. Present plan:
   - Slide 2: Opening title (Section Header, dramatic impact)
   - Slide 15: AI visual showcase (Picture/Image, engaging)
   - Slide 28: Strategy overview (Title + Content, key points)
   - Slide 37: Implementation details (Title + Content, structured)
   - Slide 23: Closing section (Section Header, transition)

5. Wait for approval before generating
```

### Template Map Query Examples

**Find section header slides:**
```python
import json
from pathlib import Path

# Load from skill directory
skill_dir = Path(".bob/skills/ppt-template-slide-workflow")
with open(skill_dir / "template_map.json") as f:
    data = json.load(f)
section_headers = [s["slide_number"] for s in data["slides"] if s["category"] == "Section Header"]
# Result: [1, 2, 23, 53, 69, 77, 105]
```

**Find visual showcase slides:**
```python
visual_slides = data["search_index"]["by_use_case"].get("Visual showcase", [])
# Result: [3, 4, 5, 12, 13, 15, 16, 17, 18, 20, 21, 22, 31, 47, 48, 49, 50, 70, 71, 72, 73, 74, 75]
```

**Find slides with specific keywords:**
```python
keyword = "cloud"
keyword_slides = data["search_index"]["by_keyword"].get(keyword, [])
# Result: [27, 35, 37, 38, 41, 44, 64, 86, 87]
```



## Common Pitfalls and Solutions

### Pitfall 1: Manual XML Slide Deletion
**Problem**: Using manual XML manipulation to delete slides
**Result**: Slides remain in presentation (117 instead of 3)
**Solution**: Use python-pptx's `delete_slide()` API (see Critical Implementation Requirements above)

### Pitfall 2: Insufficient Validation
**Problem**: Only checking ZIP integrity, not actual slide count
**Result**: Bugs not caught until user opens file
**Solution**: Load presentation object and verify slide count

### Pitfall 3: Text Replacement Mismatches
**Problem**: Template text doesn't match replacement key exactly
**Result**: Text not replaced, template content remains
**Solution**: Extract exact template text first, use repr() to see whitespace

### Pitfall 4: Wrong Slide Number Mapping
**Problem**: Mapping replacements to template slide numbers instead of visible order
**Result**: Wrong slides get wrong content
**Solution**: Map to visible slide order (1, 2, 3) after filtering

### Pitfall 5: Unicode Encoding on Windows
**Problem**: Script crashes on Windows with Unicode symbols
**Result**: Generation fails
**Solution**: Set `$env:PYTHONIOENCODING='utf-8'` or use ASCII-safe output

### Pitfall 6: Duplicate Slide Numbers
**Problem**: Using duplicate slide numbers in selection (e.g., [3, 24, 24, 37, 9])
**Result**: Only 4 slides generated instead of 5 (sets eliminate duplicates)
**Solution**: Use different slide numbers; find alternative slides with similar layouts

### Pitfall 7: Paragraph-Level Text Splitting
**Problem**: Template text split across multiple `<a:p>` elements
**Result**: Text replacement fails because combined strings don't match
**Solution**: Replace text at paragraph level, not as combined multi-line strings

### Pitfall 8: Unicode Smart Quotes
**Problem**: Template uses Unicode typographic characters (', —, –)
**Result**: Text replacement fails or shows garbled characters
**Solution**: Extract exact text from XML using `repr()`, use exact Unicode characters in replacement map

### Pitfall 9: Empty Numbered Sections
**Problem**: Only clearing content but not number paragraphs (e.g., "4.", "5.", "6.")
**Result**: Empty numbered sections visible on slides
**Solution**: Explicitly clear ALL related elements (numbers + headings + descriptions)

### Pitfall 10: File Locking During Regeneration
**Problem**: PowerPoint file open in application during script execution
**Result**: Permission denied error when trying to save
**Solution**: Close file before running script; add file locking detection to scripts

## Troubleshooting Guide

### Slide Ordering Issues
**Symptoms**: Slides appear in wrong order or text replacements target wrong slides

**Diagnosis**: Selected slides maintain template order, not selection order. Selecting [3, 24, 9] results in visible order: slide3, slide9, slide24.

**Solution**: Map replacement dictionaries to visible slide order (1, 2, 3), not template slide numbers. Extract paragraph text from generated deck to verify actual slide order.

### Text Replacement Failures
**Symptoms**: Template text remains unchanged or appears garbled

**Diagnosis**:
1. Extract template text to verify exact strings (including whitespace)
2. Check for paragraph-level splitting across multiple `<a:p>` elements
3. Look for Unicode smart quotes and special characters

**Solution**:
```bash
# Extract paragraph-level text
uv run python -c "import zipfile; from lxml import etree; \
  NS={'a':'http://schemas.openxmlformats.org/drawingml/2006/main'}; \
  z=zipfile.ZipFile('template.pptx'); \
  root=etree.fromstring(z.read('ppt/slides/slide9.xml')); \
  paragraphs=root.xpath('.//a:p', namespaces=NS); \
  for p in paragraphs: \
    text=''.join(n.text or '' for n in p.xpath('.//a:t', namespaces=NS)); \
    print(f'Paragraph: {text}')"
```

Replace text at paragraph level, use exact Unicode characters from template.

### Wrong Slide Count
**Symptoms**: Generated presentation has all 117 slides instead of selected slides

**Diagnosis**: Manual XML manipulation used for slide deletion instead of python-pptx API

**Solution**: Use `delete_slide()` and `keep_only_slides()` functions with python-pptx. Always validate by loading the presentation object:
```python
prs = Presentation(output_path)
assert len(prs.slides) == len(selected_slides)
```

### Empty Sections Visible
**Symptoms**: Slide shows empty numbered sections with no content

**Diagnosis**: Numbers not explicitly cleared when removing content

**Solution**: Clear ALL related paragraph elements (numbers, headings, descriptions):
```python
SLIDE_REPLACEMENTS = {
    1: {
        "4.": "",  # Clear number
        "Heading 4": "",  # Clear heading
        "Description 4": "",  # Clear description
    }
}
```

## Procedure

1. Inspect the template package.
   - Count slides from `ppt/slides/slide*.xml`.
   - Extract visible text from candidate slides via `<a:t>` nodes.
   - Inspect slide relationships in `ppt/slides/_rels/slideN.xml.rels` to identify layouts, images, charts, and media.
   - Inspect `ppt/presentation.xml` and `ppt/_rels/presentation.xml.rels` to understand presentation order.

2. Select relevant slides.
   - Prefer source slides whose layout and visual rhythm match the requested deck/topic.
   - If the user gives slide numbers, preserve that order unless instructed otherwise.
   - If the user gives a range as examples, identify whether they want the full range copied or a new slide modeled after those examples.

3. Create the slide workspace folders.
   - Ensure the repo has a top-level `slides/` directory.
   - Create a new run folder inside it using a safe slug derived from the deck/topic, for example `slides/ibm-business/`.
   - For every specific slide being created or edited, create a dedicated subdirectory inside that run folder, for example `slides/ibm-business/slide-01-title/` or `slides/ibm-business/slide-03-next-steps/`.
   - Store slide-specific working files in that slide directory when useful: extracted source XML snippets, generated replacement text, notes, slide preview images, or validation metadata.
   - **Save the final generated `.pptx` inside the `slides/<deck-or-topic-slug>/` folder** (e.g., `slides/ibm-business/generated_deck.pptx`).
   - **Save any generation scripts** (e.g., Python scripts used to create the deck) inside the same `slides/<deck-or-topic-slug>/` folder for reproducibility.

4. Create the output deck safely.
   - Preferred robust approach: copy the source `.pptx` to the output path, then edit the presentation slide list so only selected slides are visible.
   - Preserve all required relationships, slide layouts, masters, theme files, images, and media.
   - Prune unused slide parts/media only after validation, and only if file size matters.

5. Edit content by directly modifying slide XML in the `.pptx` ZIP package.
   - Do not rely on reusable helper scripts or `python-pptx` text-frame rebuilding for generation. Write the direct XML replacement logic inside the deck generation script so the exact source slide parts, replacements, and validation are visible for that deck.
   - Operate on `ppt/slides/slideN.xml` with `zipfile` plus `lxml`/`ElementTree`, replacing `<a:t>` text nodes or full `<a:p>` paragraphs while preserving existing drawing geometry and run styling.
   - Scope replacement maps by **visible slide number after filtering**, not by physical package part. After deleting slides, visible slide 1 may still be stored as `ppt/slides/slide3.xml`.
   - Build replacements from extracted template XML text, not assumed text.
   - Track replacement counts in the generation script and fail generation if a required key is unmatched.
   - For complex slides, explicitly clear or replace every leftover paragraph that is not approved content, slide numbers, confidentiality footers, or intentional template labels.
   - For multi-line title slides, preserve line breaks and accent-color runs where the template uses them.

6. Preserve visual fidelity.
   - Keep the source slide dimensions unchanged.
   - Reuse template fonts, colors, spacing, masters, and layouts.
   - Avoid adding new styling that conflicts with the template system.
   - For IBM/Carbon decks, prefer IBM Plex Sans, white/gray surfaces, black text, and IBM Blue accents.

7. Validate the generated deck.
   - Run a ZIP integrity check with `zipfile.testzip()`.
   - Confirm no duplicate ZIP entries.
   - Confirm visible slide count and order.
   - Confirm every replacement key matched at least once or was explicitly marked optional.
   - Confirm replacement text appears in the expected visible slide XML.
   - Extract visible paragraphs from the final deck and check for leftover source-template prose.
   - Confirm the `slides/<deck-or-topic-slug>/<slide-slug>/` directories exist for each generated or edited slide.
   - If possible, open the deck in PowerPoint or export/render previews for visual validation.

## Implementation guidance

Use low-level Open XML package editing when slide selection/copying matters. PowerPoint files are ZIP packages, and slides depend on relationships to layouts, masters, media, charts, notes, and themes. `python-pptx` is useful for straightforward text editing, but it is limited for arbitrary slide copying/deletion.

Safe implementation pattern:

```text
source template.pptx
  -> create slides/<deck-or-topic-slug>/<slide-slug>/ folders
  -> copy to output.pptx
  -> update ppt/presentation.xml slide ID list
  -> update ppt/_rels/presentation.xml.rels slide relationships if needed
  -> update section lists if present
  -> extract visible paragraphs from selected slide XML
  -> directly replace or clear text in ppt/slides/slideN.xml parts
  -> assert required replacement counts in the generation script
  -> validate package integrity, slide order, replacement coverage, and leftover text
```

Preferred direct XML pattern inside a generation script:

```python
import shutil
import zipfile
from lxml import etree

NS = {"a": "http://schemas.openxmlformats.org/drawingml/2006/main"}

def replace_in_slide_xml(root, replacements):
    counts = {old: 0 for old in replacements}
    for paragraph in root.xpath(".//a:p", namespaces=NS):
        nodes = paragraph.xpath(".//a:t", namespaces=NS)
        if not nodes:
            continue
        original = "".join(node.text or "" for node in nodes)
        updated = original
        for old, new in replacements.items():
            if old in updated:
                updated = updated.replace(old, new)
                counts[old] += 1
        if updated != original:
            nodes[0].text = updated
            for node in nodes[1:]:
                node.text = ""
    return counts

shutil.copyfile(template_path, output_path)
tmp_path = output_path.with_suffix(".tmp.pptx")
modified_parts = {}
with zipfile.ZipFile(output_path) as zin:
    for slide_part, replacements in replacements_by_slide_part.items():
        root = etree.fromstring(zin.read(slide_part))
        counts = replace_in_slide_xml(root, replacements)
        missing = [old for old, count in counts.items() if count == 0]
        if missing:
            raise ValueError(f"Unmatched replacements in {slide_part}: {missing}")
        modified_parts[slide_part] = etree.tostring(root, encoding="UTF-8", xml_declaration=True)
    with zipfile.ZipFile(tmp_path, "w") as zout:
        for item in zin.infolist():
            data = modified_parts.get(item.filename, zin.read(item.filename))
            zout.writestr(item, data)
tmp_path.replace(output_path)
```

For a complete runnable version of this pattern, refer to `scripts/direct_xml_replace_sample.py` in this skill folder.

When inserting newly copied slides:

- Allocate a new `ppt/slides/slideN.xml` part number.
- Copy its `ppt/slides/_rels/slideN.xml.rels` file.
- Add a slide override in `[Content_Types].xml`.
- Add a slide relationship in `ppt/_rels/presentation.xml.rels`.
- Add a `<p:sldId>` entry to `ppt/presentation.xml`.
- Update PowerPoint section metadata when `p14:sectionLst` is present.

## Speaker Notes

PowerPoint presentations support speaker notes that appear below slides in Presenter View. Speaker notes are essential for:
- Providing talking points and context for presenters
- Including additional details not shown on slides
- Documenting presentation flow and timing
- Sharing supplementary information with the audience

This skill supports adding, editing, and preserving speaker notes through both `python-pptx` (recommended for most cases) and direct XML manipulation (for advanced workflows).

### When to Add Speaker Notes

**During Generation** (Recommended):
- Add notes immediately after slide content replacement
- Use `python-pptx` to add notes before final save
- Ensures notes are part of the validated output

**After Generation**:
- Add notes to existing presentations
- Update notes based on feedback
- Requires reopening and re-saving the presentation

**Best Practice**: Include speaker notes as part of the generation script so they're created alongside slide content and validated together.

### Notes Structure

Speaker notes are stored in the PPTX package as:
- **Notes files**: `ppt/notesSlides/notesSlideN.xml` (one per slide with notes)
- **Relationships**: Each slide with notes has a relationship in `ppt/slides/_rels/slideN.xml.rels`
- **Relationship type**: `http://schemas.openxmlformats.org/officeDocument/2006/relationships/notesSlide`
- **Content**: Plain text or rich text formatted with DrawingML markup

### Notes XML Structure

A notes slide contains:
```xml
<p:notes xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
         xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
  <p:cSld>
    <p:spTree>
      <!-- Slide thumbnail placeholder -->
      <p:sp>
        <p:nvSpPr>
          <p:nvPr><p:ph type="sldImg"/></p:nvPr>
        </p:nvSpPr>
      </p:sp>
      
      <!-- Notes text body -->
      <p:sp>
        <p:nvSpPr>
          <p:nvPr><p:ph type="body"/></p:nvPr>
        </p:nvSpPr>
        <p:txBody>
          <a:bodyPr/>
          <a:lstStyle/>
          <a:p>
            <a:r><a:t>First paragraph of notes</a:t></a:r>
          </a:p>
          <a:p>
            <a:r><a:t>Second paragraph of notes</a:t></a:r>
          </a:p>
        </p:txBody>
      </p:sp>
    </p:spTree>
  </p:cSld>
</p:notes>
```

### Adding Speaker Notes with python-pptx

The simplest way to add speaker notes is using `python-pptx`:

```python
from pptx import Presentation

prs = Presentation("template.pptx")
slide = prs.slides[0]

# Add or update speaker notes
notes_slide = slide.notes_slide
notes_slide.notes_text_frame.text = "Key talking points:\n- Point 1\n- Point 2"

prs.save("output.pptx")
```

### Adding Speaker Notes with Direct XML

For more control or when working with the direct XML workflow:

```python
import zipfile
from lxml import etree

P_NS = "http://schemas.openxmlformats.org/presentationml/2006/main"
A_NS = "http://schemas.openxmlformats.org/drawingml/2006/main"
R_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"

NS = {"p": P_NS, "a": A_NS, "r": R_NS, "rel": REL_NS}

def add_speaker_notes_xml(pptx_path, slide_number, notes_text):
    """Add speaker notes to a slide using direct XML manipulation."""
    
    # Notes template
    notes_xml = f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:notes xmlns:a="{A_NS}" xmlns:p="{P_NS}" xmlns:r="{R_NS}">
  <p:cSld>
    <p:spTree>
      <p:nvGrpSpPr>
        <p:cNvPr id="1" name=""/>
        <p:cNvGrpSpPr/>
        <p:nvPr/>
      </p:nvGrpSpPr>
      <p:grpSpPr>
        <a:xfrm>
          <a:off x="0" y="0"/>
          <a:ext cx="0" cy="0"/>
          <a:chOff x="0" y="0"/>
          <a:chExt cx="0" cy="0"/>
        </a:xfrm>
      </p:grpSpPr>
      <p:sp>
        <p:nvSpPr>
          <p:cNvPr id="2" name="Slide Image Placeholder 1"/>
          <p:cNvSpPr><a:spLocks noGrp="1"/></p:cNvSpPr>
          <p:nvPr><p:ph type="sldImg" idx="2"/></p:nvPr>
        </p:nvSpPr>
        <p:spPr/>
      </p:sp>
      <p:sp>
        <p:nvSpPr>
          <p:cNvPr id="3" name="Notes Placeholder 2"/>
          <p:cNvSpPr><a:spLocks noGrp="1"/></p:cNvSpPr>
          <p:nvPr><p:ph type="body" idx="3" sz="quarter"/></p:nvPr>
        </p:nvSpPr>
        <p:spPr/>
        <p:txBody>
          <a:bodyPr/>
          <a:lstStyle/>
        </p:txBody>
      </p:sp>
    </p:spTree>
  </p:cSld>
  <p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>
</p:notes>'''
    
    # Parse and add text paragraphs
    root = etree.fromstring(notes_xml.encode('utf-8'))
    tx_body = root.xpath('.//p:txBody', namespaces=NS)[0]
    
    # Add paragraphs for each line
    for line in notes_text.split('\n'):
        para = etree.SubElement(tx_body, f'{{{P_NS}}}p')
        run = etree.SubElement(para, f'{{{A_NS}}}r')
        text_node = etree.SubElement(run, f'{{{A_NS}}}t')
        text_node.text = line
    
    # Write to package
    notes_part = f'ppt/notesSlides/notesSlide{slide_number}.xml'
    notes_rels_part = f'ppt/notesSlides/_rels/notesSlide{slide_number}.xml.rels'
    slide_rels_part = f'ppt/slides/_rels/slide{slide_number}.xml.rels'
    
    modified_parts = {
        notes_part: etree.tostring(root, encoding='UTF-8', xml_declaration=True)
    }
    
    # Add relationship from slide to notes
    with zipfile.ZipFile(pptx_path, 'r') as zin:
        if slide_rels_part in zin.namelist():
            rels_root = etree.fromstring(zin.read(slide_rels_part))
            
            # Check if notes relationship already exists
            existing = rels_root.xpath(
                f'.//rel:Relationship[@Type="{R_NS}/notesSlide"]',
                namespaces=NS
            )
            
            if not existing:
                # Find next relationship ID
                existing_ids = [
                    int(rel.get('Id')[3:]) 
                    for rel in rels_root.xpath('.//rel:Relationship', namespaces=NS)
                ]
                next_id = max(existing_ids) + 1 if existing_ids else 1
                
                # Add notes relationship
                rel = etree.SubElement(rels_root, f'{{{REL_NS}}}Relationship')
                rel.set('Id', f'rId{next_id}')
                rel.set('Type', f'{R_NS}/notesSlide')
                rel.set('Target', f'../notesSlides/notesSlide{slide_number}.xml')
                
                modified_parts[slide_rels_part] = etree.tostring(
                    rels_root, encoding='UTF-8', xml_declaration=True
                )
    
    # Rewrite package with notes
    tmp_path = pptx_path.with_suffix('.tmp.pptx')
    with zipfile.ZipFile(pptx_path, 'r') as zin:
        with zipfile.ZipFile(tmp_path, 'w') as zout:
            for item in zin.infolist():
                data = modified_parts.get(item.filename, zin.read(item.filename))
                zout.writestr(item, data)
            
            # Add new notes file if not already present
            if notes_part not in zin.namelist():
                zout.writestr(notes_part, modified_parts[notes_part])
    
    tmp_path.replace(pptx_path)
```

### Editing Existing Speaker Notes

To modify existing notes using direct XML:

```python
def update_speaker_notes_xml(pptx_path, slide_number, notes_text):
    """Update existing speaker notes in a slide."""
    
    notes_part = f'ppt/notesSlides/notesSlide{slide_number}.xml'
    
    with zipfile.ZipFile(pptx_path, 'r') as deck:
        if notes_part not in deck.namelist():
            # No existing notes, add new ones
            add_speaker_notes_xml(pptx_path, slide_number, notes_text)
            return
        
        root = etree.fromstring(deck.read(notes_part))
        
        # Find the notes text body
        tx_body = root.xpath(
            './/p:sp[.//p:ph[@type="body"]]/p:txBody',
            namespaces=NS
        )[0]
        
        # Clear existing paragraphs
        for para in tx_body.xpath('.//a:p', namespaces=NS):
            tx_body.remove(para)
        
        # Add new paragraphs
        for line in notes_text.split('\n'):
            para = etree.SubElement(tx_body, f'{{{A_NS}}}p')
            run = etree.SubElement(para, f'{{{A_NS}}}r')
            text_node = etree.SubElement(run, f'{{{A_NS}}}t')
            text_node.text = line
        
        modified_parts = {
            notes_part: etree.tostring(root, encoding='UTF-8', xml_declaration=True)
        }
    
    # Rewrite package
    tmp_path = pptx_path.with_suffix('.tmp.pptx')
    with zipfile.ZipFile(pptx_path, 'r') as zin:
        with zipfile.ZipFile(tmp_path, 'w') as zout:
            for item in zin.infolist():
                data = modified_parts.get(item.filename, zin.read(item.filename))
                zout.writestr(item, data)
    tmp_path.replace(pptx_path)
```

### Reading Speaker Notes

Extract speaker notes from a presentation:

```python
def read_speaker_notes(pptx_path, slide_number):
    """Read speaker notes from a slide."""
    
    notes_part = f'ppt/notesSlides/notesSlide{slide_number}.xml'
    
    with zipfile.ZipFile(pptx_path, 'r') as deck:
        if notes_part not in deck.namelist():
            return None
        
        root = etree.fromstring(deck.read(notes_part))
        
        # Find notes text
        paragraphs = root.xpath(
            './/p:sp[.//p:ph[@type="body"]]//a:p',
            namespaces=NS
        )
        
        notes_lines = []
        for para in paragraphs:
            text = ''.join(
                node.text or '' 
                for node in para.xpath('.//a:t', namespaces=NS)
            )
            if text.strip():
                notes_lines.append(text)
        
        return '\n'.join(notes_lines) if notes_lines else None
```

### Best Practices for Speaker Notes

1. **Use python-pptx for simple cases**: When only adding/updating notes text, `python-pptx` is simpler and more reliable
2. **Use direct XML for complex workflows**: When coordinating notes with slide content replacements in a generation script
3. **Preserve formatting**: Notes support rich text formatting; preserve it when editing existing notes
4. **Validate relationships**: Ensure slide-to-notes relationships are properly created
5. **Test in PowerPoint**: Always verify notes appear correctly in Presenter View

### Speaker Notes in Generation Scripts

When generating decks with speaker notes:

```python
# After slide content replacement
from pptx import Presentation

prs = Presentation(output_path)

# Add notes to each slide
speaker_notes = {
    1: "Welcome slide. Introduce yourself and the topic.",
    2: "Key points:\n- Point 1\n- Point 2\n- Point 3",
    3: "Conclusion. Thank the audience and open for questions."
}

for slide_num, notes_text in speaker_notes.items():
    slide = prs.slides[slide_num - 1]  # 0-based index
    slide.notes_slide.notes_text_frame.text = notes_text

prs.save(output_path)
```

## Japanese Language Support

This skill includes comprehensive support for generating PowerPoint presentations with Japanese text content while maintaining IBM Carbon Design System compliance.

### Overview

Japanese language support enables:
- **Native Japanese text**: Full support for Hiragana (ひらがな), Katakana (カタカナ), and Kanji (漢字)
- **IBM Plex Sans JP font**: Official IBM typeface for Japanese text
- **UTF-8 encoding**: Native Python 3.14+ Unicode support
- **Font embedding**: Automatic font assignment for Japanese text
- **Validation tools**: Utilities to verify encoding and font correctness

### IBM Plex Sans JP Font

**Font Information**:
- **Family**: IBM Plex Sans JP
- **Version**: 6.4.0 (January 2024)
- **License**: SIL Open Font License 1.1 (OFL-1.1)
- **Weights**: Thin, ExtraLight, Light, Regular, Text, Medium, SemiBold, Bold
- **Installation**: Font must be installed on viewing system, or PowerPoint will use fallback font (MS Gothic, Meiryo, etc.)

**Character Support**:
- Hiragana (ひらがな): Japanese phonetic script
- Katakana (カタカナ): Japanese phonetic script for foreign words
- Kanji (漢字): Chinese characters used in Japanese
- Latin alphabet (A-Z, a-z)
- Numbers (0-9)
- Common punctuation marks

**IBM Carbon Compliance**: IBM Plex Sans JP is the official Japanese typeface for IBM Carbon Design System, ensuring consistent brand identity across languages.

### Quick Start

Generate a Japanese presentation using the example script:

```bash
uv run python .bob/skills/ppt-template-slide-workflow/scripts/japanese_example.py
```

This creates a 3-slide presentation with Japanese content at `slides/japanese-example/IBM_Japanese_Presentation.pptx`.

### Usage in Generation Scripts

#### 1. Text Replacement with Japanese Content

Japanese text works seamlessly with the existing direct XML replacement approach:

```python
# Japanese content replacements
SLIDE_REPLACEMENTS = {
    1: {
        "L1 (Halo)": "IBMコンサルティング",
        "Project Title": "デジタルトランスフォーメーション戦略",
    },
    2: {
        "Title": "プロジェクト概要",
        "Body text": "目的: デジタル化の推進\n期間: 6ヶ月\n予算: 1億円",
    }
}

# Replace text using standard approach
replacement_counts = replace_text_in_presentation(output_path, SLIDE_REPLACEMENTS)
```

**Important**: Python 3.14+ natively supports UTF-8, so Japanese text works without special encoding handling.

#### 2. Set IBM Plex Sans JP Font

After text replacement, set the correct font for Japanese text:

```python
from font_utils import set_japanese_fonts

# Automatically set IBM Plex Sans JP for all Japanese text
results = set_japanese_fonts(output_path)
print(f"Updated {results['runs_updated']} text runs in {results['slides_with_updates']} slides")
```

This function:
- Scans all text runs in the presentation
- Detects Japanese characters (Hiragana, Katakana, Kanji)
- Sets the East Asian font to IBM Plex Sans JP
- Preserves all other formatting (size, weight, color)

#### 3. Validate Japanese Content

Verify encoding and font correctness:

```python
from japanese_utils import analyze_japanese_content, print_analysis_report

# Comprehensive analysis
analysis = analyze_japanese_content(output_path)
print_analysis_report(analysis)

# Check specific aspects
if not analysis['encoding_valid']:
    print("Warning: UTF-8 encoding issues detected")

if not analysis['fonts_valid']:
    print("Warning: IBM Plex Sans JP not correctly assigned")
```

### Complete Generation Workflow

Here's a complete example of generating a Japanese presentation:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Generate Japanese PowerPoint presentation."""

from pathlib import Path
from pptx import Presentation
from japanese_utils import analyze_japanese_content, print_analysis_report
from font_utils import set_japanese_fonts

# Paths
TEMPLATE_PATH = Path(".bob/skills/ppt-template-slide-workflow/template/Example_layouts_IBM_Consulting_Offerings_template_v_1_0_011025.pptx")
OUTPUT_PATH = Path("slides/my-japanese-deck/presentation.pptx")

# Selected slides
SELECTED_SLIDES = [2, 5, 6]

# Japanese content
SLIDE_REPLACEMENTS = {
    1: {"L1 (Halo)": "IBMコンサルティング"},
    2: {"Developing an AI Strategy": "AI戦略の開発"},
    3: {"The number 1 request...": "営業チームからの最も多い要望は..."},
}

# Speaker notes in Japanese
SPEAKER_NOTES = {
    1: "このプレゼンテーションでは、IBMのデジタルトランスフォーメーション戦略について説明します。",
    2: "AI戦略の主要な要素について説明してください。",
    3: "クライアント事例の重要性を強調します。",
}

# 1. Load template and filter slides
prs = Presentation(str(TEMPLATE_PATH))
keep_only_slides(prs, SELECTED_SLIDES)
prs.save(str(OUTPUT_PATH))

# 2. Replace text with Japanese content
replace_text_in_presentation(OUTPUT_PATH, SLIDE_REPLACEMENTS)

# 3. Set IBM Plex Sans JP font
font_results = set_japanese_fonts(OUTPUT_PATH)
print(f"✓ Updated {font_results['runs_updated']} text runs")

# 4. Add speaker notes
prs = Presentation(str(OUTPUT_PATH))
for slide_num, notes_text in SPEAKER_NOTES.items():
    prs.slides[slide_num - 1].notes_slide.notes_text_frame.text = notes_text
prs.save(str(OUTPUT_PATH))

# 5. Validate
analysis = analyze_japanese_content(OUTPUT_PATH)
print_analysis_report(analysis)

if analysis['encoding_valid'] and analysis['fonts_valid']:
    print("✓ Japanese presentation generated successfully")
else:
    print("✗ Validation failed")
```

### Font Assignment Details

#### How Font Assignment Works

PowerPoint uses different font properties for different scripts:
- **Latin font** (`<a:latin>`): For Latin alphabet (A-Z, a-z)
- **East Asian font** (`<a:ea>`): For CJK characters (Chinese, Japanese, Korean)
- **Complex Script font** (`<a:cs>`): For Arabic, Hebrew, Thai, etc.

For Japanese text, we set the East Asian font:

```xml
<a:rPr>
  <a:latin typeface="IBM Plex Sans"/>
  <a:ea typeface="IBM Plex Sans JP"/>  <!-- Japanese text uses this -->
  <a:cs typeface="IBM Plex Sans"/>
</a:rPr>
```

#### Manual Font Assignment

For advanced use cases, you can manually set fonts in slide XML:

```python
import zipfile
from lxml import etree

NS = {"a": "http://schemas.openxmlformats.org/drawingml/2006/main"}

with zipfile.ZipFile(pptx_path, 'r') as deck:
    root = etree.fromstring(deck.read('ppt/slides/slide1.xml'))
    
    # Find text runs with Japanese text
    for run in root.xpath('.//a:r', namespaces=NS):
        text_node = run.find('.//a:t', namespaces=NS)
        if text_node is not None and contains_japanese(text_node.text):
            # Get or create run properties
            rPr = run.find('.//a:rPr', namespaces=NS)
            if rPr is None:
                rPr = etree.Element(f"{{{NS['a']}}}rPr")
                run.insert(0, rPr)
            
            # Set East Asian font
            ea = etree.SubElement(rPr, f"{{{NS['a']}}}ea")
            ea.set('typeface', 'IBM Plex Sans JP')
```

### Validation and Troubleshooting

#### Validation Tools

The skill includes comprehensive validation utilities:

```bash
# Analyze Japanese content
uv run python .bob/skills/ppt-template-slide-workflow/scripts/japanese_utils.py presentation.pptx

# Check font assignments
uv run python .bob/skills/ppt-template-slide-workflow/scripts/font_utils.py presentation.pptx info

# Set fonts for Japanese text
uv run python .bob/skills/ppt-template-slide-workflow/scripts/font_utils.py presentation.pptx set

# Verify font assignments
uv run python .bob/skills/ppt-template-slide-workflow/scripts/font_utils.py presentation.pptx verify
```

#### Common Issues

**Issue**: Japanese text appears as boxes or question marks

**Cause**: IBM Plex Sans JP font not assigned to Japanese text

**Solution**:
```python
from font_utils import set_japanese_fonts
set_japanese_fonts(output_path)
```

**Issue**: Text replacement fails with Japanese content

**Cause**: Template text uses Unicode smart quotes or special characters

**Solution**: Extract exact template text first:
```bash
uv run python -c "import zipfile; from lxml import etree; \
  NS={'a':'http://schemas.openxmlformats.org/drawingml/2006/main'}; \
  z=zipfile.ZipFile('template.pptx'); \
  root=etree.fromstring(z.read('ppt/slides/slide5.xml')); \
  for p in root.xpath('.//a:p', namespaces=NS): \
    text=''.join(n.text or '' for n in p.xpath('.//a:t', namespaces=NS)); \
    print(repr(text))"
```

**Issue**: UTF-8 encoding errors on Windows

**Cause**: Windows console doesn't support UTF-8 by default

**Solution**:
```powershell
$env:PYTHONIOENCODING='utf-8'
uv run python generate_script.py
```

Or add to script:
```python
import sys
if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except AttributeError:
        pass
```

#### Character Type Detection

Check what types of Japanese characters are present:

```python
from japanese_utils import get_character_types

text = "こんにちは世界"
types = get_character_types(text)
# {'hiragana': True, 'katakana': False, 'kanji': True, 'latin': False, 'numbers': False}
```

#### Font Verification

Verify all Japanese text has correct font:

```python
from font_utils import verify_font_assignment

verification = verify_font_assignment(output_path)
print(f"Total Japanese runs: {verification['total_japanese_runs']}")
print(f"Correctly assigned: {verification['correctly_assigned']}")
print(f"Issues: {len(verification['issues'])}")

for issue in verification['issues']:
    print(f"  - {issue}")
```

### Best Practices

1. **Always set fonts after text replacement**: Japanese text needs IBM Plex Sans JP to display correctly
2. **Validate encoding and fonts**: Use validation tools to catch issues early
3. **Test on target platform**: Verify presentations display correctly on Windows, macOS, and web viewers
4. **Use UTF-8 consistently**: Python 3.14+ handles this automatically, but be aware on Windows
5. **Extract template text first**: Verify exact text before creating replacement maps
6. **Include speaker notes**: Add Japanese speaker notes for complete localization

### Reference Files

- **Example script**: `.bob/skills/ppt-template-slide-workflow/scripts/japanese_example.py`
- **Validation utilities**: `.bob/skills/ppt-template-slide-workflow/scripts/japanese_utils.py`
- **Font utilities**: `.bob/skills/ppt-template-slide-workflow/scripts/font_utils.py`

### Performance Considerations

- **Font assignment**: Setting IBM Plex Sans JP font name in XML adds negligible overhead (<1 second)
- **Font availability**: Fonts must be installed on viewing system; PowerPoint will use fallback font (MS Gothic, Meiryo, etc.) if not available
- **Generation time**: Japanese text replacement adds negligible overhead (<1 second)
- **Validation time**: Full analysis takes 2-5 seconds for typical presentations

### Future Enhancements

Potential improvements for Japanese language support:

1. **Font embedding**: Embed IBM Plex Sans JP fonts directly in PPTX files for universal compatibility (no system font installation required)
2. **Automatic language detection**: Auto-detect Japanese text and set fonts without explicit call
3. **Mixed language support**: Handle presentations with both English and Japanese content
4. **Right-to-left support**: Extend to Arabic and Hebrew with IBM Plex Sans Arabic/Hebrew
5. **Font subsetting**: Embed only used glyphs to reduce file size

## Output contract

When complete, provide:

- The generated `.pptx` path (inside `slides/<deck-or-topic-slug>/`).
- Any generation scripts created (inside `slides/<deck-or-topic-slug>/`).
- The created `slides/<deck-or-topic-slug>/` workspace path.
- The per-slide directories created inside that workspace.
- Which source template was used.
- Which source slides were selected or modeled.
- A short summary of content edits.
- Replacement coverage results: matched/unmatched replacement keys and any intentionally optional keys.
- Leftover-template check results: whether source template prose remains and what was cleared or intentionally retained.
- Validation results: integrity, duplicate-entry check, slide count, and slide order.
- **Speaker notes**: Whether speaker notes were added and to which slides.

## Examples

- User asks: "Create a PPT about IBM using slides 5-10 from the IBM template."
- Agent does: Uses the IBM Consulting Offerings template at `.bob/skills/ppt-template-slide-workflow/template/Example_layouts_IBM_Consulting_Offerings_template_v_1_0_011025.pptx`, inspects slides 5-10, chooses the closest layout, duplicates or selects the relevant slide, replaces title/body content with IBM messaging, saves a new output deck, and validates package integrity.

- User asks: "Make a client pitch deck from only the relevant template slides and edit the text from a JSON map."
- Agent does: Reads the IBM Consulting Offerings template and JSON map, keeps only mapped slides visible in the output deck, replaces matching text blocks, preserves the template assets (IBM Plex Sans fonts, IBM Blue colors, Carbon design elements), and validates the final deck.

- User asks: "Can we automate: create a PPT, get relevant slides only from template, edit content?"
- Agent does: Confirms the workflow using the included 117-slide IBM template, proposes a content-map structure, and implements or refines the generator so template slide selection and content replacement are repeatable.

- User asks: "Show me what layouts are available in the IBM template."
- Agent does: Inspects the IBM Consulting Offerings template, extracts slide titles and layout types from all 117 slides, and presents a categorized list of available layouts (title slides, content slides, comparison slides, timeline slides, etc.).


## Robust Text Replacement Requirements

Template text replacement is a deck-level reliability requirement, not a per-deck improvisation. Use direct Open XML editing in each generation script so replacements are explicit, auditable, and tailored to the chosen slides. `python-pptx` shape/run replacement is acceptable only for slide deletion/selection or a small manual correction after the direct XML replacement and leftover-template checks pass.

### 1. Always Verify Template Text First

Before creating replacement mappings, extract the actual visible template text from the slide XML:

```python
with zipfile.ZipFile(template_path) as deck:
    root = etree.fromstring(deck.read("ppt/slides/slide15.xml"))
    for paragraph in root.xpath(".//a:p", namespaces=NS):
        text = "".join(node.text or "" for node in paragraph.xpath(".//a:t", namespaces=NS))
        if text.strip():
            print(text)
```

This shows paragraph-level text in presentation order. It avoids the common failure where the plan uses straight apostrophes but the template contains curly apostrophes, or where one visible sentence is split across multiple XML text nodes.

### 2. Use Direct XML Paragraph Replacement

Put the replacement loop directly in the generation script:

```python
counts = replace_in_slide_xml(root, replacements)
if any(count == 0 for count in counts.values()):
    raise ValueError(counts)
```

**Why this matters**: This approach preserves:
- Font family, size, weight, and color
- Paragraph alignment and spacing
- Character-level formatting (bold, italic, underline)
- Theme colors and styles
- Replacement reliability across split XML runs, smart punctuation, non-breaking spaces, grouped shapes, and tables

### 3. Enforce Replacement Coverage

Replacement counting is part of the acceptance criteria. If a replacement key does not match, stop and fix the map instead of delivering a deck with old template text.

```python
missing = [old for old, count in counts.items() if count == 0]
if missing:
    raise ValueError(f"Unmatched replacements: {missing}")
```

Only mark keys optional when the source slide legitimately may not contain that text variant.

### 4. Clear Unexpected Template Prose

Many beautiful template slides include extra charts, tables, captions, and labels. If the output deck should not retain those paragraphs, explicitly clear them by setting the first `<a:t>` node to an empty string and clearing the remaining `<a:t>` nodes in the same paragraph:

```python
nodes[0].text = ""
for node in nodes[1:]:
    node.text = ""
```

Keep only intentional artifacts such as slide numbers, confidentiality footers, section labels, or content that the user explicitly wants retained.

### 5. Validate Before Delivery

For every generated template deck:

```python
with zipfile.ZipFile(output_path) as deck:
    assert deck.testzip() is None
    assert len(deck.namelist()) == len(set(deck.namelist()))
```

Then check slide count, order, replacement coverage, and leftover source-template text. A deck is not complete while old template prose remains unintentionally.

### 6. Visual Template Inspection

Generate thumbnails to understand slide layouts before selection:

```bash
uv run python .bob/skills/pptx/scripts/thumbnail.py template.pptx
```

This helps you:
- Identify which slides have appropriate layouts for your content
- Avoid slides with complex embedded elements (charts, images)
- Select slides with flexible text containers

### 7. Incremental Development

- **Start small**: Begin with 2-3 slides to test your replacement strategy
- **Verify early**: Check content accuracy before scaling to full presentation
- **Version control**: Save generation scripts with version numbers (e.g., `generate_v1.py`, `generate_v2.py`)
- **Document changes**: Track what worked and what didn't in each iteration

### 8. Content Verification Workflow

After generation, always verify using multiple methods:

```bash
# 1. Extract text content
uv run python - <<'PY'
import zipfile
from lxml import etree
NS = {"a": "http://schemas.openxmlformats.org/drawingml/2006/main"}
with zipfile.ZipFile("output.pptx") as deck:
    for name in sorted(n for n in deck.namelist() if n.startswith("ppt/slides/slide") and n.endswith(".xml")):
        root = etree.fromstring(deck.read(name))
        print("---", name, "---")
        for p in root.xpath(".//a:p", namespaces=NS):
            text = "".join(t.text or "" for t in p.xpath(".//a:t", namespaces=NS))
            if text.strip():
                print(text)
PY

# 2. Generate visual thumbnails
uv run python .bob/skills/pptx/scripts/thumbnail.py output.pptx

# 3. Check for leftover template text
uv run python -m markitdown output.pptx | grep -iE "xxxx|lorem|ipsum|placeholder|consulting offerings|project summary|client presentation"

# 4. Validate package integrity
python -c "import zipfile; z = zipfile.ZipFile('output.pptx'); print('OK' if z.testzip() is None else 'CORRUPTED')"
```

### 9. Common Pitfalls to Avoid

❌ **Don't**: Clear text frames and rebuild content
```python
# BAD - Loses all formatting
shape.text_frame.clear()
shape.text_frame.text = new_text
```

✅ **Do**: Write direct XML replacement in the deck generator and assert counts
```python
# GOOD - Preserves formatting and fails on missed replacements
counts = replace_in_slide_xml(root, replacements)
assert all(count > 0 for count in counts.values())
```

❌ **Don't**: Assume template text without verification
```python
# BAD - May not match actual template
replacements = {"Company Name": "Acme Corp"}
```

✅ **Do**: Extract and verify exact template text first
```python
# GOOD - Verify actual XML text
text = "".join(node.text or "" for node in paragraph.xpath(".//a:t", namespaces=NS))
```

❌ **Don't**: Select slides without visual inspection
```python
# BAD - May select incompatible layouts
selected_slides = [1, 2, 3, 4, 5]
```

✅ **Do**: Generate thumbnails and select appropriate layouts
```bash
# GOOD - Visual verification first
uv run python .bob/skills/pptx/scripts/thumbnail.py template.pptx
# Then select slides with compatible layouts
```

### 10. Troubleshooting Text Replacement Issues

**Problem**: Text not being replaced

**Diagnosis**:
1. Extract visible template text directly from `ppt/slides/slideN.xml`.
2. Compare with your replacement mapping (check whitespace, case, punctuation)
3. Verify slide number is in selected slides list

**Solution**: Use the extracted XML text and assert replacement counts so unmatched keys stop the generation.

**Problem**: Garbled or overlapping text

**Diagnosis**: Likely using the wrong replacement strategy, such as clearing frames or appending text instead of replacing existing XML paragraphs.

**Solution**: Switch to direct XML replacement and only use manual `python-pptx` edits after the direct XML replacement and leftover-template checks pass.

**Problem**: Lost formatting (fonts, colors, alignment)

**Diagnosis**: Text frame was cleared and rebuilt

**Solution**: Preserve the template structure by replacing text in existing XML paragraphs and retaining the first text run's styling.
