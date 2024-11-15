import os
import shutil

from .print_utils import print_yellow


def copy_directory_tree(src, dest, ignore_patterns=None):
    if ignore_patterns is None:
        ignore_patterns = []
    for root, dirs, files in os.walk(src):
        for file in files:
            if any(pattern in file for pattern in ignore_patterns):
                continue
            src_file = os.path.join(root, file)
            dest_file = os.path.join(dest, os.path.relpath(src_file, src))
            os.makedirs(os.path.dirname(dest_file), exist_ok=True)
            shutil.copy2(src_file, dest_file)
            print_yellow(f"Copying: {file}")
