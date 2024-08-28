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

    config.top_directory = os.path.abspath(topdir)


def determine_releasedir():
    releasedir = config.release_directory

    if not releasedir:
        releasedir = os.path.join(config.top_directory, ".release")

    # Convert release directory to absolute path
    releasedir_abs = os.path.abspath(releasedir)

    # Check if the release directory is an absolute path or inside the topdir
    if not os.path.isabs(releasedir) and not releasedir_abs.startswith(
        config.top_directory
    ):
        print(
            f'The release directory "{releasedir}" must be an absolute path or inside "{config.top_directory}".',
            file=sys.stderr,
        )
        sys.exit(1)

    # Create the staging directory
    try:
        os.makedirs(releasedir_abs, exist_ok=True)
    except OSError as e:
        print(
            f'Unable to create the release directory "{releasedir_abs}".',
            file=sys.stderr,
        )
        sys.exit(1)

    config.release_directory = releasedir_abs


def determine_repository_type():
    topdir = config.top_directory

    if os.path.isdir(os.path.join(topdir, ".git")):
        config.repository_type = "git"
    elif os.path.isdir(os.path.join(topdir, ".svn")):
        config.repository_type = "svn"
    elif os.path.isdir(os.path.join(topdir, ".hg")):
        config.repository_type = "hg"
    else:
        print(f'No Git, SVN, or Hg checkout found in "{topdir}".', file=sys.stderr)
        sys.exit(1)
