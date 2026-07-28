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

Sections are ordered by April 2026 platform popularity among developers using AI assistants.

### Claude Code (CLI)

```bash
# Add the community marketplace (one-time setup)
/plugin marketplace add anthropics/claude-plugins-community

# Install the plugin
/plugin install ru-text@claude-community
```

Listed in the [Claude Code community marketplace](https://github.com/anthropics/claude-plugins-community). A listing in the [official Anthropic marketplace](https://claude.com/plugins) is planned.

### Claude Code (Desktop)

In the app, install the plugin from the interface, with no terminal: the **+** button next to the prompt box → **Plugins** → **Add plugin**. That opens the plugin browser over your configured marketplaces; add the community marketplace there too. The `/plugin` command works only in the terminal CLI.

A single install is shared across the CLI, the Claude Desktop app (local and SSH sessions), VS Code, and JetBrains. Cloud sessions at claude.ai/code are the exception: a user-scope install does not carry over. Declare the plugin under `enabledPlugins` in the repository's `.claude/settings.json`, and it is installed at session start. Plugins are not available in WSL sessions.

### Codex CLI

First add the marketplace that carries ru-text:

```bash
codex plugin marketplace add hashgraph-online/awesome-codex-plugins
```

Then open the plugin browser in a Codex session, find “ru-text” and install it:

```
/plugins
```

Start a new session afterwards — a plugin's bundled skills are loaded at session start. Alternatively, use the universal skills CLI (see below).

### Notion

Two integration paths — see [notion/README.md](notion/README.md) for details:

**Notion AI Custom Skill** (standalone, Business/Enterprise plan):
1. Copy [the template page](notion/ru-text-notion-skill.md) into a Notion page
2. Designate the page as an AI skill
3. Select text and invoke “ru-text” from the AI menu

**Notion via MCP** (with Claude Code, any plan):
1. Install ru-text in Claude Code
2. Connect the [Notion MCP server](https://developers.notion.com/guides/mcp/get-started-with-mcp)
3. Ask Claude Code to read, check, and update your Notion pages

### Cursor

Copy the skill manually — ru-text is not published in the Cursor marketplace yet:

```bash
git clone https://github.com/talkstream/ru-text.git
cp -r ru-text/skills/ru-text ~/.cursor/skills/ru-text
```

Windows (PowerShell):

```powershell
git clone https://github.com/talkstream/ru-text.git
Copy-Item -Recurse ru-text\skills\ru-text "$env:USERPROFILE\.cursor\skills\ru-text"
```

### GitHub Copilot

If ru-text is already installed for Claude Code in your project, Copilot detects it automatically. Otherwise:

```bash
npx skills add talkstream/ru-text
```

Or copy manually:

```bash
git clone https://github.com/talkstream/ru-text.git
cp -r ru-text/skills/ru-text .github/skills/ru-text
```

Works in VS Code, Visual Studio, and JetBrains IDEs with Copilot.

### Gemini CLI

```bash
gemini extensions install https://github.com/talkstream/ru-text
```

### Google Antigravity

Antigravity reads the SKILL.md format natively. Copy the skill into the global skills folder to make it available across all projects:

```bash
git clone https://github.com/talkstream/ru-text.git
cp -r ru-text/skills/ru-text ~/.gemini/config/skills/ru-text
```

That path is read by Antigravity, Antigravity IDE and Antigravity CLI alike. For a single project, copy the skill into `<project>/.agents/skills/ru-text` — plural, which is the current default; the older `.agent/skills` is still accepted for backward compatibility. Antigravity is young and the paths vary by product and version — check the [Antigravity skills documentation](https://antigravity.google/docs/skills) for the current location.

### Windsurf

Copy the skill manually:

```bash
git clone https://github.com/talkstream/ru-text.git
cp -r ru-text/skills/ru-text .windsurf/skills/ru-text
```

`npx skills add talkstream/ru-text -y` can serve Windsurf too, but it writes `.windsurf/skills` only when a `.windsurf/` directory already exists in the project — it never creates one.

Invoke with `@ru-text` in Cascade chat. Also available via Cascade panel > Customizations > Skills.

### Continue.dev

If ru-text is already installed for Claude Code in your project, Continue detects it automatically. Otherwise:

```bash
npx skills add talkstream/ru-text
```

Or copy manually:

```bash
git clone https://github.com/talkstream/ru-text.git
cp -r ru-text/skills/ru-text .continue/skills/ru-text
```

`npx skills add` serves Continue only when a `.continue/` directory already exists in the project, or `~/.continue` exists on the machine.

Works in both VS Code and JetBrains extensions.

### Cline

If ru-text is already installed for Claude Code in your project, Cline detects it automatically. Otherwise:

```bash
npx skills add talkstream/ru-text
```

Or copy manually:

```bash
git clone https://github.com/talkstream/ru-text.git
cp -r ru-text/skills/ru-text .cline/skills/ru-text
```

Enable skills in Cline settings: Features > Enable Skills.

### JetBrains (Junie)

Copy the skill manually:

```bash
git clone https://github.com/talkstream/ru-text.git
cp -r ru-text/skills/ru-text .junie/skills/ru-text
```

`npx skills add talkstream/ru-text -y` writes `.junie/skills` only when a `.junie/` directory already exists in the project.

Works in IntelliJ IDEA, PyCharm, WebStorm, GoLand, PhpStorm, RubyMine, RustRover, Rider, CLion, and Android Studio.

### OpenClaw

```bash
openclaw skills install @talkstream/ru-text
```

Available on [ClawHub](https://clawhub.ai/talkstream/ru-text). Works with any LLM provider and messaging channel OpenClaw supports.

### Any platform via skills CLI

```bash
npx skills add talkstream/ru-text -y
```

Three things about `npx skills add`:

- **It installs three skills** — `ru-text`, `ru-check` and `ru-score`. In Claude Code the latter two are slash commands; on the other platforms they arrive as standalone skills. Three entries in the list is expected, not a fault.
- **Without `-y`**, in an ordinary terminal the command opens an interactive picker for skills and agents and waits for an answer — pasted into a script, it installs nothing.
- **The install is project-scoped by default.** Add `-g` for a user-level install.

### From source

```bash
git clone https://github.com/talkstream/ru-text.git
```

Then add the repo as a plugin source per your platform's docs.

Start writing Russian text — the plugin takes over automatically. If ru-text makes your products better, consider [sponsoring](https://github.com/sponsors/talkstream) continued development.

## Updating ru-text

Latest version — **v1.10.1** (see the [CHANGELOG](CHANGELOG.md)). Check your installed version in Claude Code with `claude plugins list`.

**Primary method** — for skill-based platforms (GitHub Copilot, Cline, Cursor, Google Antigravity; for Windsurf, Junie and Continue.dev see the caveats in their sections). Re-run the install — the command pulls the latest version from the repository and overwrites the skills, including any file you edited by hand:

```bash
npx skills add talkstream/ru-text -y
```

The update goes to the same scope as the install. If you installed at user level (`-g`), update with `-g` too — otherwise a project-scoped run reports success while the user-level copy stays old.

**Claude Code (CLI and Desktop).** Refresh the marketplace cache first, then update the plugin:

```bash
claude plugins marketplace update claude-community
claude plugins update ru-text@claude-community
```

Restart Claude Code (or run `/reload-plugins`) to apply the change. You can also do this from the `/plugin` menu, "Installed" tab.

Worth knowing before you install: the community marketplace pins the plugin to a specific commit rather than tracking releases. Only the marketplace's nightly sweep advances the pin, and one run updates at most thirty plugins against a catalogue of more than two thousand entries. The sweep works alphabetically, so the ru-text pin can trail the current version by months. `claude plugins list` shows the version you actually have. If you need the current one right away, install the skill with `npx skills add talkstream/ru-text` or from source — both give you what is on `main` today.

**Gemini CLI:**

```bash
gemini extensions update ru-text
```

**OpenClaw:**

```bash
openclaw skills update @talkstream/ru-text
```

**Codex CLI.** Open `/plugins`, find ru-text, and update.

**Manual copy.** If you installed the skill manually (`git clone` + `cp`), repeat your platform's install steps — they overwrite the skill with the latest version.

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
