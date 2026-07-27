---
name: ru-check
description: Run a comprehensive Russian text quality check on provided text or recent output
allowed-tools: Read, Grep, Glob
disallowed-tools: Write, Edit, NotebookEdit, Bash, PowerShell, Monitor
context: fork
user-invocable: true
disable-model-invocation: true
---

# Russian Text Quality Check

Review the text provided in $ARGUMENTS (or the most recent Russian text output if no arguments) using the ru-text skill.

## Check order

## Where the reference files live

This skill reads the corpus that ships with the **ru-text** skill, which is installed
alongside it. Locate that folder once, then read the named files from it:

- Look for a directory named `references` whose parent directory is named `ru-text`, and
  which contains `info-style.md`. Every file named below sits in that folder.
- In Claude Code the plugin root is also available directly, which saves the search.
- **Do not guess a path.** If the folder cannot be found, say so and stop — a check run
  against remembered rules instead of the corpus is not this command, and reporting one
  as the other is the failure this whole product exists to prevent.

1. **Typography** — read `typography.md`, then apply:
   - Quotes: «» primary, „" nested
   - Dashes: — (em) in text, – (en) in ranges, - (hyphen) in compounds only
   - Spaces: NBSP after single-letter prepositions, in digit groups, before units
   - Ellipsis, abbreviations, special characters

2. **Anti-patterns** — read `anti-patterns.md`, then scan for:
   - Bureaucratic language and nominalization
   - Passive voice overuse
   - Sentence bloat
   - Tautology and pleonasm

3. **Writing quality** — read `info-style.md`, then apply:
   - Stop-words and filler
   - Specificity and facts
   - Structure and clarity

4. **Domain-specific** — load if text type is identifiable:
   - UI/interface text → `ux-writing.md`
   - Email/business → `business-writing.md`
   - Needs grammar review → `editorial-punctuation.md` + `editorial-grammar.md`

5. **Experience-based / neuroslop** — read `addenda.md`, then scan for the AI-generated-prose tells:
   - Manufactured antithesis (AD-6) — «не X, а Y» / «не просто X, а Y» with no antecedent
   - Preemptive virtue qualifier (AD-7) — «без воды», «чётко, по делу»
   - Assistant-register meta-commentary (AD-8) — «Отличный вопрос!», «Надеюсь, это помогло»
   - Hollow openers (AD-9) — «давайте разберёмся», «погрузимся», «важно понимать, что»

## Output format

**Read-only — do NOT modify the source files.** `ru-check` is a *check*: it reports issues and returns the corrected text for the user to apply. It must not write to, edit, or overwrite the analysed file(s).

How this is enforced depends on the host, and it is worth being exact about it.

In Claude Code, `disallowed-tools` removes the listed tools from the pool while the command is active — verified on 2.1.220 by attempting a write through `Write`, through `Bash` redirection, through `Monitor`, and through a delegated subagent: every path was denied and no file was created. `allowed-tools` alone would not achieve this; that field pre-approves tools, it does not restrict them.

The list removes the direct file-writers — `Write`, `Edit`, `NotebookEdit` — and the command-executing tools we identified and tested on 2.1.220: `Bash`, `PowerShell` and `Monitor`. `Monitor` is easy to miss: it runs commands too, and it follows `Bash` permission rules, so a broad `Bash` allow-rule silently pre-approves it while a `disallowed-tools: Bash` entry does not remove it. **The list names the paths we closed, not every path that exists.**

Four limits, stated plainly. A connected MCP server can expose its own write tools, which a per-tool denial list cannot know about. A named subagent whose own definition grants it `tools: Write` is governed by that definition, not by a parent command's denial list. A later Claude Code release can add a tool this file does not name, and a hand-written list does not update itself. And on hosts that do not implement `disallowed-tools`, everything above is an instruction the agent is asked to follow, not a guarantee the platform enforces.

Where the mechanism ends, the contract does not: the rule is that this command returns text and never writes, on every host, whatever the tool roster happens to contain.

Returning the corrected text in the output rather than writing it keeps the command deterministic and free of side effects. Silently inserting NBSP into a source file is doubly harmful: a target that strips NBSP on import (e.g. Notion) shows the reader no change, and the same insertion breaks later exact-string tooling (grep/replace) on that file.

Return:
1. Corrected text
2. List of changes grouped by category (typography / style / grammar / domain)
3. Severity per change: critical / high / medium / low
