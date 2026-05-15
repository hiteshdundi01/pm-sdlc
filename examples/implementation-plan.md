# Plan: Internal Funnel Analytics

## Summary

Add anonymous section-transition tracking to the dashboard. Events are ingested via a new API endpoint, stored in a firm-scoped table with RLS, and queryable via a simple aggregation. No PII is collected — events contain only section identifiers and timestamps.

## User Story

As a product team lead
I want to see which dashboard sections users navigate between
So that I can prioritize feature development based on actual usage patterns

## Metadata

| Field | Value |
|-------|-------|
| Type | NEW_CAPABILITY |
| Complexity | MEDIUM |
| Systems Affected | API server, Dashboard, Database |
| Jira Issue | PROJ-122 |

---

## Patterns to Follow

### Naming
```typescript
// SOURCE: packages/api/src/services/client-service.ts:1-5
// Service files: kebab-case, suffixed with -service
// Functions: camelCase, verb-first
// Types: PascalCase, suffixed with the domain concept
export class ClientService {
  async getClientsByFirm(firmId: string): Promise<Client[]> {
```

### Error Handling
```typescript
// SOURCE: packages/api/src/services/client-service.ts:45-52
try {
  const result = await db.query(sql`
    SELECT * FROM clients WHERE firm_id = ${firmId}
  `);
  return { success: true, data: result.rows };
} catch (error) {
  logger.error('Client query failed', { error: sanitize(error), firmId });
  throw new ServiceError('CLIENT_QUERY_FAILED', error);
}
```

### Database Migrations
```sql
-- SOURCE: packages/api/migrations/0012_add_audit_log.sql:1-15
-- Migrations are numbered sequentially: NNNN_description.sql
-- Always include RLS policy
-- Always include created_at with default NOW()
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id),
  action TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY firm_isolation ON audit_log
  USING (firm_id = current_setting('app.current_firm_id')::UUID);
```

### API Routes
```typescript
// SOURCE: packages/api/src/routes/client-routes.ts:12-25
// Routes follow: router.METHOD('/resource', validateMiddleware, handler)
// All routes extract firmId from authenticated session
router.post('/clients',
  validate(createClientSchema),
  async (req, res) => {
    const firmId = req.session.firmId;
    const result = await clientService.createClient(firmId, req.body);
    res.status(201).json(result);
  }
);
```

### Tests
```typescript
// SOURCE: packages/api/src/__tests__/client-service.test.ts:1-20
// Test files: co-located in __tests__/ directory
// Pattern: describe(ServiceName) > it('should verb...')
// Use test database with RLS verification
describe('ClientService', () => {
  beforeEach(async () => {
    await resetTestDatabase();
    await setTestFirm(TEST_FIRM_ID);
  });

  it('should return only clients for the current firm', async () => {
    const result = await clientService.getClientsByFirm(TEST_FIRM_ID);
    expect(result.data).toHaveLength(2);
    result.data.forEach(client => {
      expect(client.firm_id).toBe(TEST_FIRM_ID);
    });
  });
});
```

---

## Files to Change

| File | Action | Purpose |
|------|--------|---------|
| `packages/api/migrations/0017_add_funnel_events.sql` | CREATE | Event table with RLS |
| `packages/api/src/services/funnel-service.ts` | CREATE | Event ingestion + aggregation |
| `packages/api/src/routes/funnel-routes.ts` | CREATE | POST /api/telemetry/events endpoint |
| `packages/api/src/routes/index.ts` | UPDATE | Register funnel routes |
| `packages/dashboard/src/hooks/use-section-tracker.ts` | CREATE | Dashboard instrumentation hook |
| `packages/dashboard/src/app.tsx` | UPDATE | Wire section tracker |
| `packages/api/src/__tests__/funnel-service.test.ts` | CREATE | Service tests with RLS verification |

---

## Tasks

Execute in order. Each task is atomic and verifiable.

### Task 1: Create funnel_events migration

- **File**: `packages/api/migrations/0017_add_funnel_events.sql`
- **Action**: CREATE
- **Implement**: Create the `funnel_events` table with columns: `id` (UUID PK), `firm_id` (UUID FK, NOT NULL), `section_from` (TEXT NOT NULL), `section_to` (TEXT NOT NULL), `created_at` (TIMESTAMPTZ DEFAULT NOW()). Enable RLS with firm_isolation policy. Add index on `(firm_id, created_at)`.
- **Mirror**: `packages/api/migrations/0012_add_audit_log.sql:1-15` — follow the same RLS pattern
- **Validate**: `pnpm run db:migrate && pnpm run db:migrate:down && pnpm run db:migrate`

### Task 2: Create funnel service

- **File**: `packages/api/src/services/funnel-service.ts`
- **Action**: CREATE
- **Implement**: Create `FunnelService` class with two methods: `recordEvent(firmId, sectionFrom, sectionTo)` — inserts a row; `getTopPaths(firmId, days = 30, limit = 10)` — returns aggregate of (section_from, section_to, count) ordered by count DESC. Use parameterized queries. Sanitize error logging.
- **Mirror**: `packages/api/src/services/client-service.ts:1-52` — follow naming, error handling, query patterns
- **Validate**: `pnpm run build`

### Task 3: Create funnel routes

- **File**: `packages/api/src/routes/funnel-routes.ts`
- **Action**: CREATE
- **Implement**: `POST /api/telemetry/events` — accepts `{ section_from, section_to }`, validates input with zod schema, extracts firmId from session, calls `funnelService.recordEvent()`. `GET /api/telemetry/funnel` — calls `getTopPaths()` and returns results.
- **Mirror**: `packages/api/src/routes/client-routes.ts:12-25` — follow route registration pattern
- **Validate**: `pnpm run build`

### Task 4: Register funnel routes

- **File**: `packages/api/src/routes/index.ts`
- **Action**: UPDATE
- **Implement**: Import `funnelRoutes` and add `router.use('/telemetry', funnelRoutes)` alongside existing route registrations.
- **Mirror**: `packages/api/src/routes/index.ts:8-15` — follow existing registration pattern
- **Validate**: `pnpm run build`

### Task 5: Create section tracker hook

- **File**: `packages/dashboard/src/hooks/use-section-tracker.ts`
- **Action**: CREATE
- **Implement**: React hook `useSectionTracker(sectionName)` that fires a POST to `/api/telemetry/events` on section transitions. Debounce rapid transitions (300ms). Fail silently — never let analytics break the UI.
- **Mirror**: `packages/dashboard/src/hooks/use-api.ts:1-30` — follow hook naming and fetch patterns
- **Validate**: `pnpm run build`

### Task 6: Wire section tracker into dashboard

- **File**: `packages/dashboard/src/app.tsx`
- **Action**: UPDATE
- **Implement**: Add `useSectionTracker()` calls to the 4 main dashboard sections: Overview, Client Detail, Recommendations, Settings.
- **Validate**: `pnpm run build && pnpm run dev` (smoke test: navigate between sections, check network tab)

### Task 7: Write service tests

- **File**: `packages/api/src/__tests__/funnel-service.test.ts`
- **Action**: CREATE
- **Implement**: Test `recordEvent()` inserts correctly; test `getTopPaths()` returns aggregated results; test RLS isolation (events from firm A not visible to firm B); test input validation (empty section names rejected).
- **Mirror**: `packages/api/src/__tests__/client-service.test.ts:1-20` — follow test structure and RLS verification pattern
- **Validate**: `pnpm run test`

---

## Validation

```bash
# Build / type check
pnpm run build

# Lint
pnpm run lint

# Tests
pnpm run test

# Integration tests
npx vitest run --config vitest.integration.config.ts
```

---

## Acceptance Criteria

- [ ] `POST /api/telemetry/events` accepts `{ section_from, section_to }` and returns 201
- [ ] Events are scoped to the authenticated firm via RLS
- [ ] `GET /api/telemetry/funnel` returns top paths with counts
- [ ] Dashboard section transitions fire telemetry events
- [ ] No PII in event data (no user IDs, names, or client data)
- [ ] Analytics failures don't break the dashboard UI
- [ ] All tasks completed and build passes
- [ ] Tests verify RLS isolation between firms

---

## Risks

| Risk | Mitigation |
|------|------------|
| High event volume from rapid navigation | 300ms debounce in the hook; daily aggregation query |
| RLS misconfiguration leaks cross-firm data | Integration test with two firms verifies isolation |
| Analytics error crashes dashboard | Hook uses try/catch with silent failure; no throw |
