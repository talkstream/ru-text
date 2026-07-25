# ru-text — Claude Code plugin for Russian text quality

**Author:** Arseniy Kamyshev (nafigator@gmail.com)
**Repo:** https://github.com/talkstream/ru-text
**Site:** https://ru-text.org
**Sponsors:** https://github.com/sponsors/talkstream
**Version:** 1.10.1 | **License:** MIT | **Platforms:** Claude Code, GitHub Copilot, Windsurf, Cursor, Cline, JetBrains (Junie), Continue.dev, Codex CLI, Gemini CLI, Google Antigravity, OpenClaw, Notion

~1,044 independently formulated rules across 7 thematic areas. No verbatim quotes, full source attribution.

## Priorities

1. **Quality** — every rule must be accurate and actionable
2. **User care** — plugin helps, never restricts. User's explicit style request overrides defaults
3. **Performance** — SKILL.md under 600 words; references load on demand, not at startup
4. **Legal safety** — no "distilled from", no implied endorsement, no author names in section headers

## Architecture

```
.claude-plugin/plugin.json      → Claude Code plugin metadata
.codex-plugin/plugin.json       → Codex CLI plugin metadata
.cursor-plugin/plugin.json      → Cursor plugin metadata
openclaw.plugin.json            → OpenClaw native plugin manifest
gemini-extension.json           → Gemini CLI extension metadata
(No new manifests needed — GitHub Copilot, Windsurf, Cline, JetBrains Junie, and Continue.dev read standard SKILL.md natively)
skills/ru-text/SKILL.md         → always-on typography + routing table (<600 words, cross-platform)
skills/ru-text/references/      → 9 domain files + addenda + sources (loaded on demand)
skills/ru-text/agents/openai.yaml → Codex skill metadata (Claude ignores)
skills/ru-text/agents/gemini.yaml → Gemini skill metadata (Claude ignores)
commands/ru-check.md            → /ru-check command (Claude Code only, fork context)
commands/ru-score.md            → /ru-score command (Claude Code only, fork context)
notion/ru-text-notion-skill.md  → Notion AI Custom Skill template (self-contained, ~1450 words)
notion/README.md                → Bilingual Notion setup guide (AI Skill + MCP workflow)
README.md + README.en.md        → bilingual docs (RU primary = GitHub default; EN in README.en.md; welcoming EN switcher atop README.md)
PRIVACY_POLICY.md               → zero data collection statement
assets/icon.png                 → 512×512 marketplace icon (Codex composerIcon; derived from logo-round.png)
```

Progressive disclosure: Claude reads SKILL.md first (typography rules, top stop-words, routing table), then loads domain-specific references only when the task requires them.

## Commands

```bash
claude plugins validate /path/to/ru-text    # validate manifest
claude plugins marketplace update ru-text   # refresh marketplace cache
/ru-text                                    # activate skill manually
/ru-text:ru-check <text>                    # comprehensive quality check (fork context)
/ru-text:ru-score <text>                    # text quality score 0–10 (fork context)
```

## Conventions

### Legal (apply to ALL text in repo: README, CHANGELOG, commits, comments)
- NEVER say "distilled from" — use "informed by" or "independently formulated"
- NEVER imply source authors endorse this plugin
- NEVER use author names in section headers as if they endorse (e.g., "Nora Gal's principles" → "Clean language principles, cf. N. Gal")
- IP notice references: Article 1259(5) of the Russian Civil Code, 17 USC §102(b), Berne Convention

### Content
- New rules from experience → `addenda.md` (AD-1, AD-2, …), NOT domain files
- Reference files >100 lines must have Table of Contents
- SKILL.md description must stay under 250 chars (Claude truncates beyond that)
- Plugin must follow its own typography rules (dogfooding)

### plugin.json (Zod strict mode — unknown fields break the plugin silently)
- Valid fields: `name`, `version`, `description`, `author` (object: name, email, url), `homepage`, `repository` (string URL), `license`, `keywords` (array)
- NEVER add `tags`, `category`, `source` — these belong in marketplace.json only (issue #26555)
- `repository` must be a string, NOT an object — `"https://..."` not `{"type":"git","url":"..."}`
- After editing plugin.json: `claude plugins validate /path/to/ru-text` before committing
- Keep versions in sync across ALL manifests: .claude-plugin (plugin.json AND marketplace.json — two fields there), .codex-plugin, .cursor-plugin, gemini-extension.json, openclaw.plugin.json — **the hardcoded «Latest version» line in README.md and README.en.md**, and **the `**Version:**` header of this file**. The v1.10.1 gate caught the READMEs still advertising the previous release, and then caught this file doing the same
- Codex CLI is pre-1.0 (v0.118.0) — plugin.json schema may change between minor versions

### Dev workflow (local plugin testing)
- Update cache after source changes: `claude plugins marketplace update ru-text`
- Reinstall if cache is stale: `claude plugins uninstall ru-text && claude plugins install ru-text`
- Verify: `/reload-plugins` then `/doctor` — expect 0 plugin errors

### Git
- New commits on main (no amend, no force push — branch is protected)
- Commit message: no source author names, no "distilled", no problematic language

## Gotchas

- No build step, no dependencies — pure markdown plugin
- awesome-claude-code (hesreallyhim): NEVER submit via gh CLI — web form only, 14-day cooldown on violation
- Anthropic marketplaces (verified 2026-04-30): ru-text IS in `anthropics/claude-plugins-community` (slug `ru-text@claude-community`, sha-pinned to a specific commit) and IS NOT in `anthropics/claude-plugins-official` (the directory backing claude.com/plugins). Single submission form for BOTH directories: clau.de/plugin-directory-submission → claude.ai/settings/plugins/submit or platform.claude.com/plugins/submit. Anthropic curators decide tier per submission. PRs opened directly to either repo are auto-closed (read-only mirrors of Anthropic's internal pipeline). Routine version updates need NO form (verified 2026-06-09): an automated nightly `bump-plugin-shas` action + periodic Bulk-sync re-pin every listed plugin to its upstream HEAD (gated by `validate-plugins`). The ru-text pin advanced on its own from `7932d7c` (Mar) to `13d1a03` with no re-submission; just push the new version to main and wait for the next sync. The form is needed ONLY for initial listing, official-tier promotion, or when auto-bump starts failing tightened policies. PRs to either repo are still auto-closed — no manual sha-bump path
- Version bump in plugin.json is REQUIRED for users to get updates (Claude Code uses version for cache invalidation)
- `${CLAUDE_PLUGIN_ROOT}` is a Claude-Code-only token. Valid contexts: `.claude-plugin/plugin.json`, hooks, MCP/LSP configs, and any other file consumed only by Claude Code. NEVER use it in `skills/ru-text/SKILL.md` body or other cross-platform skill content — Codex, Cursor, Windsurf, Cline, JetBrains Junie, Continue.dev, Gemini CLI, and GitHub Copilot do not substitute it and would render the literal `${CLAUDE_PLUGIN_ROOT}/...` string in their UI (regression fixed in v1.7.2). In skill bodies, use relative paths like `references/<filename>`; the existing Glob fallback in SKILL.md covers any nonstandard marketplace layout in Claude Code
- `content/originals/` contains pre-compaction backups — gitignored, do not delete
- marketplace.json does NOT support `$schema` or root-level `description` — use `metadata.description`
- Codex CLI: self-serve publishing NOT available (as of v0.118.0). Users install via `/plugins` interactive menu
- Codex install command may change — verify at developers.openai.com/codex/plugins before updating docs
- awesome-codex-plugins (hashgraph-online): community Codex marketplace where ru-text is listed. Generator-driven — `scripts/generate_plugins_json.py` fetches each plugin's repo HEAD and derives the entry's icon from `interface.composerIcon` (icon lives in `.agents/plugins/marketplace.json`, NOT root `plugins.json`; icon file must be ≤50KB, SVG preferred/PNG accepted). Push `composerIcon` + the icon file to your HEAD BEFORE the mirror PR, else the icon is silently dropped. Hard CI gate: `validate-plugin-pr.py` (run locally with `--base-ref origin/main`). Icon added v1.7.3 (`assets/icon.png`), mirror PR #162 (issue #11). Full mechanics in project memory `reference_awesome_codex_plugins.md`
- GitHub Copilot: reads `.github/skills/`, `.claude/skills/`, `.agents/skills/` — all three. Also `~/.copilot/skills/` global. Submit to github/awesome-copilot (staged branch, not main)
- Windsurf: reads `.windsurf/skills/` and can read `.claude/skills/` if cross-agent enabled. Manual: Cascade > Customizations > Skills. No official directory; third-party: windsurf.run
- Cline: reads `.cline/skills/` and `.claude/skills/` natively. Enable via Settings > Features > Enable Skills. No official marketplace
- JetBrains Junie: reads `.junie/skills/` ONLY — does NOT auto-read `.claude/skills/` (detects but requires manual import). Works in all JetBrains IDEs. No skills marketplace
- Continue.dev: reads `.continue/skills/` and `.claude/skills/`. Continue Hub exists but no skill submissions yet
- SKILL.md is cross-platform (Claude Code + GitHub Copilot + Windsurf + Cursor + Cline + JetBrains Junie + Continue.dev + Codex + Gemini CLI) — do NOT duplicate it
- Cursor: marketplace at cursor.com/marketplace/publish, manual review. `.cursor-plugin/plugin.json` ready
- Gemini CLI: auto-discovery via `gemini-cli-extension` GitHub topic (added). Gallery at geminicli.com/extensions/
- OpenClaw: natively reads `.claude-plugin/` as bundles. Native manifest `openclaw.plugin.json`. ClawHub: published at clawhub.ai/talkstream/ru-text (the listing tracks the latest release; do not pin a version in this note — it goes stale). Publish CLI: `npm i -g clawhub && clawhub login && clawhub skill publish ./skills/ru-text --slug ru-text --version <semver>`. The `--version` flag is REQUIRED — omitting it fails with `Error: --version must be valid semver`
- OpenClaw indexes ru-text as a **skill** (not plugin). Users install via `openclaw skills install ru-text`, NOT `openclaw plugins install`
- Cursor: standalone skill path is `~/.cursor/skills/ru-text`. Full plugin local testing: `~/.cursor/plugins/local/ru-text/` (requires `.cursor-plugin/plugin.json`). NOT `.agents/skills/` (Vercel/npx convention, Cursor doesn't read it). PR #8 confirmed the bug; `plugins/local/` confirmed by Cursor engineer in cursor/plugin-template#4
- NeuralDeep (neuraldeep.ru): listed and live — the April 2026 submission passed moderation. Catalogue at neuraldeep.ru/skills accepts «формат claude-skill и любые репозитории со SKILL.md»; install CLI `npx skillsbd add owner/repo/skill`. Web form at neuraldeep.ru/submit (GitHub OAuth required)
- Notion: no plugin architecture. Two integration paths: (1) Notion AI Custom Skill template page in `notion/`, (2) MCP bridge (Claude Code + Notion MCP server). Notion AI Skills require Business/Enterprise plan. Template must be self-contained (no `${CLAUDE_PLUGIN_ROOT}` paths)
