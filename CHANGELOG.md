# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
