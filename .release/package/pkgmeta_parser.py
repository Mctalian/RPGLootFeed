import os

from .config import config


def determine_pkgmeta_file():
    pkgmeta_file = config.pkgmeta_file
    topdir = config.top_directory

    # If pkgmeta_file is not set, use default paths
    if not pkgmeta_file:
        pkgmeta_file = os.path.join(topdir, ".pkgmeta")
        # Check if .pkgmeta does not exist and pkgmeta.yaml does exist
        if not os.path.isfile(pkgmeta_file) and os.path.isfile(
            os.path.join(topdir, "pkgmeta.yaml")
        ):
            pkgmeta_file = os.path.join(topdir, "pkgmeta.yaml")

    return pkgmeta_file
