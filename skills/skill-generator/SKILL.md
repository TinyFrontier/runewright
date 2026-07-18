---
name: skill-generator
description: >-
  Creates a production-ready Agent Skill from a request or brief using the seven
  Runewright elements, truth-source pointers, validation, and a feedback loop. If
  no ready brief exists, it runs skill-brief automatically. Use for "create a
  skill" or "turn this workflow into a skill." Do not use for a role needing
  isolated context or permissions; use subagent-generator instead.
---

# skill-generator

Produce a complete skill directory, not advice about how to create one. Read
`../runewright-blueprint/SKILL.md` before work and follow its language contract.
Execute the steps in order.

## Steps

1. **Read lessons.** Read the last five records in
   `.runewright/feedback/skill-generator.md`; skip when the file does not exist.

2. **Resolve the brief automatically.** Look for a matching ready brief in
   `.runewright/briefs/<name>.md`. When found, reuse all of it and ask only about
   the section whose semantic role is undefined gaps, regardless of its localized
   heading. When no ready brief exists and the user did not explicitly request
   no brief, read and execute `../skill-brief/SKILL.md` in the current conversation
   with the original request. Do not ask permission to start the interview. After
   the brief is written, return here and continue without another invocation.
   If the user explicitly skips the brief, ask once for all missing data:
   - 2-4 verbatim triggers and 1-2 adjacent requests that must not invoke the skill;
   - truth-source files, docs, databases, commands, or URLs;
   - verifiable done criteria and the likely failure;
   - the best existing output, if any.

3. **Initialize project state when needed.** If `.runewright/sources/` is absent,
   copy `assets/sources-scaffold/` from this skill into it. Register each named
   source in `sources/INDEX.md`; create an external source card for each URL. In
   the generated skill, cite stable source IDs and never copy source contents.

4. **Fill the template.** Use a kebab-case folder name matching frontmatter
   `name`; keep description <= 500 characters, body <= 150 lines, and workflow to
   3-9 verifiable steps with explicit branches. Avoid forceful filler such as
   repeated "always"; use a source or criterion instead. Write user-facing prose
   and headings in the brief's explicit artifact language, or otherwise in the
   language of the user's current request. Preserve code, paths, IDs, and keys.

5. **Create files.** Write `<skills-dir>/<name>/SKILL.md` and create
   `.runewright/feedback/<name>.md` with `# Feedback: <name>` if missing.

6. **Validate and repair until every item passes:**
   - [ ] Description states use cases and exclusions and is <= 500 characters.
   - [ ] Truth-sources section cites IDs or paths and says to ask, never invent.
   - [ ] Workflow has 3-9 numbered, verifiable steps and explicit branches.
   - [ ] Glossary has at most seven terms or is omitted.
   - [ ] Done checklist and concrete good and bad examples exist.
   - [ ] Gold-standard section links an example or explicitly says none exists yet.
   - [ ] First workflow step reads feedback and last step appends to it.
   - [ ] Body is <= 150 lines and contains no copied documentation.
   - [ ] YAML frontmatter is valid and contains only `name` and `description`.

7. **Finish.** Show the generated `SKILL.md` and one sentence explaining how to
   invoke it and what its first run does. Append this generator's feedback record
   using the blueprint contract.

## SKILL.md template

Localize human-facing headings and prose to the target artifact language while
preserving the semantic structure below.

```markdown
---
name: <kebab-case-name>
description: >-
  <What it does.> Use when: <verbatim triggers>. Do not use when: <anti-triggers>;
  use <alternative> instead.
---

# <Title>

## Truth sources
- `<source ID or path>` - <what to retrieve and at which step>
- Rule: if a fact is absent from sources, ask the user; never invent it.

## Terms
- **<term>** - <one-line definition>

## Workflow
1. Read the last five records in `.runewright/feedback/<name>.md` and apply lessons.
2. <action> -> <verifiable result>
N. Append the outcome to `.runewright/feedback/<name>.md`.

## Result criteria
Done when:
- [ ] <verifiable condition>
- [ ] Every factual claim cites a source.

Good: <specific one- or two-line example>.
Bad: <specific likely failure in one or two lines>.

## Gold standard
<`examples/<file>` accepted unchanged on <date> | no gold standard yet; save and
link the first result accepted unchanged>
```

## Generator result criteria

Done when the skill and feedback log exist and all nine validation checks pass.

Good: a smaller model can execute the skill without clarification.

Bad: copied source content or a description without anti-triggers.
