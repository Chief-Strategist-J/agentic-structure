# AGENTS.md — read this before writing any code

This file is read natively by Claude Code, Gemini CLI, Cursor, Codex, Copilot, Windsurf, and most other coding agents. If your tool doesn't read it natively, `CLAUDE.md` / `GEMINI.md` / `.cursor/rules/` in this repo each `@AGENTS.md`-import this file — so wherever you're reading this from, it's the same rules.

## Before writing ANY code, in this exact order

1. Read `platform/rules-manifest.yaml` in full. Every entry there is a real, enforced rule — not a suggestion, not a style preference.
2. Read every file under `platform/adr/`. These are prior architecture decisions. Do not silently contradict one.
3. State out loud (in your response, before editing anything) which rule IDs from the manifest apply to this task.
4. Read `docs/architecture.md` for the full reasoning behind any rule ID you're unsure about — the manifest gives you the check, the doc gives you the "why."

## Absolute boundaries — violating any of these is not a judgment call

- Never use Kotlin `!!`, TypeScript `any`, or an unchecked Go type assertion (`x.(T)` without the `, ok` form).
- Never use `panic()` in Go `features/` or `domain/` — handle errors as values.
- Never write a business conditional, a data transform, or a `fetch`/`axios` call inside a UI component file. UI components render already-decided props — nothing else.
- Never write inline conditional logic inside `style={{...}}` — use style resolvers or variant systems.
- Never import across vertical slice boundaries directly (`(features)/<a-feature>` importing from `(features)/<b-feature>`) — shared items belong in `platform/`, `components/ui/`, or `lib/`.
- Never write a `for`/`while` loop inside `features/`, `domain/`, or component code. Use the transform methods catalogued in `docs/architecture.md` (`map`/`filter`/`fold`/`reduce`/`pipe` per language). A loop belongs only inside `platform/fp` itself or a low-level adapter.
- Never violate vertical slice folder structure (no flat `controllers/`, `services/`, `models/` layered dirs).
- Never write a destructive database migration (drop, rename, narrow a type) without a linked ADR justifying it, and never add a `NOT NULL` column without a default in the same migration.
- Never write non-idempotent migrations — every `CREATE TABLE`, `ADD COLUMN`, and `CREATE INDEX` must have `IF NOT EXISTS` guards.
- Never invent or copy a concrete example noun (Order, Pricing, User, etc.) into structural code, folder names, or interfaces unless that is genuinely this project's real domain — placeholders (`<Feature>`, `<Entity>`) stay placeholders until a human names the real thing.
- Never name rule YAML files arbitrarily — follow `<feature>.<concern>.rules.yaml`.
- Never use raw or string-indexed config/env reads (`config["key"]`, `os.Getenv`, `System.getenv`) in feature code — inject typed structs/models.
- Never ship a mutating endpoint (POST/PUT/PATCH/DELETE) without requiring an `Idempotency-Key`, and never implement dedup/uniqueness only in application code — it must be enforced by a database constraint.
- Never query or write data without an explicit tenant-scoping parameter. There is no such thing as an unscoped query in this system.
- Never claim a rule is satisfied without actually running its check command and showing the real output. Do not say "this follows the rules" without evidence.

## After writing code, before saying you're done

Run:
```
bash scripts/run-rules-manifest.sh --changed
```
- Any `blocking` finding → STOP. Do not present the change as complete. State the exact rule ID and the failing output, and either fix it or explain why it's genuinely blocked and needs a human decision.
- Any `required-with-justification` finding → surface it explicitly with your proposed justification. Do not silently proceed past it.
- If a check script can't run in your current environment (missing tool, no network), say so explicitly and mark that check as unverified — never assume it would have passed.

## If a rule conflicts with what the user is asking for

Stop and say so plainly. Propose either a compliant alternative or an explicit ADR-supersession (see `platform/adr/TEMPLATE.md`) for a human to approve. Do not quietly reinterpret a `blocking` rule to make the conflict disappear.

## Reference

- Full architecture + reasoning: `docs/architecture.md`
- Machine-readable rules: `platform/rules-manifest.yaml`
- Prior decisions: `platform/adr/`
- Run all checks: `bash scripts/run-rules-manifest.sh`
- Run only checks touching your changed files: `bash scripts/run-rules-manifest.sh --changed`
