#!/bin/bash
# GitHub drift detector — branch protection intact? canonical topics? stale branches?
# Runs daily on Mamoun's Mac via launchd or cron.
set +e
WEBHOOK="https://flow.smorchestra.ai/webhook/github-drift"
TS=$(date -u +%FT%TZ)
DRIFT=()

REPOS=(
  SMOrchestra-ai/smorch-dev SMOrchestra-ai/smorch-brain SMOrchestra-ai/Signal-Sales-Engine
  SMOrchestra-ai/smorchestra-web SMOrchestra-ai/contabo-mcp-server SMOrchestra-ai/eo-microsaas-plugin
  SMOrchestra-ai/eo-mena SMOrchestra-ai/smorch-dist SMOrchestra-ai/gtm-fitness-scorecard
  SMOrchestra-ai/digital-revenue-score SMOrchestra-ai/content-automation SMOrchestra-ai/EO-Scorecard-Platform
  SMOrchestra-ai/SaaSFast SMOrchestra-ai/super-ai-agent SMOrchestra-ai/smorch-context
  smorchestraai-code/eo-microsaas-training
)

for repo in "${REPOS[@]}"; do
  # Default branch = main?
  DEF=$(gh api "repos/$repo" --jq .default_branch 2>/dev/null)
  [ "$DEF" != "main" ] && DRIFT+=("$repo:default-$DEF")
  
  # Branch protection on main
  PROTECT=$(gh api "repos/$repo/branches/main/protection" --jq .required_pull_request_reviews.required_approving_review_count 2>/dev/null)
  [ -z "$PROTECT" ] && DRIFT+=("$repo:no-main-protection")
  
  # Has 3 canonical topics? (domain + status-* + distribution-*)
  TOPICS=$(gh api "repos/$repo" --jq '.topics | @csv' 2>/dev/null)
  echo "$TOPICS" | grep -qE "(smo|eo|shared|external-fork)" || DRIFT+=("$repo:missing-domain-topic")
  echo "$TOPICS" | grep -qE "status-(production|beta|dev|archived)" || DRIFT+=("$repo:missing-lifecycle-topic")
  echo "$TOPICS" | grep -qE "distribution-(internal|customer|fork)" || DRIFT+=("$repo:missing-distribution-topic")
done

# Dependabot alerts count across org
CRIT=$(gh api "orgs/SMOrchestra-ai/dependabot/alerts?state=open&severity=critical" --jq 'length' 2>/dev/null || echo 0)
[ "$CRIT" -gt 0 ] && DRIFT+=("dependabot-critical:$CRIT")

SEVERITY="info"
[ ${#DRIFT[@]} -gt 0 ] && SEVERITY="warn"

PAYLOAD=$(printf '{"ts":"%s","severity":"%s","drift":[%s]}' \
  "$TS" "$SEVERITY" "$(printf '"%s",' "${DRIFT[@]}" | sed 's/,$//')")
curl -s --max-time 10 -X POST "$WEBHOOK" -H 'Content-Type: application/json' -d "$PAYLOAD" >/dev/null 2>&1
LOGFILE="$HOME/.claude/logs/github-drift.log"
mkdir -p "$(dirname "$LOGFILE")"
echo "$TS $SEVERITY ${#DRIFT[@]} ${DRIFT[*]}" >> "$LOGFILE"
