---
name: subagent-generator
description: >-
  Creates a subagent role for the active platform: Claude Code Markdown or Codex
  TOML, with boundaries, minimal permissions, parallelism, and a fixed report
  contract. If no ready brief exists, it runs skill-brief automatically. Use for
  "create an agent" or work needing isolated or parallel context. Do not use when
  separate context or permissions are unnecessary; use skill-generator instead.
---

# subagent-generator

Create role configuration for the requested platform. Read
`../runewright-blueprint/SKILL.md` first and follow its language contract. Execute
the steps in order.

## Terms

- **Platform** - Claude Code or Codex; do not infer it only from existing folders.
- **Scope** - project, stored in the repository, or user, stored in the home folder.
- **Role** - one narrow responsibility with its own context.

## Skill or subagent?

Use a subagent only when at least one condition holds:

- work should be isolated from orchestrator context, such as search or large logs;
- the role needs distinct permissions or a model;
- independent parts can run in parallel.

Otherwise stop and recommend skill-generator.

## Steps

1. **Read lessons.** Read the last five records in
   `.runewright/feedback/subagent-generator.md`; skip when missing.

2. **Resolve the brief automatically.** Reuse a matching ready brief in
   `.runewright/briefs/<name>.md`. If none exists and the user did not explicitly
   request no brief, execute `../skill-brief/SKILL.md` in the current conversation
   with the original request. Do not ask permission to interview. For this role,
   ensure the brief covers self-contained input, boundaries, permissions,
   platform, parallelism, report format, and `skill plus subagent` as executor.
   Continue here after writing the brief, without another invocation. If the user
   explicitly skips the brief, collect all missing fields in one message.

3. **Choose platform and scope.** Explicit user choice beats environment clues.
   For a cross-platform role, create both formats. Otherwise use the active client;
   ask one question only if it cannot be determined. Check for duplicates:
   - Claude Code: `.claude/agents/*.md` or `~/.claude/agents/*.md`;
   - Codex: `.codex/agents/*.toml` or `~/.codex/agents/*.toml`.
   If the role exists, offer to improve it and stop.

4. **Design least privilege.** For a read-only Claude role, use `Read, Glob, Grep`
   and add `Bash` only when needed; for Codex use `sandbox_mode = "read-only"`.
   For a writing Claude role, add only required `Write`, `Edit`, and `Bash`. For a
   writing Codex role, inherit the parent's sandbox unless a wider policy has an
   explicit reason. Inherit model and reasoning unless the user requests otherwise.

5. **Create one or two files:**
   - Claude project/user: `.claude/agents/<name>.md` or
     `~/.claude/agents/<name>.md`, using template A;
   - Codex project/user: `.codex/agents/<name>.toml` or
     `~/.codex/agents/<name>.toml`, using template B.
   Create `.runewright/feedback/agent-<name>.md` when missing. Write human-facing
   role prose in the explicitly requested language, or otherwise the language of
   the user's current request. Keep keys, paths, and report control tokens stable.

6. **Validate and repair.** Require kebab-case name; trigger and anti-trigger in
   description; self-contained input; explicit prohibitions; least privilege;
   fixed report format; and defined parallelism. Validate Markdown YAML. Validate
   TOML and require `name`, `description`, and `developer_instructions`.

7. **Finish.** Show each path and a delegation example. If both formats exist,
   explain that they describe one role but must not reference each other. Append
   this generator's feedback record using the blueprint contract.

## Template A - Claude Code

Localize human-facing headings and prose, but preserve frontmatter keys and the
report labels and status values below.

```markdown
---
name: <kebab-case-name>
description: <role>. Use when: <conditions>. Do not use when: <cases>.
tools: <minimal comma-separated list>
---

You are <role>.

## Input
The orchestrator provides <paths, task, criteria>. If data is missing, return BLOCKED.

## Truth sources
- `<ID or path>` - <what to retrieve>. If a fact is absent, never invent it.

## Workflow
1. <action> -> <verifiable result>
N. Return the required report.

## Prohibited
- <action or area outside responsibility>

## Parallelism
<Up to N copies plus partition rule | one instance plus reason>.

## Report format
STATUS: DONE | PARTIAL | BLOCKED
RESULT: <paths or findings>
VERIFIED: <criteria and evidence>
ISSUES: <issues | none>
```

## Template B - Codex

```toml
name = "<kebab-case-name>"
description = "<role>. Use when: <conditions>. Do not use when: <cases>."
sandbox_mode = "read-only"
developer_instructions = """
You are <role>.

Input: the orchestrator provides <paths, task, criteria>. Missing data means BLOCKED.
Truth sources: <IDs or paths>. Never invent an absent fact.
Workflow: <3-9 verifiable steps>.
Prohibited: <boundaries>.
Parallelism: <N copies and partition rule | one instance plus reason>.

Final report:
STATUS: DONE | PARTIAL | BLOCKED
RESULT: <paths or findings>
VERIFIED: <criteria and evidence>
ISSUES: <issues | none>
"""
```

For a writing Codex role, remove `sandbox_mode` so it inherits parent policy; do
not grant broader permissions automatically.

## Result criteria

Done when every requested platform has a valid file, permissions are minimal,
and the role can be delegated without conversation history.

Good: Claude and Codex variants of one role return the same report contract.

Bad: full permissions with the input `do what we discussed`.
