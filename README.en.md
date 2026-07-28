# ru-text

[![Version](https://img.shields.io/github/v/release/talkstream/ru-text?label=version&color=2ea44f)](https://github.com/talkstream/ru-text/releases/latest) [![GitHub stars](https://img.shields.io/github/stars/talkstream/ru-text?style=flat&label=stars)](https://github.com/talkstream/ru-text/stargazers) [![GitHub Sponsors](https://img.shields.io/badge/Sponsor-30363D?logo=GitHub-Sponsors&logoColor=EA4AAA)](https://github.com/sponsors/talkstream)

**Languages:** [Русский](README.md) | English

Your AI agent already writes Russian. ru-text takes care of how that text looks and reads: guillemets and em dashes appear on their own, bureaucratic phrasing goes, and the references on editing, UX copy and business correspondence load when they are needed.

## Install

Hand this sentence to your AI agent:

> Установи навык https://github.com/talkstream/ru-text глобально и вызывай его для любых задач с русским текстом: вычитка, типографика, редактура, UX-тексты, деловая переписка.

It takes it from there: where its own platform keeps skills is something the agent knows better than an instruction written a year ago does.

Then start a new session — skills are loaded when a session starts, not in the one that installed them.

Installing by hand, agent got it wrong, or your platform installs through its own tool — all of that is in [INSTALL.en.md](INSTALL.en.md): the directories of twelve platforms with the vendor URL each came from, the click-paths for Claude Desktop and Notion (Notion installs by clicking, not by agent), and four things an agent cannot discover by trying.

## What it looks like

Before:

> В целях повышения эффективности взаимодействия между подразделениями было принято решение о проведении мероприятий по оптимизации документооборота. Ответственными лицами осуществляется контроль за надлежащим исполнением поручений.

After:

> Чтобы отделы работали быстрее, мы упрощаем документооборот. За исполнением поручений следят Иванов и Петрова.

Three things changed: verbal nouns became verbs, the passive named who acts, and "в целях" and "осуществляется" left — both are in the catalogue of 92 stop-words.

## What it will fix

**Buttons, errors, empty states.** "Отмена" instead of "Нет". An error says what happened and what to do. A placeholder is an example, not an instruction.

**Emails and messages.** "Довожу до сведения" becomes "сообщаю". Subject, first sentence and request move into place. The tone stays respectful without being obsequious.

**Landing pages and documentation.** "Команда профессионалов" is replaced by something checkable. Typography, inverted-pyramid structure, links that say where they lead.

**Text that came out of a model** — yours or someone else's. ru-text knows sixteen tells of machine writing. Five are visible in the fragment itself:

- manufactured antithesis ("не X, а Y" with no antecedent);
- preemptive self-praise ("чётко, по делу, без воды");
- assistant-register filler ("Отличный вопрос!", "Надеюсь, помог");
- hollow openers ("давайте разберёмся", "погрузимся");
- phantom attribution ("как показывают исследования" with no study behind it).

Nine more are of the same kind. Two others are charged to the whole document rather than to a fragment, because no local edit repairs them: a piece that stayed a chat transcript, and a piece written for a search engine instead of a reader.

Twelve of the sixteen tells carry a written carve-out naming where the device is legitimate — a quotation, an analysis of someone else's text, a legal formula. The carve-out is read before the finding is raised.

## Boundaries

**Your request outranks the rules.** Ask for a casual, academic, legal, SEO or literary style and ru-text adapts. These are quality defaults, not requirements.

**Nothing is rewritten silently.** A check returns the corrected version plus a list of changes; a file is edited in place only when you ask for that.

**Someone else's words stay theirs.** Quoted material, code blocks and third-party text inside your document are reproduced as-is.

**It turns off like any skill.** Through your platform: `/plugin` in Claude Code, or by deleting the skill directory elsewhere.

## Scoring

`/ru-text:ru-score` gives a score from 0 to 10 across five dimensions: typography, clean language, grammar, structure, precision for the reader. Each dimension comes with specific issues and quoted fragments.

The top labels have a floor the arithmetic does not override. A document that turned out to be a chat transcript, or one written for a search engine, is never labelled «Эталонный» or «Хороший» whatever it scores — and the rubric names the rule that capped it. The number itself is printed as it computed.

`/ru-text:ru-check` does the analysis without a score: findings, the rule behind each, and a proposed replacement.

## The corpus

Over 2,000 linguistic atoms: rules, wrong → right pairs, dictionary entries and carve-outs. That is a floor rather than a figure, and it is counted by a command:

```bash
tools/extract-atoms.sh skills/ru-text | wc -l
```

The corpus is spread over ten reference files, and they load on demand rather than at session start: a large body of rules costs no context until it is needed. Open any of them and count the rules yourself — that is more reliable than a number maintained by hand.

- [`typography.md`](skills/ru-text/references/typography.md) — quotes, dashes, non-breaking spaces, digit grouping, abbreviations
- [`info-style.md`](skills/ru-text/references/info-style.md) — the catalogue of 92 stop-words, text structure, facts over adjectives
- [`editorial-punctuation.md`](skills/ru-text/references/editorial-punctuation.md) — complex sentences, comma traps, introductory words
- [`editorial-grammar.md`](skills/ru-text/references/editorial-grammar.md) — agreement, pleonasms, verb government, gerunds, homophones
- [`ux-writing.md`](skills/ru-text/references/ux-writing.md) — buttons, errors, empty states, forms, notifications, onboarding
- [`business-writing.md`](skills/ru-text/references/business-writing.md) — emails, messengers, tone, meeting notes
- [`anti-patterns.md`](skills/ru-text/references/anti-patterns.md) — wrong-to-right pairs, grouped by severity
- [`addenda.md`](skills/ru-text/references/addenda.md) — sixteen tells of machine writing, with their carve-outs
- [`scoring.md`](skills/ru-text/references/scoring.md) — the scoring rubric: dimensions, weights, floors
- [`sources.md`](skills/ru-text/references/sources.md) — sources and attribution

## Updating

A one-shot install has no mechanism of its own: the agent installed the skill and forgot about it. Every few months, ask it to run the install again; what changed is in the [CHANGELOG](CHANGELOG.md), and the per-platform commands are in [INSTALL.en.md](INSTALL.en.md#updating).

One thing worth knowing up front: the ru-text pin in the Claude Code community marketplace trails the current version by months. `claude plugins list` shows the version you have; if it is old, install the skill by copying — [the same file](INSTALL.en.md#what-an-agent-cannot-work-out-for-itself) explains how.

## Sources and credits

These books, guides and tools taught me how to work with Russian text. If ru-text saves you time, buy their books and use their tools.

**Typography and layout.** Artyom Gorbunov, "Typography and Layout" · [Bureau Gorbunov's Tips](https://bureau.ru/soviet/) · A. Milchin and L. Cheltsova, "The Publisher's and Author's Handbook" · [Ilya Birman's typography layout](https://ilyabirman.ru/typography-layout/) · [Type.today journal](https://type.today)

**Information style.** Maxim Ilyakhov, "Write, Shorten" and "Clear and Understandable" · [T—Zh editorial policy](https://journal.tinkoff.ru/manual/) · [Kontur guides](https://guides.kontur.ru) · [Yandex Gravity UI](https://gravity-ui.com)

**Writing and language.** M. Ilyakhov and L. Sarycheva, "New Rules of Business Correspondence" · Nora Gal, "[Living Word and Dead Word](http://lib.ru/TRANSLATORS/NORA_GAL/slowo.txt)" · D. Rozental's reference books · Artemy Lebedev, "[Mandership](https://www.artlebedev.ru/kovodstvo/)" · [Ozon's UX writing practices](https://habr.com/ru/companies/ozontech/articles/821383/) · GOST R 7.0.12-2011 and GOST 7.12-93

The full list, with what each source contributed, is in [`sources.md`](skills/ru-text/references/sources.md).

Nearby tools: [Glavred](https://glvrd.ru), [Lebedev's Typograf](https://www.artlebedev.ru/typograf/), [Orfogrammka](https://orfogrammka.ru).

## Intellectual property notice

ru-text is an independent work of authorship by Arseniy Kamyshev. The rules in it are the author's own understanding of Russian typography and editorial standards, formed over years of practice and of reading the sources listed above. All formulations are original; nothing is quoted verbatim. The underlying principles — typographic rules, grammatical norms, editorial technique — are not subject to copyright: Article 1259(5) of the Russian Civil Code, 17 USC §102(b), the Berne Convention.

The authors and publishers of the sources listed have not endorsed or reviewed this plugin. The links are for the reader's convenience. Product names belong to their respective owners.

## What's next

A Telegram bot, a browser extension, a WordPress plugin. Ideas and corrections go to [issues](https://github.com/talkstream/ru-text/issues) or [discussions](https://github.com/talkstream/ru-text/discussions).

## Author

Arseniy Kamyshev — [nafigator@gmail.com](mailto:nafigator@gmail.com) · [Telegram](https://t.me/nafigator) · [GitHub](https://github.com/talkstream)

I work on social projects, and the work on ru-text rests on support from the people it turned out to be useful to. If it makes your products better — [GitHub Sponsors](https://github.com/sponsors/talkstream).

[MIT](LICENSE) · [Privacy policy](PRIVACY_POLICY.md) · the plugin makes no network calls and collects no data.
