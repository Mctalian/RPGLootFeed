import json

import requests

from .print_utils import print_green, print_red


def upload_to_github(release_id, archive_name, github_token, project_github_slug):
    url = f"https://uploads.github.com/repos/{project_github_slug}/releases/{release_id}/assets?name={archive_name}"
    headers = {
        "Authorization": f"token {github_token}",
        "Content-Type": "application/zip",
    }
    with open(archive_name, "rb") as f:
        response = requests.post(url, headers=headers, data=f)
    if response.status_code == 201:
        print_green("Successfully uploaded to GitHub")
    else:
        print_red(f"Failed to upload to GitHub: {response.status_code}")
        print_red(response.text)


def upload_to_curseforge(
    archive_name,
    cf_token,
    slug,
    game_version,
    file_type,
    changelog_path,
    changelog_markup,
):
    url = f"https://www.curseforge.com/api/projects/{slug}/upload-file"
    headers = {"X-Api-Token": cf_token}
    payload = {
        "displayName": archive_name,
        "gameVersions": game_version,
        "releaseType": file_type,
        "changelog": open(changelog_path).read(),
        "changelogType": changelog_markup,
    }
    files = {"file": open(archive_name, "rb")}
    response = requests.post(url, headers=headers, data=payload, files=files)
    if response.status_code == 200:
        print_green("Successfully uploaded to CurseForge")
    else:
        print_red(f"Failed to upload to CurseForge: {response.status_code}")
        print_red(response.text)
