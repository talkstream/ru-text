# ru-text

[![Version](https://img.shields.io/github/v/release/talkstream/ru-text?label=version&color=2ea44f)](https://github.com/talkstream/ru-text/releases/latest) [![License](https://img.shields.io/github/license/talkstream/ru-text?label=license&color=blue)](LICENSE) [![GitHub stars](https://img.shields.io/github/stars/talkstream/ru-text?style=flat&label=stars)](https://github.com/talkstream/ru-text/stargazers)

[Русский](README.md) · [Install](INSTALL.en.md) · [What changed](CHANGELOG.md) · [Sources](skills/ru-text/references/sources.md)

Your AI agent is already putting your thoughts into Russian, and it shows: straight quotes where the language wants guillemets, a hyphen where it wants an em dash, "в целях повышения эффективности" ("with a view to increasing the efficiency of"), "Отличный вопрос!" ("Great question!"). The thought is yours; the voice is a machine's.

ru-text is a Russian proofreading skill for AI agents. It works inside the agent and cleans this up as it goes: typography, bureaucratic register, and seventeen tells of machine-written text (neuroslop). For every edit it gives you the fragment and the rule behind it.

Your words, your style and your tone it does not touch: those are not errors. And it will not rewrite your file until you ask it to.

## Install

Hand this sentence to your AI agent:

> Установи навык https://github.com/talkstream/ru-text глобально и вызывай его, когда работа идёт над качеством русского текста: вычитка, типографика, очистка от нейрослопа, редактура, UX-тексты, деловая переписка — или по прямому упоминанию ru-text.

*In English: install the ru-text skill globally and invoke it for any Russian-text task — proofreading, typography, neuroslop cleanup, editing, UX copy, business correspondence.* Hand your agent the Russian, not the translation.

That is usually enough: the agent knows where its platform keeps skills better than a year-old instruction does. It works in Claude Code, Codex and ChatGPT, Cursor, GitHub Copilot, Gemini CLI, Google Antigravity, Windsurf, Continue.dev, Cline, JetBrains Junie, OpenClaw and Notion.

In ChatGPT you do not need that sentence — there is a card in the plugin directory:

[![Install in ChatGPT and Codex](https://img.shields.io/badge/Install_in_ChatGPT_and_Codex-000000?style=for-the-badge)](https://chatgpt.com/plugins/plugins_6a6b66a0142c81918659256b4a12adba)

Open it and press the plus button. The skill then works in ChatGPT — in the browser, in the desktop app and on the phone. Codex runs it inside that same desktop app; in Codex CLI it is the sentence above that installs it.

The agent picks skills up when a session starts, so start a new one. Then try it on real text: give the agent a paragraph and ask it to "вычитай" ("proofread this"). What comes back is a corrected version and a list of edits. No list — the skill did not load; see [INSTALL.en.md](INSTALL.en.md).

## What a day with it looks like

Three short moves.

**You write, you ask for a proofread.** "Вычитай это письмо" ("proofread this email"). Back comes the corrected text and a list: what was replaced and under which rule. You need not accept all of it — the rule is named, so there is something to argue with.

**The agent writes, and it cleans as it goes.** In text the agent writes itself, typography is applied silently: quotes, dashes, non-breaking spaces. That is the norm of the language, and there is nothing to report.

**Before publishing, ask for a score.** "Оцени этот текст по ru-text" ("score this text with ru-text"): 0–10 across five dimensions, and every finding comes with a quotation and the rule. The score can be checked line by line and argued with.

Along with the score, the rubric prints what it did not measure: factual accuracy, fit with the audience, the author's voice, originality, effectiveness, conformity to the brief. Voice is not part of the score: 8.0 for a cautious text and 8.0 for a blunt one mean the same thing.

The two top labels, "Эталонный" ("Benchmark") and "Хороший" ("Good"), do not go to a document that stayed a chat transcript or was written for a search engine: such a text can be clean in every phrase and useless as a whole.

In Claude Code these moves have commands: `/ru-text:ru-check` for the analysis with a rule behind each finding, `/ru-text:ru-score` for the number. On the other platforms, words are enough.

## What it catches

Catching a model by its vocabulary is hopeless: the vocabulary is ours. Its manner gives it away. It compliments your question, and argues with something nobody said.

Here are five sentences with not one fact in them:

> Отличный вопрос! Сейчас всё объясню — коротко, без воды и по делу. Скажу честно: тут есть нюанс. Давайте разберёмся, как это работает. Дело не в скорости, а в предсказуемости.

*"Great question! I will explain it all now — briefly, no fluff, straight to the point. I will be honest with you: there is a nuance here. Let us work out how this works. It is not about speed, it is about predictability."*

The same answer from someone who has something to say:

> Под нагрузкой система замедляется предсказуемо: очередь растёт линейно до 800 запросов в секунду, дальше отказы. Вот замеры.

*"Under load the system slows down predictably: the queue grows linearly up to 800 requests per second, and past that it starts failing. Here are the measurements."*

The devices, in order:

- "Отличный вопрос!" ("Great question!") — assistant-register filler;
- "коротко, без воды и по делу" ("briefly, no fluff, straight to the point") — praising yourself for brevity;
- "скажу честно" ("I will be honest") — declared sincerity;
- "давайте разберёмся" ("let us work this out") — a hollow opener;
- "дело не в скорости, а в предсказуемости" ("it is not about speed, it is about predictability") — manufactured antithesis: it denies what nobody asserted.

I see the first version every day — in other people's READMEs and in my own drafts. It reads smoothly and reports nothing.

Before it raises a finding, the skill reads the carve-outs. Inside a quotation, in an analysis of someone else's text, in a legal formula, the device is legitimate. And the tricolon, the model's favourite rhythm of three, is legitimate when there really are three things.

There are seventeen such tells in all. Two of them are charged against the document as a whole, because no local edit repairs them: a text that stayed a transcript of a chat with a neural network, and a text written for a search query.

The skill takes bureaucratic register apart the same way: "в целях повышения эффективности взаимодействия" ("with a view to increasing the efficiency of interdepartmental interaction") becomes "чтобы отделы работали быстрее" ("so the departments work faster"); "осуществляется контроль" ("control is carried out") becomes "следит Петрова" ("Petrova is watching it"). Verbal nouns turn back into verbs, faceless oversight acquires a surname. The skill does not invent facts — it will ask you for the surname.

Beyond prose it knows interfaces and correspondence: a button names the action, "Отмена" ("Cancel") rather than "Нет" ("No"); an error says what happened and what to do next; a subject line leads with the business at hand; "довожу до сведения" ("I hereby bring to your attention") unfolds into "сообщаю" ("I am letting you know").

On a landing page and in documentation, "команда профессионалов" ("a team of professionals") gives way to something a reader can check, the conclusion moves to the top, and a link says where it leads.

## What you decide

**Your request outranks the rules.** Say "пиши разговорно" ("write it conversationally") and it will be conversational. Academic, legal, SEO, literary — the same. These are defaults, and a direct request from you cancels them.

**You issue the mandate.** The install sentence asks the agent to invoke the skill when the work is about the quality of Russian text, or when you name ru-text directly. Want it narrower: "вызывай ru-text, только когда я прошу вычитку" ("invoke ru-text only when I ask for a proofread"). Want it wider: "вызывай ru-text на любом русском тексте" ("invoke ru-text on any Russian text"). The agent follows your wording.

**Nothing is rewritten silently.** When it checks, the skill hands back the corrected version and a list of the changes; it edits your file only if you asked for that directly.

**Someone else's text stays theirs.** Quotations, code and third-party fragments inside your document are reproduced as they are: a remark about them, perhaps; an edit to them, never.

**One command turns it off.** In Claude Code — `/plugin`; on the other platforms, delete the skill directory.

## What it costs you in context

ru-text does not run the whole corpus over every paragraph — that would be waste, and you would be the one paying for it.

One file stays in context permanently (4 kilobytes): the typography table and the top of the stop-word list. The references sit beside it and load when their turn comes. Say "вычитай" and the skill reads the whole corpus.

When the agent checks itself, a fast pass runs: typography and stop-words — the things a single line decides. If five findings accumulate, or a trace of machine writing shows up, the pass expands into a full proofread on its own. The tells themselves it does not judge: each carries a carve-out naming where the device is legitimate, and the carve-outs live only in the full reference. And the fast pass never calls itself a full proofread.

## The corpus

Over 2,000 linguistic atoms: rules, wrong → right pairs, dictionary entries and carve-outs. That is a floor, not an exact number, and a command counts it:

```bash
tools/extract-atoms.sh skills/ru-text | wc -l
```

I used to type that number in by hand. It drifted across the files, I fixed it in nine of them at once — and in the note recording that fix I got even the number of files wrong. Now a script prints it.

The corpus sits in 10 reference files, and they load on demand. Open any of them and count the rules yourself.

- [`typography.md`](skills/ru-text/references/typography.md) — quotes, dashes, non-breaking spaces, digit grouping, abbreviations
- [`info-style.md`](skills/ru-text/references/info-style.md) — the catalogue of 92 stop-words, text structure, facts instead of judgements
- [`editorial-punctuation.md`](skills/ru-text/references/editorial-punctuation.md) — complex sentences, comma traps, introductory words
- [`editorial-grammar.md`](skills/ru-text/references/editorial-grammar.md) — agreement, pleonasms, verb government, gerunds, homophones
- [`ux-writing.md`](skills/ru-text/references/ux-writing.md) — buttons, errors, empty states, forms, notifications, confirmation dialogs
- [`business-writing.md`](skills/ru-text/references/business-writing.md) — emails, messengers, tone, meeting notes
- [`anti-patterns.md`](skills/ru-text/references/anti-patterns.md) — wrong-to-right pairs, grouped by severity
- [`addenda.md`](skills/ru-text/references/addenda.md) — seventeen tells of machine writing, with their carve-outs
- [`scoring.md`](skills/ru-text/references/scoring.md) — the scoring rubric: dimensions, weights, lower bounds
- [`sources.md`](skills/ru-text/references/sources.md) — sources and attribution

## What's new in 2.3.0

The stop-word catalogue no longer commands the deletion of «ну», «кстати» and «как-то» unconditionally: in the conversational register (social media, a personal blog, a support chat, a message to a colleague) those three entries no longer apply. In the other registers they apply as before.

The unit is the segment, not the file: one document carries registers side by side. And machine text cannot hide behind a conversational coat — three or more distinct neuroslop tells in a segment cancel the carve-out.

⚠ What this release does not claim: that text is now livelier, or that these words survive more often. A controlled measurement did not show that. What changed is the letter of the instruction, and that is visible in a diff. [What changed](CHANGELOG.md) · [Release](https://github.com/talkstream/ru-text/releases/tag/v2.3.0)

## Updating

A one-shot install has no update mechanism: the agent installed the skill and forgot about it. There is one signal — the repository's releases: Watch → Custom → Releases. When a release notification arrives, ask your agent to update the skill. Re-running the install command is no use: where the skill is installed by copying, it does not update but places the new version inside the old one. The commands for each platform are in [INSTALL.en.md](INSTALL.en.md#updating).

In the Claude Code community marketplace, ru-text trails the current version by months. `claude plugins list` will show the version installed; if it is old, install the skill by copying: three commands in [INSTALL.en.md](INSTALL.en.md#the-shared-directory).

## Sources and credits

These books, guides and tools taught me how to work with Russian text. If ru-text saves you time — buy these books and use these tools.

**Typography and layout.** Artyom Gorbunov, "Typography and Layout" · [Bureau Gorbunov's Tips](https://bureau.ru/soviet/) · A. Milchin and L. Cheltsova, "The Publisher's and Author's Handbook" · [Ilya Birman's typography layout](https://ilyabirman.ru/typography-layout/) · [Type.today journal](https://type.today)

**Information style.** Maxim Ilyakhov, "Write, Shorten" and "Clear and Understandable" · [T—Zh editorial policy](https://journal.tinkoff.ru/manual/) · [Kontur guides](https://guides.kontur.ru) · [Yandex Gravity UI](https://gravity-ui.com)

**Writing and language.** Artemy Lebedev, "[Mandership](https://www.artlebedev.ru/kovodstvo/)" · Nora Gal, "[Living Word and Dead Word](http://lib.ru/TRANSLATORS/NORA_GAL/slowo.txt)" · D. Rozental's reference books · M. Ilyakhov and L. Sarycheva, "New Rules of Business Correspondence" · [Ozon's UX writing practices](https://habr.com/ru/companies/ozontech/articles/821383/) · GOST R 7.0.12-2011 and GOST 7.12-93

The full list and what each source contributed are in [`sources.md`](skills/ru-text/references/sources.md). Alongside them, the tools: [Glavred](https://glvrd.ru), [Lebedev's Typograf](https://www.artlebedev.ru/typograf/), [Orfogrammka](https://orfogrammka.ru).

## Intellectual property notice

ru-text is an independent work of authorship by Arseniy Kamyshev. The rules in it are how the author understands Russian typography and editorial standards; that understanding formed over years of practice and of reading the sources listed above. All formulations are original; nothing is quoted verbatim. The underlying principles — typographic rules, grammatical norms, editorial technique — are not subject to copyright: Article 1259(5) of the Russian Civil Code, 17 USC §102(b), the Berne Convention.

The authors and publishers of the sources listed have not endorsed or reviewed this skill. The links are for the reader's convenience. Product names belong to their respective owners.

## Author

Arseniy Kamyshev — [nafigator@gmail.com](mailto:nafigator@gmail.com) · [Telegram](https://t.me/nafigator) · [GitHub](https://github.com/talkstream)

Next I want a Telegram bot and a browser extension. Ideas and remarks go to [issues](https://github.com/talkstream/ru-text/issues) or [discussions](https://github.com/talkstream/ru-text/discussions). Found a wrong rule? Open an issue: the corpus grows on findings like that too. In the CHANGELOG I credit the person who found it.

If ru-text saved you time on proofreading — [GitHub Sponsors](https://github.com/sponsors/talkstream).

[MIT](LICENSE) · [Privacy policy](PRIVACY_POLICY.md) · the skill makes no network calls and collects no data. This page was proofread by the current version of ru-text.
