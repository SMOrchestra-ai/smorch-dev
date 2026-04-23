#!/bin/bash
# Phase 1 GitHub SSoT Apply — idempotent, dry-run by default
# Usage: ./phase-1-apply.sh [--apply]  (omit --apply for dry run)
set -e

DRY_RUN=1
[ "$1" = "--apply" ] && DRY_RUN=0

say() { echo "[$( [ $DRY_RUN -eq 1 ] && echo DRY || echo APPLY )] $*"; }

# ========= Canonical topics per repo =========
# Format: owner/repo:tag1,tag2,tag3,...

declare -A TOPICS=(
  # SMOrchestra-ai
  ["SMOrchestra-ai/smorch-dev"]="smo,status-dev,distribution-internal,ai-native,claude-code,plugins"
  ["SMOrchestra-ai/smorch-brain"]="smo,status-dev,distribution-internal,ai-native,claude-code,registry,skills"
  ["SMOrchestra-ai/Signal-Sales-Engine"]="smo,status-beta,distribution-internal,b2b,outbound,signal-intelligence,smorchestra"
  ["SMOrchestra-ai/smorchestra-web"]="smo,status-production,distribution-internal,smorchestra"
  ["SMOrchestra-ai/contabo-mcp-server"]="eo,status-dev,distribution-internal,contabo,mcp,vps,infrastructure"
  ["SMOrchestra-ai/eo-microsaas-plugin"]="eo,status-production,distribution-customer"
  ["SMOrchestra-ai/eo-mena"]="eo,status-production,distribution-internal,arabic,mena,training"
  ["SMOrchestra-ai/smorch-dist"]="smo,status-dev,distribution-internal,ai-native,claude-code,plugins,distribution"
  ["SMOrchestra-ai/gtm-fitness-scorecard"]="smo,status-production,distribution-internal,gtm,lead-magnet,nextjs,scoring"
  ["SMOrchestra-ai/digital-revenue-score"]="smo,status-production,distribution-internal,assessment,b2b,mena,revenue"
  ["SMOrchestra-ai/content-automation"]="smo,status-dev,distribution-internal,ai-native,automation,content,smorchestra"
  ["SMOrchestra-ai/EO-Scorecard-Platform"]="eo,status-beta,distribution-customer,assessment,scoring,saasfast"
  ["SMOrchestra-ai/SaaSFast"]="shared,status-dev,distribution-internal,saas,saasfast,nextjs,supabase,rtl,arabic"
  ["SMOrchestra-ai/super-ai-agent"]="smo,status-dev,distribution-internal,ai-agent,automation,claude-sdk,smorchestra"
  ["SMOrchestra-ai/smorch-context"]="smo,status-dev,distribution-internal,ai-native,context,project-brain,smorchestra"
  # smorchestraai-code
  ["smorchestraai-code/eo-microsaas-training"]="eo,status-production,distribution-customer,training"
  ["smorchestraai-code/SaaSfast-Page-Online"]="eo,status-production,distribution-customer,nextjs,saasfast,product-site"
  ["smorchestraai-code/SSE-latest"]="smo,status-archived,b2b,signal-intelligence,smorchestra,archived"
  ["smorchestraai-code/SaaSfast-ar"]="eo,status-archived,archived"
  ["smorchestraai-code/eo-dashboard"]="eo,status-archived,dashboard,nextjs,supabase,archived"
  ["smorchestraai-code/ssh-mcp-server"]="eo,status-archived,infrastructure,mcp,ssh,archived"
  ["smorchestraai-code/supervibes"]="external-fork,status-dev,distribution-fork,ai-native,claude-code,orchestration"
  ["smorchestraai-code/gstack"]="external-fork,status-dev,distribution-fork,ai-native,claude-code"
  ["smorchestraai-code/paperclip"]="external-fork,status-dev,distribution-fork,orchestration"
  ["smorchestraai-code/superpowers"]="external-fork,status-dev,distribution-fork,ai-native,skills"
  ["smorchestraai-code/Signal-Sales-Engine-v1"]="smo,status-archived,scraping,signals,archived"
  ["smorchestraai-code/Signal-Based-"]="smo,status-archived,archived"
)

# ========= Active repos needing branch protection =========
# Skip: external-fork, status-archived
ACTIVE_REPOS=(
  "SMOrchestra-ai/smorch-dev"
  "SMOrchestra-ai/smorch-brain"
  "SMOrchestra-ai/Signal-Sales-Engine"
  "SMOrchestra-ai/smorchestra-web"
  "SMOrchestra-ai/contabo-mcp-server"
  "SMOrchestra-ai/eo-microsaas-plugin"
  "SMOrchestra-ai/eo-mena"
  "SMOrchestra-ai/smorch-dist"
  "SMOrchestra-ai/gtm-fitness-scorecard"
  "SMOrchestra-ai/digital-revenue-score"
  "SMOrchestra-ai/content-automation"
  "SMOrchestra-ai/EO-Scorecard-Platform"
  "SMOrchestra-ai/SaaSFast"
  "SMOrchestra-ai/super-ai-agent"
  "SMOrchestra-ai/smorch-context"
  "smorchestraai-code/eo-microsaas-training"
  "smorchestraai-code/SaaSfast-Page-Online"
)

# ========= Repos that need main created FROM dev =========
NEEDS_MAIN_FROM_DEV=(
  "SMOrchestra-ai/contabo-mcp-server"
  "SMOrchestra-ai/digital-revenue-score"
)

# ========= Repos that need dev created FROM main =========
NEEDS_DEV_FROM_MAIN=(
  "SMOrchestra-ai/smorch-dev"
  "SMOrchestra-ai/smorchestra-web"
  "SMOrchestra-ai/eo-microsaas-plugin"
  "SMOrchestra-ai/smorch-dist"
  "SMOrchestra-ai/super-ai-agent"
  "smorchestraai-code/eo-microsaas-training"
  "smorchestraai-code/SaaSfast-Page-Online"
)

# ========= Repos needing default branch flip dev → main =========
FLIP_DEFAULT_TO_MAIN=(
  "SMOrchestra-ai/smorch-brain"
  "SMOrchestra-ai/contabo-mcp-server"
  "SMOrchestra-ai/eo-mena"
  "SMOrchestra-ai/digital-revenue-score"
  "SMOrchestra-ai/content-automation"
  "SMOrchestra-ai/EO-Scorecard-Platform"
  "SMOrchestra-ai/SaaSFast"
  "SMOrchestra-ai/smorch-context"
)

# ========= STEP 1: Apply topics (idempotent) =========
say "STEP 1 — Apply canonical topics"
for repo in "${!TOPICS[@]}"; do
  IFS=',' read -ra TAGS <<< "${TOPICS[$repo]}"
  args=""
  for t in "${TAGS[@]}"; do args="$args --add-topic $t"; done
  if [ $DRY_RUN -eq 1 ]; then
    say "  $repo: ${TOPICS[$repo]}"
  else
    gh repo edit "$repo" $args 2>&1 | tail -1
  fi
done

# ========= STEP 2: Create missing main branches from dev =========
say ""
say "STEP 2 — Create missing main from dev"
for repo in "${NEEDS_MAIN_FROM_DEV[@]}"; do
  if [ $DRY_RUN -eq 1 ]; then
    say "  $repo: would create main from dev"
  else
    SHA=$(gh api repos/$repo/git/refs/heads/dev --jq '.object.sha' 2>/dev/null)
    [ -z "$SHA" ] && { say "  $repo: dev SHA not found, skip"; continue; }
    gh api repos/$repo/git/refs --method POST -f ref="refs/heads/main" -f sha="$SHA" 2>&1 | head -5
  fi
done

# ========= STEP 3: Create missing dev branches from main =========
say ""
say "STEP 3 — Create missing dev from main"
for repo in "${NEEDS_DEV_FROM_MAIN[@]}"; do
  if [ $DRY_RUN -eq 1 ]; then
    say "  $repo: would create dev from main"
  else
    SHA=$(gh api repos/$repo/git/refs/heads/main --jq '.object.sha' 2>/dev/null)
    [ -z "$SHA" ] && { say "  $repo: main SHA not found, skip"; continue; }
    gh api repos/$repo/git/refs --method POST -f ref="refs/heads/dev" -f sha="$SHA" 2>&1 | head -5
  fi
done

# ========= STEP 4: Flip default branch dev → main =========
say ""
say "STEP 4 — Flip default branch dev → main"
for repo in "${FLIP_DEFAULT_TO_MAIN[@]}"; do
  if [ $DRY_RUN -eq 1 ]; then
    say "  $repo: would flip default to main"
  else
    gh repo edit "$repo" --default-branch main 2>&1 | tail -1
  fi
done

# ========= STEP 5: Apply branch protection =========
say ""
say "STEP 5 — Apply branch protection (main + dev on active repos)"

PROTECTION_MAIN='{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "restrictions": null,
  "required_conversation_resolution": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}'

PROTECTION_DEV='{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "restrictions": null,
  "required_conversation_resolution": false,
  "allow_force_pushes": false,
  "allow_deletions": false
}'

for repo in "${ACTIVE_REPOS[@]}"; do
  for br in main dev; do
    if [ $DRY_RUN -eq 1 ]; then
      say "  $repo/$br: would apply protection"
    else
      body=$PROTECTION_MAIN
      [ "$br" = "dev" ] && body=$PROTECTION_DEV
      echo "$body" | gh api -X PUT "repos/$repo/branches/$br/protection" --input - 2>&1 | head -3 || say "  $repo/$br: skip (branch missing)"
    fi
  done
done

say ""
say "STEP 6 — Archive flag verification (no action, just report)"
for repo in "smorchestraai-code/SSE-latest" "smorchestraai-code/SaaSfast-ar" "smorchestraai-code/eo-dashboard" "smorchestraai-code/ssh-mcp-server" "smorchestraai-code/Signal-Sales-Engine-v1" "smorchestraai-code/Signal-Based-"; do
  ARCH=$(gh repo view "$repo" --json isArchived --jq '.isArchived')
  say "  $repo: archived=$ARCH"
done

say ""
say "DONE. Run with --apply to execute."
