# .release/local/argument_parser.py
import argparse


def parse_args(args):
    parser = argparse.ArgumentParser(description="Release tool for WoW Addons")

    # Command-line options
    parser.add_argument(
        "-c", action="store_true", help="Skip copying files into the package directory."
    )
    parser.add_argument("-z", action="store_true", help="Skip creating a zip file.")
    parser.add_argument(
        "-e", action="store_true", help="Skip checkout of external repositories."
    )
    parser.add_argument(
        "-l", action="store_true", help="Skip @localization@ keyword replacement."
    )
    parser.add_argument("-L", action="store_true", help="Skip uploading to CurseForge.")
    parser.add_argument("-d", action="store_true", help="Skip uploading.")
    parser.add_argument(
        "-D",
        action="store_true",
        help="Local dev mode (Skips uploading, skips zip, keeps existing pkgdir, skips external if it exists)",
    )
    parser.add_argument("-u", action="store_true", help="Use Unix line-endings.")
    parser.add_argument(
        "-o",
        action="store_true",
        help="Keep existing package directory, overwriting its contents.",
    )
    parser.add_argument(
        "-v", action="store_true", help="Verbose mode, adds extra prints"
    )
    parser.add_argument(
        "-V", action="store_true", help="Super Verbose mode, adds even more prints"
    )
    parser.add_argument(
        "-p",
        type=str,
        help="Set the project id used on CurseForge for localization and uploading.",
    )
    parser.add_argument(
        "-w", type=str, help="Set the addon id used on WoWInterface for uploading."
    )
    parser.add_argument(
        "-a", type=str, help="Set the project id used on Wago Addons for uploading."
    )
    parser.add_argument(
        "-r", type=str, help="Set the directory containing the package directory."
    )
    parser.add_argument("-t", type=str, help="Set top-level directory of checkout.")
    parser.add_argument(
        "-s", action="store_true", help="Create a stripped-down 'nolib' package."
    )
    parser.add_argument(
        "-S",
        action="store_true",
        help="Create a package supporting multiple game types from a single TOC file.",
    )
    parser.add_argument(
        "-g", type=str, help="Set the game version to use for uploading."
    )
    parser.add_argument("-m", type=str, help="Set the pkgmeta file to use.")
    parser.add_argument(
        "-n",
        type=str,
        help="""Set the package zip file name and upload label. 
        Use "-n help" for more info.""",
    )

    return parser.parse_args(args)
