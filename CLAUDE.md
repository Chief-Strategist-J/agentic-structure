# Claude Code — Instructions & Architecture Enforcement

@AGENTS.md

## Claude Code Specific Enforcement Protocol

You are operating under **Zero-Trust Mechanical Rule Enforcement**. You must strictly obey all rules defined in `@AGENTS.md` and `agent-kit/platform/rules-manifest.yaml`.

### 1. Mandatory Pre-Edit Protocol
Before generating or modifying any code in this repository:
1. State out loud:
   - The exact task you are executing.
   - The exact Rule IDs from `agent-kit/platform/rules-manifest.yaml` that apply (e.g. `ID-TAXONOMY-001`, `DB-RLS-001`, `STRUCTURE-001`, `TS-ANY-001`, `LOOP-001`).
   - The relevant ADR from `agent-kit/platform/adr/` (e.g. `ADR-0001`).

### 2. Mandatory Post-Edit Gate
Before presenting your work as done or answering the user:
```bash
bash agent-kit/scripts/run-rules-manifest.sh --changed
```
- If any `blocking` rule fails: **STOP**. Fix the code immediately. Do NOT present incomplete or failing work.
- Output the raw script verification results in your response as evidence.

### 3. Non-Negotiable Architecture Constraints
- **§14 Taxonomy**: Every request handler, DTO, and outgoing call must preserve `Trace-ID`, `Request-ID`, `Tenant-ID`, and `Idempotency-Key` (on mutations). Never alias `requestId` as `idempotencyKey`.
- **§12 Multi-Tenancy**: Every table with `tenant_id` must have `ENABLE ROW LEVEL SECURITY` and `CREATE POLICY`. Every repository query must accept tenant context.
- **§12 Replicas**: Reads default to replica unless `ReadConsistency.STRONG` is explicitly declared. Never use `sleep()` before reading written data.
- **§13 Idempotency**: Idempotency tables must enforce `UNIQUE(tenant_id, idempotency_key)` and `payload_hash`.
- **§13 Outbox**: Never publish directly to message brokers inside DB mutations — write to outbox table inside the transaction.
- **§1 & §2 Slices**: Follow vertical slice layout (`internal/features/<feature>/`, `features/<feature>/`, `app/(features)/<feature>/`). Never create flat `controllers/`, `services/`, `models/`.
- **§3 & §5 Code**: Zero `any`, zero `!!`, zero `panic()` in features, zero `for`/`while` loops in features (use functional combinators).
