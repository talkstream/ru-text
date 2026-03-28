---
name: ru-text
description: >
  Use when writing, editing, or reviewing Russian-language text, or when user
  mentions ru-text. Covers typography, info-style, editorial, UX writing, business
  correspondence. Auto-activates on Russian text output.
---

# ru-text — Russian Text Quality

Independent Russian text quality reference by Arseniy Kamyshev.
With gratitude to the authors whose work shaped modern Russian text standards.
Credits and recommended reading: [sources.md](references/sources.md)

**Style priority**: if the user explicitly requests a specific style (casual, academic, SEO, literary, etc.), their prompt overrides these default rules where they conflict. These rules are defaults, not mandates.

## Always-On: Typography

Apply these rules to ALL Russian text output without exception.

| Rule | Wrong | Correct |
|---|---|---|
| Primary quotes: guillemets | "текст" | «текст» |
| Nested quotes: lapki | «"вложенные"» | «„вложенные"» |
| Em dash with spaces | слово - слово | слово — слово |
| En dash for ranges, no spaces | 10-15 дней | 10–15 дней |
| NBSP after single-letter prepositions | в начале (breakable) | в\u00A0начале |
| Ellipsis: single character | ... | … |
| Digit groups with thin spaces | 1000000 | 1 000 000 |
| Decimal comma (not dot) | 3.14 | 3,14 |
| Ordinal with hyphen | 1ый, 2ой | 1-й, 2-й |
| Numero sign | No. 5, #5 | № 5 |
| Abbreviations with NBSP | т.д., т.е. | т. д., т. е. |
| Ruble symbol after number | 1500 руб | 1 500 ₽ |

Full typography reference: [typography.md](references/typography.md)

`/ru-text:ru-score` — text quality score (0–10, 5 dimensions).

## Top Stop-Words (remove or replace)

| Stop-word | Replace with |
|---|---|
| является | — (dash) or restructure |
| осуществлять | делать, проводить |
| в настоящее время | сейчас |
| данный | этот |
| определённый | (name the specific thing) |
| произвести оплату | оплатить |
| высококачественный | (name the specific quality) |
| был осуществлён | (active voice + actor) |
| на сегодняшний день | сегодня |
| в целях | чтобы |

Full stop-word catalog (97 entries): [info-style.md](references/info-style.md)

## When to Load Reference Files

| Task | Load |
|---|---|
| Writing/editing articles, blog posts, SEO, content | [info-style.md](references/info-style.md) |
| Interface text, buttons, errors, hints, microcopy | [ux-writing.md](references/ux-writing.md) |
| Emails, messenger, business correspondence | [business-writing.md](references/business-writing.md) |
| Punctuation review, comma placement | [editorial-punctuation.md](references/editorial-punctuation.md) |
| Grammar, capitalization, agreement, pleonasms | [editorial-grammar.md](references/editorial-grammar.md) |
| Finding and fixing text problems, diagnostics | [anti-patterns.md](references/anti-patterns.md) |
| Text scoring, quality assessment | [scoring.md](references/scoring.md) |
| Credits, source attribution | [sources.md](references/sources.md) |
| Experience-based rules (dash overuse, etc.) | [addenda.md](references/addenda.md) |

## Quality Checklist

Before delivering Russian text:

### Typography (mandatory)
- [ ] Quotes: «» primary, „" nested
- [ ] Dashes: — in text, – in ranges, - only in compounds; max 1–2 per paragraph
- [ ] NBSP after в, к, с, о, у, и, а
- [ ] Ellipsis: … (single char)
- [ ] Abbreviations: т. д., т. п. (with NBSP)
- [ ] No double spaces, no space before punctuation

### Writing quality (when creating/editing)
- [ ] No filler words (является, осуществляет, данный)
- [ ] Specific claims backed by facts or numbers
- [ ] Active voice preferred
- [ ] One idea per paragraph
- [ ] Reader benefit clear in every section

### Editorial (when proofreading)
- [ ] No tautology or pleonasm
- [ ] Lists grammatically homogeneous
- [ ] Capitalization follows Russian norms (no Title Case)
- [ ] Comma traps checked (однако, наконец, значит)
