# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2026-03-31

### Added
- Published to official Anthropic plugin marketplace
- One-command installation: `/plugin install ru-text`
- Badge: official plugin status in README

### Changed
- Claude Code Quick Start simplified from 2-step marketplace-add to 1-step install

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
