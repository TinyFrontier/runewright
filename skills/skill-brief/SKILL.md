---
name: skill-brief
description: >-
  Interviews the user before creating a skill or subagent role, collecting the
  task, triggers, truth sources, criteria, boundaries, and gold example in one to
  three rounds, then writes a generator-ready brief. Use when requirements are
  still in the user's head. Do not use when a complete brief already exists or
  when gathering product or documentation requirements instead.
---

# skill-brief

Extract task knowledge before generation so the result is correct on its first
run. Write `.runewright/briefs/<name>.md` for skill-generator or
subagent-generator. Never invent an answer for the user. Read
`../runewright-blueprint/SKILL.md` and follow its language contract.

First read the last five records in `.runewright/feedback/skill-brief.md`; skip
when the file does not exist.

## Interview rules

- One round is one message with 3-5 questions. Stop after three rounds; record
  remaining gaps as undefined.
- Do not ask for facts already stated or derivable from project files. Inspect
  existing skills and `.runewright/sources/INDEX.md` first.
- The most valuable input is the manual walkthrough in round 1: how the user last
  performed the task, step by step. Derive the workflow, sources, and criteria
  from it, then ask only to close gaps.
- `I don't know` and `it varies` are valid answers. Record them without pressure.
- Ask questions in the language of the user's current request. Write the brief in
  an explicitly requested artifact language, or otherwise in that same language.

## Rounds

**Round 1 - task and walkthrough:**

1. What is the task in one sentence, and what form should the result take?
2. How often does it recur, and who runs it: you, a smaller model, or both?
3. Walk me through the last time you did it: where you started, what you checked,
   what you decided, and how you finished. An unordered account is fine.
4. Share the best finished example if one exists: a path or link.

**Round 2 - close only observed gaps:**

- Triggers: what exact 2-4 phrases would you use to request this task?
- Anti-triggers: what similar requests mean a different task, and where should
  they be routed?
- Sources: where does the truth live for each step: files, databases, docs, URLs?
- Branches: what changes for variants from the walkthrough, including rare but
  required cases?

**Round 3 - criteria and boundaries, only when missing:**

- What verifiable signs mean the result is accepted?
- What mistake is the executor most likely to make? Has it happened before?
- What files, actions, or other roles are out of bounds?
- Does the task need isolated context or parallel work, suggesting a subagent?
- For a subagent, also confirm platform, scope, permissions, self-contained input,
  parallelism, and report format.

## Brief template

Localize prose and human-facing headings to the target artifact language while
preserving these semantic sections so generators can find them by meaning:

```markdown
# Skill or subagent brief: <name>
Date: <date>. Status: ready for generation | gaps remain

## Task and result
<one or two sentences plus result format>
Recurrence: <frequency and executor>

## Triggers - verbatim from the user
- "<phrase>"
## Anti-triggers
- "<phrase>" -> <alternative>

## Manual walkthrough
1. <step> - source: <where the truth lives>
Branches: <if X, then ...>

## Truth sources
- <path, URL, or database> - <what to retrieve>

## Criteria
Done: <verifiable conditions>
Likely failure: <from the user's answers>
## Gold standard
<path | none; use the first accepted result>
## Boundaries
<prohibited actions>
## Executor
<skill | skill plus subagent and why>
## Undefined
<gaps to clarify on first run | none>
```

## Completion

1. Create `.runewright/briefs/` if needed, write the brief, and show a five-line
   summary plus the undefined items.
2. Offer to continue immediately with the appropriate generator; it should reuse
   the brief and ask only about undefined items.
3. Append a record to `.runewright/feedback/skill-brief.md` using the live-skill
   contract; create the file when missing.

## Result criteria

Done when every semantic section exists, the manual walkthrough has at least
three sourced steps, and gaps are explicitly listed.

Good: the generator needs no question except those listed as undefined.

Bad: the model invents triggers instead of recording the user's exact phrases.
