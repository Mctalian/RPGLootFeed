import os
import re


# Function to check if a file or directory should be ignored
def should_ignore(path, ignore_files, ignore_dirs):
    if os.path.basename(path) in ignore_dirs:
        return True
    for dir in ignore_dirs:
        if path.startswith(f"./{dir}/"):
            return True
    return os.path.basename(path) in ignore_files


# Function to scan for hard-coded strings
def check_hardcoded_strings(file_content, filename):
    issues = []

    # Check for Print(...) calls with hard-coded strings
    print_matches = re.findall(
        r'(?:\w+:)?Print\(\s*"([^"]+)(?:"(?:\s*\+|\s*\.\.)\s*|\s*"\s*\))',
        file_content,
        re.DOTALL,
    )
    for match in print_matches:
        issues.append(f'Hard-coded string in Print(...) in {filename}: "{match}"')

    # Check for config options with hard-coded name or desc fields
    config_matches = re.findall(
        r'\b(name|desc)\s*=\s*"([^"]+)"', file_content, re.DOTALL
    )
    for field, value in config_matches:
        issues.append(f'Hard-coded {field} in {filename}: "{value}"')

    # Check for config options with hard-coded values in key-value pairs within "values" tables
    values_matches = re.findall(r"\bvalues\s*=\s*{([^}]*)}", file_content, re.DOTALL)
    for match in values_matches:
        key_value_matches = re.findall(r'\[?"?(.*)"?\]?\s*=\s*"([^"]+)"', match)
        for key, value in key_value_matches:
            issues.append(
                f'Hard-coded key-value pair in "values" table in {filename}: "{key.strip()} = {value.strip()}"'
            )

    return issues


# Function to recursively scan directories for .lua files
def scan_directory(directory, ignore_files=None, ignore_dirs=None):
    if ignore_files is None:
        ignore_files = []
    if ignore_dirs is None:
        ignore_dirs = []
    all_issues = []

    for root, dirs, files in os.walk(directory):
        # Modify dirs in place to remove ignored directories from the scan
        dirs[:] = [
            d for d in dirs if not should_ignore(os.path.join(root, d), [], ignore_dirs)
        ]

        for file in files:
            if file.endswith(".lua") and not should_ignore(
                os.path.join(root, file), ignore_files, []
            ):
                filepath = os.path.join(root, file)
                with open(filepath, "r", encoding="utf-8") as f:
                    content = f.read()
                    issues = check_hardcoded_strings(content, filepath)
                    if issues:
                        all_issues.extend(issues)

    return all_issues


def main():
    ignore_files = [
        "IntegrationTest.lua",
        "SmokeTest.lua",
    ]
    ignore_dirs = [
        "Fonts",
        "Icons",
        "locale",
    ]

    # Scan the current directory
    issues = scan_directory("RPGLootFeed", ignore_files, ignore_dirs)

    # Output any issues found
    if issues:
        print("Hard-coded strings found:")
        for issue in issues:
            print(f"  {issue}")
        exit(1)
    else:
        print("No hard-coded strings found.")


if __name__ == "__main__":
    main()
