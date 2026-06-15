#!/usr/bin/env bash

set -euo pipefail

PROJECT_KEY="${1:?PROJECT_KEY is required}"
BRANCH="${2:?BRANCH is required}"
APPLICATION_NAME="${3:?APPLICATION_NAME is required}"
SONAR_HOST_URL="${SONAR_HOST_URL:-https://sonarcloud.io}"

if [ -z "${SONAR_TOKEN:-}" ]; then
  echo "SONAR_TOKEN environment variable is required"
  exit 1
fi

RESPONSE=$(curl -s -u "$SONAR_TOKEN:" \
  "$SONAR_HOST_URL/api/qualitygates/project_status?projectKey=$PROJECT_KEY&branch=$BRANCH")

STATUS=$(echo "$RESPONSE" | jq -r '.projectStatus.status')

METRICS="\
alert_status,quality_gate_details,\
violations,blocker_violations,critical_violations,major_violations,minor_violations,info_violations,\
new_violations,new_blocker_violations,new_critical_violations,new_major_violations,new_minor_violations,new_info_violations,\
bugs,reliability_rating,new_bugs,new_reliability_rating,\
code_smells,sqale_rating,new_code_smells,\
duplicated_lines,new_duplicated_lines,\
coverage,lines_to_cover,uncovered_lines,branch_coverage,new_coverage,new_lines_to_cover,new_uncovered_lines,new_branch_coverage,\
vulnerabilities,security_rating,security_remediation_effort,new_vulnerabilities,new_security_rating,new_security_remediation_effort,\
security_review_rating,new_security_review_rating,\
complexity,cognitive_complexity, new_complexity,new_cognitive_complexity"

# Fetch metrics for both overall and new code
METRICS_RESPONSE=$(curl -s -u "$SONAR_TOKEN:" \
  "$SONAR_HOST_URL/api/measures/component?component=$PROJECT_KEY&branch=$BRANCH&metricKeys=$METRICS")

echo ""
echo "========================================"
echo "SONARQUBE QUALITY GATE"
echo "Application: ${APPLICATION_NAME}"
echo "========================================"
echo ""

if [ "$STATUS" = "OK" ]; then
  echo "STATUS                         ✅ PASSED"
else
  echo "STATUS                         ❌ FAILED"
fi

echo ""
echo "----------------------------------------"
echo " NEW CODE"
echo "----------------------------------------"

echo "$METRICS_RESPONSE" | jq -r '
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

  "",
  "Reliability          : " + rating("new_reliability_rating"),
  "Maintainability      : " + rating("new_sqale_rating"),
  "",
  "Violations           : " + value("new_violations"),
  "  Blocker            : " + value("new_blocker_violations"),
  "  Critical           : " + value("new_critical_violations"),
  "  Major              : " + value("new_major_violations"),
  "  Minor              : " + value("new_minor_violations"),
  "  Info               : " + value("new_info_violations"), 
  "",
  "  Bugs               : " + value("new_bugs"),
  "  Code Smells        : " + value("new_code_smells"),
  "  Duplicated Lines   : " + value("new_duplicated_lines"),
  "",
  "Coverage             : " + value("new_coverage") + "%",
  " Lines to cover      : " + value("new_lines_to_cover"),
  " Uncovered lines     : " + value("new_uncovered_lines"),
  " Branch coverage     : " + value("new_branch_coverage"),
  "",
  "Complexity           : " + value("new_complexity"),
  "Cognitive complexity : " + value("new_cognitive_complexity"),
  "",
  "Security             : " + rating("new_security_rating"),
  " Vulnerabilities     : " + value("new_vulnerabilities"),
  " Remediation Effort  : " + value("new_security_remediation_effort") + "mn",
  "",
  "Security Hotspots    : " + rating("new_security_review_rating"),
  "" 
'

echo ""
echo "----------------------------------------"
echo " OVERALL"
echo "----------------------------------------"

echo "$METRICS_RESPONSE" | jq -r '
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

  "",
  "Reliability         : " + rating("reliability_rating"),
  "Maintainability     : " + rating("sqale_rating"),
  "",
  "Violations          : " + value("violations"),
  "  Blocker           : " + value("blocker_violations"),
  "  Critical          : " + value("critical_violations"),
  "  Major             : " + value("major_violations"),
  "  Minor             : " + value("minor_violations"),
  "  Info              : " + value("info_violations"), 
  "",
  "  Bugs              : " + value("bugs"),
  "  Code Smells       : " + value("code_smells"),
  "  Duplicated Lines  : " + value("duplicated_lines"),
  "",
  "Coverage            : " + value("coverage") + "%",
  " Lines to cover     : " + value("lines_to_cover"),
  " Uncovered lines    : " + value("uncovered_lines"),
  " Branch coverage    : " + value("branch_coverage"),
  "",
  "Complexity           : " + value("new_complexity"),
  "Cognitive complexity : " + value("new_cognitive_complexity"),
  "",
  "Security            : " + rating("security_rating"),
  " Vulnerabilities    : " + value("vulnerabilities"),
  " Remediation Effort : " + value("security_remediation_effort") + "mn",
  "",
  "Security Hotspots   : " + rating("security_review_rating"),
  "" 
'

echo "========================================"
echo ""

if [ "$STATUS" != "OK" ]; then
  echo "Quality Gate failed"
  exit 1
fi