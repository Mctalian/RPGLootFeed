import os
import re
from collections import OrderedDict

import defusedxml.ElementTree as ET

base_dir = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "RPGLootFeed"
)
locale_dir = os.path.join(base_dir, "locale")


def parse_locales_xml(xml_file):
    """Parse locales.xml to extract Lua file names"""
    tree = ET.parse(xml_file)
    root = tree.getroot()
    namespace = {"ns": root.tag.split("}")[0].strip("{")}
    locale_files = [
        script.attrib["file"] for script in root.findall("ns:Script", namespace)
    ]
    return locale_files


def parse_locale_file_with_regions(file_path):
    """
    Parse a Lua locale file into regions with their translation entries.
    Returns:
    - header_lines: Lines before the first region
    - regions: Dictionary of region_name -> list of translation entries (key, value)
    - footer_lines: Lines after the last region
    """
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Extract header (everything before first region)
    header_match = re.search(r"(.*?)^--#region", content, re.DOTALL | re.MULTILINE)
    header_lines = (
        header_match.group(1).splitlines() if header_match else content.splitlines()
    )

    # Extract regions with their content
    region_pattern = r"^--#region\s+([^\n]+)\n(.*?)--#endregion"
    region_matches = re.findall(region_pattern, content, re.DOTALL | re.MULTILINE)

    regions = OrderedDict()
    for region_name, region_content in region_matches:
        # Parse translations in this region
        translations = []
        for line in region_content.splitlines():
            # Skip empty lines and comments
            if not line.strip() or (
                line.strip().startswith("--") and "--[[" not in line
            ):
                continue

            # Extract translation key and value
            match = re.match(r'L\["(.+?)"\]\s*=\s*(.+)', line.strip())
            if match:
                key = match.group(1)
                value = match.group(2)
                translations.append((key, value, line))

        regions[region_name.strip()] = translations

    # Extract footer (everything after last endregion)
    parts = content.split("--#endregion\n")
    if len(parts) > 1:
        # The last part will be what comes after the last --#endregion
        footer_lines = parts[-1].splitlines()
    else:
        footer_lines = []

    return header_lines, regions, footer_lines


def sort_regions_by_keys(regions):
    """
    Sort translations within each region:
    1. Untranslated (commented) entries first, sorted alphabetically by key
    2. Translated entries next, sorted alphabetically by key
    """
    for region_name, translations in regions.items():
        # Split into translated and untranslated entries
        untranslated = []
        translated = []

        for entry in translations:
            key, value, line = entry
            if line.strip().startswith("--"):
                untranslated.append(entry)
            else:
                translated.append(entry)

        # Sort each group alphabetically
        untranslated.sort(key=lambda x: x[0].lower())
        translated.sort(key=lambda x: x[0].lower())

        # Combine: untranslated first, then translated
        regions[region_name] = untranslated + translated

    return regions


def generate_updated_locale_file(header_lines, regions, footer_lines):
    """Generate the content for an updated locale file"""
    lines = header_lines.copy()

    for region_name, translations in regions.items():
        lines.append(f"--#region {region_name}")
        for _key, _value, original_line in translations:
            lines.append(original_line)
        lines.append("--#endregion")

    lines.extend(footer_lines)
    return "\n".join(lines) + "\n"


def process_locale_file(reference_regions, locale_file_path):
    """
    Process a locale file to:
    1. Create missing region blocks
    2. Add commented-out English values for missing translations
    3. Sort regions alphabetically by locale key
    """
    if not os.path.exists(locale_file_path):
        print(f"File not found: {locale_file_path}")
        return

    # Parse the current locale file
    header_lines, target_regions, footer_lines = parse_locale_file_with_regions(
        locale_file_path
    )

    # Create a dictionary to track existing translations in the target file
    existing_translations = {}
    for region_name, translations in target_regions.items():
        for key, value, _ in translations:
            existing_translations[key] = (value, region_name)

    # Create updated regions for the target file
    updated_regions = OrderedDict()

    # Process each region from the reference file
    for ref_region_name, ref_translations in reference_regions.items():
        region_translations = []

        # Process each translation in the reference region
        for ref_key, ref_value, _ in ref_translations:
            if ref_key in existing_translations:
                # Translation exists in target file
                target_value, target_region = existing_translations[ref_key]
                # Add it to the proper region (which might be different from its current region)
                region_translations.append(
                    (ref_key, target_value, f'L["{ref_key}"] = {target_value}')
                )
            else:
                # Translation doesn't exist - add a commented out version with English value
                region_translations.append(
                    (ref_key, "", f'-- L["{ref_key}"] = {ref_value}')
                )

        # Add the region with its translations
        updated_regions[ref_region_name] = region_translations

    # Sort translations within each region
    updated_regions = sort_regions_by_keys(updated_regions)

    # Generate updated locale file content
    updated_content = generate_updated_locale_file(
        header_lines, updated_regions, footer_lines
    )

    # Write updated content back to the file
    with open(locale_file_path, "w", encoding="utf-8") as f:
        f.write(updated_content)

    # print(f"Updated {locale_file_path}")


def main():
    locales_xml = f"{locale_dir}/locales.xml"
    locale_files = parse_locales_xml(locales_xml)

    # Reference locale file (enUS.lua)
    reference_file = "enUS.lua"
    reference_path = f"{locale_dir}/{reference_file}"

    # Parse and sort the reference file
    header_lines, reference_regions, footer_lines = parse_locale_file_with_regions(
        reference_path
    )
    sorted_reference_regions = sort_regions_by_keys(reference_regions)

    # First, update the reference file (enUS.lua) itself to ensure it's sorted
    updated_reference_content = generate_updated_locale_file(
        header_lines, sorted_reference_regions, footer_lines
    )
    with open(reference_path, "w", encoding="utf-8") as f:
        f.write(updated_reference_content)
    # print(f"Updated reference locale file: {reference_path}")

    # Now process each other locale file
    for locale_file in locale_files:
        if locale_file in ["main.lua", reference_file]:
            continue

        locale_path = f"{locale_dir}/{locale_file}"
        process_locale_file(sorted_reference_regions, locale_path)


if __name__ == "__main__":
    main()
