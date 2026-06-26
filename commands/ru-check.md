---
name: ru-check
description: Run a comprehensive Russian text quality check on provided text or recent output
allowed-tools: Read, Grep, Glob
context: fork
---

# Russian Text Quality Check

Review the text provided in $ARGUMENTS (or the most recent Russian text output if no arguments) using the ru-text skill.

## Check order

Reference files: `${CLAUDE_PLUGIN_ROOT}/skills/ru-text/references/<filename>`

1. **Typography** — read `${CLAUDE_PLUGIN_ROOT}/skills/ru-text/references/typography.md`, then apply:
   - Quotes: «» primary, „" nested
   - Dashes: — (em) in text, – (en) in ranges, - (hyphen) in compounds only
   - Spaces: NBSP after single-letter prepositions, in digit groups, before units
   - Ellipsis, abbreviations, special characters

2. **Anti-patterns** — read `${CLAUDE_PLUGIN_ROOT}/skills/ru-text/references/anti-patterns.md`, then scan for:
   - Bureaucratic language and nominalization
   - Passive voice overuse
   - Sentence bloat
   - Tautology and pleonasm

3. **Writing quality** — read `${CLAUDE_PLUGIN_ROOT}/skills/ru-text/references/info-style.md`, then apply:
   - Stop-words and filler
   - Specificity and facts
   - Structure and clarity

4. **Domain-specific** — load if text type is identifiable:
   - UI/interface text → `${CLAUDE_PLUGIN_ROOT}/skills/ru-text/references/ux-writing.md`
   - Email/business → `${CLAUDE_PLUGIN_ROOT}/skills/ru-text/references/business-writing.md`
   - Needs grammar review → `${CLAUDE_PLUGIN_ROOT}/skills/ru-text/references/editorial-punctuation.md` + `${CLAUDE_PLUGIN_ROOT}/skills/ru-text/references/editorial-grammar.md`

5. **Experience-based / neuroslop** — read `${CLAUDE_PLUGIN_ROOT}/skills/ru-text/references/addenda.md`, then scan for the AI-generated-prose tells:
   - Manufactured antithesis (AD-6) — «не X, а Y» / «не просто X, а Y» with no antecedent
   - Preemptive virtue qualifier (AD-7) — «без воды», «чётко, по делу»
   - Assistant-register meta-commentary (AD-8) — «Отличный вопрос!», «Надеюсь, это помогло»
   - Hollow openers (AD-9) — «давайте разберёмся», «погрузимся», «важно понимать, что»

## Output format

**Read-only — do NOT modify the source files.** `ru-check` is a *check*: it reports issues and returns the corrected text for the user to apply. It must not write to, edit, or overwrite the analysed file(s) — its `allowed-tools` are `Read, Grep, Glob` by design. Returning the corrected text in the output (not writing it) keeps the command deterministic and free of side effects. Silently inserting NBSP into a source file is doubly harmful: a target that strips NBSP on import (e.g. Notion) shows the reader no change, and the same insertion breaks later exact-string tooling (grep/replace) on that file.

Return:
1. Corrected text
2. List of changes grouped by category (typography / style / grammar / domain)
3. Severity per change: critical / high / medium / low
