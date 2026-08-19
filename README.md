# Data-Driven, Rules-Engine, Vertical-Slice Architecture — v2
### Polyglot Enterprise Edition: Go + Kotlin + Next.js (TypeScript) + Python + Java

> **UNIVERSAL MACHINE & AGENT INSTRUCTION**: This repository is governed by **Zero-Trust Mechanical Rule Enforcement**. All 41 rules defined in `agent-kit/platform/rules-manifest.yaml` and `@AGENTS.md` are **mechanically enforced, non-negotiable compile-time gates**.

---

## ⚡ 1-Command Installation & Setup

Install the entire platform, rules engine, and pre-commit gates into any workspace with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/Chief-Strategist-J/agentic-structure/main/install.sh | bash
```

### Targeted Directory Installation:
```bash
curl -fsSL https://raw.githubusercontent.com/Chief-Strategist-J/agentic-structure/main/install.sh | TARGET_DIR=/path/to/workspace bash
```

---

## 🚀 Quick Start (Docker Compose Stack)

Start the full microservice and observability stack (PostgreSQL, Kafka KRaft, OpenTelemetry Collector, Go, Kotlin, Python, Java, Next.js Web):

```bash
docker compose up --build -d
```

| Service | Port | Healthcheck / Endpoint |
|---|---|---|
| **Next.js Web Frontend** | `3000` | [http://localhost:3000](http://localhost:3000) |
| **Go Microservice** | `8080` | `http://localhost:8080/health` |
| **Kotlin Microservice** | `8081` | `http://localhost:8081/health` |
| **Python Microservice** | `8082` | `http://localhost:8082/health` |
| **PostgreSQL Database** | `5432` | `localhost:5432` |
| **Kafka Broker (KRaft)** | `9092` | `localhost:9092` |
| **OTel Collector (gRPC)** | `4317` | `localhost:4317` |

---

## 🛡️ Mechanically Enforced Rule ID Matrix (41 Rules)

Every rule is checked on **`git commit`** via pre-commit hooks and in CI pipelines:

```bash
bash agent-kit/scripts/run-rules-manifest.sh --changed
```

| Rule ID | Severity | Concern | Mechanism |
|---|---|---|---|
| `NAMING-001` | blocking | §0 Naming Law (No Template Example Nouns) | `validate-naming.sh` |
| `NAMING-002` | blocking | §0 Rule File Naming (`<feature>.<concern>.rules.yaml`) | `validate-rule-file-naming.sh` |
| `STRUCTURE-001` | blocking | §1 & §2 Vertical Slice Architecture | `validate-folder-structure.sh` |
| `KT-NULL-001` | blocking | §3 Kotlin Null Safety (Ban `!!` in features) | `no-force-unwrap-kotlin.sh` |
| `GO-ASSERT-001` | blocking | §3 Go Type Assertion (Enforce `, ok` form) | `no-unchecked-type-assertion-go.sh` |
| `GO-ERRCHECK-001` | blocking | §3 Go Error Handling (Check all errors) | `go-errcheck.sh` |
| `GO-PANIC-001` | blocking | §3 Go Panic Ban in features | `no-panic-in-features-go.sh` |
| `TS-ANY-001` | blocking | §3 TypeScript `any` Ban | `no-any-typescript.sh` |
| `TS-ASSERT-001` | blocking | §3 TypeScript `as T` Unsafe Cast Ban | `no-unsafe-cast-typescript.sh` |
| `TS-STRICT-001` | blocking | §3 TSConfig Strictness (`noUncheckedIndexedAccess`) | `validate-tsconfig-strict.sh` |
| `RESOURCE-TIMEOUT-001` | required* | §4 Explicit Timeouts (Go/Kotlin/TS/Py/Java) | `no-default-timeouts.sh` |
| `LOOP-001` | blocking | §5 Functional Combinators (Zero Loops in Features) | `no-loops-in-features.sh` |
| `RULE-ENGINE-LEVELS-001`| blocking | §2 & §6 3-Level Rules Engine (Zero `if-else` Decisions) | `no-if-else-business-logic.sh` |
| `CONFIG-SCHEMA-001` | blocking | §6 Config JSON Schema Validation | `validate-config.sh` |
| `CONFIG-ACCESS-001` | blocking | §6 Typed Config Access (No string-indexed access) | `no-string-config-access.sh` |
| `SECURITY-SECRET-001` | blocking | §6 Secret Scanning (No committed credentials) | `no-committed-secrets.sh` |
| `CENTRAL-001` | blocking | §9 Centralization Master List (No bespoke clients) | `enforce-centralization-master-list.sh` |
| `ADR-COVERAGE-001` | blocking | §10 ADR Governance (Structural changes need ADR) | `check-adr-coverage.sh` |
| `AGENT-LOOP-001` | blocking | §10 3-Agent Loop Citations (Cite followed ADRs) | `validate-3-agent-loop-citations.sh` |
| `UI-LOGIC-001` | blocking | §11 Frontend Logic Ban (No business branching in JSX)| `no-business-logic-in-jsx.sh` |
| `UI-TRANSFORM-001` | blocking | §11 Frontend Transforms (No `.map()` in components)| `no-data-transforms-in-components.sh` |
| `UI-MAGIC-VALUES-001` | blocking | §11 Frontend Magic Values (Tokens/config only) | `no-magic-values-in-components.sh` |
| `UI-FETCH-001` | blocking | §11 Frontend Direct Fetch (Use data layer only) | `no-fetch-in-components.sh` |
| `UI-STYLE-001` | required* | §11 Design Tokens (No raw inline pixel/hex values) | `no-inline-style-values.sh` |
| `UI-INLINE-STYLE-001` | blocking | §11 Inline Style Ternary Ban | `no-inline-style-ternary.sh` |
| `UI-CROSS-IMPORT-001` | blocking | §11 Slice Isolation (No feature cross-imports) | `no-cross-feature-imports.sh` |
| `UI-COMPONENT-SIZE-001` | advisory | §11 Component Size (<100 lines) | `check-component-size.sh` |
| `DB-MIGRATION-001` | blocking | §12 Additive Migrations (`NOT NULL` requires `DEFAULT`)| `lint-migrations.sh` |
| `DB-MIGRATION-002` | blocking | §12 Destructive Migration ADR Reference | `lint-migrations.sh` |
| `DB-MIGRATION-003` | blocking | §12 Idempotent Migrations (`IF NOT EXISTS` guards)| `lint-migrations-idempotent.sh` |
| `DB-RLS-001` | blocking | §12 Row-Level Security (RLS) on tenant tables | `lint-migrations-rls.sh` |
| `DB-TENANT-001` | blocking | §12 Mandatory Tenant Query Parameter | `no-unscoped-queries.sh` |
| `DB-COMPAT-001` | blocking | §12 Schema Compatibility Window | `validate-db-compat-window.sh` |
| `DB-STATEMENT-TIMEOUT-001`| blocking | §12 Query Statement Timeout | `check-db-statement-timeout.sh` |
| `REPLICA-CONSISTENCY-001` | blocking | §12 Replica Read Consistency Parameter | `check-replica-consistency-param.sh` |
| `API-IDEMPOTENCY-001` | blocking | §13 OpenAPI `Idempotency-Key` Header | `require-idempotency-key-openapi.sh` |
| `DB-IDEMPOTENCY-001` | blocking | §13 DB Idempotency Constraints | `lint-idempotency-table.sh` |
| `API-CONCURRENCY-001` | required* | §13 OpenAPI `If-Match`/`ETag` Concurrency Control | `require-etag-openapi.sh` |
| `OUTBOX-PATTERN-001` | blocking | §13 Transactional Outbox Pattern | `no-uncoordinated-event-publish.sh` |
| `ID-TAXONOMY-001` | blocking | §14 21+ Identifier Taxonomy (Zero Aliasing) | `validate-identifier-taxonomy.sh` |
| `DEP-PIN-001` | blocking | §16 Dependency Pinning (No `^` or `~` ranges) | `no-floating-deps.sh` |

---

## 🏛️ Master Architecture Specification

### 0. The Naming Law
- Interfaces and ports are named `<Feature>Repository`, `<Feature>Publisher`, `<Feature>Cache` — `<Feature>` is discovered from your domain, never copied from a template.
- Rule files are named `<feature>.<concern>.rules.yaml`.
- All scaffolds and templates use `<Feature>`, `<Entity>`, `<Concern>` placeholders until real domain names are substituted.

---

### 1. Unified Repository Topology

```
├── platform/                       # Cross-Language Operational Assets (Repo Level Only)
│   ├── contracts/{openapi, proto, jsonschema, events/}
│   ├── config/                     # Layered Config System (base.yaml, env/*.yaml, secrets.ref.yaml)
│   ├── adr/                        # Architecture Decision Records
│   ├── ci/                         # Reusable Pipeline Definitions
│   └── infra/{terraform, k8s, docker, observability}
│
├── services/                       # Self-Contained Polyglot Microservices
│   ├── go-svc/                     # Go Microservice (internal/engine, internal/features, pkg, tests)
│   ├── kotlin-svc/                 # Kotlin Microservice (platform/engine, features, src/test)
│   ├── python-svc/                 # Python Microservice (app/platform/engine, app/features, tests)
│   ├── java-svc/                   # Java Microservice (src/main/java/com/platform, src/test)
│   └── web/                        # Next.js Web Application (app/(features), shared, lib, tests)
│
└── agent-kit/                      # Automated Mechanical Rules Enforcement Engine
    ├── platform/rules-manifest.yaml
    └── scripts/
        ├── run-rules-manifest.sh   # Manifest Runner (Supports --changed diff scoping)
        ├── install-git-hooks.sh    # Pre-commit Hook Installer
        └── checks/                 # 40 Mechanical Check Scripts
```

---

### 2. Service Structures & Language Platforms

Each language platform is completely isolated with zero cross-service contamination:

#### Go (`services/go-svc`)
```
services/go-svc/
├── cmd/{api,worker}/main.go
├── internal/
│   ├── engine/rules_engine.go   # 3-Level Rules Engine
│   ├── features/<feature>/      # Vertical Slices (<verb>_handler.go, logic.go, validate.go)
│   ├── domain/<entity>.go       # Pure Entities
│   ├── ports/<feature>_repository.go
│   ├── adapters/{postgres, kafka}/
│   └── platform/{fp, errors, tracing}/
├── pkg/formatters/              # Single-responsibility Go formatters (date.go)
└── tests/{unit, integration, contract, perf}/
```

#### Kotlin (`services/kotlin-svc`)
```
services/kotlin-svc/
├── app/Application.kt
├── domain/<Entity>.kt
├── features/<feature>/          # Vertical Slices (<Verb><Feature>Handler.kt, Rules.kt)
├── ports/<Feature>Repository.kt
├── adapters/{postgres-exposed, kafka}/
├── platform/
│   ├── engine/RulesEngine.kt    # 3-Level Rules Engine
│   ├── fp/                      # Functional Combinators (EitherNel, ValidationResult)
│   ├── errors/                  # AppError Taxonomy
│   └── formatters/              # Single-responsibility Kotlin formatters (DateFormatter.kt)
└── src/test/kotlin/{unit, integration, contract, perf}/
```

#### Python (`services/python-svc`)
```
services/python-svc/
├── app/
│   ├── domain/<entity>.py
│   ├── features/<feature>/      # Vertical Slices (handlers, logic, validation)
│   ├── ports/<feature>_repository.py
│   ├── adapters/{postgres, kafka}/
│   └── platform/
│       ├── engine/rules_engine.py # 3-Level Rules Engine (AtomicRule, Policy, RuleEvaluationAudit)
│       ├── fp/functional.py       # map_list, filter_list, partition_list
│       ├── errors/                # AppError Hierarchy
│       └── formatters/            # Date and Currency formatters
└── tests/{unit, integration, contract, perf}/
```

#### Next.js Web (`services/web`)
```
services/web/
├── app/(features)/<feature>/    # Vertical Slices (page.tsx, actions.ts, schema.ts)
├── shared/
│   ├── ui/Button.tsx            # Dumb Shared UI Components
│   └── formatters/date.ts       # Single-responsibility Web formatters
├── lib/
│   ├── rules/evaluator.ts       # 3-Level Rules Engine
│   ├── fp/functional.ts         # TypeScript Functional Combinators
│   ├── errors/AppError.ts       # TypeScript Error Taxonomy
│   ├── http/client.ts           # Auto-injected Trace & Security Headers
│   └── transforms/              # Viewmodel Transforms (<feature>.viewmodel.ts)
└── tests/{unit, integration, contract, perf}/
```

---

### 3. The 3-Level Rules Engine (`RULE-ENGINE-LEVELS-001`)

Raw `if-else` branching for business logic is **mechanically banned**. All business decisions use the 3-level Rules Engine:

- **Level 1 (Atomic Rule)**: Single condition evaluation (`field`, `operator`, `value`) producing a scalar result with a rationale and user-facing explanation.
- **Level 2 (Compound Rule)**: Boolean composition (`AND`, `OR`, `NOT`) of Level 1 rules.
- **Level 3 (Policy)**: Top-level policy evaluated into a complete `RuleEvaluationAudit` with:
  - `evaluation_id`, `trace_id`, `tenant_id`
  - `fired_atomic_rules` (List of passed rule IDs)
  - `user_facing_reasons` (Customer-visible explanation)
  - `debug_waterfall` (Step-by-step latency & evaluation trace)

---

### 4. Functional Combinators — Zero Loops Law (`LOOP-001`)

`for` and `while` loops inside feature code are **mechanically banned**. Use declarative combinators:

| Operation | Go | Kotlin | TypeScript | Python | Java |
|---|---|---|---|---|---|
| **Transform** | `fp.Map(s, fn)` | `s.map { }` | `s.map()` | `map_list(s, fn)` | `s.stream().map()` |
| **Filter** | `fp.Filter(s, pred)` | `s.filter { }` | `s.filter()` | `filter_list(s, pred)` | `s.stream().filter()` |
| **Fold/Reduce**| `fp.Reduce(s, init, fn)`| `s.fold(init) { }`| `s.reduce()` | `functools.reduce()` | `s.stream().reduce()` |
| **Partition** | `fp.Partition(s, pred)` | `s.partition { }` | `partition(s, pred)` | `partition_list(s, pred)`| `Collectors.partitioningBy()`|

---

### 5. Frontend Law — Zero Logic in UI (`UI-LOGIC-001`, `UI-TRANSFORM-001`)

React components (`.tsx`) are purely presentational. They may only contain:
1. **Markup & Style Bindings**.
2. **Calls to Hooks / Props computed elsewhere**.

- ❌ **No inline conditionals deciding business state**: `if (total > 500)` → Move to Rules Engine or viewmodel.
- ❌ **No inline transforms**: `raw.map(x => ...)` → Move to `lib/transforms/<feature>.viewmodel.ts`.
- ❌ **No direct data fetching in components**: `fetch()` / `axios` → Use `lib/data/<feature>.ts`.
- ❌ **No cross-feature imports**: Feature `wallet` cannot import from `deals`. Use `shared/ui/`.

---

### 6. Database Migrations — Expand, Migrate, Contract (`DB-MIGRATION-001..003`)

Destructive migrations in a single deployment are strictly blocked:
1. **Deploy 1 (Expand)**: Add column as nullable or with a default (`IF NOT EXISTS`, `DEFAULT ...`).
2. **Deploy 2 (Migrate)**: Idempotent data backfill & dual-writing in application code.
3. **Deploy 3 (Contract)**: Drop old column only after a bake period, requiring an explicit ADR citation (`-- ADR: platform/adr/0004-....md`).

---

### 7. The 21+ Identifier Taxonomy (`ID-TAXONOMY-001`)

Every request carries explicit, non-overlapping identifiers:
- `Request-ID`: Single HTTP hop identifier.
- `Trace-ID`: Distributed trace propagated across all services (`W3C traceparent`).
- `Span-ID`: Unit of work child span.
- `Correlation-ID`: Multi-request long-running business workflow.
- `Idempotency-Key`: Client-provided deduplication key (Database UNIQUE constraint).
- `Tenant-ID`: Multi-tenant isolation key (Enforced by Row-Level Security).
- `ETag / If-Match`: Optimistic concurrency version control.

---

### 8. AI Agent Persistent Memory & 3-Agent Loop (§10)

Because LLMs do not retain memory across sessions:
1. **Architecture Decision Records (`platform/adr/`)** serve as the persistent source of truth.
2. **The 3-Agent Loop**:
   - **Agent 1 (Generator)**: Proposes code and cites followed ADRs.
   - **Agent 2 (Reviewer)**: Runs mechanical linters and checks vertical-slice boundaries.
   - **Agent 3 (Cross-Checker)**: Verifies internal consistency against `platform/adr/` and external validity.

---

## 🧪 Testing Service Suites

```bash
# Go Service Tests
cd services/go-svc && go test ./...

# Kotlin Service Tests
cd services/kotlin-svc && ./gradlew test

# Python Service Tests
cd services/python-svc && pytest

# Next.js Web Tests
cd services/web && npm test
```

---

## 📜 License
MIT License. Enforced for high-scale enterprise resilience.
