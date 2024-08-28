# .release/local/print_utils.py

import sys

# Define ANSI color codes
CYAN = "\033[0;36m"
YELLOW = "\033[33m"
RED = "\033[31m"
GREEN = "\033[0;32m"
NO_COLOR = "\033[0m"

# Verbose flags
verbose = False
super_verbose = False


def set_verbose(is_verbose):
    global verbose
    verbose = is_verbose


def set_super_verbose(is_super_verbose):
    global super_verbose
    global verbose
    if is_super_verbose:
        verbose = True
    super_verbose = is_super_verbose


def print_cyan(message):
    print(f"{CYAN}{message}{NO_COLOR}")


def print_green(message):
    print(f"{GREEN}{message}{NO_COLOR}")


def print_red(message):
    print(f"{RED}{message}{NO_COLOR}")


def print_yellow(message):
    print(f"{YELLOW}{message}{NO_COLOR}")


def print_no_verbose(message):
    if not verbose:
        print(message)


def print_verbose(message):
    if verbose:
        print(message)


def print_debug(message):
    if super_verbose:
        print(message)
