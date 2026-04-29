Our architecture looked perfect on paper.

Then we audited it. 40% was fiction.

Beautiful documentation. Honor-system enforcement. The kind of system that works until someone is under deadline pressure at 2am.

We walked through 11 of 12 deployment steps. Checked every control. Found 4 critical holes that could have destroyed production data.

Here's what broke and what we built to fix it:

1/ Git Force-Push Bypass

Developers could force-push to protected branches using a specific SSH key. Not blocked. Not monitored. Not even logged.

→ Fix: GitHub branch protection hook that reads our SSH key registry
→ No key in registry = no push, period

2/ Supabase MCP: Zero SQL Protection

Our AI agent could write any SQL query it wanted. No validation. No parameterization. One typo away from deleting the production database.

→ Fix: Parameterized all Supabase queries
→ Added SQL validator in Claude Code
→ Zero raw SQL in agent execution

3/ Missing Secret Scanner

We had a secrets detection rule in CLAUDE.md. Nobody enforced it. Git hooks did not scan for API keys, tokens, or credentials.

→ Fix: Built git pre-commit hook using gitleaks + custom patterns
→ Scans every commit, blocks on match
→ Added a False Positive Dashboard so the team can tune it

4/ No Deployment Audit Trail

We documented who could deploy. We never logged what got deployed, when, or by what process.

→ Fix: Deployment cron job via Tailscale mesh and GitHub API
→ Logs every deploy: who, what, when, success or fail

The hard truth: documentation without enforcement is corporate fiction.

You can write the most beautiful architecture guide. It does not matter if nobody follows it when the CEO says "ship this now."

We went from "you must follow these patterns" to "your system will not let you break these patterns."

Compliance jumped from 70% to 100%.

DM me "AUDIT" and I'll send you the exact checklist we used to find our 4 critical gaps.

P.S. When was the last time you audited what's actually enforced vs. what's just documented?
