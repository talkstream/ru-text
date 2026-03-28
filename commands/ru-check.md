---
name: ru-check
description: Run a comprehensive Russian text quality check on provided text or recent output
allowed-tools: Read, Grep, Glob
context: fork
---

# Russian Text Quality Check

Review the text provided in $ARGUMENTS (or the most recent Russian text output if no arguments) using the ru-text skill.

## Check order

1. **Typography** — apply all rules from [typography.md](../skills/ru-text/references/typography.md):
   - Quotes: «» primary, „" nested
   - Dashes: — (em) in text, – (en) in ranges, - (hyphen) in compounds only
   - Spaces: NBSP after single-letter prepositions, in digit groups, before units
   - Ellipsis, abbreviations, special characters

2. **Anti-patterns** — scan against [anti-patterns.md](../skills/ru-text/references/anti-patterns.md):
   - Bureaucratic language and nominalization
   - Passive voice overuse
   - Sentence bloat
   - Tautology and pleonasm

3. **Writing quality** — apply core principles from [info-style.md](../skills/ru-text/references/info-style.md):
   - Stop-words and filler
   - Specificity and facts
   - Structure and clarity

4. **Domain-specific** — load if text type is identifiable:
   - UI/interface text → [ux-writing.md](../skills/ru-text/references/ux-writing.md)
   - Email/business → [business-writing.md](../skills/ru-text/references/business-writing.md)
   - Needs grammar review → [editorial-punctuation.md](../skills/ru-text/references/editorial-punctuation.md) + [editorial-grammar.md](../skills/ru-text/references/editorial-grammar.md)

## Output format

Return:
1. Corrected text
2. List of changes grouped by category (typography / style / grammar / domain)
3. Severity per change: critical / high / medium / low
