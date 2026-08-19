# AGENTS.md — Mandatory Architecture & Rules Specification

> **UNIVERSAL AGENT INSTRUCTION**: This file is read natively by Claude Code, Gemini CLI, Cursor, Windsurf, Copilot, Codex, and all autonomous coding agents. All rules in this document and `agent-kit/platform/rules-manifest.yaml` are **mechanically enforced, non-negotiable compile-time gates**.

---

## 1. Mandatory Execution Protocol (Every Agent Turn)

### Before writing or modifying ANY code:
1. **Read `agent-kit/platform/rules-manifest.yaml` in full.**
2. **Read every ADR under `agent-kit/platform/adr/`.** Do not silently contradict a prior decision.
3. **State out loud in your initial response** which exact Rule IDs from the manifest apply to your current task.
4. **Read `agent-kit/docs/architecture.md` and `rule-need-enforament/reference-rules.md`** for deep rationale.

### After writing code, before claiming completion:
Run:
```bash
bash agent-kit/scripts/run-rules-manifest.sh --changed
```
- **`blocking` finding** → **STOP IMMEDIATELY**. Fix the violation before proceeding. Do NOT declare the task complete.
- **`required-with-justification` finding** → Surface explicitly to the user with formal justification.
- **Never claim a rule is satisfied without running the script and presenting the actual output.**

---

## 2. Absolute Boundaries & Non-Negotiables

### A. §0 The Naming Law (`NAMING-001`, `NAMING-002`)
- **No example nouns**: Never copy template/example nouns (`Order`, `Pricing`, `User`, `Cart`, `Invoice`, `Todo`) into structural code. Port interfaces are `<Feature>Repository`, `<Feature>Publisher`.
- **Rule file naming**: Rule YAML files must match `<feature>.<concern>.rules.yaml` (`<concern>` = validation | decision | workflow | eligibility).

### B. §1 & §2 Vertical Slice Topology (`STRUCTURE-001`)
- **Go**: `cmd/{api,worker}/main.go`, `internal/features/<feature>/` (`<verb>_handler.go`, `<verb>_command.go`, `<verb>_result.go`, `logic.go`, `rules.go`, `validate.go`), `internal/domain/<entity>.go`, `internal/ports/<feature>_repository.go`, `internal/adapters/{postgres,kafka,redis}/`, `internal/engine/`, `internal/platform/`.
- **Kotlin**: `platform/`, `domain/<Entity>.kt`, `features/<feature>/` (`<Verb><Feature>Route.kt`, `Command.kt`, `Handler.kt`, `Rules.kt`, `Validation.kt`), `ports/<Feature>Repository.kt`, `adapters/`, `app/Application.kt`.
- **Next.js**: `app/(features)/<feature>/` (`page.tsx`, `actions.ts`, `schema.ts`, `hooks.ts`, `components/`), `lib/` (`data/`, `rules/`, `config/`, `errors/`, `tracing/`, `validation/`, `transforms/`), `components/ui/`.
- **Banned Layered Layouts**: Flat `controllers/`, `services/`, `models/`, `repositories/`, `handlers/`, `pages/api/`, `utils/`, `helpers/` are **strictly rejected**.
- **Slice Isolation (`UI-CROSS-IMPORT-001`)**: Never import across vertical slice boundaries directly (`(features)/feature-a` importing from `(features)/feature-b`). Shared code belongs in `platform/`, `components/ui/`, or `lib/`.

### C. §3 Brutal Type & Null Safety (`KT-NULL-001`, `GO-ASSERT-001`, `GO-ERRCHECK-001`, `GO-PANIC-001`, `TS-ANY-001`, `TS-ASSERT-001`, `TS-STRICT-001`)
- **Kotlin**: Ban `!!` outside tests. Wrap platform types `String!`. Use `Either<NonEmptyList<AppError>, Command>` for boundary validation. Never use `List<T>?` — use `List<T>` defaulting to `emptyList()`.
- **Go**: Check every `(T, error)` before touching `T`. Never discard errors with `_`. Every type assertion `x.(T)` must use `, ok` form. Never `panic()` in `features/` or `domain/`.
- **TypeScript**: `any` is strictly banned. Never use `as Type` on external/unknown data; use zod `.parse()` / `.safeParse()`. Enforce `strict: true`, `noUncheckedIndexedAccess: true`, `exactOptionalPropertyTypes: true` in `tsconfig.json`.

### D. §5 Functional Transforms & No Loops (`LOOP-001`)
- **No loops in feature slices**: Never write `for` or `while` loops inside `features/`, `domain/`, or UI components.
- **Required combinators**: Use `map`, `filter`, `fold`, `reduce`, `groupBy`, `partition`, `pipe` per language. Loops belong ONLY inside `platform/fp` or low-level byte adapters.

### E. §9 Everything Centralized Master List (`CENTRAL-001`)
If it appears more than once anywhere in `features/`, it is a bug:
- **Tracing init + span decorators**: `platform/tracing`, `platform/engine`, `platform/adapters/base`, `platform/http` (never in `features/`).
- **Config loading/typing**: `platform/config` loader, one typed struct (no string-indexed reads `config["key"]`, `os.Getenv`, `System.getenv` in features — `CONFIG-ACCESS-001`).
- **Error codes/taxonomy**: `platform/errors` (no hand-typed error strings).
- **HTTP client**: `platform/http` factory (no `new HttpClient()`, `axios.create`, or `fetch()` in features).
- **Rules engine runtime**: `platform/engine` (no feature-local if/else rule evaluation).
- **DB pool / connection management**: `adapters/<store>/base` (no `sql.Open`, `pgxpool.New`, `new Pool` in features).

### F. §10 AI 3-Agent Loop & ADR Governance (`ADR-COVERAGE-001`, `AGENT-LOOP-001`)
- **Agent 1 (Generator)**: Proposes code and **MUST cite which ADR(s) and architecture doc section(s) it followed** in the PR/commit.
- **Agent 2 (Reviewer / Enforcer)**: Runs mechanical linters and LLM checks for vertical slice boundaries and rules-engine placement.
- **Agent 3 (Cross-checker)**: Verifies external validity and internal consistency against `platform/adr/*.md`. Any conflict requires an explicit ADR supersession proposal approved by a human.
- **ADR Requirement**: Structural changes (new top-level directory, port pattern, engine action) require a linked ADR under `platform/adr/`.

### G. §11 Frontend Zero-Logic Law (`UI-LOGIC-001`, `UI-TRANSFORM-001`, `UI-MAGIC-VALUES-001`, `UI-FETCH-001`, `UI-STYLE-001`, `UI-INLINE-STYLE-001`, `UI-CROSS-IMPORT-001`, `UI-COMPONENT-SIZE-001`)
- **Three Things Only in `.tsx`**: Markup, style bindings, and calls to hooks/props computed elsewhere.
- **No Business Conditionals**: No multi-condition boolean guards in JSX (`UI-LOGIC-001`).
- **No Data Transformation in Components**: `.map`/`.filter`/`.reduce` on raw API data inside a component is banned — raw to view-model transformation lives in `lib/transforms/<feature>.viewmodel.ts` (`UI-TRANSFORM-001`).
- **No Inline Magic Values**: Thresholds (> 500), status strings ("ACTIVE"), enum literals sourced from `lib/config` or contract enums (`UI-MAGIC-VALUES-001`).
- **No Direct Fetching**: Network calls go through `lib/data/<feature>.ts` (`UI-FETCH-001`).
- **Styling Discipline**: No inline style ternaries `style={{...}}` (`UI-INLINE-STYLE-001`). No raw hex/px outside design tokens (`UI-STYLE-001`). Use dedicated style resolvers `lib/styles/<feature>.styles.ts` or `cva()`.
- **Component Size**: Flag `.tsx` files exceeding 100 lines for container vs presentational splitting (`UI-COMPONENT-SIZE-001`).

---

## 3. §14 Full Identifier Taxonomy (Strictly Enforced: `ID-TAXONOMY-001`)

Every request across all services carries this taxonomy. **Each identifier has ONE distinct meaning and MUST NOT be aliased (e.g., Request-ID != Idempotency-Key != Trace-ID).**

| Identifier | Generated by | Enforced Meaning | Propagation | Failure If Missing / Aliased |
|---|---|---|---|---|
| **Request-ID** | Edge / Gateway / Caller | Identifies this exact HTTP request/response pair. New value on every retry. | Per HTTP call | Cannot isolate individual call logs. |
| **Trace-ID** | First service in chain | Identifies entire distributed execution across all services for one user action. | Ambient W3C `traceparent` unchanged | End-to-end distributed tracing breaks. |
| **Span-ID** | Each service per unit of work | Identifies one specific operation/span within the trace. | Child span per hop | Trace waterfall loses execution step visibility. |
| **Correlation-ID** | Originating business workflow | Identifies a multi-request workflow spanning multiple Trace-IDs over time. | Persisted with workflow/saga state | Cannot correlate multi-step business transactions. |
| **Operation-ID** | Client / API contract layer | Identifies WHAT business operation is being performed (e.g. `createWallet`). | Fixed per logical operation | Spans and metrics cannot group by business action. |
| **Idempotency-Key** | Client | Enables safe retry/dedup. Same key across all retries of the SAME intended mutation. | Same value across retries | Duplicate writes and double charges. |
| **Causation-ID** | Triggering event/command | Points to the immediate predecessor that caused this event/request to exist. | Set once at creation | Root-cause analysis in event-driven systems fails. |
| **Parent-Request-ID**| Immediate upstream caller | Points to the specific parent HTTP request in cross-trace asynchronous calls. | Set per hop | Cross-trace call attribution is lost. |
| **Actor-ID** | Auth / Identity layer | WHO (user or service account) is responsible for this action. | Flows unchanged into audit logs | Compliance failure; audit log cannot identify actor. |
| **Client-ID** | Auth / Identity layer | WHICH application/integration is calling (distinct from Actor-ID). | Flows unchanged | Cannot apply per-client rate limiting or analytics. |
| **Tenant-ID** | Auth / Identity layer | WHICH tenant owns this operation and its data. | Ambient context to DB RLS | Catastrophic cross-tenant data leak vulnerability. |
| **Session-ID** | Frontend / Auth session | WHICH user login session/browser context this request belongs to. | Cookie/token-scoped | Cannot revoke individual sessions or replay UX. |
| **Resource-ID** | Resource creator | WHICH specific entity is being read or mutated. | Stable for resource lifetime | Cannot address target entity. |
| **Resource-Version**| Database | WHICH version of that specific resource state this is. | Incremented on mutation | Concurrency lost-update bugs. |
| **ETag / If-Match** | Server (ETag), Client (If-Match)| HTTP optimistic concurrency control carrying Resource-Version. | Per-request header | Concurrent writers silently clobber data. |
| **Deadline** | Client / Upstream service | WHEN operation must stop (absolute timestamp or remaining budget). | Context deadline / AbortSignal | Wasted server work on timed-out requests. |
| **Priority** | Client / Rules Engine | Urgency scheduling relative to other work for load-shedding. | Queue/worker priority | Cannot shed load gracefully under traffic spikes. |
| **Retry-Count** | Retrying layer | How many times this exact operation has already been attempted. | Incremented per retry | Runaway retry storms. |
| **Source** | Originating system | WHERE technically originated (batch job vs user UI vs webhook). | Set at origin | Cannot distinguish batch anomalies from user traffic. |
| **Environment** | Deployment / Infra | dev / staging / prod deployment context. | Embedded in spans/logs | Dev logs contaminate production telemetry. |
| **Security Context** | Auth Boundary | Authentication, authorization scopes, roles, data classification. | Resolved once at API edge | Authorization bypass vulnerabilities. |

### Strict Rules for Taxonomy:
1. **Never alias identifiers**: `idempotencyKey = requestId` or `traceId = requestId` is a blocking violation.
2. **Never regenerate Trace-ID downstream**: Inherit ambient `traceparent`; never create orphan root spans.
3. **Attach all identifiers in `platform/http`**: The centralized HTTP client auto-injects all ambient headers.

---

## 4. §12 Database, Multi-Tenancy & Sharding Laws

- **Multi-Tenancy & RLS (`DB-RLS-001`, `DB-TENANT-001`)**:
  - Every table with `tenant_id` MUST enforce `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` and `CREATE POLICY` at the database engine.
  - Application-layer `WHERE tenant_id = ?` ALONE is strictly forbidden.
  - Every repository query MUST take an explicit tenant context parameter.
- **Idempotency Uniqueness at DB Level (`DB-IDEMPOTENCY-001`, `API-IDEMPOTENCY-001`)**:
  - Every mutating endpoint (POST/PUT/PATCH/DELETE) requires `Idempotency-Key`.
  - Database must enforce `UNIQUE(tenant_id, idempotency_key)` and store `payload_hash`.
- **Migrations & Compatibility (`DB-MIGRATION-001`, `DB-MIGRATION-002`, `DB-MIGRATION-003`, `DB-COMPAT-001`)**:
  - Expand → Migrate → Contract across 3 separate deployments.
  - Never add `NOT NULL` without a `DEFAULT` on the same statement.
  - Destructive migrations (`DROP`, `RENAME`, `ALTER TYPE`) require `-- ADR:` comment.
  - All migrations must be idempotent using `IF NOT EXISTS` guards.
  - `db.compat.minSupportedSchemaVersion` in `platform/config/base.yaml` defines the compatibility window.
- **Replicas & Read Consistency (`REPLICA-CONSISTENCY-001`)**:
  - Writes go to primary. Reads default to replica unless `ReadConsistency.STRONG` is explicitly passed.
  - Never use arbitrary `sleep()` or `delay()` before reading written data.
- **Connection Pools & Timeouts (`DB-STATEMENT-TIMEOUT-001`, `RESOURCE-TIMEOUT-001`)**:
  - Centralize connection pooling in `platform/adapters/<store>/base`.
  - Every query and database pool MUST configure an explicit `statement_timeout`.

---

## 5. §13 Multi-Layer Independent Validation & Outbox Pattern

- **4-Layer Independent Validation**:
  1. Frontend: `schema.ts` (Zod) for UX feedback.
  2. API Boundary: Server-side validation accumulating ALL errors (`EitherNel`, `ValidationError` slice, Zod issues).
  3. Domain Layer: Business invariants and state transition legality.
  4. Database Layer: `NOT NULL`, `CHECK`, `UNIQUE(tenant_id, idempotency_key)`, and RLS.
  - **No layer may skip validation assuming another layer already checked.**
- **Transactional Outbox Pattern (`OUTBOX-PATTERN-001`)**:
  - State mutations that emit events MUST write the event to an outbox table in the same database transaction.
  - Direct message broker publishing inside database transactions is strictly banned.
- **Optimistic Concurrency (`API-CONCURRENCY-001`)**:
  - Update operations on mutable resources MUST require `If-Match` / `ETag`.

---

## 6. Verification Command Cheat Sheet

```bash
# Run all 40 checks across the entire repo
bash agent-kit/scripts/run-rules-manifest.sh

# Run only checks matching changed files in git diff
bash agent-kit/scripts/run-rules-manifest.sh --changed
```
