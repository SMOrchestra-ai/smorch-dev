44 Claude Code practices.
17 implemented in one session.
9 were useless in our context.

Most teams using Claude Code are running theater. Beautiful CLAUDE.md files. Rules everyone reads. Rules nobody enforces.

Especially under deadline pressure.

I watched Vishwas's Claude Code tips video. 50 ideas. Scored every single one against our actual architecture. Here's what survived and what we built on top of it:

1/ The Enforcement Hierarchy

CLAUDE.md = suggestions (~80% compliance)
Git hooks = requirements (90% compliance)
GitHub branch protection = near-unbreakable (99.9%)
System-level blockers = 100% compliance

The difference between a suggestion and a requirement is enforcement. We rebuilt our entire stack around this.

2/ What We Actually Enforce

→ Conventional commits via GitHub branch protection (no semantic versioning = PR blocks)
→ Prettier formatting locked in pre-commit hook (commit fails locally if violated)
→ CLAUDE.md compliance hook reads rules, validates every commit
→ Destructive command blocker: rm -rf in automation = blocked at CI/CD
→ Secret scanner: gitleaks + custom patterns on every push
→ Namespace separation: human/ prefix for human work, agent/ for AI-generated

3/ The Breakthrough Moment

I stopped asking "did people follow the rules?"

Started asking "did the system let them break the rules?"

Old way: "Everyone should use conventional commits." Result: 70% compliance. PRs with messages like "fix stuff" slipped through.

New way: GitHub hook rejects any commit that does not match the pattern. Engineer literally cannot push a bad commit.

Result: 100% compliance. Setup cost: 2 hours. Enforcement cost: zero.

4/ Why This Matters at 3am

"We have good discipline" is not a business continuity plan. Discipline breaks under deadline pressure, staffing changes, new engineer onboarding, and 3am emergency deploys.

A system that forces the right behavior works at 3am. Works with a new team member who has not read the wiki. Works when you are panicking.

Setup: 40 hours across 2 weeks.
Maintenance: 5 hours per month.
Alternative: 8-16 hours per month of human enforcement work.

The teams winning with Claude Code are not the ones with the best documentation. They are the ones with the best hooks.

DM me "HOOKS" and I'll send you the enforcement hierarchy template we use to convert suggestions into requirements.

P.S. How many of your CLAUDE.md rules are actually enforced by hooks right now?
