#!/usr/bin/env bash

set -euo pipefail

PROJECT_KEY="${1:?PROJECT_KEY is required}"
BRANCH="${2:?BRANCH is required}"
SONAR_HOST_URL="${SONAR_HOST_URL:-https://sonarcloud.io}"

if [ -z "${SONAR_TOKEN:-}" ]; then
  echo "SONAR_TOKEN environment variable is required"
  exit 1
fi

RESPONSE=$(curl -s -u "$SONAR_TOKEN:" \
  "$SONAR_HOST_URL/api/qualitygates/project_status?projectKey=$PROJECT_KEY&branch=$BRANCH")

STATUS=$(echo "$RESPONSE" | jq -r '.projectStatus.status')

MEASURES_RESPONSE=$(curl -s -u "$SONAR_TOKEN:" \
  "$SONAR_HOST_URL/api/measures/component?component=$PROJECT_KEY&branch=$BRANCH&metricKeys=coverage,duplicated_lines_density,reliability_rating,security_rating,sqale_rating,security_hotspots_reviewed")

echo ""
echo "========================================"
echo "SONARQUBE QUALITY GATE"
echo "========================================"

if [ "$STATUS" = "OK" ]; then
  echo "STATUS                         ✅ PASSED"
else
  echo "STATUS                         ❌ FAILED"
fi

echo ""
echo "----------------------------------------"
echo "NEW CODE"
echo "----------------------------------------"

echo "$RESPONSE" | jq -r '
  .projectStatus.conditions[]
  | if .metricKey == "new_reliability_rating" then
      "Reliability                    " + (if .status == "OK" then "✅ A" else "❌ FAILED" end)

    elif .metricKey == "new_security_rating" then
      "Security                       " + (if .status == "OK" then "✅ A" else "❌ FAILED" end)

    elif .metricKey == "new_maintainability_rating" then
      "Maintainability                " + (if .status == "OK" then "✅ A" else "❌ FAILED" end)

    elif .metricKey == "new_security_hotspots_reviewed" then
      "Security Hotspots              " + (if .status == "OK" then "✅ " else "❌ " end) + (.actualValue // "n/a") + "%"

    else
      empty
    end
'

echo ""
echo "----------------------------------------"
echo "OVERALL CODE"
echo "----------------------------------------"

echo "$MEASURES_RESPONSE" | jq -r '
  def value($metric):
    (.component.measures[]? | select(.metric == $metric) | .value) // "n/a";

  def rating($metric):
    if value($metric) == "1.0" or value($metric) == "1" then "A"
    elif value($metric) == "2.0" or value($metric) == "2" then "B"
    elif value($metric) == "3.0" or value($metric) == "3" then "C"
    elif value($metric) == "4.0" or value($metric) == "4" then "D"
    elif value($metric) == "5.0" or value($metric) == "5" then "E"
    else value($metric)
    end;

  "Coverage                       " + value("coverage") + "%",
  "Duplications                   " + value("duplicated_lines_density") + "%",
  "Reliability                    " + rating("reliability_rating"),
  "Security                       " + rating("security_rating"),
  "Maintainability                " + rating("sqale_rating"),
  "Security Hotspots              " + value("security_hotspots_reviewed") + "%"
'

echo "========================================"

if [ "$STATUS" != "OK" ]; then
  echo "Quality Gate failed"
  exit 1
fi