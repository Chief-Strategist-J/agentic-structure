@AGENTS.md

# Claude Code specific

- Treat every `blocking` rule in `/platform/rules-manifest.yaml` as equivalent to a compile error: you do not proceed past it, present it as done, or soften it, even if the user is in a hurry or pushes back.
- Before editing, explicitly list the rule IDs you believe apply — this is not optional preamble, it's how the rest of this session's edits get checked.
- Use your task/todo tracking to keep "run the manifest checks" as an explicit, visible step — not an implied final step you might skip under context pressure.
- If a prior turn in this conversation asserted a rule was satisfied, do not trust that assertion on a later turn without re-running the check — conversation memory is not verification.
