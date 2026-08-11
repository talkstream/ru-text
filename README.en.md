# ru-text

[![Version](https://img.shields.io/github/v/release/talkstream/ru-text?label=version&color=2ea44f)](https://github.com/talkstream/ru-text/releases/latest) [![License](https://img.shields.io/github/license/talkstream/ru-text?label=license&color=blue)](LICENSE) [![GitHub stars](https://img.shields.io/github/stars/talkstream/ru-text?style=flat&label=stars)](https://github.com/talkstream/ru-text/stargazers)

[Русский](README.md) · [Install](INSTALL.en.md) · [What changed](CHANGELOG.md) · [Sources](skills/ru-text/references/sources.md)

Your AI agent is already putting your thoughts into Russian, and it shows: straight quotes where the language wants guillemets, a hyphen where it wants an em dash, "в целях повышения эффективности" ("with a view to increasing the efficiency of"), "Отличный вопрос!" ("Great question!"). The thought is yours; the voice is a machine's.

ru-text is a Russian proofreading skill for AI agents. It works inside the agent and cleans this up as it goes: typography, bureaucratic register, and seventeen tells of machine-written text (neuroslop). For every edit it gives you the fragment and the rule behind it.

Your words, your style and your tone it does not touch: those are not errors. And it will not rewrite your file until you ask it to.

## What's new in 2.3.0

The stop-word catalogue no longer commands the deletion of «ну», «кстати» and «как-то» unconditionally. In the conversational register — social media, a personal blog, a support chat, a message to a colleague — those three entries no longer apply. Everywhere else they apply as before.

- **The unit is the segment, not the file.** One document carries both registers: a work-chat message often contains a client letter in draft. The skill has to name the register signs in its remark.
- **Incidentality does not decide.** In live speech even the «кстати» that opens the main fact is released; in a business letter even the honestly incidental «кстати» stays a finding.
- **Machine text cannot hide behind a conversational coat.** Three or more neuroslop tells in a segment and the carve-out does not apply.
- **Four reference cases hold the rule's four branches.** The set grows from 31 to 35.

Why these three words: in one run over 20 pairs of live texts the skill cut them six times. Three judges on our blind panel, without knowing which side was which, independently named such cuts as a reason a checked text reads deader than the original.

⚠ **What this release does not claim:** that text is now livelier, or that these words survive more often. A controlled measurement across three corpus snapshots — including the one whose run cut them — left them in place in all three snapshots, so the corpus version is not the cause and no claim about frequency is supported. But two runs of the three did that AGAINST the letter of the catalogue: the correct outcome rested on the model disobeying the corpus. What changed is the letter of the instruction, and that is visible in a diff. [What changed](CHANGELOG.md) · [Release](https://github.com/talkstream/ru-text/releases/tag/v2.3.0)

## Neuroslop

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

Before it raises a finding, the skill reads the carve-outs. Inside a quotation, in an analysis of someone else's text, in a legal formula, the device is legitimate. And the tricolon — the model's favourite rhythm of three — is legitimate when there really are three things.

The reference holds seventeen such tells in all. Two of them are charged against the document as a whole, because no local edit repairs them: a text that stayed a transcript of a chat with a neural network, and a text written for a search query.

The skill takes bureaucratic register apart the same way: "в целях повышения эффективности взаимодействия" ("with a view to increasing the efficiency of interdepartmental interaction") becomes "чтобы отделы работали быстрее" ("so the departments work faster"); "осуществляется контроль" ("control is carried out") becomes "следит Петрова" ("Petrova is watching it"). Verbal nouns turn back into verbs, faceless oversight acquires a surname, and "в целях" and "осуществлять" are cut: both are in the catalogue of 92 stop-words. The skill does not invent facts — it will ask you for the surname.

## Install

Hand this sentence to your AI agent:

> Установи навык https://github.com/talkstream/ru-text глобально и вызывай его, когда работа идёт над качеством русского текста: вычитка, типографика, очистка от нейрослопа, редактура, UX-тексты, деловая переписка — или по прямому упоминанию ru-text.

*In English: install the ru-text skill globally and invoke it for any Russian-text task — proofreading, typography, neuroslop cleanup, editing, UX copy, business correspondence.* Hand your agent the Russian, not the translation.

That is usually enough: the agent knows where its platform keeps skills better than a year-old instruction does. It works in Claude Code, Codex and ChatGPT, Cursor, GitHub Copilot, Gemini CLI, Google Antigravity, Windsurf, Continue.dev, Cline, JetBrains Junie, OpenClaw and Notion.

In ChatGPT you do not need that sentence — there is a card in the plugin directory:

[![Install in ChatGPT and Codex](https://img.shields.io/badge/Install_in_ChatGPT_and_Codex-000000?style=for-the-badge)](https://chatgpt.com/plugins/plugins_6a6b66a0142c81918659256b4a12adba)

Open it and press the plus button. The skill then works in ChatGPT — in the browser, in the desktop app and on the phone. Codex runs it inside that same desktop app; in Codex CLI it is the sentence above that installs it.

Skills are picked up when a session starts, so start a new one.

Then try it on real text: give the agent a paragraph and ask it to "вычитай" ("proofread this"). What comes back is a corrected version and a list of edits. No list — the skill did not load; see [INSTALL.en.md](INSTALL.en.md).

Installing by hand, an agent that put it in the wrong place, or a platform with an installer of its own — all of that is in [INSTALL.en.md](INSTALL.en.md): the skill directory for each platform, with the vendor page the path came from; the click-paths for Claude Desktop and Notion; and four things an agent will not discover by trying.

## What you decide

**Your request outranks the rules.** Say "пиши разговорно" ("write it conversationally") and it will be conversational. Academic, legal, SEO, literary — the same. These are defaults, and a direct request from you cancels them.

**You issue the mandate.** The install sentence asks the agent to invoke the skill for any task involving Russian text. Want a narrower mandate? Write one: "вызывай ru-text, только когда я прошу вычитку" ("invoke ru-text only when I ask for a proofread"). The agent follows your wording.

**Nothing is rewritten silently.** When it checks, the skill hands back the corrected version and a list of the changes; it edits your file only if you asked for that directly.

**Someone else's text stays theirs.** Quotations, code and third-party fragments inside your document are reproduced as they are: a remark about them, perhaps; an edit to them, never.

**One command turns it off.** In Claude Code — `/plugin`; on the other platforms, delete the skill directory.

Sometimes the agent runs the proofread itself, without asking: that is how its automatic checks are set up. Such a pass begins with a fast check, and the fast check never passes itself off as a full proofread.

## What else it fixes

**Buttons, errors, empty states.** A button names the action — "Отмена" ("Cancel") rather than "Нет" ("No"); an error says what happened and what to do next; a placeholder is an example, not an instruction.

**Emails and messages.** The subject line leads with the business at hand — "Согласовать бюджет на Q3" ("Approve the Q3 budget"); the first sentence carries the request or the conclusion; "довожу до сведения" ("I hereby bring to your attention") unfolds into "сообщаю" ("I am letting you know"). The tone stays respectful, without fawning.

**Landing pages and documentation.** Instead of "команда профессионалов" ("a team of professionals") — something a reader can check; the conclusion on top, by the inverted pyramid; a link says where it leads.

## Scoring

Claude Code has two commands. `/ru-text:ru-score` takes a reading from a text: a score from 0 to 10 across five dimensions — typography, clean language, grammar, structure, precision for the reader. Every finding comes with a quotation from your text and the rule it was raised under, so the score can be checked line by line and argued with. `/ru-text:ru-check` does the analysis without a score: findings, the rule for each, a proposed replacement. On the other platforms, ask in words — "оцени этот текст по ru-text" ("score this text with ru-text"), "вычитай" ("proofread this") — and the rubric loads itself.

Along with the score, the rubric prints what it did not measure: factual accuracy, fit with the audience, the author's voice and originality, effectiveness, conformity to the brief. Voice is not part of the score: 8.0 for a cautious text and 8.0 for a blunt one mean the same thing.

The two top labels — "Эталонный" ("Benchmark") and "Хороший" ("Good") — do not go to a document that stayed a chat transcript or was written for a search engine: such a text can be clean in every phrase and useless as a whole. The rubric names the rule that capped the label. The number itself is printed exactly as it came out.

## The corpus

Over 2,000 linguistic atoms: rules, wrong → right pairs, dictionary entries and carve-outs. That is a floor, not an exact number, and a command counts it:

```bash
tools/extract-atoms.sh skills/ru-text | wc -l
```

I used to type that number in by hand. It drifted across the files, I fixed it in nine of them at once — and in the note recording that fix I got even the number of files wrong. Now a script prints it.

The corpus is laid out across 10 reference files, and they load on demand, so at the start of a session your context is untouched. Open any of them and count the rules yourself.

- [`typography.md`](skills/ru-text/references/typography.md) — quotes, dashes, non-breaking spaces, digit grouping, abbreviations
- [`info-style.md`](skills/ru-text/references/info-style.md) — the catalogue of 92 stop-words, text structure, facts instead of judgements
- [`editorial-punctuation.md`](skills/ru-text/references/editorial-punctuation.md) — complex sentences, comma traps, introductory words
- [`editorial-grammar.md`](skills/ru-text/references/editorial-grammar.md) — agreement, pleonasms, verb government, gerunds, homophones
- [`ux-writing.md`](skills/ru-text/references/ux-writing.md) — buttons, errors, empty states, forms, notifications, confirmation dialogs
- [`business-writing.md`](skills/ru-text/references/business-writing.md) — emails, messengers, tone, meeting notes
- [`anti-patterns.md`](skills/ru-text/references/anti-patterns.md) — wrong-to-right pairs, grouped by severity
- [`addenda.md`](skills/ru-text/references/addenda.md) — seventeen tells of machine writing, with their carve-outs
- [`scoring.md`](skills/ru-text/references/scoring.md) — the scoring rubric: dimensions, weights, floors
- [`sources.md`](skills/ru-text/references/sources.md) — sources and attribution

## What it costs you in context

ru-text does not run the whole corpus over every paragraph — that would be waste, and you would be the one paying for it.

One file stays in context permanently — the always-on skill. That is 4 kilobytes: the typography table and the top of the stop-word list. The references sit beside it and load when their turn comes.

Say "вычитай" or "прогони ru-text" ("run ru-text over this") and it reads the whole corpus.

When the agent checks itself, a fast pass runs over the index of tells and the stop-word catalogue. It catches typography and stop-words — the things a single line decides. If five findings accumulate, or a trace of machine writing shows up, the pass expands into a full proofread on its own.

The fast pass does not judge the tells of machine writing: each of them carries a carve-out naming where the device is legitimate, and the carve-outs live only in the full reference. Spotting a trace is a reason to expand.

## Updating

A one-shot install has no update mechanism: the agent installed the skill and forgot about it. There is one signal — the repository's releases: Watch → Custom → Releases. When a release notification arrives, ask your agent to update the skill. Re-running the install command is no use: where the skill is installed by copying, it does not update but places the new version inside the old one. What changed is written in the [CHANGELOG](CHANGELOG.md); the commands for each platform are in [INSTALL.en.md](INSTALL.en.md#updating).

The ru-text pin in the Claude Code community marketplace trails the current version by months. `claude plugins list` will show the version you have; if it is old, install the skill by copying: three commands in [INSTALL.en.md](INSTALL.en.md#the-shared-directory).

## Sources and credits

These books, guides and tools taught me how to work with Russian text. If ru-text saves you time — buy their books and use their tools.

**Typography and layout.** Artyom Gorbunov, "Typography and Layout" · [Bureau Gorbunov's Tips](https://bureau.ru/soviet/) · A. Milchin and L. Cheltsova, "The Publisher's and Author's Handbook" · [Ilya Birman's typography layout](https://ilyabirman.ru/typography-layout/) · [Type.today journal](https://type.today)

**Information style.** Maxim Ilyakhov, "Write, Shorten" and "Clear and Understandable" · [T—Zh editorial policy](https://journal.tinkoff.ru/manual/) · [Kontur guides](https://guides.kontur.ru) · [Yandex Gravity UI](https://gravity-ui.com)

**Writing and language.** Artemy Lebedev, "[Mandership](https://www.artlebedev.ru/kovodstvo/)" · Nora Gal, "[Living Word and Dead Word](http://lib.ru/TRANSLATORS/NORA_GAL/slowo.txt)" · D. Rozental's reference books · M. Ilyakhov and L. Sarycheva, "New Rules of Business Correspondence" · [Ozon's UX writing practices](https://habr.com/ru/companies/ozontech/articles/821383/) · GOST R 7.0.12-2011 and GOST 7.12-93

The full list, with what each source contributed, is in [`sources.md`](skills/ru-text/references/sources.md).

Alongside them, the tools: [Glavred](https://glvrd.ru), [Lebedev's Typograf](https://www.artlebedev.ru/typograf/), [Orfogrammka](https://orfogrammka.ru).

## Intellectual property notice

ru-text is an independent work of authorship by Arseniy Kamyshev. The rules in it are the author's own understanding of Russian typography and editorial standards, formed over years of practice and of reading the sources listed above. All formulations are original; nothing is quoted verbatim. The underlying principles — typographic rules, grammatical norms, editorial technique — are not subject to copyright: Article 1259(5) of the Russian Civil Code, 17 USC §102(b), the Berne Convention.

The authors and publishers of the sources listed have not endorsed or reviewed this plugin. The links are for the reader's convenience. Product names belong to their respective owners.

## What's next

Next I want a Telegram bot and a browser extension. A WordPress plugin I am only thinking about so far. Ideas and remarks go to [issues](https://github.com/talkstream/ru-text/issues) or [discussions](https://github.com/talkstream/ru-text/discussions).

## Author

Arseniy Kamyshev — [nafigator@gmail.com](mailto:nafigator@gmail.com) · [Telegram](https://t.me/nafigator) · [GitHub](https://github.com/talkstream)

If ru-text saved you a proofreading pass — [GitHub Sponsors](https://github.com/sponsors/talkstream). Found a rule that is wrong? Open an [issue](https://github.com/talkstream/ru-text/issues). The corpus grows on findings like that too, and in the CHANGELOG they are credited by name.

[MIT](LICENSE) · [Privacy policy](PRIVACY_POLICY.md) · the plugin makes no network calls and collects no data. This page was proofread by the current version of ru-text.
