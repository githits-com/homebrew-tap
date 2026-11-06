"""Select a reviewed manual PR or an App-authored, formula-only CI result."""

import json
import os
import re
import subprocess
from pathlib import Path


BOT = "githits-homebrew-tap-bumper[bot]"
FORMULA = "Formula/githits-scan.rb"


def select_pr(event_name, event, repository, fetch):
    """Return a PR number and immutable head SHA, or None to skip publication."""
    if event_name == "pull_request_target":
        if event["action"] != "labeled" or event["label"]["name"] != "pr-pull":
            return None
        pr = event["pull_request"]
        return pr["number"], pr["head"]["sha"]
    if event_name == "workflow_dispatch":
        number = str(event["inputs"]["pull_request"])
        if not number.isascii() or not number.isdecimal() or int(number) < 1:
            raise ValueError("Pull request must be a positive integer")
        pr = fetch(f"repos/{repository}/pulls/{number}")
        sha = event["inputs"].get("head_sha") or pr["head"]["sha"]
        if not re.fullmatch(r"[0-9a-fA-F]{40}", sha):
            raise ValueError("Expected a 40-character commit SHA")
        return int(number), sha
    if event_name != "workflow_run":
        return None
    run = event["workflow_run"]
    if run["event"] != "pull_request" or run["conclusion"] != "success":
        return None
    if run["head_repository"]["full_name"] != repository or len(run["pull_requests"]) != 1:
        return None
    number = run["pull_requests"][0]["number"]
    pr = fetch(f"repos/{repository}/pulls/{number}")
    if pr["state"] != "open" or pr["user"]["login"] != BOT or pr["changed_files"] != 1:
        return None
    if pr["base"]["ref"] != "main" or pr["head"]["sha"] != run["head_sha"]:
        return None
    if (pr["head"]["repo"] or {}).get("full_name") != repository:
        return None
    files = fetch(f"repos/{repository}/pulls/{number}/files?per_page=2")
    if len(files) != 1 or files[0]["filename"] != FORMULA or files[0]["status"] != "modified":
        return None
    return number, pr["head"]["sha"]


def fetch(path):
    """Read GitHub metadata with the read-only job token, never token arguments."""
    result = subprocess.run(["gh", "api", path], check=True, text=True, stdout=subprocess.PIPE)
    return json.loads(result.stdout)


if __name__ == "__main__":
    selected = select_pr(os.environ["GITHUB_EVENT_NAME"],
                         json.loads(Path(os.environ["GITHUB_EVENT_PATH"]).read_text()),
                         os.environ["GITHUB_REPOSITORY"], fetch)
    if selected:
        with Path(os.environ["GITHUB_OUTPUT"]).open("a") as output:
            output.write(f"number={selected[0]}\nsha={selected[1]}\n")
        print(f"Selected PR #{selected[0]} at {selected[1]}.")
    else:
        print("No eligible PR; publication skipped.")
