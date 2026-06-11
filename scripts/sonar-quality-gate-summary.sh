#!/usr/bin/env bash

set -euo pipefail

PROJECT_KEY="${1:?PROJECT_KEY is required}"
BRANCH="${2:?BRANCH is required}"

echo "========================================"
echo "SONARQUBE QUALITY GATE"
echo "========================================"

RESPONSE=$(curl -s -u "$SONAR_TOKEN:" \
  "https://sonarcloud.io/api/qualitygates/project_status?projectKey=$PROJECT_KEY&branch=$BRANCH")

STATUS=$(echo "$RESPONSE" | jq -r '.projectStatus.status')

echo "QUALITY GATE STATUS: $STATUS"
echo ""

echo "$RESPONSE" | jq -r '
  .projectStatus.conditions[]
  | if .metricKey == "new_coverage" then
      "Coverage >= " + .errorThreshold + "%                " + 
      (if .status == "OK" then "✅" else "❌" end) + 
      " actual=" + (.actualValue // "n/a") + "%"

    elif .metricKey == "new_duplicated_lines_density" then
      "Duplications <= " + .errorThreshold + "%             " + 
      (if .status == "OK" then "✅" else "❌" end) + 
      " actual=" + (.actualValue // "n/a") + "%"
    
    elif .metricKey == "new_maintainability_rating" then
      "Maintainability Rating = A     " + 
      (if .status == "OK" then "✅" else "❌" end)
    
    elif .metricKey == "new_reliability_rating" then
      "Reliability Rating = A         " + 
      (if .status == "OK" then "✅" else "❌" end)
    
    elif .metricKey == "new_security_rating" then
      "Security Rating = A            " + 
      (if .status == "OK" then "✅" else "❌" end)
    
    elif .metricKey == "new_security_hotspots_reviewed" then
      "Security Hotspots Reviewed     " + 
      (if .status == "OK" then "✅" else "❌" end) + 
      " actual=" + (.actualValue // "n/a") + "%"
    
    else
      empty
    end
'

echo "========================================"

if [ "$STATUS" != "OK" ]; then
  echo "Quality Gate failed"
  exit 1
fi