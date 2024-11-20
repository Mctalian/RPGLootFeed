import os
import zipfile

from .print_utils import print_green


def create_zipfile(src_dir, output_filename):
    with zipfile.ZipFile(output_filename, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(src_dir):
            for file in files:
                zipf.write(
                    os.path.join(root, file),
                    os.path.relpath(os.path.join(root, file), src_dir),
                )
    print_green(f"Created zip file: {output_filename}")
