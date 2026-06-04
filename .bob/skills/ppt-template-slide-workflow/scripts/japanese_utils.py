#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Japanese text utilities for PowerPoint generation.

Provides functions for:
- Japanese character detection
- UTF-8 encoding validation
- Font validation (IBM Plex Sans JP)
- Text extraction and analysis
"""

import re
import zipfile
from pathlib import Path
from typing import Dict, List, Optional
from lxml import etree

# XML namespaces
NS = {
    'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
    'p': 'http://schemas.openxmlformats.org/presentationml/2006/main',
    'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
}


def contains_japanese(text: str) -> bool:
    """
    Check if text contains Japanese characters.
    
    Args:
        text: Text to check
        
    Returns:
        True if text contains Hiragana, Katakana, or Kanji characters
        
    Example:
        >>> contains_japanese("こんにちは")
        True
        >>> contains_japanese("Hello World")
        False
        >>> contains_japanese("Hello 世界")
        True
    """
    if not text:
        return False
    
    japanese_pattern = re.compile(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]')
    return bool(japanese_pattern.search(text))


def get_character_types(text: str) -> Dict[str, bool]:
    """
    Analyze character types present in text.
    
    Args:
        text: Text to analyze
        
    Returns:
        Dictionary with boolean flags for each character type
        
    Example:
        >>> get_character_types("こんにちは世界")
        {'hiragana': True, 'katakana': False, 'kanji': True, 'latin': False}
    """
    return {
        'hiragana': bool(re.search(r'[\u3040-\u309F]', text)),
        'katakana': bool(re.search(r'[\u30A0-\u30FF]', text)),
        'kanji': bool(re.search(r'[\u4E00-\u9FFF]', text)),
        'latin': bool(re.search(r'[A-Za-z]', text)),
        'numbers': bool(re.search(r'[0-9]', text)),
    }


def validate_japanese_encoding(pptx_path: Path) -> bool:
    """
    Validate UTF-8 encoding of Japanese text in presentation.
    
    Args:
        pptx_path: Path to PowerPoint file
        
    Returns:
        True if all Japanese text is properly UTF-8 encoded
        
    Raises:
        FileNotFoundError: If presentation file doesn't exist
    """
    if not pptx_path.exists():
        raise FileNotFoundError(f"Presentation not found: {pptx_path}")
    
    try:
        with zipfile.ZipFile(pptx_path) as deck:
            slide_parts = [n for n in deck.namelist() if 'ppt/slides/slide' in n and n.endswith('.xml')]
            
            for slide_part in slide_parts:
                try:
                    xml_bytes = deck.read(slide_part)
                    xml_text = xml_bytes.decode('utf-8')
                    
                    # Verify Japanese characters are preserved
                    if contains_japanese(xml_text):
                        # Re-encode and compare
                        reencoded = xml_text.encode('utf-8')
                        if reencoded != xml_bytes:
                            print(f"Encoding mismatch in {slide_part}")
                            return False
                            
                except UnicodeDecodeError as e:
                    print(f"UTF-8 decode error in {slide_part}: {e}")
                    return False
                    
        return True
        
    except zipfile.BadZipFile:
        print(f"Invalid PowerPoint file: {pptx_path}")
        return False


def validate_japanese_fonts(pptx_path: Path, expected_font: str = "IBM Plex Sans JP") -> bool:
    """
    Validate that Japanese text uses the correct font (IBM Plex Sans JP).
    
    Args:
        pptx_path: Path to PowerPoint file
        expected_font: Expected font name for Japanese text
        
    Returns:
        True if all Japanese text uses the expected font
        
    Raises:
        FileNotFoundError: If presentation file doesn't exist
    """
    if not pptx_path.exists():
        raise FileNotFoundError(f"Presentation not found: {pptx_path}")
    
    issues = []
    
    try:
        with zipfile.ZipFile(pptx_path) as deck:
            slide_parts = [n for n in deck.namelist() if 'ppt/slides/slide' in n and n.endswith('.xml')]
            
            for slide_part in slide_parts:
                root = etree.fromstring(deck.read(slide_part))
                
                # Find all text runs with Japanese text
                for run in root.xpath('.//a:r', namespaces=NS):
                    text_node = run.find('.//a:t', namespaces=NS)
                    if text_node is not None and text_node.text and contains_japanese(text_node.text):
                        # Check if IBM Plex Sans JP is specified for East Asian text
                        rPr = run.find('.//a:rPr', namespaces=NS)
                        if rPr is not None:
                            ea_font = rPr.find('.//a:ea', namespaces=NS)
                            if ea_font is not None:
                                font_name = ea_font.get('typeface', '')
                                if font_name != expected_font:
                                    issues.append(f"{slide_part}: Japanese text uses '{font_name}' instead of '{expected_font}'")
                            else:
                                issues.append(f"{slide_part}: No East Asian font specified for Japanese text")
                        else:
                            issues.append(f"{slide_part}: No font properties for Japanese text run")
        
        if issues:
            print("Font validation issues found:")
            for issue in issues:
                print(f"  - {issue}")
            return False
            
        return True
        
    except zipfile.BadZipFile:
        print(f"Invalid PowerPoint file: {pptx_path}")
        return False


def extract_japanese_text(pptx_path: Path) -> Dict[int, List[str]]:
    """
    Extract all Japanese text from presentation, organized by slide.
    
    Args:
        pptx_path: Path to PowerPoint file
        
    Returns:
        Dictionary mapping slide numbers to lists of Japanese text strings
        
    Raises:
        FileNotFoundError: If presentation file doesn't exist
    """
    if not pptx_path.exists():
        raise FileNotFoundError(f"Presentation not found: {pptx_path}")
    
    japanese_text = {}
    
    try:
        with zipfile.ZipFile(pptx_path) as deck:
            slide_parts = sorted([n for n in deck.namelist() if 'ppt/slides/slide' in n and n.endswith('.xml')])
            
            for idx, slide_part in enumerate(slide_parts, 1):
                root = etree.fromstring(deck.read(slide_part))
                slide_japanese = []
                
                # Extract all text from paragraphs
                for paragraph in root.xpath('.//a:p', namespaces=NS):
                    text_nodes = paragraph.xpath('.//a:t', namespaces=NS)
                    if text_nodes:
                        para_text = ''.join(node.text or '' for node in text_nodes)
                        if para_text.strip() and contains_japanese(para_text):
                            slide_japanese.append(para_text.strip())
                
                if slide_japanese:
                    japanese_text[idx] = slide_japanese
        
        return japanese_text
        
    except zipfile.BadZipFile:
        print(f"Invalid PowerPoint file: {pptx_path}")
        return {}


def analyze_japanese_content(pptx_path: Path) -> Dict:
    """
    Analyze Japanese content in presentation.
    
    Args:
        pptx_path: Path to PowerPoint file
        
    Returns:
        Dictionary with analysis results including:
        - total_slides: Total number of slides
        - slides_with_japanese: Number of slides containing Japanese text
        - character_types: Character type statistics
        - encoding_valid: Whether UTF-8 encoding is valid
        - fonts_valid: Whether fonts are correctly set
        
    Raises:
        FileNotFoundError: If presentation file doesn't exist
    """
    if not pptx_path.exists():
        raise FileNotFoundError(f"Presentation not found: {pptx_path}")
    
    japanese_text = extract_japanese_text(pptx_path)
    
    # Analyze character types across all Japanese text
    all_text = ' '.join(text for texts in japanese_text.values() for text in texts)
    char_types = get_character_types(all_text)
    
    # Count slides
    with zipfile.ZipFile(pptx_path) as deck:
        total_slides = len([n for n in deck.namelist() if 'ppt/slides/slide' in n and n.endswith('.xml')])
    
    return {
        'total_slides': total_slides,
        'slides_with_japanese': len(japanese_text),
        'character_types': char_types,
        'encoding_valid': validate_japanese_encoding(pptx_path),
        'fonts_valid': validate_japanese_fonts(pptx_path),
        'japanese_text_by_slide': japanese_text,
    }


def print_analysis_report(analysis: Dict) -> None:
    """
    Print a formatted analysis report.
    
    Args:
        analysis: Analysis results from analyze_japanese_content()
    """
    print("\n" + "="*60)
    print("Japanese Content Analysis Report")
    print("="*60)
    
    print(f"\nSlides:")
    print(f"  Total slides: {analysis['total_slides']}")
    print(f"  Slides with Japanese: {analysis['slides_with_japanese']}")
    
    print(f"\nCharacter Types:")
    for char_type, present in analysis['character_types'].items():
        status = "✓" if present else "✗"
        print(f"  {status} {char_type.capitalize()}")
    
    print(f"\nValidation:")
    enc_status = "✓ PASS" if analysis['encoding_valid'] else "✗ FAIL"
    font_status = "✓ PASS" if analysis['fonts_valid'] else "✗ FAIL"
    print(f"  UTF-8 Encoding: {enc_status}")
    print(f"  IBM Plex Sans JP: {font_status}")
    
    if analysis['japanese_text_by_slide']:
        print(f"\nJapanese Text by Slide:")
        for slide_num, texts in sorted(analysis['japanese_text_by_slide'].items()):
            print(f"  Slide {slide_num}:")
            for text in texts[:3]:  # Show first 3 items
                preview = text[:50] + "..." if len(text) > 50 else text
                print(f"    - {preview}")
            if len(texts) > 3:
                print(f"    ... and {len(texts) - 3} more")
    
    print("\n" + "="*60 + "\n")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python japanese_utils.py <presentation.pptx>")
        sys.exit(1)
    
    pptx_path = Path(sys.argv[1])
    
    if not pptx_path.exists():
        print(f"Error: File not found: {pptx_path}")
        sys.exit(1)
    
    # Run analysis
    analysis = analyze_japanese_content(pptx_path)
    print_analysis_report(analysis)
