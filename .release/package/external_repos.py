import os
import subprocess

from .print_utils import print_red, print_yellow


def checkout_external(
    external_dir,
    external_uri,
    external_tag,
    external_type,
    external_slug,
    external_checkout_type,
    external_path,
):
    # Implement the logic to checkout external repositories
    # This is a placeholder implementation
    print_yellow(f"Checking out external repository: {external_uri}")
    # Example command to checkout a git repository
    if external_type == "git":
        cmd = ["git", "clone", external_uri, external_dir]
        if external_tag:
            cmd.extend(["--branch", external_tag])
        subprocess.run(cmd, check=True)
    elif external_type == "svn":
        cmd = ["svn", "checkout", external_uri, external_dir]
        subprocess.run(cmd, check=True)
    else:
        print_red(f"Unsupported repository type: {external_type}")


def fetch_externals(externals):
    external_pids = []
    for external in externals:
        external_dir = external.get("dir")
        external_uri = external.get("uri")
        external_tag = external.get("tag")
        external_type = external.get("type")
        external_slug = external.get("slug")
        external_checkout_type = external.get("checkout_type")
        external_path = external.get("path")
        print_yellow(f"Fetching external: {external_dir}")
        pid = subprocess.Popen(
            [
                "checkout_external",
                external_dir,
                external_uri,
                external_tag,
                external_type,
                external_slug,
                external_checkout_type,
                external_path,
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        ).pid
        external_pids.append(pid)
    return external_pids
