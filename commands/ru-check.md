---
name: ru-check
description: Run a comprehensive Russian text quality check on provided text or recent output
allowed-tools: Read, Grep, Glob
context: fork
---

# Russian Text Quality Check

Review the text provided in $ARGUMENTS (or the most recent Russian text output if no arguments) using the ru-text skill.

## Setup: locate reference files

1. `Glob("**/ru-text/references/scoring.md", path: "~/.claude/plugins/cache/")`
2. The parent directory of the result = REFS (if multiple results, use the last one)
3. All reference files below are at `REFS/<filename>`

## Check order

1. **Typography** — read `REFS/typography.md`, then apply:
   - Quotes: «» primary, „" nested
   - Dashes: — (em) in text, – (en) in ranges, - (hyphen) in compounds only
   - Spaces: NBSP after single-letter prepositions, in digit groups, before units
   - Ellipsis, abbreviations, special characters

2. **Anti-patterns** — read `REFS/anti-patterns.md`, then scan for:
   - Bureaucratic language and nominalization
   - Passive voice overuse
   - Sentence bloat
   - Tautology and pleonasm

3. **Writing quality** — read `REFS/info-style.md`, then apply:
   - Stop-words and filler
   - Specificity and facts
   - Structure and clarity

4. **Domain-specific** — load if text type is identifiable:
   - UI/interface text → `REFS/ux-writing.md`
   - Email/business → `REFS/business-writing.md`
   - Needs grammar review → `REFS/editorial-punctuation.md` + `REFS/editorial-grammar.md`

## Output format

Return:
1. Corrected text
2. List of changes grouped by category (typography / style / grammar / domain)
3. Severity per change: critical / high / medium / low
