---
name: runewright-blueprint
description: >-
  Reference standard for Runewright: seven required skill elements,
  anti-patterns, language policy, and the live-skill feedback contract. Read by
  skill-generator, subagent-generator, and skill-audit. Use directly only to
  inspect the standard. Do not use to create a skill; use skill-brief or
  skill-generator instead.
---

# Runewright Blueprint

A skill is a route, not a textbook. Knowledge lives in project truth sources
under `.runewright/sources/`; a skill says where to look and in what order to
act. This gives strong and small models the same reproducible route.

Limits: `description` <= 500 characters; skill body <= 150 lines; agent body
<= 100 lines.

## Language contract

- Repository instructions, templates, comments, and stable control tokens are English.
- Converse in the language of the user's current request.
- Generated artifact language: explicit requested language first; otherwise the
  language of the user's current request.
- Localize human-facing prose and headings while preserving their semantic roles.
- Keep code, identifiers, paths, source IDs, YAML/TOML keys, `DONE`, `PARTIAL`,
  `BLOCKED`, and feedback enum values unchanged.

## Seven required skill elements

1. **Description with triggers and anti-triggers.** The description is all an
   agent sees before invocation. Formula: what it does; use when phrased as the
   user would ask; do not use for adjacent cases and name the alternative.
   - [ ] Includes use cases and exclusions; <= 500 characters.

2. **Truth sources.** Point to source IDs, paths, or retrieval commands; never
   copy documentation. Every factual claim must be traceable to a source.
   - [ ] Has a truth-sources section and says: ask when missing; never invent.

3. **Ordered workflow.** Use 3-9 numbered steps in strict order. Each step is one
   action with a verifiable result; branches are explicit.
   - [ ] Has 3-9 verifiable steps and explicit branches.

4. **Concise terms.** Define at most seven terms in one line each, then use those
   terms without repeating the explanation.
   - [ ] Glossary has at most seven entries, or is omitted when unnecessary.

5. **Result criteria.** Provide a verifiable done checklist, one concrete good
   example, and one concrete bad example that exposes the likely failure mode.
   - [ ] Has a done checklist plus good and bad examples.

6. **Gold-standard examples.** Link to one or two accepted outputs and state why
   they worked, with a metric. If none exists, say the first output accepted
   unchanged becomes the gold standard.
   - [ ] Links a measured example or explicitly states that none exists yet.

7. **Feedback loop.** The workflow reads recent feedback first and appends an
   execution record last. Use the contract below.
   - [ ] First step reads feedback; last step appends to it.

## Anti-patterns

| Anti-pattern | Rule |
|---|---|
| Empty wrapper that only says "invoke X" | A wrapper adds parsing or context, or does not exist. |
| Same function as command, skill, and agent | One function has one entry point; other components link to it. |
| Sub-skill with one parent | Extract a sub-skill only when at least two parents reuse it. |
| More than 150 lines or copied documentation | Move knowledge to sources; keep only the route. |
| Too many skills | Add one only for a task that has repeated at least three times. |
| Repeated "always" and "must" | Replace forceful tone with a source or verifiable criterion. |
| Copied external documentation | Store a pointer and verification date; let skill-audit check freshness. |

## Live-skill feedback contract

Log: `.runewright/feedback/<skill-name>.md`; agents use
`agent-<name>.md`. The log is append-only and is created on first use.

```markdown
## <YYYY-MM-DD> <task in 3-5 words>
- Outcome: accepted unchanged | accepted with edits | reworked | rejected
- User edits: <specific changes | none>
- Lesson: <one rule that changes the next run | none>
- Gold candidate: <path when accepted unchanged | none>
```

Rules:

- One record represents one run and is written by the executor. Never edit past
  records; revoke a bad lesson with `Lesson revoked from <date>: <reason>`.
- Read the last five records at startup, not the whole file. The workflow wins over
  a conflicting lesson; record the conflict in a new entry.
- Quality signals: a rising `accepted unchanged` share means lessons work; the
  same edit twice means consolidate it; two consecutive `reworked` outcomes mean
  the skill is broken and should be rebuilt through skill-generator.

Consolidate after ten records since the last consolidation, a repeated edit, or a
scheduled audit:

1. Read the full log and group lessons as repeated, one-off, or revoked.
2. Put repeated lessons in the right place: selection error -> anti-trigger;
   order error -> workflow; quality error -> criteria and bad example; factual
   error -> truth source, not the skill.
3. Move the best accepted-unchanged output to `examples/` and update the gold link.
4. Recheck all seven elements and limits; when adding a lesson, remove any text
   that is no longer needed.
5. Append: `## <date> CONSOLIDATION - lessons X and Y moved; ignore earlier log`.
