import os

import yaml

from .config import config
from .print_utils import print_red, print_yellow


def parse_pkgmeta_file(pkgmeta_file):
    if not os.path.isfile(pkgmeta_file):
        print_red(f"pkgmeta file not found: {pkgmeta_file}")
        return None

    with open(pkgmeta_file, "r") as f:
        try:
            pkgmeta_data = yaml.safe_load(f)
            print_yellow(f"Parsed pkgmeta file: {pkgmeta_file}")
            return pkgmeta_data
        except yaml.YAMLError as e:
            print_red(f"Error parsing pkgmeta file: {e}")
            return None


def handle_pkgmeta_data(pkgmeta_data):
    if not pkgmeta_data:
        return

    # Example of handling some pkgmeta data
    if "externals" in pkgmeta_data:
        externals = pkgmeta_data["externals"]
        for external in externals:
            print_yellow(f"External: {external}")

    if "move-folders" in pkgmeta_data:
        move_folders = pkgmeta_data["move-folders"]
        for src, dest in move_folders.items():
            print_yellow(f"Move folder: {src} to {dest}")

    # Add more handling as needed
