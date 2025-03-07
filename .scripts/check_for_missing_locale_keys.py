import os
import re

# Directory paths
base_dir = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "RPGLootFeed"
)
locale_dir = os.path.join(base_dir, "locale")
enUS_file = os.path.join(locale_dir, "enUS.lua")

# Regex patterns
locale_key_pattern = re.compile(r'G_RLF\.L\["(.*?)"\]')
definition_pattern = re.compile(r'L\["(.*?)"\]')
comment_pattern = re.compile(r"^\s*--")


# Function to get all locale keys from Lua files (excluding locale directory)
def get_locale_keys(base_dir):
    locale_keys = set()
    for root, _, files in os.walk(base_dir):
        if locale_dir in root:
            continue
        for file in files:
            if file.endswith(".lua"):
                with open(os.path.join(root, file), "r") as f:
                    for line in f:
                        if not comment_pattern.match(line):
                            keys = locale_key_pattern.findall(line)
                            locale_keys.update(keys)
    return locale_keys


# Function to get all defined keys in enUS.lua
def get_defined_keys(enUS_file):
    defined_keys = set()
    with open(enUS_file, "r") as f:
        for line in f:
            if not comment_pattern.match(line):
                keys = definition_pattern.findall(line)
                defined_keys.update(keys)
    return defined_keys


# Main function to check for missing keys
def check_missing_keys():
    locale_keys = get_locale_keys(base_dir)
    defined_keys = get_defined_keys(enUS_file)

    missing_keys = locale_keys - defined_keys
    if missing_keys:
        print("Missing locale keys in enUS.lua:\n")
        for key in missing_keys:
            print(f'L["{key}"]')
        print("\nPlease define the missing keys in enUS.lua")
        exit(1)
    else:
        print("All locale keys are defined in enUS.lua")
        exit(0)


if __name__ == "__main__":
    check_missing_keys()
