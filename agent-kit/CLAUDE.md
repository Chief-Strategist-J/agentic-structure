# Claude Code — Instructions & Architecture Enforcement

@AGENTS.md

## Claude Code Specific Enforcement Protocol

You are operating under **Zero-Trust Mechanical Rule Enforcement**. You must strictly obey all rules defined in `@AGENTS.md` and `platform/rules-manifest.yaml`.

### 1. Mandatory Pre-Edit Protocol (Every Turn)
Before generating or modifying any code in this repository:
1. State out loud:
   - The exact task you are executing.
   - The exact Rule IDs from `platform/rules-manifest.yaml` that apply (e.g. `ID-TAXONOMY-001`, `DB-RLS-001`, `STRUCTURE-001`, `CENTRAL-001`, `UI-TRANSFORM-001`, `LOOP-001`, `TS-ANY-001`, `DB-MIGRATION-001`).
   - The relevant ADR from `platform/adr/` (e.g. `ADR-0001`).

### 2. Mandatory Post-Edit Gate (Before Claiming Done)
Before presenting your work as done or answering the user:
```bash
bash scripts/run-rules-manifest.sh --changed
```
- If any `blocking` rule fails: **STOP IMMEDIATELY**. Fix the code. Do NOT present incomplete or failing work.
- Output the raw script verification results in your response as evidence.

### 3. Non-Negotiable Architecture Constraints
- **§14 Taxonomy**: Every request handler, DTO, and outgoing call must preserve `Trace-ID`, `Request-ID`, `Tenant-ID`, and `Idempotency-Key` (on mutations). Never alias `requestId` as `idempotencyKey` or `traceId`.
- **§12 Multi-Tenancy & RLS**: Every table with `tenant_id` must have `ENABLE ROW LEVEL SECURITY` and `CREATE POLICY`. Every repository query must take an explicit tenant parameter.
- **§12 Replicas**: Reads default to replica unless `ReadConsistency.STRONG` is explicitly declared. Never use `sleep()` before reading written data.
- **§12 DB Timeouts & Pool**: Database connections and pools must configure explicit `statement_timeout`.
- **§13 Idempotency**: Idempotency tables must enforce `UNIQUE(tenant_id, idempotency_key)` and `payload_hash`.
- **§13 Outbox**: Never publish directly to message brokers inside DB mutations — write to outbox table inside the transaction.
- **§11 Frontend Zero Logic**: Components (`.tsx`) contain only markup, style bindings, and props. No business conditionals, no data transforms (`.map`/`.filter` on raw data belongs in `lib/transforms/<feature>.viewmodel.ts`), no direct fetch (`lib/data/`), no inline style ternaries.
- **§9 Centralization**: Never construct HTTP clients, DB connection pools, ad-hoc rules engines, or tracing SDKs inside `features/`.
- **§1 & §2 Slices**: Follow vertical slice layout (`internal/features/<feature>/`, `features/<feature>/`, `app/(features)/<feature>/`). Never create flat `controllers/`, `services/`, `models/`, `repositories/`.
- **§3 & §5 Code**: Zero `any`, zero `!!`, zero `panic()` in features, zero `for`/`while` loops in features (use functional combinators).
- **§10 AI Loop**: Must cite followed ADR(s) and architecture doc section(s) in commit/PR.
