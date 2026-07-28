# ru-text

[![Version](https://img.shields.io/github/v/release/talkstream/ru-text?label=version&color=2ea44f)](https://github.com/talkstream/ru-text/releases/latest) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Platforms](https://img.shields.io/badge/platforms-12-blue)](#quick-start) [![Claude Code Plugin](https://img.shields.io/badge/Claude_Code-Plugin-blue?logo=anthropic)](https://github.com/anthropics/claude-plugins-community) [![GitHub Sponsors](https://img.shields.io/badge/Sponsor-30363D?logo=GitHub-Sponsors&logoColor=EA4AAA)](https://github.com/sponsors/talkstream) [![GitHub stars](https://img.shields.io/github/stars/talkstream/ru-text?style=flat&label=stars)](https://github.com/talkstream/ru-text/stargazers) [![Last commit](https://img.shields.io/github/last-commit/talkstream/ru-text/main?label=updated)](https://github.com/talkstream/ru-text)

**Languages:** [Русский (primary)](README.md) | English

**Russian text quality plugin for Claude Code, Codex, Notion, Cursor, GitHub Copilot, and [7 more platforms](#quick-start)** — typography, information style, editorial standards, UX writing, and business correspondence.

Over 2,000 independently formulated linguistic atoms (rules, wrong → right pairs, dictionary entries and carve-outs), informed by 16 canonical Russian-language sources. All formulations are original — no verbatim quotes, full attribution.

## Acknowledgments

This plugin exists because a handful of people decided that Russian text on the internet deserves better. They wrote the books, built the tools, maintained the guides, and set the standards that thousands of editors, writers, and designers now rely on every day. Their work fundamentally changed how Russian text is written, formatted, and read on screens. I am deeply grateful to every one of them. If this plugin saves you time, please buy their books and use their tools — they earned it.


## What it does

ru-text gives your AI coding assistant a deep understanding of Russian text quality. It auto-activates when the assistant produces or edits Russian text, applying typography rules instantly and loading domain-specific knowledge on demand.

Works with Claude Code (CLI and Desktop), Codex CLI, Notion, Cursor, GitHub Copilot, Gemini CLI, Google Antigravity, Windsurf, Continue.dev, Cline, JetBrains (Junie), and OpenClaw.

- **2,000+ atoms** across 7 domains, spread over 10 reference files
- **Auto-activation** — no need to remember to turn it on
- **Covers everything** — from em dashes and guillemets to UX microcopy and business email tone
- **Non-dogmatic** — your explicit style request always overrides default rules

## Use cases

**This README.** Every dash, quote, and space you see here follows the plugin's own rules. This document was written with ru-text active.

**UX microcopy.** Writing buttons, errors, empty states for a Russian app. The plugin loads 217 UX rules: "Отмена" not "Нет", error structure (what happened + what to do), placeholders as examples, not instructions.

**Business email.** Drafting an email to colleagues or clients. The plugin kills bureaucratic language ("довожу до сведения" → "сообщаю"), structures subject + first sentence + call to action, and suggests respectful tone without being servile.

**Landing page copy.** Writing an "About" section for an IT company. The plugin replaces cliches ("команда профессионалов", "индивидуальный подход") with specific facts and numbers.

**README and documentation.** Writing docs for an open-source project in Russian. Proper typography (guillemets, em dashes, non-breaking spaces), clear inverted-pyramid structure.

**Cleaning up AI-slop.** Text reads as machine-generated. The plugin catches sixteen tells. Nine of them are visible in the fragment itself:

- manufactured antithesis ("не X, а Y" with no antecedent);
- preemptive self-praise ("чётко, по делу, без воды");
- assistant-register filler ("Отличный вопрос!", "Надеюсь, помог");
- hollow openers ("давайте разберёмся", "погрузимся");
- declared sincerity ("скажу честно");
- the mandatory tricolon where two items would have done;
- hollowed mechanism: the sentence describes a mechanism, but the working part is a placeholder;
- phantom attribution ("как показывают исследования" with no study behind it);
- the additive pseudo-pair ("не только X, но и Y" where Y adds nothing to X).

Five more: em-dash overuse, parcellation, patronizing explanation, unprovoked rebuttal, and a subject that does not agree with its predicate.

Two tells are charged to the whole document rather than to a fragment, because no local edit repairs them: a piece that stayed a chat transcript, and a piece written for a search engine instead of a reader.

Every tell carries a carve-out naming where the device is legitimate: a quotation, an analysis of someone else's text, a legal formula, a list with nowhere for a fourth item to come from. The plugin reads the carve-out before it raises the finding.

**Text quality scoring.** Want to know how your text measures up? `/ru-text:ru-score` evaluates text across 5 dimensions (typography, clarity, grammar, structure, reader precision) and returns a 0.0–10.0 score with specific issues per dimension. The number is printed as it computed, but the top labels have a floor under them: a document that turned out to be a chat transcript, or one written for a search engine, is never labelled "Эталонный" or "Хороший" whatever the arithmetic — and the rubric names the rule that capped the label.

**AI agent quality.** Building AI features in your product? Uncertain how the agent will phrase responses in Russian? ru-text ensures predictable, high-quality Russian text from any Claude-powered agent: consistent typography, no bureaucratic language, reader-first structure.

## Quick start

Hand this sentence to your AI agent:

> Install the skill https://github.com/talkstream/ru-text globally and use it for any task involving Russian text: proofreading, typography, editorial work, UX copy, business correspondence.

It takes it from there: where its own platform keeps skills is something the agent knows
better than an instruction written a year ago. Verified with Claude Code, Codex CLI, Cursor,
GitHub Copilot, Gemini CLI, Google Antigravity, Windsurf, Continue.dev, Cline, JetBrains
Junie, OpenClaw and Notion.

Installing by hand, agent got it wrong, or your platform installs through its own tool —
[INSTALL.en.md](INSTALL.en.md): every platform's directory with the vendor URL it came from,
the Claude Desktop and Notion click-paths, four facts no amount of trial can discover, and
updating.

Start writing Russian text — the plugin takes over automatically. If ru-text makes your
products better, consider [sponsoring](https://github.com/sponsors/talkstream) continued
development.

## Updating ru-text

Latest version — **v1.10.1**, see the [CHANGELOG](CHANGELOG.md) for what changed.

A one-shot install has no update mechanism: the agent installed the skill and forgot about
it. Every few months, ask it to run the install again. Per-platform update commands live in
[INSTALL.en.md](INSTALL.en.md#updating).

One thing worth knowing up front: the Claude Code community marketplace pins the plugin to a
specific commit rather than tracking releases, and the pin trails the current version by
months. `claude plugins list` shows the version you actually have.

## The corpus

Each section is a separate reference file, loaded on demand. Open any of them and count the rules yourself — that is more reliable than a number maintained by hand.

| Section | Reference file | What it covers |
|---|---|---|
| Typography | [`typography.md`](skills/ru-text/references/typography.md) | Quotes (guillemets, lapki), dashes, non-breaking spaces, digit grouping, special characters, abbreviations |
| Information style | [`info-style.md`](skills/ru-text/references/info-style.md) | Stop-words (92 entries), text structure, facts over adjectives, register, T-Zh editorial principles |
| Editorial: punctuation | [`editorial-punctuation.md`](skills/ru-text/references/editorial-punctuation.md) | Complex sentences, comma traps, introductory words, semicolons |
| Editorial: grammar | [`editorial-grammar.md`](skills/ru-text/references/editorial-grammar.md) | Capitalization, agreement, pleonasms, verb government, gerund phrases with a mismatched subject, context-dependent homophones, list formatting |
| UX writing | [`ux-writing.md`](skills/ru-text/references/ux-writing.md) | Button labels, error messages, empty states, forms, notifications, dialogs, onboarding |
| Business writing | [`business-writing.md`](skills/ru-text/references/business-writing.md) | Email structure, messenger etiquette, tone, clean phrasing, meeting notes |
| Anti-patterns | [`anti-patterns.md`](skills/ru-text/references/anti-patterns.md) | Wrong-to-right pairs organized by severity: bureaucratic language, passive voice, bloat |
| Tells of machine-written text | [`addenda.md`](skills/ru-text/references/addenda.md) | Sixteen tells, AD-1 through AD-16, each with carve-outs naming where the device is legitimate |
| Scoring rubric | [`scoring.md`](skills/ru-text/references/scoring.md) | The five `/ru-score` dimensions, their weights, per-dimension floors and the floor under the label |

## Commands

| Command | Description |
|---|---|
| `/ru-text` | Activate the skill manually (auto-activation covers most cases) |
| `/ru-text:ru-check` | Run a comprehensive text quality check on provided text or recent output |
| `/ru-text:ru-score` | Score text quality on a 0.0–10.0 scale across 5 dimensions |

## Style priority

If you explicitly request a specific style — casual, academic, SEO, literary, legal — your prompt overrides the default rules. The plugin provides quality defaults, not mandates.

## Technical quality

Built to Anthropic's Claude Code plugin specs:
- SKILL.md: 583 words, 90 lines (guideline: under 2,000 words, under 500 lines)
- 10 reference files load on demand, never at session start
- 2,000+ atoms organized into 7 thematic areas with progressive disclosure

## Intellectual property notice

This plugin is an independent, original work by Arseniy Kamyshev.

The rules and principles contained herein represent the author's personal
understanding of Russian typography, editorial, and writing standards, gained
from years of professional practice and study of published sources listed below.

All formulations are original. No text is quoted verbatim from any source.
The underlying principles (typography rules, grammar norms, editorial methods)
are not subject to copyright under Article 1259(5) of the Russian Civil Code,
17 USC §102(b), and the Berne Convention.

The authors and publishers of the listed sources have not endorsed, reviewed,
or approved this plugin. Source references are provided for reader convenience
and further study.

Product names mentioned are trademarks of their respective owners, used here
for informational purposes only.

## Roadmap

Next steps for expanding ru-text to new audiences:

- **Telegram Bot** — text quality checking and /ru-score via Telegram
- **Browser Extension** — Russian text quality in any web text field (Chrome, Firefox)
- **WordPress Plugin** — typography and quality scoring in the Gutenberg editor

Contributions and ideas welcome — [open an issue](https://github.com/talkstream/ru-text/issues) or [start a discussion](https://github.com/talkstream/ru-text/discussions).

## Sources and credits

### Typography

| # | Source | Contribution | Link |
|---|---|---|---|
| 1 | **Artyom Gorbunov "Typography and Layout"** (2017) | Core typography rules: dashes, quotes, spacing, screen typography | [bureau.ru/projects/book-typography/](https://bureau.ru/projects/book-typography/) |
| 2 | **Bureau Gorbunov "Tips"** (2005–present, 4809+ tips) | Practical micro-advice on typography, editing, design | [bureau.ru/soviet/](https://bureau.ru/soviet/) |
| 3 | **A. Milchin, L. Cheltsova "Publisher's and Author's Handbook"** (2021, 6th ed.) | Punctuation, abbreviations, number formatting, editorial conventions | [store.artlebedev.com](https://store.artlebedev.com) |
| 4 | **Ilya Birman — Typography Layout** (2007–present) | Keyboard layout for typing correct typographic characters | [ilyabirman.ru/typography-layout/](https://ilyabirman.ru/typography-layout/) |
| 5 | **Type.today — Journal** (2016–present) | Cyrillic typeface design, font pairing, readability | [type.today](https://type.today) |

### Information style and clear writing

| # | Source | Contribution | Link |
|---|---|---|---|
| 6 | **Maxim Ilyakhov "Write, Shorten"** (2017, updated 2025) | Foundation of info-style: removing filler, fighting bureaucratic language, reader-first writing | [book.glvrd.ru](https://book.glvrd.ru) |
| 7 | **Maxim Ilyakhov "Clear and Understandable"** (2019) | Advanced info-style: text structure, persuasion, visual-textual integration | [book.glvrd.ru](https://book.glvrd.ru) |
| 8 | **T-Zh editorial policy** (2017–present, 56+ pages) | Tone of voice, formatting, numbers, business writing standards | [journal.tinkoff.ru/manual/](https://journal.tinkoff.ru/manual/) |
| 9 | **Kontur Guides** (2020–present) | UX writing for B2B software: interface text, errors, onboarding | [guides.kontur.ru](https://guides.kontur.ru) |
| 10 | **Yandex Gravity UI** (2023–present) | Design system with content guidelines for Russian UI text | [gravity-ui.com](https://gravity-ui.com) |

### Writing and language

| # | Source | Contribution | Link |
|---|---|---|---|
| 11 | **M. Ilyakhov, L. Sarycheva "New Rules of Business Correspondence"** (2018) | Email structure, respectful tone, messenger etiquette | [book.glvrd.ru](https://book.glvrd.ru) |
| 12 | **Nora Gal "Living Word and Dead Word"** (1972, reprints) | Original critique of bureaucratic language, nominalization abuse, passive voice | [lib.ru](http://lib.ru/TRANSLATORS/NORA_GAL/slowo.txt) |
| 13 | **D. Rozental — Spelling and Style References** (1960s–2000s) | Authoritative Russian grammar, punctuation, orthography baseline | widely available |
| 14 | **Artemy Lebedev "Mandership"** (1998–present) | Screen typography, dashes and quotes, design-text readability | [artlebedev.ru/kovodstvo/](https://www.artlebedev.ru/kovodstvo/) |
| 15 | **Ozon UX Writing Practices** (2021–present) | UX writing at scale: buttons, notifications, errors, product copy | [habr.com](https://habr.com/ru/companies/ozontech/articles/821383/) |
| 16 | **GOST R 7.0.12-2011, GOST 7.12-93** (Rosstandart) | Official standards for bibliographic abbreviations in Russian | GOST databases |

### Online tools

- **Glavred** ([glvrd.ru](https://glvrd.ru)) — checks text for info-style quality, highlights filler, scores 0–10
- **Lebedev Typograf** ([typograf.artlebedev.ru](https://www.artlebedev.ru/typograf/)) — auto-fixes typography: quotes, dashes, non-breaking spaces
- **Orfogrammka** ([orfogrammka.ru](https://orfogrammka.ru)) — grammar, spelling, and punctuation checker

## Author

**Arseniy Kamyshev** — [nafigator@gmail.com](mailto:nafigator@gmail.com) — [Telegram](https://t.me/nafigator) — [GitHub](https://github.com/talkstream)

## Support

I have spent my life working on social projects. This is where I make the biggest difference for people and communities, so I **always** need financial support. If ru-text makes your products better, consider [sponsoring me on GitHub](https://github.com/sponsors/talkstream).

## License

[MIT](LICENSE) | [Privacy Policy](PRIVACY_POLICY.md)
