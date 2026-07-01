import sys
import requests
from datetime import datetime, timezone

GITHUB_TOKEN = sys.argv[1]
OWNER = sys.argv[2]
REPO = sys.argv[3]
SHA = sys.argv[4]

headers = {
    "Authorization": f"Bearer {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json",
}


def github_get(url: str):
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()


def get_mr_from_commit(deployment_sha: str):
    
    response = github_get(
        f"https://api.github.com/repos/{OWNER}/{REPO}/commits/{deployment_sha}/pulls"
    )

    if not response:
        return None

    mr = response[0]

    print()
    print(f"MR trouvée : #{mr['number']} - {mr['merge_commit_sha'][:7]} - {mr['merged_at']} - {mr['title']}")

    return mr


def get_all_commits_from_mr(pr_number: int):
    
    commits = github_get(
        f"https://api.github.com/repos/{OWNER}/{REPO}/pulls/{pr_number}/commits"
    )

    if not commits:
        return []

    print()
    print(f"{len(commits)} commit(s) trouvé(s) dans la MR #{pr_number} :")

    for commit in commits:
        commit_date = commit["commit"]["committer"]["date"]
        message = commit["commit"]["message"].splitlines()[0]

        print(f"- {commit['sha'][:7]} | {commit_date} | {message}")

    return commits


def get_first_commit_date_from_commits(commits) -> datetime:
    
    commit_dates = [
        datetime.fromisoformat(
            commit["commit"]["committer"]["date"].replace("Z", "+00:00")
        )
        for commit in commits
    ]

    return min(commit_dates)

def get_mr_commit_date(commit_sha: str) -> datetime:
    commit = github_get(
        f"https://api.github.com/repos/{OWNER}/{REPO}/commits/{commit_sha}"
    )

    return datetime.fromisoformat(
        commit["commit"]["committer"]["date"].replace("Z", "+00:00")
    )

def dora_calculate_lead_time(token: str, owner: str, repo: str, deployment_sha: str) -> float | None:
    
    mr = get_mr_from_commit(deployment_sha)

    if mr is None:
        print("Aucune MR associée à ce SHA.")
        return None

    commits = get_all_commits_from_mr(mr["number"])

    if not commits:
        print(f"Aucun commit trouvé pour la MR #{mr['number']}.")
        return None

    first_commit_date = get_first_commit_date_from_commits(commits)

    deployed_at = get_mr_commit_date(deployment_sha)

    lead_time_hours = (deployed_at - first_commit_date).total_seconds() / 3600

    print()
    print(f"SHA               : {deployment_sha}")
    print(f"MR                : #{mr['number']}")
    print(f"Premier commit    : {first_commit_date.isoformat()}")
    print(f"Déploiement/merge : {deployed_at.isoformat()}")
    
    lead_time_seconds = (deployed_at - first_commit_date).total_seconds()
    lead_time_minutes = lead_time_seconds / 60
    lead_time_hours = lead_time_minutes / 60
    print(f"Lead time         : {lead_time_minutes:.1f} min ({lead_time_hours:.2f} h)")
    print(f"{lead_time_seconds:.0f}")
    
    return lead_time_hours

dora_calculate_lead_time(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])


# if __name__ == "__main__":
#     import sys

#     if len(sys.argv) != 2:
#         sys.exit(1)

#     lead_time = calculate_lead_time(sys.argv[1])

#     if lead_time is not None:
#         print(lead_time)