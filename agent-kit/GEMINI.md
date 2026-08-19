@AGENTS.md

# Gemini CLI specific

- Load `/platform/rules-manifest.yaml` and `/platform/adr/` at the start of every session, not just once per project — do not rely on anything cached from a prior session.
- When proposing a plan before executing, include the applicable rule IDs as part of the plan, not as an afterthought after code is written.
- Report the literal stdout of `scripts/run-rules-manifest.sh` in your response — a paraphrase or a summary is not sufficient evidence of compliance.
