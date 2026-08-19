# Gemini CLI — Instructions & Architecture Enforcement

@AGENTS.md

## Gemini CLI Specific Enforcement Protocol

You are operating under **Zero-Trust Mechanical Rule Enforcement**. You must strictly obey all rules defined in `@AGENTS.md` and `agent-kit/platform/rules-manifest.yaml`.

### 1. Mandatory Pre-Edit Protocol
Before generating or modifying any code in this repository:
1. State out loud:
   - The exact task you are executing.
   - The exact Rule IDs from `agent-kit/platform/rules-manifest.yaml` that apply.
   - The relevant ADR from `agent-kit/platform/adr/`.

### 2. Mandatory Post-Edit Gate
Before presenting your work as done or answering the user:
```bash
bash agent-kit/scripts/run-rules-manifest.sh --changed
```
- If any `blocking` rule fails: **STOP**. Fix the code immediately. Do NOT present incomplete or failing work.
- Output the raw script verification results in your response as evidence.
