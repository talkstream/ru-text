# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Documentation and distribution polish following the v1.10.0 neuroslop release — no rule changes.

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

### Changed
- **Capability descriptions** across all manifests and the cross-platform `SKILL.md` descriptor now
  list "AI-text cleanup", so the v1.10.0 neuroslop capability appears on every listing surface (#21).

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
