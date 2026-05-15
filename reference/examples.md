# Ideation Session Examples

Real examples of what great ideation sessions look like. Use these as reference for the quality bar and format expectations.

---

## Example 1: Internal Usage Analytics

### The Brief

> "We're running a pilot with 15 users. I have no idea which parts of the dashboard they actually use. I need some kind of analytics but we can't collect PII."

### HMW Framing

**How might we** understand which features drive engagement for pilot users **without** collecting any personally identifiable information?

### Sharpening Questions (and answers)

1. **Who specifically needs this data?** → Product lead and engineering manager, for weekly prioritization decisions
2. **What does success look like?** → "I can see the top 5 user paths through the dashboard and decide what to invest in next sprint"
3. **What's the PII constraint exactly?** → No user IDs, names, emails, or client data in the analytics tables. Firm-level aggregation is acceptable.
4. **What's been tried?** → Nothing. Currently relying on occasional user interviews.
5. **Why now?** → Pilot is 3 weeks in. Need to decide what to build for Phase 2 in 2 weeks.

### Variations Generated

1. **Funnel analytics** — Track section transitions (A → B → C). Shows paths, not pages. Privacy-safe.
2. **Session heatmap** — Track time-in-section. Shows where users spend time. Requires timer logic.
3. **Feature flag telemetry** — Wrap features in flags, count flag evaluations. Shows what's accessed but not how.
4. **Weekly survey bot** — Automated Slack prompt asking "what did you use this week?" Zero instrumentation needed.
5. **Log mining** — Parse existing API access logs for endpoint patterns. No new code. But noisy.
6. **Simplification: just ask** — 15 users. Schedule 5 calls. Get richer data than any analytics system. But doesn't scale.

### What Resonated

The user liked #1 (funnel analytics) and #6 (just ask). Pushed back on #2 (too complex for the value) and #4 (users won't fill out surveys).

### Stress Testing

| Direction | Value | Feasibility | Differentiation |
|-----------|-------|-------------|-----------------|
| Funnel analytics | High — directly answers "what do users do" | Medium — 2-3 days of work, fits existing stack | Low — basic analytics, but privacy-first is differentiating for the pilot |
| Just ask | High — richest qualitative data | Very high — zero code | None — everyone can do this |

### Decision

**Both.** Do the user interviews immediately (they're free). Build funnel analytics in parallel for ongoing quantitative data after interviews are done.

### What made it good:
- Clear HMW framing tied to a concrete decision ("what to build for Phase 2")
- Honest pushback: "just ask" was surfaced as a viable non-engineering solution
- The "Not Doing" list cut 4 reasonable ideas with specific reasons
- Assumptions were testable: "will the team actually look at the data?"

---

## Example 2: Configuration Management Rethink

### The Brief

> "Our app has config scattered everywhere — env vars, JSON files, database settings, feature flags in code. It's a mess. I want to clean it up."

### HMW Framing

**How might we** unify application configuration so that any setting can be found, understood, and changed in one place — without a 3-month refactor?

### Sharpening Questions (and answers)

1. **Who is affected?** → Developers (finding config), DevOps (deploying), and support (diagnosing customer-specific settings)
2. **What breaks today?** → "Last week we spent 4 hours debugging because a feature flag was set in code but overridden by an env var. Nobody knew both existed."
3. **How many config sources exist?** → 5: `.env`, `config.json`, database `settings` table, feature flags in code, and Kubernetes ConfigMaps.
4. **What's the risk appetite?** → Low. This is a production system. Can't break existing config during migration.
5. **What's the timeline?** → Want a plan in 1 week. Can execute incrementally over 2-3 sprints.

### Variations Generated

1. **Config registry** — Single source of truth that reads from all 5 sources with explicit precedence rules. Existing code doesn't change; the registry is a new layer on top.
2. **Eliminate and converge** — Pick one source (env vars) and migrate everything else to it. Brutal but simple.
3. **Config-as-code** — All config in typed files (TypeScript), validated at build time. Database and env vars are eliminated.
4. **Config service** — Microservice that serves config via API. All apps query it. Centralized but adds a dependency.
5. **Documentation-first** — Don't change the architecture. Instead, auto-generate a config inventory that shows every setting, its source, its current value, and where it's used. Fix the findability problem without touching the config itself.

### Decision

**Direction 5 (documentation-first) as Phase 1, Direction 1 (config registry) as Phase 2.**

The user realized the immediate pain is *findability*, not architecture. A config inventory solves 80% of the debugging pain in days. The registry can come later with lower risk because the inventory provides a migration roadmap.

### What made it good:
- Constraint-based thinking (#5) unlocked a simpler first step
- Pre-mortem on #2 revealed it would break 3 deployment scripts
- The decision was phased — solve the urgent problem first, then the systemic one
- "Just document it" was initially dismissed as "not a real solution" until the stress test showed it solved the actual pain point (debugging time)

---

## Patterns to Notice

As you accumulate sessions, look for:
- **Which frameworks unlock the best thinking for your domain?** HMW and constraint-based thinking tend to be the most universally useful. SCAMPER works better for improving existing products. First Principles works best when everyone is stuck in conventional thinking.
- **Where do you tend to get stuck?** If every ideation session stalls at "but we can't because...", you need more constraint-removal thinking. If sessions produce too many options, you need sharper convergence criteria.
- **What types of "Not Doing" items keep coming back?** If the same idea keeps appearing on the "Not Doing" list across multiple sessions, maybe it should be doing. Track these.
- **When does "just ask the user" win?** For small user bases (< 50), direct conversation almost always beats instrumentation. Don't over-engineer data collection when you can just talk to people.
