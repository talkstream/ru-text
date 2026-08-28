# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.7.0] - 2026-08-27

### Added

- **R49 and R50 look at the same spot from opposite sides, and the corpus never said so.** One
  demands the spaces around an ellipsis be removed, the other demands a space be added; what
  orders them is the case of the letter on the right — lowercase or a digit continues the
  sentence (R49), an uppercase letter starts a new one (R50). Without that split the two rules
  eat each other's edits and the text settles nowhere.
- **Three carve-outs where the space stays**: a range (`А…Я`, `10…20 °C` — the left side is an
  index, not a word), a dialogue reply (`— Я думал … —` — a dash on the right, and eating that
  space turns an infelicity into an error), and an empty ellipsis at the start of a line.

## [2.6.0] - 2026-08-27

### Added

- **R53 said «no commas between groups» and would break R54 if taken literally.** The rule reads
  «разряды разделяются пробелами… запятые и точки не используются», but the very next rule
  requires a comma as the DECIMAL separator — so `1,500` is legal under both readings at once,
  «полторы тысячи» and «одна целая пятьсот тысячных», and nothing in the text tells them apart.
- **The ambiguity is resolved by counting groups, and only there**: `1,500,000` has two groups,
  and a decimal comma occurs once — commas out, spaces in. A single comma is left alone. The
  carve-out sits under R53 rather than R32, because R53 carries the full wording.

## [2.5.0] - 2026-08-27

### Added

- **R74 said «no dot after a unit» and stayed silent about the dot that ends a sentence.** Applied
  literally it merges two sentences: `Вес 5 кг. Брутто указано` would become `Вес 5 кг Брутто
  указано`. The carve-out now sits next to the rule, in the same file.
- **Two exemptions, each a minimal pair**: the dot goes only when the sentence continues
  (a lowercase letter to the right); it stays when the sentence closes, and end of text is not a
  continuation. **Multi-letter units only** — `кг`, `км`, `мин`, `га`.

## [2.4.0] - 2026-08-17

### Fixed
- **R30 lost a letter in every summary of itself.** The full corpus lists eight single-letter
  words that bind to the next word — `в, к, с, о, у, и, а, я` — and three summaries listed
  seven, dropping «я»: the always-on Quality Checklist of `SKILL.md`, the `ru-check` skill and
  the Notion template. Reported from outside on 17.08.2026;
  `grep -rn 'в, к, с' --include='*.md' .` finds the list in five places — the rule, this entry
  and those three.

  **The long list is the correct one, and it is the summaries that were fixed.** Three layers
  execute the rule and all three bound all eight: this repository's own typography gate
  (`tools/check-typography.sh`, `PREP`), the frozen golden set, and the paid engine, which is
  private and cannot be checked from here. So the short list contradicted the product's
  behaviour, not only its reference. Ководство § 62 forbids leaving any single-letter word at
  the end of a line, not only prepositions and conjunctions: «на строчке не могут остаться…
  одно-, двух- и некоторая часть трехбуквенных слов».

  The heading of section C.1 was fixed too: it said «однобуквенных предлогов/союзов» while its
  own list contained «я», a pronoun. Both readings shipped in the same commit and lived to
  v1.4.0 — that they were copied from the heading is not shown, only that the same narrowing
  appears in all three.

  A fourth narrowing surfaced in the same sweep and is fixed here: the header of
  `tools/check-typography.sh` described R30 as «a single-letter preposition does not end a
  line», while the code beneath binds all eight. That line names no letters, so the new gate
  cannot hold it — it is read, not matched.

- **Four more places where the always-on file and the corpus disagreed.** The ruble row showed
  «1500 руб → 1 500 ₽» — that is the ₽-over-«руб.» rule of `ux-writing.md` § L.6, a
  UX-register rule that does not govern a general table, while R69 legitimises «1 500 руб.»
  in ordinary text; the row now shows what the always-on rules do command, grouping and a
  non-breaking space. The dash and digit-group examples were typed with ORDINARY spaces, so a
  model copying the example produced exactly the defect the row teaches against; both now carry
  the real code points. And the checklist never asked for the non-breaking space before the em
  dash that R16 and R44 require.

- **`anti-patterns.md` credited `typography.md` with two rules it does not have.** «Double
  spaces» and «inconsistent ё» were listed as «all covered in typography.md». Double spaces have
  no rule anywhere in the corpus and stay as hygiene the checklist asks for; ё is governed, but
  by `ux-writing.md` § L.3–L.5. ⚠ The first repair of that sentence said the corpus has no rule
  for either — the same error one layer down, caught by proofreading before release.

### Internal
- **A summary can no longer narrow its rule in silence.** `tools/check-dogfood.sh` compares the
  letters a summary names against the letters the rule names, in both directions: a summary that
  drops a letter and one that invents a letter fail alike, and changing the rule's list fails all
  three summaries at once until they follow. ⚠ It guards the enumeration, not the prose around
  it — that prose is read rather than matched, and the checker says so in its own header.

## [2.3.0] - 2026-08-11

### Added
- **B.2 — a carve-out for the live register.** Three entries of the stop-word catalogue —
  `ну|убрать`, `кстати|убрать или встроить в структуру`, `как-то|убрать или уточнить` —
  command deletion without any condition, and in live speech that command is wrong. In the
  разговорный register of §F — a message to a colleague, a support chat, a personal blog —
  those three entries no longer apply. Everywhere else they apply as before.

  Three things in the rule are there because a measurement demanded them. **The unit is the
  SEGMENT, not the file,** and the register signs must be named in the remark: one document
  carries both registers routinely — a work-chat message with a client letter drafted inside
  it is the ordinary case. **Incidentality is refused in both directions:** in a live register
  even the «кстати» that opens the central fact is released, and in a published one even the
  honestly incidental «кстати» stays a finding. **The neuroslop cluster takes the tie-break**
  — three or more distinct addenda tells in a segment and the carve-out does not apply — so
  machine text cannot wear a conversational coat to free its own evidence.

  Four golden cases pin its four branches: register for «ну» (32), the crossed axes where
  register and incidentality order opposite verdicts (33), «как-то» (34), and slop imitating
  chat (35). The set grows 31 → 35.

  Why the three entries and not the catalogue: three blind judges, reading twenty pairs
  without knowing which side was which, independently named deletions of exactly these words
  as a reason a checked text reads deader than the original.

  ⚠ **What this release does NOT claim.** It does not claim the check now produces livelier
  text, and it does not claim these words survive more often. A controlled measurement — the
  same prompt and file across three corpus snapshots, including the one whose run produced the
  original deletions — released the words in all three arms. The corpus version is not the
  cause, and no frequency claim is supported in either direction. What changed, and what is
  checkable by reading a diff, is the letter of the catalogue.

### Fixed
- **Two install guides that nothing compared.** A correction of 30.07 — «re-running the
  install command does not update a copy install» — went into `INSTALL.md` alone, and
  `INSTALL.en.md` carried the disproved instruction for eleven more days. Prose translates and
  must differ; COMMANDS do not, so a gate now compares the set of commands each guide quotes.
  Both quote the same 21 today.
- **The register carve-out was first called B.1, and B.1 was taken** — by the carve-out for an
  amplifier at an admission, which golden case 29 references eleven times. Renamed, with the
  reason recorded so the skipped number is not read as an accident.

### Internal
- The two install guides are compared by the set of commands each quotes — the gate that
  would have caught the eleven-day drift above. Selftest 158 → 159 cases.
- `docs/roadmap-v2.1-conservation.md` carries the third panel, the rule it produced, the claim
  that was withdrawn and the standard adopted after it: **a rule is justified by the letter of
  the corpus and by an inventory checked against the blind key — never by the outcome of a
  single run.**

## [2.2.0] - 2026-08-10

The narrowing of 2.1.0 never reached anyone. `2bcbe74` landed on main AFTER the v2.1.0 tag —
by one hour and fifty-seven minutes — so the release, its assets and every catalogue pinned to
it carry the previous description, the one the narrowing was written to replace. On the day this
was found, `git diff --name-only v2.1.0 HEAD -- skills/ru-text` named exactly one file,
`SKILL.md`, and the published `ru-text-skill.zip` still holds «Also any Russian output» at line
5. This release is the delivery.

A minor version rather than a patch, deliberately: the skill now decides differently when to
speak and says less when it does. That is a change in behaviour a user will notice, not a
repair, whatever the smallness of the diff.

### Changed
- **The skill speaks less, and in one place reaches less.** Its `description` now reads
  «Typography silently on any Russian output; deeper editing on request», the always-on line
  reads «Apply to ALL Russian text output — silently: fix, don't announce», and the top
  stop-word table is gated «when writing or editing on request» — a gate it never had, which
  is a narrowing and is named as one. Typography itself still applies to any Russian output;
  what changed there is the volume, not the reach. The skill was loud where it was merely
  present.

  The activating decision is made by `description` in the frontmatter, not by the install
  prompt — so editing the prompt changes nothing for anyone who has already installed. If you
  are already on 2.1.0 or earlier, updating is the only way to get this.
- **The install prompt asks for a narrower job.** «…вызывай его для любых задач с русским
  текстом» became «…когда работа идёт над качеством русского текста… или по прямому упоминанию
  ru-text», in both READMEs and in the sandbox probe that hands the string to a fresh agent —
  all three byte-identical, which is itself a gate.
- **Notion setup guide.** «9 признаков ИИ-текста (нейрослоп) в 4 категориях» over a section
  holding four tells and nine example rows — a tell count more than double the truth. Now
  «Признаки ИИ-текста (нейрослоп): 4 категории, 9 примеров», in both language halves, and
  measured by a gate rather than remembered.

### Fixed
- **The install guides no longer promise something that does not happen — in BOTH languages.**
  They said the install command could be repeated to update. It cannot: `cp -r` places the new
  version INSIDE the old one, the previous release stays on top, and the agent reads the file
  on top — so the skill goes on running an older corpus. Measured on two labelled versions;
  after a repeat, `ru-text/ru-text/SKILL.md` appears. Eight platforms install by copying and
  are affected — Cline, Codex CLI, Continue.dev, Cursor, GitHub Copilot, Google Antigravity,
  JetBrains Junie and Windsurf, counted from `tools/install-paths.tsv` rather than remembered.
  Both `INSTALL.md` and `INSTALL.en.md` now say `rsync -a --delete` and give the command that
  proves the skill is installed exactly once.

  `INSTALL.en.md` carried the disproved instruction eleven days longer than the Russian half,
  because the correction of 30.07 was applied to one file and not its pair — and the «Updating»
  paragraph of BOTH READMEs still told the reader to run the install again. All four places are
  corrected here. Nothing cross-checks the two install guides; that they can drift for eleven
  days unnoticed is now known and unguarded.
- **Fifteen typographic defects in `notion/README.md`** — fourteen R30, one R16/R44 — in a
  page that documents those very rules. The file was on neither the checked list nor the
  exclusion list of the typography gate; the exclusion note names the Notion TEMPLATE, full
  of deliberately broken examples, and the setup guide beside it was never considered.
- **Three stale counts in the roadmaps** saying «sixteen tells» in the present tense over a
  reference that holds seventeen.
- **The selftest could exit ZERO without finishing.** *(Recorded after the fact: this shipped
  in 2.2.0 and was left out of this entry; the omission was found while preparing 2.3.0 and is
  written here rather than misattributed to the later release.)* A counter was incremented and
  never initialised; under `set -eu` that aborts bash 3.2 — which is `/bin/sh` on macOS — and
  the EXIT trap then reset the status. A run that died mid-way reported nothing and returned
  success, and `gates.sh` read it as a pass. The suite now cannot exit zero without reaching
  its summary, for any caller including CI, and `gates.sh` additionally requires the summary
  line.

### Internal
- The number of machine-text tells, the Notion template's own size, and the typography of the
  Notion guide are now gates rather than hand-maintained figures. Selftest 108 → 158 cases.
- The prose-shape ruler was normalised by a quantity that falls together with what it
  measures, so it was blind to chopping; the headline metric is now the 90th percentile of
  sentence length, monotone against dose on five texts of five.

## [2.1.0] - 2026-08-09

### Added
- **AD-18 — uppercase band vs. deliberate emphasis.** The corpus said one thing about capitals,
  in one unconditioned line of a summary table: replace them with bold. Measured over the two
  live corpora of the flattening experiment, the check obeyed it sixteen times, and every one of
  the sixteen was one or two words long — a risk marker in a working plan, a word of insistence
  in a message. Three blind judges had independently named uppercase turned into italics as a
  reason checked text reads deader than the original. Worse than over-reach, the line did not
  decide: two runs over the same source produced six conversions and zero, and inside one run
  the same word was lowered in prose and kept in a status-table cell. AD-18 sets a measured
  threshold — a band of three or more consecutive uppercase words, where a lowercase word or a
  line break ends the run and attached punctuation does not — with four carve-outs: one or two
  words are never flagged, abbreviations are outside the rule, machine text and status cells are
  not prose emphasis, headings are layout. Severity Low; the replacement is offered, not
  asserted. The trigger returns zero over all 25 files of all three corpus states, so none of
  the sixteen conversions happens under it.

### Fixed
- **Three rules were ruled correct and held by nothing.** The set's criterion forbids LOSING a
  finding; a carve-out REMOVES one, so it cannot fail that criterion however broken it is. B.1
  (an amplifier at an admission) had shipped nine days earlier with no positive case; the
  uncovered delta of the AD-7 repair was executed by none of the 29 cases; and inside the new
  cases themselves, B.1's «binding» branch and AD-18's heading carve-out were exercised by
  nothing. All four are now named by a case, and the audit that finds this class is one grep per
  sub-clause over the expected files.
- **The architecture map in the project brief still listed `commands/`**, deleted five releases
  earlier when the two commands became skills. A stale instruction is acted on as truth; this
  one had already produced a false reviewer finding.

### Golden set
- 28 → 31 cases. **29** — B.1 with both banks in one letter: nine amplifiers, five released
  across all three branches of condition (1), four findings; two lemmas stand three times each
  and split in opposite directions, so a run judging by the word rather than by attachment fails
  both. **30** — the AD-7 delta as a minimal pair: the same wrong-example formula twice, word for
  word, released once and flagged once, differing only in whether the text itself raised the
  vice. **31** — AD-18 from both sides: one seven-word band, and five ways to set capitals that
  the tool must leave alone.

## [2.0.1] - 2026-07-30

### Fixed
- **The English README was still the pre-rewrite page.** «Five are visible in the fragment
  itself» pointed at a fragment containing none of the five: the neuroslop section was lifted
  to the front in Russian and not in English, and the sentence stayed pointing at the
  bureaucratese demo that replaced it. The page's central claim referred to nothing. Rewritten
  section for section against the Russian, with every Russian specimen glossed for a reader who
  does not read Russian, and with three things the English page never carried: how to tell a
  silent install failure, the reader's right to narrow the trigger, and what the rubric does
  NOT measure.
- **The arithmetic, in English.** «Seventeen tells» over «Five… Nine more… Two others» is
  sixteen. The running count is gone, as it is in Russian.
- **Four unreproducible token figures**, deleted in Russian by 505e4f2 and still standing in
  English: 86,000 / 1,700 / 3,000 / 51,000, plus «nearly half». Replaced by the one measurable
  number — four kilobytes, which `wc -c skills/ru-text/SKILL.md` settles.
- **The install prompt had drifted between the three files that quote it.** A typography
  normaliser put two non-breaking spaces inside the copyable command in README.md, so the
  string a reader copies stopped matching the one `tools/probe-install.sh` hands a fresh agent
  — the probe was testing a string we do not publish. The prompt is a literal, not prose;
  `check-typography.sh` now skips that blockquote, and `check-dogfood.sh` compares the three
  copies on exact bytes. Selftest 93 → 94.

## [2.0.0] - 2026-07-30

### Breaking changes

The same text can now come back with a different verdict. Nothing was removed and no command
changed its interface, but four changes move findings and labels, and anyone who pinned a
score or wrote a test against `/ru-score` output should re-run it before upgrading.

- **A document can be held below «Хороший» by a single rule.** AD-14 (the piece is a chat
  transcript) and AD-15 (the piece is addressed to a search engine) are charged to the whole
  document and put a floor under the top two labels. A text that scored 8.4 and was called
  «Хороший» in 1.10.1 keeps the 8.4 and loses the word.
- **The AD-7 register carve-out no longer covers an author writing about their own text.**
  It protects a speaker *inside* the text — dialogue, quotation, a character. Conversational
  self-description that passed under the old wording is now a finding.
- **Nine new tells and three new grammar sections mean more findings on unchanged text.**
  AD-10…AD-16, plus §I verb government, §J gerund phrases with a mismatched subject and §K
  context-dependent homophones. Text that was clean against 1.10.1 can be clean against 2.0.0
  and still score lower, because the Structure and Precision dimensions now see more.
- **The per-domain rule counts are gone from both READMEs.** If you quoted «96 typography
  rules» from this project, there is no longer a number there to quote — see «Changed» for
  why, and quote `tools/extract-atoms.sh skills/ru-text | wc -l` instead.

### Added
- **Seven tells of machine-written Russian**, measured against the golden set before they
  shipped: AD-10 declared sincerity · AD-11 mandatory tricolon · AD-12 hollowed mechanism ·
  AD-13 phantom attribution · AD-14 chat transcript as the artifact · AD-15 search-engine
  addressee · AD-16 additive pseudo-pair. AD-14 and AD-15 are the first rules in this set
  charged to the **document** rather than to a fragment — the defect is the shape of the
  piece, and no local edit removes it. Nine further candidates were rejected on the record;
  two of those rejections matter most, because even sentence rhythm and vocabulary poverty
  are what detectors mistake for machine text and also what dry regulatory prose and
  non-native Russian look like.
- **The README asks the agent to install the skill, instead of teaching the human to.** The
  «Быстрый старт» section was thirteen platform-by-platform recipes, 195 of the file's 411
  lines. It is now one sentence to hand to an AI agent — «Установи навык
  https://github.com/talkstream/ru-text глобально и вызывай его для любых задач с русским
  текстом» — because an agent knows where its own platform keeps skills better than an
  instruction written a year ago does. The README lost half its length.
  The decision was tested rather than argued: three fresh agents were handed nothing but that
  sentence, in sandboxes, role-framed as three different platforms' agents. Two installed
  correctly; one put Codex's copy in `~/.codex/skills` on the strength of a December-2025
  blog post, while OpenAI's current documentation says user skills live in
  `$HOME/.agents/skills`. All three read this repository's README as their first source —
  which is why the per-platform material was moved rather than deleted.
- **`INSTALL.md` / `INSTALL.en.md`** — everything the one-liner does not carry, organised
  around the fact the audit turned up: `~/.agents/skills/` is read by Codex, Cursor, Windsurf
  AND GitHub Copilot, so this is one shared path plus exceptions rather than thirteen silos.
  Also there: the Claude Desktop and Notion click-paths, which no agent can drive; the four
  negative facts trial cannot discover (ru-text is absent from the Cursor marketplace, cloud
  sessions do not inherit the plugin, the community pin trails by months, `npx skills add`
  installs three skills); and the update story a one-shot install does not have.
- **`tools/install-paths.tsv`** — where each platform loads a skill from, with the vendor URL
  and the date it was read. One source for the INSTALL tables and for the probe's assertions,
  so the two cannot drift apart.
- **`tools/probe-install.sh`** — the gate that replaces reading prose against vendor docs. It
  builds a sandbox, prints the one-line prompt, and afterwards judges the disk: did the skill
  land at a path this platform documents, did a copy land anywhere it does not, are the bytes
  this corpus, did all ten reference files arrive. The second of those is the one that
  matters — an agent usually writes several copies, so a check that only looked for a hit
  would have blessed the `~/.codex/skills` failure. The script deliberately does not run the
  agent: a shell cannot start another vendor's agent, and one that pretended to would be a
  gate testing itself. Five selftest cases, one per outcome.
- **AD-17, a comma welded to a dash.** Raised by the director on reading a junction in this
  project's own README: «люди так не пишут в живой жизни, даже профессионалы языка». The rule is
  honest about its footing — Rozental §64 PERMITS the junction, Lebedev's Ководство §143 does not
  discuss combining marks, and nothing was found from Ilyakhov, so the rule claims no source
  forbids it. It observes that living prose avoids what the norm allows, which is what `addenda.md`
  is for. Five carve-outs, and the first is load-bearing: the trigger is a JUNCTION, not the
  character pair, so direct speech («„Хороший вопрос“, — ответил инженер») is two constructions and
  never flagged.
- **§A.1 of `editorial-punctuation.md` gains the particle rule.** A restrictive particle in front
  of a conjunction moves the comma left rather than removing it: «вызывай ru-text, только когда я
  прошу». The gap was found by a check that had to reach outside the corpus to catch it (ПАС
  §116–117, Розенталь §33.6) — nothing in the corpus could have.
- **A model may call the check again, and it now starts cheap.** `ru-check` and `ru-score` carried
  `disable-model-invocation: true`, which solved a real cost problem — a 15–20k-token check firing
  on any Russian text in sight — by making the tool unreachable to the agent that was supposed to
  run it. The flag is gone, the descriptions now carry the Russian phrases a person actually says
  («вычитай», «прогони ru-text», «оцени текст»), and the cost problem is solved where it lives:
  an explicit request reads the whole corpus, while a self-initiated run starts with triage — the
  neuroslop index plus the stop-word catalogue, ~3k tokens against ~51k — and escalates on
  evidence. Triage may report only what a single line decides; a neuroslop tell is never a triage
  finding, because every AD rule's carve-outs live in the full file.
- **A grammar layer the corpus had been missing**, in `editorial-grammar.md`: §I verb
  government from a **closed list** of the verbs and prepositions that are actually confused,
  plus mismatched government across coordinated members · §J the gerund phrase whose subject
  is not the subject of the sentence · §K context-dependent homophones. An **open** case
  check was written first and then deliberately rejected: over a whole text it flags the
  ordinary variation of a fluent writer, which makes it a detector of non-native Russian
  rather than a grammar rule.
- **Nine golden cases for the new rules, and four carve-out controls** (#29). The set grew
  from 13 texts to 22. Cases 12, 13, 19 and 22 assert **zero** findings and are built only
  from constructions the rules exempt — clean prose, the AD-1…AD-9 carve-outs, the 2026
  carve-outs, and the grammar ones. They are what would catch the rules firing on honest
  writing, and all four now measure zero.
- **A floor under the label in `scoring.md`.** A document charged with AD-14 or AD-15 is
  never labelled «Эталонный» or «Хороший», whatever the arithmetic says. This is not a cap:
  the number is still printed as it computed, and the report names the rule that held the
  label down. The arithmetic can be right and the word on top of it still false.
- **Four checkers and a release builder.** `tools/gates.sh` runs CI's sequence as one
  command, which is what lets the pre-push hook run it at all: with no `package.json` and no
  `pyproject`, this repository looked to that hook like a project with no tests, and the
  selftest now fails when the two copies of that sequence drift. `check-version.sh` holds the
  version at ten points, the skill description inside its budget, the six Russian trigger
  phrases inside the head of it, and the size SKILL.md is advertised at. `check-dogfood.sh`
  holds the numbers this product states about itself against the corpus, with a completeness
  guard that names any file stating one that nobody registered. `build-release.sh` builds the
  two release assets from tracked files only, refuses a dirty tree, and proves each asset by
  unpacking it. The selftest grew from 45 cases to 81.
- **`tools/atom-map.tsv` gains its first sixteen rows** — the first in the repository's
  history. Nine record the `scoring.md` lines whose scope the new rules extend; one records
  AD-7.5, whose rationale says in plain words that the meaning was changed on purpose.

### Changed
- **AD-7.5 narrowed.** The register carve-out now protects a speaker *inside* the text —
  dialogue, quotation, a character — and not an author writing about their own text in a
  conversational tone. The assistant register is a monologue written to sound like speech,
  and it fell straight through the old wording. AD-7 also gains the trigger forms a model
  actually reaches for: «скажу честно», «если честно», «не буду врать».
- **The corpus size is now quoted as a machine-counted floor.** «~1 044 rules» was a
  hand-maintained figure nobody could reproduce; it is replaced in eleven files by «over
  2,000 linguistic atoms» / «более 2 000 лингвистических атомов» — the unit this
  repository's own no-loss gate counts, reproducible with
  `tools/extract-atoms.sh skills/ru-text | wc -l` (2219 at this release). A floor rather than
  a figure, so that adding a rule does not oblige anyone to re-stamp eleven files.
- **The per-domain rule counts are gone from both READMEs.** The «Домены» table quoted seven
  figures — 96, 197, 88, 171, 217, 128, 138 — which sum to 1035: the retired «~1 044 rules»,
  split up. v1.10.1 recounted them by hand and corrected four; one release later three of
  the recounted ones were wrong again (57 comma traps against a stated 56, 59 button labels
  against a stated 58), and four of the seven domain figures appear nowhere in the corpus at
  all. The table now names the reference file for each section instead, so a reader who wants
  a number can open the file and count. The one number that stayed — «Стоп-слова (92 записи)»
  — is the one `check-dogfood.sh` verifies against §B on every run.

### Fixed
- **Both control texts of the golden set asserted zero findings and had never been run.**
  Both failed on their first run — seven findings and six, every one a real typographic
  defect in the fixture, which contained no non-breaking spaces at all while claiming to be
  written by the rules of the corpus.
- **Three defects in the new rules, caught by the measurement rather than by reading.** A
  document-level charge replaced ten ordinary findings with three and the text came out
  looking cleaner; density replaced the per-instance findings with a line about density;
  and AD-16 absorbed a pleonasm that lived in Grammar, scoring its target text 1.1 **higher**
  than before the rule against it existed. All three are now rules in their own right, the
  last of them stating the general principle: a new rule must never make its target score
  better.
- **The «Техническое качество» section advertised a SKILL.md that no longer existed.** It
  claimed 587 words where the file holds 583, and 9 reference files where `references/`
  holds 10. A claim offered as evidence has to be measured, so `check-version.sh` now reads
  the file and compares both READMEs against it. It compares the numbers rather than the
  sentence: Russian inflects the noun with the numeral — 583 слова, 587 слов, 581 слово —
  and a literal-string check would go red on a correct line the day the count crossed a
  declension boundary.
- **The note about the community marketplace was wrong, and wrong in the direction that
  costs users the release.** Since #19 both READMEs have said the pin «advances automatically
  with up to a day's lag». It does not. The pin is moved by a nightly sweep that opens at
  most thirty pull requests per run against a catalogue of more than two thousand entries,
  walking it roughly in alphabetical order; ru-text sits about 72% of the way down that list
  and has not been bumped once in the marketplace's last 300 commits to its manifest. Both
  READMEs now describe the mechanism, tell the reader that `claude plugins list` shows what
  they actually have, and point at `npx skills add talkstream/ru-text` or a source install
  for anyone who needs the current version today.
- **Every install channel the README advertises was run against its vendor's current
  documentation, and eight of them had drifted.** The instructions were written once and
  never re-checked; the platforms moved.
  - **Claude Desktop does not take the CLI's commands.** `/plugin` is terminal-only; in the
    app the path is the **+** button → **Plugins** → **Add plugin**. And «one install works
    in CLI, Desktop, VS Code, JetBrains and Web» was false on Web: a user-scope install does
    not reach a cloud session, which needs `enabledPlugins` in the repository's
    `.claude/settings.json`. WSL sessions have no plugins at all.
  - **Codex needs a marketplace added before `/plugins` shows anything** — `codex plugin
    marketplace add <owner>/<repo>` — and a new session before the bundled skills load.
    Neither step was in the README.
  - **ru-text is not in the Cursor marketplace.** The README told users to search for it
    there; the catalogue lists 216 plugins and none of them is ru-text. The manual copy,
    previously the fallback, is now the instruction.
  - **Both Antigravity paths had moved.** Global is `~/.gemini/config/skills/`, which all
    three Antigravity products read; per-project is `.agents/skills/` — plural — with the
    old singular still accepted for compatibility.
  - **OpenClaw refs are owner-qualified**: `@talkstream/ru-text`, as ClawHub's own page
    instructs. Bare slugs are tolerated only for already-installed or unambiguous skills.
  - **`npx skills add` does less than the README implied.** It installs three skills, not
    one. Without `-y` it opens an interactive picker and, pasted into a script, installs
    nothing. It writes `.windsurf/skills`, `.junie/skills` and `.continue/skills` only when
    those directories already exist, so on a fresh project it leaves those three platforms
    unserved — their sections now lead with the manual copy. And it is project-scoped: a
    user-level install (`-g`) has to be updated with `-g`, or the update reports success
    while the old copy stays.
- **`.codex-plugin/plugin.json` put `logo` at the top level**, where the Codex manifest
  schema does not define it; it belongs inside `interface`. Moved.
- **The Notion template inventory was missing a section and quoting a stale word count.**
  The template grew an «AI-Text Tells (Neuroslop)» section in June that the «What's included»
  list never mentioned, and the «~1,450 words» figure had drifted to 1,865. The list now
  names the section, and the word count is gone rather than re-stamped — same reasoning as
  the domain table.
- **The convention file's own claim about the corpus floor was wrong in the way it warns
  against.** It said the floor is stated «in eleven files». Nine files state it, and
  `.codex-plugin/plugin.json` on `main` was still advertising «~1,044 rules» while the
  sentence claimed the sweep was complete. The count is replaced by the `grep` that
  reproduces it.
- **The ClawHub publish note was false in the direction that ships the wrong version.** It
  said `--version` is required and that omitting it fails. On clawhub 0.23.1 the guard fires
  only when the flag is present and malformed; omitted, the flag defaults to the registry's
  next patch. A dry run without it printed «Would publish ru-text@1.10.2» and exited 0 — so
  publishing 2.0.0 without `--version 2.0.0` would have silently shipped a patch release.

## [1.10.1] - 2026-07-25

Corrects a safety claim that was never enforced, and folds in the documentation and distribution work
that landed after the v1.10.0 tag (#19–#24). Those commits sit inside this tag, so they belong in a
dated entry rather than in an unreleased section the tag would quietly carry along.

### Added
- **README badges and an update guide.** Both READMEs gained version, platform, and stars badges,
  plus a dedicated «Обновление» / «Updating ru-text» section: a primary cross-platform method
  (`npx skills add talkstream/ru-text`), per-platform update commands (Claude Code marketplace +
  plugin update, `gemini extensions update`, OpenClaw, Codex, manual copy), and a note that the
  community-marketplace pin advances with up to a day's lag (#19).
- **Neuroslop parity for the Notion AI-Skill template.** The self-contained Notion template now
  carries a condensed AI-Text Tells section — manufactured antithesis, virtue self-praise,
  assistant-register replies, hollow openers — with carve-outs faithful to the canonical
  AD-6/AD-7/AD-8/AD-9 (#20, #21).
- **The project's own conventions are now part of the repository.** `.claude/CLAUDE.md` — the release
  checklist, the manifest field rules, the per-platform gotchas — sat inside a gitignored directory,
  so it existed on one machine and reached no contributor and no fresh clone. The ignore rule is now
  scoped (`.claude/*` with an exception for `CLAUDE.md`), keeping `settings.local.json` private. The
  checklist itself gained the line the release gate caught missing: bump the hardcoded version in both
  READMEs alongside the seven manifest fields.

### Changed
- **Capability descriptions** across all manifests and the cross-platform `SKILL.md` descriptor now
  list "AI-text cleanup", so the v1.10.0 neuroslop capability appears on every listing surface (#21).

### Removed
- **Redundant duplicate tools list.** The standalone «Смотрите также» / «See also» section repeated
  the three online tools already listed under «Онлайн-инструменты» / «Online tools»; removed as
  info-style redundancy (#23).
- **`Social Preview 1280x640.png` (60 KB).** Referenced by nothing, yet shipped to every user who
  installed the plugin. `.playwright-mcp/` and local screenshot artefacts are now gitignored too.

### Fixed
- **The read-only contract is now mechanically backed, not merely declared.** Since v1.8.1 `/ru-check` and
  `/ru-score` have stated they never write to your files, citing `allowed-tools: Read, Grep, Glob` as
  the mechanism. That field restricts nothing: Claude Code's documentation says it "grants permission
  for the listed tools" and "does not restrict which tools are available: every tool remains
  callable", and the Agent Skills specification calls the same field "pre-approved". The guarantee
  rested on nothing. Both commands now carry
  `disallowed-tools: Write, Edit, NotebookEdit, Bash, PowerShell, Monitor`, which removes those tools
  while the command is active. Beyond the three file-writing tools the list names the command-executing tools we
  identified and tested — it names the paths we closed, not every path that exists. `Monitor` is easy
  to overlook: it runs commands and follows `Bash` permission rules,
  so a broad `Bash` allow-rule silently pre-approves it while a `disallowed-tools: Bash` entry does not
  remove it. Verified on Claude Code 2.1.220 by attempting a write through `Write`, through `Bash`
  redirection, through `Monitor` and through a delegated subagent: every path denied, no file created,
  and the reference files still read normally. Four limits are stated in the commands themselves: a
  connected MCP server can expose write tools a per-tool denial list cannot know about; a named
  subagent whose own definition grants it `tools: Write` is governed by that definition rather than by
  a parent denial list; a later Claude Code release can add a tool this file does not name; and on
  hosts that do not implement the field this is an instruction rather than a platform guarantee. The
  contract itself stays behavioural — the commands return text and never write, whatever the roster
  contains.
- **Stop-word catalog count in `SKILL.md`.** The always-on skill advertised "97 entries"; the catalog
  in `references/info-style.md` §B holds 92. Corrected in both copies of `SKILL.md`.
- **`scoring.md` broke the plugin's own R53.** The rule count was written with a plain space between
  digit groups where R53 requires a thin non-breaking space. The corpus now obeys itself here.
- **`openclaw.plugin.json` declared skills that do not exist.** The manifest listed `ru-check` and
  `ru-score` as sibling skills; only `skills/ru-text/` exists — the other two are commands. The
  declaration now matches reality.
- **Domain-table counters corrected to verified recounts.** Both READMEs report the authoritative
  per-section counts, each re-derived from its reference file: button labels 51 → 58, stop-words
  97 → 92, comma-trap constructions 57 → 56, clean business-writing phrases 43 → 41, plus the
  SKILL.md word count 585 → 587. The approximate headline rule count is an intentional anchor and is
  unchanged (#23).
- **Dogfooding: dropped a self-virtue phrase.** Removed «никакой воды» / «no filler words» from the
  documentation use-case in both READMEs — it was exactly the preemptive virtue qualifier the
  plugin's own AD-7 rule flags as neuroslop (#24).

## [1.10.0] - 2026-06-27

Adds a model-agnostic neuroslop catalogue — a named index of the recurring tells of AI-generated
Russian prose — with two new experiential rules, an extended virtue-qualifier rule, and sharper
detection and scoring for manufactured antithesis. No correctness coverage removed; the approximate
"~1 044" headline is unchanged (the two new experiential rules stay within its tolerance).

### Added
- **AD-8. Assistant-register meta-commentary (сервисные реплики ассистента).** New experiential rule
  in `addenda.md` flagging the chatbot-persona flourish — sycophantic acknowledgements («Отличный
  вопрос!», «Вы абсолютно правы») and assistant sign-offs («Надеюсь, это помогло», «Готов помочь»)
  — that perform a service persona instead of carrying content. Carve-outs spare genuine live
  dialogue, chat support, interviews, contact blocks, authorial prefaces, and one-way FAQs; a
  single-count clause prevents double-charging with AD-2. Severity **Low**, a secondary signal in
  Ч — Clarity, wired into `scoring.md`.
- **AD-9. Hollow opener (пустой зачин).** New experiential rule flagging openers that announce
  explanation instead of delivering it — «давайте разберёмся», «погрузимся», «важно понимать, что»,
  filler «итак» — with density (a cluster of such openers) as the primary signal. Carve-outs spare
  genuine summative or resumptive «итак», real step-by-step tutorials, informative «важно», and the
  quoted or live-dialogue register; it cross-references the throat-clearing stop-words already in
  `info-style.md` §B rather than restating them. Severity **Low**, a secondary signal in С — Structure.
- **Neuroslop index.** A named digest at the head of `addenda.md` mapping each recurring tell of
  AI-generated Russian prose to its canonical home (AD-6/AD-7/AD-8/AD-9, plus `info-style.md` §B and
  `anti-patterns.md`). A model-agnostic preamble notes the tells skew by training era and
  instruction-tuning style; a breakdown by specific model family is intentionally omitted as
  unverifiable and fast-dating.
- **Table of contents for `addenda.md`** (the file now exceeds 100 lines; per the repo convention).
- **`/ru-check` step 5.** The check now also loads `addenda.md` and scans for the neuroslop tells
  (AD-6 through AD-9), closing a gap where the experiential rules were not part of the check flow.
- **README neuroslop use-case** in both languages (RU and EN), describing cleanup of AI-generated text.
- **Community health files.** `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1), `SECURITY.md`, and
  `.github/PULL_REQUEST_TEMPLATE.md`, closing the remaining GitHub Community Standards gaps;
  `CONTRIBUTING.md` links the Code of Conduct (#17).

### Changed
- **AD-7 extended to positive-polarity self-praise.** The preemptive virtue qualifier now also covers
  positive-form delivery flourishes — «чётко, по делу», «коротко и ясно», «простыми словами»,
  «разложу по полочкам» — and the unproven-claim tricolon «быстро, качественно, надёжно». New
  carve-outs spare qualifiers that preview concrete content and established genre or rubric labels; a
  single-count clause prevents double-charging with the `info-style.md` §B unproven-claim adjectives.
- **AD-6 detection and scoring strengthened (without banning the construction).** The
  manufactured-antithesis rule adds the triggers «не просто X, а Y» and «вопрос/суть не в X, а в Y»,
  while explicitly NOT auto-flagging the degree-narrowing «не столько X, сколько Y» or an
  antecedent-free «важно не X, а Y». In `scoring.md`, a cluster of two or more manufactured pairs
  within ~150 words now lands С — Structure in the 5–6 band or lower, while a single antecedent-backed
  pair still does not move it (the 7–8 anchor is unchanged) — stronger, but never to zero, and with no
  new non-compensatory cap. The 0–2 legitimate-pair body quota and the asymmetric-self-correction
  allowance are preserved.

## [1.9.0] - 2026-06-26

Clarifies which references take precedence for web/general text, consolidates duplicate
rules into canonical homes, and paraphrases attributed quotes. No rules removed; correctness
coverage fully preserved.

### Changed
- **Editorial-reference precedence formalized.** The typography precedence note (`typography.md`
  C.4) now leads with web/screen typography norms (as set out in «Ководство», «Типографика и
  вёрстка», «Советы»); the print-editorial handbooks («Справочник издателя и автора», Розенталь)
  and the metrological ГОСТ apply for their own domains or where the web-oriented norms are silent.
  Framed as an editorial choice by register — explicitly not an endorsement by any author.
- **Anti-bureaucratic attribution updated.** The канцелярит anti-pattern and the «clean language»
  section (`editorial-grammar.md` §H) now credit M. Ilyakhov as the modern info-style lead
  alongside the existing «cf. N. Gal / K. Chukovsky» precursors.
- **«Дашборд» guidance softened** to neutral — the term is accepted in modern Russian product
  interfaces; «панель»/«сводка» kept as a context alternative.

### Refactored
- **Duplicate rules consolidated to canonical homes + cross-references.** Pleonasms and tautology
  now live canonically in `editorial-grammar.md` §E.1/§E.2; the dead→live канцелярит catalog in
  §H.2; `anti-patterns.md` cross-references them via a top-N digest (the same pattern its Typography
  category already used). The diagnostic `anti-patterns.md` is ~11% leaner. Fixed a stale count
  (READMEs said 139 anti-patterns; the canonical figure is 138). No rule lost — unique entries were
  relocated, not deleted.

### Fixed
- Paraphrased all attributed verbatim quotes (Chekhov; an HSE rhetoric note; a БРЭ encyclopedia
  note — a copyrighted source; Goodhart's law) so the project's «no verbatim quotes» statement holds
  everywhere; independent formulation with «cf.» attribution.
- Reworded the `addenda.md` intro to drop extraction-implying framing → «independently formulated;
  the listed sources informed the work, no rule is taken or copied».
- Dogfood: corrected ASCII «...» → «…» in examples; minor width/example accuracy fixes.

### Volume & model context (measured before → after)
- **Always-on `SKILL.md`: unchanged** (585 words) — no change to per-session context.
- **On-demand reference corpus: ~unchanged** (≈15.8k words, +0.6%). Consolidation removed true
  duplicates and made the diagnostic `anti-patterns.md` ~11% smaller, but unique rules were
  relocated to canonical homes rather than deleted, so the total size is flat by design — the
  value of this release is consistency and correct attribution, not a reduction in context size.

## [1.8.1] - 2026-06-26

### Added
- **Google Antigravity** install instructions in both READMEs. Antigravity reads the SKILL.md format natively, so ru-text works with no repackaging — copy the skill into `~/.gemini/antigravity/skills/` (global) or `<project>/.agent/skills/` (workspace); paths vary by version, so the section links the official Antigravity Skills codelab. Brings the documented platform count to 12.

### Changed
- **README is now Russian-primary.** `README.md` holds the Russian text (the GitHub default, fitting for a Russian-text-quality tool) and the English version moved to `README.en.md`. A prominent, welcoming English switcher sits atop `README.md` so English readers are greeted and one click from the full English docs. File history preserved via `git mv`.
- **`/ru-check` and `/ru-score` declare an explicit read-only contract.** Both commands now state that they report issues and return the corrected text (or a quality score) and must never write to, edit, or overwrite the analysed source file(s) — their `allowed-tools` are `Read, Grep, Glob` by design. Stops non-deterministic, silent NBSP insertion into source files: such a change is invisible in targets that strip NBSP on import (e.g. Notion) and breaks later exact-string grep/replace tooling on that file. Doc-only; no rules changed. (#15)
- **Always-on skill — reviewing vs. rewriting.** `SKILL.md` now instructs that when *checking* or proofreading existing text or a file, ru-text returns the corrected version plus a list of changes rather than silently overwriting the source; in-place rewrites happen only on explicit request. Closes the path by which proofreading via the always-on skill could mutate a source file.

## [1.8.0] - 2026-06-08

### Added
- **AD-6. Manufactured antithesis (ложная антитеза).** New experience-based rule in `addenda.md` flagging the symmetric contrastive-negation pair («не X, а Y», «это не…, это…», «не там, где…, а там, где…») where the negated pole has no antecedent in the text -- one of the strongest machine-generation tells in Russian prose, measured at high density in AI drafts and near-zero in live human writing. A three-condition test (no antecedent + symmetry + zero-increment deletion test) keeps it from ever flagging the author's asymmetric self-correction («вернее…», «то есть…», «не то чтобы X, но Y»), numeric corrections, fixed idioms, or antecedent-backed antitheses. Severity **Medium** — the strongest tell in this set; a primary signal in the С — Structure dimension (supporting Ч — Clarity), reflected in the С rubric anchors and wired into `scoring.md`. Dimension weights and non-compensatory caps are unchanged; density (not a single pair) is what moves the score. Quota: 0 in headings, 0–2 legitimate pairs in body.
- **AD-7. Preemptive virtue qualifier (непрошенная оговорка «без воды»).** New rule in `addenda.md` flagging the trailing self-praise flourish that denies a fault the reader never raised — «без воды», «без виляния», «честно говоря», «и без всякой магии» — an announced-not-demonstrated virtue and a frequent machine tell, cousin to AD-4. Allow-list keeps informative «без» (без сахара, без интернета, ноль моков — без заглушек), genuine epistemic qualifiers (строго говоря), and conversational/literary discourse markers (честно говоря — register carve-out, cf. AD-2.3); single-counts with AD-2 to avoid double-charging the same fragment across Ч and С. Severity Low; secondary signal in Ч — Clarity (supporting С — Structure), wired into `scoring.md`.

### Changed
- **Editorial-reference precedence generalised.** The "register and precedence" note in `typography.md` (section C.4) previously scoped the editorial-over-metrological rule to the percent sign. It now states the general principle: human-oriented references (Ководство, Справочник издателя, Розенталь) take precedence for general and web text, and ГОСТ 8.417 applies only where those references are silent or as a context variant for scientific-technical documents. No paragraph numbers are attached to «Ководство»; the percent-sign provenance remains Шульмейстер/Гиленсон plus the de-facto Runet norm.

## [1.7.3] - 2026-05-29

### Added
- **Codex marketplace icon.** Added `assets/icon.png` (512x512 grayscale, derived from the project's brand logo `logo-round.png`) and referenced it via `interface.composerIcon` in `.codex-plugin/plugin.json`, so ru-text displays an icon in the awesome-codex-plugins marketplace browser. Mirrored upstream in hashgraph-online/awesome-codex-plugins#162 (resolves issue #11).

### Changed
- **Percent sign now defaults to no space (`100%`).** Rule R37 in `typography.md` previously forced a non-breaking space before the percent sign (`100<nbsp>%`). For general and web text -- ru-text's primary register -- the dominant de facto norm and the traditional Russian hand-typesetting handbooks (М. Шульмейстер; П. Гиленсон) set the percent sign tight to the number (`100%`). The spaced form (`100 %`) is the metrological convention of ГОСТ 8.417 and remains valid for scientific and technical documents, but it is now positioned as a lower-priority, context-specific variant rather than the default. Provenance note: ГОСТ 8.417-2002 was superseded by ГОСТ 8.417-2024 (in force 30 Sep 2024), which keeps the spaced form; this change is a register/precedence decision (editorial norm over metrological standard for general text), not a claim that the standard's rule is obsolete.
- Added a short "register and precedence" note to section C.4 of `typography.md`: where a metrological standard (ГОСТ 8.417) conflicts with editorial practice for general text, the editorial norm is the default.
- Removed the obsolete "tight % sign" entry from the typography anti-pattern list in `anti-patterns.md` (it contradicted the new R37 default).

## [1.7.2] - 2026-04-30

### Fixed
- **Cross-platform skill rendering.** Replaced Claude-specific `${CLAUDE_PLUGIN_ROOT}` path tokens in both `skills/ru-text/SKILL.md` and the root `SKILL.md` (the latter is consumed by `npx skills add` and similar universal skill-discovery tools) with relative `references/<filename>` paths. Codex Desktop, Cursor, Windsurf, Cline, JetBrains Junie, Continue.dev, Gemini CLI, and GitHub Copilot do not substitute that variable, so users on those platforms previously saw raw `${CLAUDE_PLUGIN_ROOT}/skills/ru-text/references/...` strings rendered as literal text in the skill description panel. Relative paths match the documented Codex skill convention and continue to work on Claude Code via the existing `Glob("**/ru-text/references/...")` fallback.

### Changed
- **Quick Start order.** Sections in both READMEs (EN and RU) are now sorted by April 2026 platform popularity among developers using AI assistants: Claude Code (CLI) → Claude Code (Desktop) → Codex CLI → Notion → Cursor → GitHub Copilot → Gemini CLI → Windsurf → Continue.dev → Cline → JetBrains (Junie) → OpenClaw. Claude Code (Desktop) is now a separate sub-section that points to the same install commands. Headline and "Works with…" paragraph reordered to match.

## [1.7.1] - 2026-04-24

### Added
- 4 new anti-patterns in `addenda.md` (AD-2 … AD-5), all marked `Severity: Low` and integrated as secondary signals in the Clarity and Structure dimensions of `scoring.md`:
  - **AD-2.** Excessive parcellation — staccato rhythm from short sentence fragments. Context-sensitive: wrong in info-style/UX/business, acceptable in publicism, legitimate device in literature (cf. Розенталь, «Справочник», ГЛАВА L).
  - **AD-3.** Patronizing explanation (разжёвывание очевидного) — redundant over-explaining of what context already conveys. Includes an explicit cross-reference distinguishing it from `info-style.md` A.2 «примитивизация» (which denotes the opposite failure: oversimplification at the cost of meaning).
  - **AD-4.** Unprovoked rebuttal — constructions like «а это уже…», «но на самом деле…» without an antecedent claim in the text. Diagnostic test: is there actually a prior claim being rebutted?
  - **AD-5.** Subject-predicate semantic mismatch — antropomorphic predicates implying will or consciousness applied to subjects that lack them. Explicit exception for normative technical/ML terminology: сходимость, стремление к оптимуму, принятие решения машиной, обучение модели (cf. БРЭ, article Антропоморфизм).
- `scoring.md`: AD-2…AD-5 referenced as secondary signals in Clarity (AD-3, AD-5) and Structure (AD-2, AD-4) dimensions. Dimension weights and non-compensatory caps unchanged.

### Credits
- Anti-patterns AD-2..AD-5 proposed by @V8-Software in issue #9 (2026-04-16). Original terminology adjusted in three places to prevent terminological collisions and false positives on established technical writing (see issue comment for rationale).

## [1.7.0] - 2026-04-14

### Added
- GitHub Copilot support: install instructions, `.github/skills/` path documentation
- Windsurf (Codeium) support: install instructions, `.windsurf/skills/` path documentation
- Cline support: install instructions, `.cline/skills/` path documentation
- JetBrains Junie support: install instructions, `.junie/skills/` path documentation
- Continue.dev support: install instructions, `.continue/skills/` path documentation
- Roadmap section in both READMEs: Telegram Bot, Browser Extension, WordPress Plugin

### Changed
- Platform support expanded: 7 → 12 platforms (Claude Code, GitHub Copilot, Windsurf, Cursor, Cline, JetBrains Junie, Continue.dev, Codex CLI, Gemini CLI, OpenClaw, Notion, skills CLI)
- Quick Start section reorganized for 12-platform listing

## [1.6.0] - 2026-04-09

### Added
- Notion integration: AI Custom Skill template for in-Notion text quality checks (`notion/ru-text-notion-skill.md`)
- Notion MCP workflow documentation (Claude Code + Notion MCP server)
- OpenClaw support: native plugin manifest (`openclaw.plugin.json`)
- ClawHub marketplace readiness (`metadata.openclaw` in SKILL.md frontmatter)
- OpenClaw and Notion installation instructions in both READMEs
- `notion/` directory with self-contained skill template and bilingual setup guide

### Changed
- Platform support expanded: Claude Code, Codex CLI, Gemini CLI, Cursor, OpenClaw, Notion
- Consistent digit formatting across all README files (English: `~1,040`; Russian: `~1 040`)

### Fixed
- Claude Code install: added `@claude-community` marketplace suffix
- Codex CLI: replaced non-existent `codex install` with interactive `/plugins` browser
- Cursor: added `/add-plugin` as primary install method, manual copy as fallback
- OpenClaw: corrected install syntax to `clawhub:ru-text` format
- Notion: fixed keyboard shortcut (removed wrong `Ctrl+J`), corrected menu path
- Typography: fixed closing lapki quote U+0022 → U+201C in SKILL.md and Notion template
- OpenClaw manifest: removed undocumented fields (`kind`, `enabledByDefault`)
- Cursor: corrected manual install path (`.agents/skills/` → `~/.cursor/skills/`)
- Cursor: added Windows (PowerShell) install path for manual skill setup (thanks @dreik, PR #8)
- Cursor: documented `~/.cursor/plugins/local/` as full plugin local testing path (cf. cursor/plugin-template#4)

## [1.5.1] - 2026-04-01

### Fixed
- Reference files unreachable for marketplace users: Claude could not resolve relative paths in SKILL.md and commands because the Skill tool does not provide a base directory
- Used `${CLAUDE_PLUGIN_ROOT}` (official Claude Code variable, substituted inline in skill content) for absolute paths to reference files, with Glob fallback for cross-platform compatibility

### Changed
- SKILL.md and commands now use `${CLAUDE_PLUGIN_ROOT}/skills/ru-text/references/<filename>` paths instead of unresolvable relative markdown links
- Trimmed redundant quality checklist items from SKILL.md (covered by reference files)

## [1.5.0] - 2026-03-31

### Added
- Published to Anthropic community plugin marketplace
- Installation via `/plugin marketplace add anthropics/claude-plugins-community` + `/plugin install ru-text`
- Badge: plugin status in README

### Changed
- Claude Code Quick Start updated with marketplace setup step

## [1.4.0] - 2026-03-30

### Added
- Gemini CLI extension support (`gemini-extension.json`, `agents/gemini.yaml`)
- Cursor compatibility: reads SKILL.md via `.agents/skills/` standard
- Multi-platform Quick Start in README (Claude Code, Codex CLI, Gemini CLI, Cursor)

## [1.3.0] - 2026-03-30

### Added
- OpenAI Codex CLI compatibility (`.codex-plugin/plugin.json`, `agents/openai.yaml`)
- Codex installation instructions in README

## [1.2.0] - 2026-03-29

### Added
- `/ru-text:ru-score` command: text quality scoring on a 0.0–10.0 scale
- 5-dimension analytic rubric: typography, clarity, grammar, structure, reader precision
- Non-compensatory scoring: critical weakness in one dimension caps total score
- scoring.md reference file with full algorithm, rubric anchors, and research basis

## [1.1.0] - 2026-03-29

### Added
- Claude Cowork compatibility (works automatically, same plugin structure)
- Privacy Policy (PRIVACY_POLICY.md)
- 8 modern UX button patterns (Archive, Favorite, Mute, Report, Add to cart, Wishlist, Filter, React)
- Table of Contents in all reference files over 100 lines
- Use cases section in both READMEs
- Technical quality section in both READMEs
- GitHub Sponsors integration

### Changed
- SKILL.md description optimized to 196 characters (under 250-char truncation threshold)
- README split into separate English and Russian files (README.md + README.ru.md)

## [1.0.0] - 2026-03-29

### Added

- Initial release: ~1040 independently formulated rules for Russian text quality
- Auto-activation when Claude produces or edits Russian text
- `/ru-text:ru-check` command for manual comprehensive text quality checks
- 7 domains: typography (96 rules), information style (197), editorial punctuation (88), editorial grammar (171), UX writing (217), business writing (128), anti-patterns (139)
- Experience-based addenda system for rules discovered through practice
- Bilingual README (English + Russian)
- Full source attribution with purchase/access links
