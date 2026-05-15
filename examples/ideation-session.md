# Internal Usage Analytics

## Problem Statement
How might we understand which features in our dashboard actually drive user engagement, so we can focus development effort on what matters — without collecting any personally identifiable information?

## Target User
Product team leads and engineering managers at a B2B SaaS company running an internal pilot, who need to make data-driven decisions about feature investment with limited user feedback channels.

## Recommended Direction
**Privacy-first funnel analytics**: Instrument the dashboard to track anonymous section transitions (e.g., "user navigated from Overview → Client Detail → Recommendations") using a lightweight event pipeline. Events contain only section identifiers and timestamps — no user IDs, names, or client data. Data is aggregated daily and retained for 90 days.

This direction won because:
- It answers the core question ("which features matter") without touching PII
- It's feasible within the existing stack (API endpoint + simple table)
- It provides differentiation from basic page-view analytics by capturing *flow*, not just *visits*

## Key Assumptions to Validate
- [ ] Section transitions are a meaningful proxy for engagement (vs. time-on-page or click depth). **Test**: Compare transition data against qualitative user feedback for 2 weeks.
- [ ] 90-day retention is sufficient for trend detection. **Test**: Run sample queries against synthetic data to see if seasonal patterns emerge in the window.
- [ ] The team will actually look at the data. **Test**: Schedule a weekly 15-min review for the first month. If no one shows up, the feature doesn't matter.

## MVP Scope
**In scope:**
- Event table with firm-scoped isolation (row-level security)
- API endpoint for event ingestion (section_from, section_to, timestamp)
- Dashboard instrumentation for 4 main section transitions
- Simple aggregate query: top 10 paths by frequency

**Out of scope:**
- Real-time analytics dashboard (batch is fine for MVP)
- Funnel visualization (table of numbers is sufficient)
- Historical backfill (start fresh)
- User segmentation (no user identity in the data model)

## Not Doing (and Why)
- **Click heatmaps** — Requires DOM instrumentation, adds bundle size, and answers a different question (where do users click) vs. what we need (what do users do)
- **Session recording** — PII risk is too high. Even "anonymous" recordings can contain client data visible on screen.
- **A/B testing framework** — Premature. We don't have enough users for statistical significance. When we do, this becomes a separate feature.
- **Custom event tracking SDK** — Over-engineering. A single `POST /api/telemetry/events` endpoint is sufficient for MVP.
- **Export/download** — Nobody asked for it. Don't build export until someone needs to put this data somewhere else.

## Open Questions
- What's the right granularity for section transitions? Per-page, per-tab, or per-component?
- Should we track "time in section" or just transitions? Time adds complexity but may be more useful.

## Explored Directions

**Direction A: Full-stack analytics platform** — Build a complete analytics system with dashboards, funnels, and cohort analysis. Rejected: over-engineered for a pilot with <20 users. Would take 2 sprints instead of 2 days.

**Direction B: Third-party analytics** — Use Mixpanel, Amplitude, or PostHog. Rejected: PII risk with sending data to third parties during pilot. Also, another vendor dependency.

**Direction C: Privacy-first funnel analytics** ← *Selected*. Right-sized for the problem. Answers the question. No PII. Buildable in days.
