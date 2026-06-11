#!/usr/bin/env python3

import argparse
import base64
import json
import os
import sys
import urllib.request
import urllib.parse


RATINGS = {
    "1": "A",
    "2": "B",
    "3": "C",
    "4": "D",
    "5": "E",
}


LABELS = {
    "new_coverage": "Coverage",
    "new_duplicated_lines_density": "Duplications",
    "new_maintainability_rating": "Maintainability Rating",
    "new_reliability_rating": "Reliability Rating",
    "new_security_rating": "Security Rating",
    "new_security_hotspots_reviewed": "Security Hotspots Reviewed",
}


def icon(status: str) -> str:
    return "✅" if status == "OK" else "❌"


def fetch_quality_gate(project_key: str, branch: str, token: str) -> dict:
    query = urllib.parse.urlencode({
        "projectKey": project_key,
        "branch": branch,
    })

    url = f"https://sonarcloud.io/api/qualitygates/project_status?{query}"

    auth = base64.b64encode(f"{token}:".encode()).decode()

    request = urllib.request.Request(
        url,
        headers={
            "Authorization": f"Basic {auth}",
            "Accept": "application/json",
        },
    )

    with urllib.request.urlopen(request, timeout=30) as response:
        return json.loads(response.read().decode())


def format_condition(condition: dict) -> str:
    metric = condition.get("metricKey")
    status = condition.get("status")
    actual = condition.get("actualValue", "n/a")
    threshold = condition.get("errorThreshold", "n/a")

    if metric == "new_coverage":
        return f"Coverage >= {threshold}%                {icon(status)} actual={actual}%"

    if metric == "new_duplicated_lines_density":
        return f"Duplications <= {threshold}%             {icon(status)} actual={actual}%"

    if metric == "new_maintainability_rating":
        rating = RATINGS.get(str(actual), actual)
        return f"Maintainability Rating = A     {icon(status)} actual={rating}"

    if metric == "new_reliability_rating":
        rating = RATINGS.get(str(actual), actual)
        return f"Reliability Rating = A         {icon(status)} actual={rating}"

    if metric == "new_security_rating":
        rating = RATINGS.get(str(actual), actual)
        return f"Security Rating = A            {icon(status)} actual={rating}"

    if metric == "new_security_hotspots_reviewed":
        return f"Security Hotspots Reviewed     {icon(status)} actual={actual}%"

    label = LABELS.get(metric, metric)
    return f"{label}: {status} actual={actual} threshold={threshold}"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-key", required=True)
    parser.add_argument("--branch", required=True)
    args = parser.parse_args()

    token = os.getenv("SONAR_TOKEN")
    if not token:
        print("ERROR: SONAR_TOKEN environment variable is missing.", file=sys.stderr)
        return 1

    data = fetch_quality_gate(args.project_key, args.branch, token)

    project_status = data.get("projectStatus", {})
    status = project_status.get("status", "UNKNOWN")
    conditions = project_status.get("conditions", [])

    print("========================================")
    print("SONARQUBE QUALITY GATE")
    print("========================================")
    print(f"QUALITY GATE STATUS: {status}")
    print("")

    if not conditions:
        print("No Quality Gate conditions returned.")
    else:
        for condition in conditions:
            print(format_condition(condition))

    print("========================================")

    return 0 if status == "OK" else 1


if __name__ == "__main__":
    raise SystemExit(main())