#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Font utilities for PowerPoint generation with Japanese support.

Provides functions for:
- Setting IBM Plex Sans JP font for Japanese text
- Font embedding in presentations (future enhancement)
- Font validation and verification
"""

import zipfile
from pathlib import Path
from typing import Optional
from lxml import etree

# Import Japanese utilities
try:
    from .japanese_utils import contains_japanese
except ImportError:
    from japanese_utils import contains_japanese

# XML namespaces
NS = {
    'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
    'p': 'http://schemas.openxmlformats.org/presentationml/2006/main',
    'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
}


def set_japanese_font_in_xml(root: etree._Element, font_name: str = "IBM Plex Sans JP") -> int:
    """
    Set IBM Plex Sans JP font for all Japanese text in slide XML.
    
    This function scans all text runs in the slide and sets the East Asian
    font to IBM Plex Sans JP for any runs containing Japanese characters.
    
    Args:
        root: XML root element of slide
        font_name: Font name to use for Japanese text (default: "IBM Plex Sans JP")
        
    Returns:
        Number of text runs updated with Japanese font
        
    Example:
        >>> with zipfile.ZipFile(pptx_path) as deck:
        ...     root = etree.fromstring(deck.read('ppt/slides/slide1.xml'))
        ...     count = set_japanese_font_in_xml(root)
        ...     print(f"Updated {count} text runs")
    """
    updated_count = 0
    
    # Find all text runs
    for run in root.xpath('.//a:r', namespaces=NS):
        text_node = run.find('.//a:t', namespaces=NS)
        
        if text_node is not None and text_node.text and contains_japanese(text_node.text):
            # Get or create run properties
            rPr = run.find('.//a:rPr', namespaces=NS)
            if rPr is None:
                # Insert rPr as first child of run
                rPr = etree.Element(f"{{{NS['a']}}}rPr")
                run.insert(0, rPr)
            
            # Get or create East Asian font element
            ea = rPr.find('.//a:ea', namespaces=NS)
            if ea is None:
                ea = etree.SubElement(rPr, f"{{{NS['a']}}}ea")
            
            # Set font name
            ea.set('typeface', font_name)
            updated_count += 1
    
    return updated_count


def set_japanese_fonts(pptx_path: Path, font_name: str = "IBM Plex Sans JP") -> dict:
    """
    Set IBM Plex Sans JP font for all Japanese text in presentation.
    
    This function processes all slides in the presentation and sets the
    appropriate font for Japanese text while preserving all other formatting.
    
    Args:
        pptx_path: Path to PowerPoint file
        font_name: Font name to use for Japanese text (default: "IBM Plex Sans JP")
        
    Returns:
        Dictionary with results:
        - slides_processed: Number of slides processed
        - runs_updated: Total number of text runs updated
        - slides_with_updates: Number of slides that had updates
        
    Raises:
        FileNotFoundError: If presentation file doesn't exist
        
    Example:
        >>> results = set_japanese_fonts(Path("presentation.pptx"))
        >>> print(f"Updated {results['runs_updated']} text runs across {results['slides_with_updates']} slides")
    """
    if not pptx_path.exists():
        raise FileNotFoundError(f"Presentation not found: {pptx_path}")
    
    modified_parts = {}
    total_runs_updated = 0
    slides_with_updates = 0
    slides_processed = 0
    
    # Read and modify slide XML
    with zipfile.ZipFile(pptx_path, 'r') as zin:
        slide_parts = sorted([n for n in zin.namelist() if 'ppt/slides/slide' in n and n.endswith('.xml')])
        
        for slide_part in slide_parts:
            slides_processed += 1
            root = etree.fromstring(zin.read(slide_part))
            
            # Set Japanese fonts in this slide
            runs_updated = set_japanese_font_in_xml(root, font_name)
            
            if runs_updated > 0:
                total_runs_updated += runs_updated
                slides_with_updates += 1
                
                # Store modified XML
                modified_parts[slide_part] = etree.tostring(
                    root,
                    encoding='UTF-8',
                    xml_declaration=True
                )
    
    # Write modified presentation
    if modified_parts:
        tmp_path = pptx_path.with_suffix('.tmp.pptx')
        
        with zipfile.ZipFile(pptx_path, 'r') as zin:
            with zipfile.ZipFile(tmp_path, 'w', zipfile.ZIP_DEFLATED) as zout:
                for item in zin.infolist():
                    data = modified_parts.get(item.filename, zin.read(item.filename))
                    zout.writestr(item, data)
        
        # Replace original with modified
        tmp_path.replace(pptx_path)
    
    return {
        'slides_processed': slides_processed,
        'runs_updated': total_runs_updated,
        'slides_with_updates': slides_with_updates,
    }


def verify_font_assignment(pptx_path: Path, expected_font: str = "IBM Plex Sans JP") -> dict:
    """
    Verify that Japanese text has correct font assignment.
    
    Args:
        pptx_path: Path to PowerPoint file
        expected_font: Expected font name for Japanese text
        
    Returns:
        Dictionary with verification results:
        - total_japanese_runs: Total text runs with Japanese text
        - correctly_assigned: Runs with correct font
        - missing_font: Runs without font specification
        - wrong_font: Runs with incorrect font
        - issues: List of specific issues found
        
    Raises:
        FileNotFoundError: If presentation file doesn't exist
    """
    if not pptx_path.exists():
        raise FileNotFoundError(f"Presentation not found: {pptx_path}")
    
    total_japanese_runs = 0
    correctly_assigned = 0
    missing_font = 0
    wrong_font = 0
    issues = []
    
    with zipfile.ZipFile(pptx_path) as deck:
        slide_parts = sorted([n for n in deck.namelist() if 'ppt/slides/slide' in n and n.endswith('.xml')])
        
        for slide_idx, slide_part in enumerate(slide_parts, 1):
            root = etree.fromstring(deck.read(slide_part))
            
            for run in root.xpath('.//a:r', namespaces=NS):
                text_node = run.find('.//a:t', namespaces=NS)
                
                if text_node is not None and text_node.text and contains_japanese(text_node.text):
                    total_japanese_runs += 1
                    
                    rPr = run.find('.//a:rPr', namespaces=NS)
                    if rPr is not None:
                        ea = rPr.find('.//a:ea', namespaces=NS)
                        if ea is not None:
                            font = ea.get('typeface', '')
                            if font == expected_font:
                                correctly_assigned += 1
                            else:
                                wrong_font += 1
                                issues.append(f"Slide {slide_idx}: Wrong font '{font}' (expected '{expected_font}')")
                        else:
                            missing_font += 1
                            issues.append(f"Slide {slide_idx}: No East Asian font specified")
                    else:
                        missing_font += 1
                        issues.append(f"Slide {slide_idx}: No font properties")
    
    return {
        'total_japanese_runs': total_japanese_runs,
        'correctly_assigned': correctly_assigned,
        'missing_font': missing_font,
        'wrong_font': wrong_font,
        'issues': issues,
    }


def get_font_info(pptx_path: Path) -> dict:
    """
    Get information about fonts used in presentation.
    
    Args:
        pptx_path: Path to PowerPoint file
        
    Returns:
        Dictionary with font information:
        - latin_fonts: Set of Latin fonts used
        - ea_fonts: Set of East Asian fonts used
        - cs_fonts: Set of Complex Script fonts used
        
    Raises:
        FileNotFoundError: If presentation file doesn't exist
    """
    if not pptx_path.exists():
        raise FileNotFoundError(f"Presentation not found: {pptx_path}")
    
    latin_fonts = set()
    ea_fonts = set()
    cs_fonts = set()
    
    with zipfile.ZipFile(pptx_path) as deck:
        slide_parts = [n for n in deck.namelist() if 'ppt/slides/slide' in n and n.endswith('.xml')]
        
        for slide_part in slide_parts:
            root = etree.fromstring(deck.read(slide_part))
            
            # Find all run properties
            for rPr in root.xpath('.//a:rPr', namespaces=NS):
                # Latin font
                latin = rPr.find('.//a:latin', namespaces=NS)
                if latin is not None:
                    font = latin.get('typeface')
                    if font:
                        latin_fonts.add(font)
                
                # East Asian font
                ea = rPr.find('.//a:ea', namespaces=NS)
                if ea is not None:
                    font = ea.get('typeface')
                    if font:
                        ea_fonts.add(font)
                
                # Complex Script font
                cs = rPr.find('.//a:cs', namespaces=NS)
                if cs is not None:
                    font = cs.get('typeface')
                    if font:
                        cs_fonts.add(font)
    
    return {
        'latin_fonts': sorted(latin_fonts),
        'ea_fonts': sorted(ea_fonts),
        'cs_fonts': sorted(cs_fonts),
    }


def print_font_report(pptx_path: Path) -> None:
    """
    Print a comprehensive font usage report.
    
    Args:
        pptx_path: Path to PowerPoint file
    """
    print("\n" + "="*60)
    print("Font Usage Report")
    print("="*60)
    print(f"\nPresentation: {pptx_path.name}")
    
    # Get font info
    font_info = get_font_info(pptx_path)
    
    print("\nFonts Used:")
    print(f"  Latin Fonts: {', '.join(font_info['latin_fonts']) if font_info['latin_fonts'] else 'None'}")
    print(f"  East Asian Fonts: {', '.join(font_info['ea_fonts']) if font_info['ea_fonts'] else 'None'}")
    print(f"  Complex Script Fonts: {', '.join(font_info['cs_fonts']) if font_info['cs_fonts'] else 'None'}")
    
    # Verify Japanese font assignment
    verification = verify_font_assignment(pptx_path)
    
    print("\nJapanese Text Font Verification:")
    print(f"  Total Japanese text runs: {verification['total_japanese_runs']}")
    print(f"  Correctly assigned: {verification['correctly_assigned']}")
    print(f"  Missing font: {verification['missing_font']}")
    print(f"  Wrong font: {verification['wrong_font']}")
    
    if verification['issues']:
        print("\nIssues Found:")
        for issue in verification['issues'][:10]:  # Show first 10
            print(f"  - {issue}")
        if len(verification['issues']) > 10:
            print(f"  ... and {len(verification['issues']) - 10} more")
    else:
        print("\n✓ All Japanese text has correct font assignment")
    
    print("\n" + "="*60 + "\n")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python font_utils.py <presentation.pptx> [command]")
        print("\nCommands:")
        print("  info    - Show font information (default)")
        print("  set     - Set IBM Plex Sans JP for Japanese text")
        print("  verify  - Verify font assignments")
        sys.exit(1)
    
    pptx_path = Path(sys.argv[1])
    command = sys.argv[2] if len(sys.argv) > 2 else "info"
    
    if not pptx_path.exists():
        print(f"Error: File not found: {pptx_path}")
        sys.exit(1)
    
    if command == "set":
        print(f"Setting IBM Plex Sans JP for Japanese text in {pptx_path.name}...")
        results = set_japanese_fonts(pptx_path)
        print(f"✓ Processed {results['slides_processed']} slides")
        print(f"✓ Updated {results['runs_updated']} text runs in {results['slides_with_updates']} slides")
        
    elif command == "verify":
        verification = verify_font_assignment(pptx_path)
        print(f"\nVerification Results:")
        print(f"  Total Japanese runs: {verification['total_japanese_runs']}")
        print(f"  Correctly assigned: {verification['correctly_assigned']}")
        print(f"  Issues: {verification['missing_font'] + verification['wrong_font']}")
        
        if verification['issues']:
            print("\nIssues:")
            for issue in verification['issues']:
                print(f"  - {issue}")
        
    else:  # info
        print_font_report(pptx_path)
