---
name: skill-audit
description: >-
  Audits all skills, agents, and commands in a Claude Code and/or Codex
  environment for duplication, bloat, inactivity, and compliance with the seven
  Runewright elements; writes a remediation plan without deleting anything. Use
  for "audit my skills" or after installing plugins. Do not use to edit one
  specific skill; use skill-generator instead.
---

# skill-audit

Run a repeatable autonomous audit. Do not delete or edit components; report facts
and a plan only. Apply changes in a separate turn after user confirmation. Read
`../runewright-blueprint/SKILL.md` before starting and follow its language contract.

Read the last five records in `.runewright/feedback/skill-audit.md`; skip when the
file does not exist.

## Step 1 - Inventory

Collect path, byte size, line count, and type for every component on platforms
present in the environment:

- Claude Code: `.claude/skills/*/SKILL.md`, `.claude/agents/*.md`, and
  `.claude/commands/*.md`; user-level `~/.claude/skills|agents`; plugin paths from
  `~/.claude/plugins/installed_plugins.json` into `<installPath>/skills|agents|commands`,
  using only the latest installed version of each plugin.
- Codex: project and parent `.agents/skills/*/SKILL.md`, plus
  `~/.agents/skills/*/SKILL.md`.

Exclude templates and scaffolds nested inside plugins.

## Step 2 - Usage

- Inspect `.runewright/feedback/*.md`: a live skill has a non-empty log; an empty
  log for a skill older than one month suggests non-use.
- Inspect available platform history, such as command mentions in
  `~/.claude/history.jsonl`.

Keep `not used` distinct from `no usage data`.

## Step 3 - Blueprint compliance

Rate every skill or agent on the seven blueprint elements with stable values
`OK`, `WEAK`, or `MISSING`. Also check: description <= 500 characters with
triggers and anti-triggers; skill body <= 150 lines; agent body <= 100 lines;
valid YAML; name matches its folder or filename; no copied documentation; no
broken file references.

## Step 4 - Duplication and structure

- Group overlapping components: a command, skill, and agent for one function;
  skills with the same triggers; or the same skill under different Claude and
  Codex names. Recommend one canonical entry point and links or removal for the rest.
- Mark sub-skills with only one parent as merge candidates.
- Identify stale plugin-cache versions.
- Estimate total description load as bytes divided by four and the savings from
  removing duplicates or inactive components.

## Step 5 - Missing pieces

- For skills without truth sources, list claims the agent is expected to remember.
- Find recurring domains with no skill; ask the user for domains only when the
  project does not make them evident.
- Find feedback loops that only read or only write and logs needing consolidation:
  ten or more records or repeated edits.

## Step 6 - Report

Write `.runewright/audits/audit-<YYYY-MM-DD>.md`, creating the directory if needed.
Write prose and localize human-facing headings in the target artifact language
from the blueprint. Preserve the following semantic structure:

```markdown
# Skill audit - <date>
## Summary
Total: N skills, M agents, K commands. Description load: about X tokens.
## REMOVE (requires confirmation)
| Component | Evidence-based reason | Savings |
## MERGE
| Group | Canonical entry point | Action for the rest |
## IMPROVE
| Component | Missing blueprint elements | Concrete change |
## CREATE
| Domain or task | Recurrence evidence |
## Application plan
Numbered order: removals and merges after confirmation; improvements through
skill-generator; new skills through skill-brief.
```

Show the summary and plan to the user. Append a record to this skill's feedback log.

## Result criteria

Done when the report exists, every verdict cites evidence such as a path, size,
or date, and only the report and feedback log changed.

Good: `graphify: 56.8 KB and about 1,150 lines of code in SKILL.md; move code to
scripts/ and add anti-triggers to the description` - fact, diagnosis, and action.

Bad: `skill X seems unnecessary` - no size, usage evidence, or concrete action.

## Gold standard

No gold standard yet. Link the first report whose plan the user accepts unchanged.
