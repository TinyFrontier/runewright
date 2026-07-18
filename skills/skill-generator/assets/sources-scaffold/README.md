# Truth sources (`.runewright/sources/`)

This is the single place from which skills and agents retrieve facts. A skill
contains a pointer here, never the knowledge itself. At runtime, the agent reads
and cites the source. When no source exists, it asks the user instead of inventing
an answer.

## Three kinds of truth

- **Derived truth**, such as repository structure, current APIs, or route lists,
  is not stored. Store a retrieval command such as `curl <url>/openapi.json` or
  `ls src/routes`; a saved copy becomes stale immediately.
- **Decided truth**, such as stack choices, conventions, or product boundaries,
  belongs in `decisions/`: one decision and its rationale per file. It is the only
  truth type stored here in full because it cannot be derived elsewhere.
- **External truth**, such as vendor docs, specifications, or dashboards, is a
  pointer in `external/`: URL, what to find, how to read it, and verification date.

## Rules

- Skills cite stable IDs from the flat `INDEX.md` (`DEC-*`, `EXT-*`, `CMD-*`), not
  paths. A file can move after one registry row is updated.
- Before adding a factual claim to a skill, add a source card and registry row,
  then cite its ID.
- When a source conflicts with reality, update the source. Supersede a decision
  with a new one; do not teach the discrepancy to a skill.
- skill-audit checks broken IDs, external pointers older than 90 days, and
  decisions without rationale.

## Structure

```text
.runewright/
  sources/
    INDEX.md     # flat registry, read in full
    decisions/   # DEC-*.md; use _TEMPLATE.md
    external/    # EXT-*.md; use _TEMPLATE.md
  feedback/      # skill execution logs; see runewright-blueprint
  briefs/        # briefs from skill-brief
  audits/        # reports from skill-audit
```
