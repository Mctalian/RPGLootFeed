import sys

from .argument_parser import parse_args
from .config import config
from .pkgmeta_parser import determine_pkgmeta_file
from .print_utils import (
    print_cyan,
    print_green,
    print_red,
    print_yellow,
    set_super_verbose,
    set_verbose,
)
from .repository_setup import determine_releasedir, determine_topdir


def main():
    args = parse_args(sys.argv[1:])

    # Update the config object with parsed arguments
    config.update_from_args(args)

    # Set verbosity based on flags
    if config.verbose:
        set_verbose(True)
    if config.super_verbose:
        set_super_verbose(True)

    # Print messages based on flags
    if config.local_mode:
        print_cyan("🖥️  Local Mode enabled! Taking a bunch of shortcuts...")
    if config.skip_copying:
        print_green("Skipping copying files into the package directory.")
    if config.skip_zip:
        print_green("Skipping creating a zip file.")
    if config.skip_external_repos:
        print_green("Skipping checkout of external repositories.")
    if config.skip_localization:
        print_green("Skipping @localization@ keyword replacement.")
    if config.only_localization:
        print_green("Only doing @localization@ keyword replacement.")
    if config.use_unix_line_endings:
        print_green("Using Unix line-endings.")
    if config.overwrite_existing:
        print_green("Overwriting existing package directory contents.")
    if config.nolib:
        print_green("Creating a stripped-down 'nolib' package.")
    if config.multi_game_types:
        print_green(
            "Creating a package supporting multiple game types from a single TOC file."
        )

    # Handle options
    if config.curseforge_id:
        print_yellow(f"Setting CurseForge project id: {config.curseforge_id}")
    if config.wowinterface_id:
        print_yellow(f"Setting WoWInterface addon id: {config.wowinterface_id}")
    if config.wago_addons_id:
        print_yellow(f"Setting Wago Addons project id: {config.wago_addons_id}")
    if config.release_directory:
        print_yellow(f"Setting release directory: {config.release_directory}")
    if config.top_directory:
        print_yellow(f"Setting top-level directory: {config.top_directory}")
    if config.game_version:
        print_yellow(f"Setting game version: {config.game_version}")
    if config.pkgmeta_file:
        print_yellow(f"Setting pkgmeta file: {config.pkgmeta_file}")
    if config.package_name_label:
        if config.package_name_label.lower() == "help":
            print_cyan(
                """
                Set the package zip file name and upload label.
                Tokens: {package-name}{project-revision}{project-hash}{project-abbreviated-hash}
                        {project-author}{project-date-iso}{project-date-integer}{project-timestamp}
                        {project-version}{game-type}{release-type}
                Flags:  {alpha}{beta}{nolib}{classic}
                """
            )
        else:
            print_yellow(f"Setting package name and label: {config.package_name_label}")

    determine_topdir()
    determine_releasedir()
    print(f"Top-level directory: {config.top_directory}")
    print(f"Release directory: {config.release_directory}")

    # Determine the pkgmeta file
    config.pkgmeta_file = determine_pkgmeta_file()
    if config.pkgmeta_file:
        print_yellow(f"Using pkgmeta file: {config.pkgmeta_file}")
    else:
        print_red("No pkgmeta file found.")


if __name__ == "__main__":
    main()
