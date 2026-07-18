# Runewright

A skill and subagent factory for LLM agents. One GitHub marketplace supports two
runtimes: **Claude Code** and **Codex**. Runewright turns a workflow into a small,
source-grounded route that strong and smaller models can execute consistently.

## Included skills

| Skill | Purpose |
|---|---|
| `skill-brief` | Runs a one-to-three-round interview and records the task, triggers, sources, criteria, boundaries, and gold example. |
| `skill-generator` | Turns a request into a production-ready `SKILL.md`; automatically runs `skill-brief` when no ready brief exists. |
| `subagent-generator` | Creates a Claude Code Markdown role and/or Codex TOML role; automatically runs `skill-brief` when needed. |
| `skill-audit` | Audits environment skills for duplication, bloat, inactivity, and blueprint compliance, then writes a remediation plan. |
| `runewright-blueprint` | Defines the seven required elements, anti-patterns, language policy, and live-skill feedback contract used by the other skills. |

Typical loop: `skill-brief` -> `skill-generator` -> use the skill -> run
`skill-audit` periodically. Every generated skill keeps an append-only execution
log and can incorporate recurring feedback during later consolidation.

## Language behavior

The repository, manifests, templates, and skill instructions are English. At
runtime, Runewright:

- speaks in the language of the user's current request;
- writes a generated brief, skill, or agent in an explicitly requested language;
- otherwise writes the artifact in the language of the user's current request;
- keeps code, identifiers, paths, source IDs, YAML/TOML keys, and status tokens
  such as `DONE`, `PARTIAL`, and `BLOCKED` stable.

## Install from the GitHub marketplace

### Claude Code

From a terminal:

```bash
claude plugin marketplace add TinyFrontier/runewright
claude plugin install runewright@runewright
```

Or from an interactive Claude Code session:

```text
/plugin marketplace add TinyFrontier/runewright
/plugin install runewright@runewright
```

Invoke skills explicitly as `/runewright:skill-brief`,
`/runewright:skill-generator`, `/runewright:subagent-generator`, and so on. Claude
can also select them from their descriptions. Calling either generator without a
ready brief starts the brief interview automatically unless the user explicitly
asks to skip it.

### Codex

```bash
codex plugin marketplace add TinyFrontier/runewright
codex plugin add runewright@runewright
```

Start a new task after installation so Codex loads the plugin components. Invoke
skills explicitly as `$runewright:skill-brief`, `$runewright:skill-generator`, and
so on, or let Codex select one from its description.

Both marketplace commands can use a private repository when local Git is already
authorized. For public installation, make this repository public and publish the
files from the release branch.

### Local Codex development without a marketplace

```bash
git clone https://github.com/TinyFrontier/runewright.git
cd runewright
./install-codex.sh
./install-codex.sh --project /path/to/repo
```

The script creates symlinks in `~/.agents/skills` or
`<repo>/.agents/skills`, so `git pull` updates locally installed skills without a
plugin reinstall. If a destination is an ordinary file or directory, the script
reports a conflict and does not overwrite it.

## Project state

Generated and accumulated state lives in the platform-neutral `.runewright/`
directory at the project root:

```text
.runewright/
  sources/    # truth sources: INDEX.md, decisions/, external/
  feedback/   # skill and agent execution logs
  briefs/     # briefs written by skill-brief
  audits/     # skill-audit reports
```

`skill-generator` copies the initial `sources/` scaffold from
`skills/skill-generator/assets/sources-scaffold/` on first use.

## Design decisions

- **A skill is a route, not a textbook.** Knowledge lives under
  `.runewright/sources/`: derived truth is represented by a retrieval command,
  decided truth by a decision file with rationale, and external truth by a pointer
  with its last verification date. Skills cite stable IDs from a flat `INDEX.md`.
- **One skill format serves both platforms.** Agent Skills frontmatter contains
  `name` and `description`; the workflow lives in the body. Relative skill links,
  such as `../runewright-blueprint/SKILL.md`, work in Claude's plugin cache and
  through Codex skill symlinks.
- **Agent roles use two native formats.** `subagent-generator` writes YAML-frontmatter
  Markdown for Claude Code and TOML with `developer_instructions` for Codex while
  keeping one role contract and report format.
- **Hard size limits.** Skill body <= 150 lines, agent body <= 100 lines, and
  description <= 500 characters. Short descriptions reduce persistent context
  load and remain useful when a client truncates long skill lists.
- **No automatic deletion.** `skill-audit` proposes a plan. Destructive changes
  require separate user confirmation.

## Release validation

```bash
claude plugin validate . --strict
bash -n install-codex.sh
```

Update the release version together in `.claude-plugin/plugin.json` and
`.codex-plugin/plugin.json`. Current version: `0.3.0`.

## Limitations

- `install-codex.sh` requires a POSIX shell and is only needed for direct skill
  installation. Windows users should prefer marketplace installation.
- Claude Code and Codex use different subagent configuration formats, so a
  cross-platform role is represented by two files.
