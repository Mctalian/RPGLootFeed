import os
import sys

from .config import config


def determine_topdir():
    topdir = config.top_directory

    # If topdir is not provided, determine it
    if not topdir:
        dir = os.getcwd()

        # Check if the current directory or any parent directory contains version control directories
        while True:
            if (
                os.path.isdir(os.path.join(dir, ".git"))
                or os.path.isdir(os.path.join(dir, ".svn"))
                or os.path.isdir(os.path.join(dir, ".hg"))
            ):
                topdir = dir
                break

            # Move up one directory
            parent_dir = os.path.dirname(dir)
            if parent_dir == dir:  # If we reach the root directory
                break
            dir = parent_dir

        # If no version control directory is found
        if not topdir or not (
            os.path.isdir(os.path.join(topdir, ".git"))
            or os.path.isdir(os.path.join(topdir, ".svn"))
            or os.path.isdir(os.path.join(topdir, ".hg"))
        ):
            print("No Git, SVN, or Hg checkout found.", file=sys.stderr)
            sys.exit(1)

    config.top_directory = topdir


def determine_releasedir():
    releasedir = config.release_directory

    # If releasedir is not provided, default to .release under topdir
    if not releasedir:
        if not config.top_directory:
            determine_topdir()
        releasedir = os.path.join(config.top_directory, ".release")

    config.release_directory = releasedir
