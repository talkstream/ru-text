# ru-text — Claude Code plugin for Russian text quality

**Author:** Arseniy Kamyshev (nafigator@gmail.com)
**Repo:** https://github.com/talkstream/ru-text
**Site:** https://ru-text.org
**Sponsors:** https://github.com/sponsors/talkstream
**Version:** 2.10.9 | **License:** MIT | **Platforms:** Claude Code, GitHub Copilot, Windsurf, Cursor, Cline, JetBrains (Junie), Continue.dev, Codex CLI, Gemini CLI, Google Antigravity, OpenClaw, Notion

Over 2,000 independently formulated linguistic atoms across 7 thematic areas. No verbatim quotes, full source attribution.

## Priorities

1. **Quality** — every rule must be accurate and actionable
2. **User care** — plugin helps, never restricts. User's explicit style request overrides defaults
3. **Performance** — SKILL.md at most **650 words** (measured `LC_ALL=C wc -w`); references load on demand, not at startup. The figure used to read «under 600» and was false: the file was 615 words when nobody checked, and the always-on dash fix of 01.08.2026 took it to 640. The budget is now a gate in `tools/check-dogfood.sh`, not a sentence — a size claim about the one file loaded on every turn is exactly the kind that goes stale in silence.
4. **Legal safety** — no "distilled from", no implied endorsement, no author names in section headers

## Architecture

```
.claude-plugin/plugin.json      → Claude Code plugin metadata
.codex-plugin/plugin.json       → Codex CLI plugin metadata
.cursor-plugin/plugin.json      → Cursor plugin metadata
openclaw.plugin.json            → OpenClaw native plugin manifest
gemini-extension.json           → Gemini CLI extension metadata
(No new manifests needed — GitHub Copilot, Windsurf, Cline, JetBrains Junie, and Continue.dev read standard SKILL.md natively)
skills/ru-text/SKILL.md         → always-on typography + routing table (≤650 words, gated, cross-platform)
skills/ru-text/references/      → 8 domain files + addenda + sources (loaded on demand)
skills/ru-text/agents/openai.yaml → Codex skill metadata (Claude ignores)
skills/ru-text/agents/gemini.yaml → Gemini skill metadata (Claude ignores)
skills/ru-check/SKILL.md        → /ru-text:ru-check full-corpus check (fork context, read-only; moved from commands/ in a2d26d1)
skills/ru-score/SKILL.md        → /ru-text:ru-score 0–10 quality score (fork context, read-only; moved from commands/ in a2d26d1)
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

### What belongs in this repository, and what does not

**Paid is whatever deterministically FIXES arbitrary user text. Public is the corpus — rules
in prose — and detectors whose input set is hard-wired into this repository.**

Adopted 16.08.2026, after two adversarial panels and an arbiter were asked to find the leak
and found none: no file here has ever transformed text, and the history says so —
`git log --all --diff-filter=A --pretty=format: --name-only -- '*.ts' '*.js' '*.mjs'` is
empty. The scripts under `tools/` are discipline gates — the count is deliberately not
stated here, because a hand-maintained number goes stale in the commit that adds a file, and
this one did. `check-typography.sh` hard-wires three filenames in `FILES` and takes no
arguments at all, and its own header records that the
same patterns over the corpus files report 53 «violations» that are all correct content.
`check-dogfood.sh` does not detect stop-words in prose — it counts them in the reference and
verifies the documentation quotes the right number.

Three more obvious phrasings were tried and each broke on a real file. «Prose vs code» would
exile `check-typography.sh`, the very gate that enforces this repository's own typography
claim. «Needed by the skill vs needed by the service» would exile `check-frozen.sh`, which
exists *for* the paid service yet guards public bytes.

The surviving predicate is settled by one question a reviewer can grep: **does this file write
corrected text?** ⚠ There is no machine gate for it and there will not be one — telling a
detector from a transformer is reading, not matching. Calling it a check would make it a
promise without a mechanism, which is the exact debt this repository spends its gates
retiring. It is review discipline, and it is named as such.

**The predicate's second edge: detection is also the product.** A reviewer asking only «does
this file write corrected text?» would wave through a deterministic stop-word linter over
arbitrary prose — neither side of the line above claims it: it fixes nothing, and its input is
not hard-wired. Declined all the same. What may not ship here is deterministic code that
APPLIES this corpus — its rules, its dictionaries, or a derivative of them — to text from
outside this repository, whether the output is a correction or a report: reporting is the other
half of what the paid `ru_check` sells.

The word *deterministic* is load-bearing — the skills in this repository apply the corpus
through a model, and they stay exactly where they are. Two other neighbours also stay: gates
that apply the corpus to THIS repository's own files (`check-typography.sh`), and instruments
that read arbitrary text but apply no corpus rule to it and propose no change
(`measure-prose-shape.py` counts sentence-length variance; the AD-6 mention in its docstring is
motivation, not a pattern it matches). Same status as the predicate itself: no machine gate, and
there will not be one — «applies the corpus» and «arbitrary input» are read, not matched.

**Routing rule for new work:** deterministic code that applies the corpus to outside text —
correcting it or reporting on it — is born in the private service repository, from its first
commit. It is never written public-first — one public commit is
irreversible, and moving it afterwards buys nothing: what shipped under MIT stays shipped —
in every release tag and in every clone.

⚠ **The risk runs the other way.** Nothing already published can be recalled, so the danger is
not the past but the temptation to publish the engine for convenience — a wasm demo on the
site, an npm package «so people can try it». That would close the only moat the paid side has,
and it needs an explicit decision, never a convenience.

### How a rule earns its place

**A rule is justified by the LETTER of the corpus and by an inventory checked against the
blind key — never by the outcome of a single run.** Adopted 11.08.2026, after a carve-out
shipped with a justification that did not survive its own control: «one pass removed these
words six times» was true and useless, because the same prompt on the same file released them
in all three corpus snapshots tried, including the one whose run produced the removals.

Practically, three tests before a rule is written:

- **Does the corpus TEXT command something wrong?** That is checkable by reading, it is
  deterministic, and it stays true tomorrow. It is the only ground that holds.
- **Is the inventory direction-checked against the key?** A blind judge's VOTE is a fact; the
  causal story he writes beside it is a hypothesis, because he does not know which side was
  the intervention. One signal on this line was withdrawn when its attribution turned out
  inverted — the judge had described the untouched original as the damaged side.
- **Would the claim survive a second run?** If it rests on «the tool does X», it is a property
  of a coin whose bias nobody has measured. Say what the text now permits and forbids; never
  how often the model will do it.

Corollary for release notes and README: claims about the corpus text ship; claims about run
outcomes do not.

### Content
- New rules from experience → `addenda.md` (AD-1, AD-2, …), NOT domain files
- Reference files >100 lines must have Table of Contents
- SKILL.md description: 250 chars is OUR style budget (`tools/check-version.sh`), not a platform limit — Claude Code truncates the listing at 1,536, upload/API/standard allow 1,024 (09.10.2026; `~/.claude/runbooks/plugin-marketplaces.md` §3.3, §7)
- Plugin must follow its own typography rules (dogfooding)
- **The corpus size is quoted as a floor, in atoms, and the floor is machine-counted.** «Over 2,000 linguistic atoms» / «более 2 000 лингвистических атомов». Reproduce the count with `tools/extract-atoms.sh skills/ru-text | wc -l` (2219 on 28.07.2026), and find every file that states the floor with `grep -rlE '2[ ,\xc2\xa0]000 (linguistic atoms|лингвистических атомов)|2,000\+ atoms' --include='*.json' --include='*.md' . | grep -v node_modules` — 9 on 28.07.2026, and NOT a number to memorise. This sentence used to say «in eleven files», which was itself a hand-maintained count and was itself wrong: the true figure was nine, and `.codex-plugin/plugin.json` was still saying «~1,044 rules» on main while the sentence claimed the sweep was complete. The floor replaced «~1 044 rules», a figure nobody could reproduce. A floor is chosen on purpose: it survives the corpus growing, so adding a rule does not oblige anyone to re-stamp anything. Raise it only when the count clears the next thousand, and raise it everywhere in one commit

### plugin.json (unknown top-level keys are stripped and `validate` warns; nested objects `userConfig`, `channels`, `lspServers`, `monitors` stay strict — 09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.1)
- Valid fields: `name`, `version`, `description`, `author` (object: name, email, url), `homepage`, `repository` (string URL), `license`, `keywords` (array); the list is wider now: also `displayName`, `icon`, `documentationUrl`, `supportUrl`, `privacyPolicyUrl`, `termsOfServiceUrl`, `metadata`, `defaultEnabled`, `dependencies`, `userConfig` (09.10.2026, §3.1)
- Keep `tags`, `category`, `source` out of plugin.json — they belong in marketplace.json only; hygiene, not a breakage: `validate` calls them «harmless here but unused» and issue #26555 was closed 2026-04-18 (09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §7 item 1)
- `repository` must be a string, NOT an object — `"https://..."` not `{"type":"git","url":"..."}`
- After editing plugin.json: `claude plugins validate /path/to/ru-text` before committing
- Keep versions in sync across ALL manifests: .claude-plugin (plugin.json AND marketplace.json — two fields there), .codex-plugin, .cursor-plugin, gemini-extension.json, openclaw.plugin.json — and **the `**Version:**` header of this file** — eight points, and `tools/check-version.sh --print` lists them. The READMEs no longer state the version in prose: they carry a badge that renders it live from the releases API, so there is nothing there to go stale. The v1.10.1 gate caught those two prose lines advertising the previous release, and then caught this file doing the same; the badge removes the first failure mode rather than re-checking it
- Codex CLI is pre-1.0 and moves fast: 0.144.0 locally, 0.162.0 on npm as `@openai/codex` (09.10.2026). The primary Codex format is now a root `plugin.json` (Agent Plugins, `extensions.com.openai`) and `.codex-plugin/plugin.json` is a «compatibility fallback»; the portal accepts both, and a present `extensions.com.openai` displaces `.codex-plugin` (09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.4). The note here said v0.118.0 for months. The plugin.json schema may change between minor versions, so re-check it at each release rather than trusting this line

### Dev workflow (local plugin testing)
- Update cache after source changes: `claude plugins marketplace update ru-text`
- Reinstall if cache is stale: `claude plugins uninstall ru-text && claude plugins install ru-text`
- Verify: `/reload-plugins` then `/doctor` — expect 0 plugin errors

### Git
- New commits on main (no amend, no force push — branch is protected)
- Commit message: no source author names, no "distilled", no problematic language

## Gotchas

- No build step, no dependencies — pure markdown plugin
- awesome-claude-code (hesreallyhim): ⚠ CLOSED to outsiders since 09.10.2026 — the owner limited issue creation and comments to collaborators, so #1543 can be neither edited, closed nor resubmitted; the director unsubscribed and left. Do not plan submissions there. History: NEVER submit via gh CLI — web form only (confirmed); the «14-day cooldown» is NOT confirmed — no COOLDOWN.md, no term in CONTRIBUTING; the real gates are a resource age of 14 days or 100 stars and one open application per author (09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.9, §7 item 17)
- Anthropic marketplaces (re-measured 2026-10-09): ru-text IS in `anthropics/claude-plugins-community` (2284 entries, index 1633, pinned by sha) and IS NOT in `anthropics/claude-plugins-official` (315 entries). ⚠ **The official tier CANNOT be applied for** — the docs say it (the former wording «There is no application process…» no longer exists, 09.10.2026): the portal «doesn't take submissions through the directory portal. If you work with an Anthropic partner contact, ask them about an official-marketplace listing» (code.claude.com/docs/en/plugins/publish.md:133; `~/.claude/runbooks/plugin-marketplaces.md` §3.2). The old note here claimed one form served both directories and that curators picked the tier; that was false, and it cost a session's worth of planning. The Console form (platform.claude.com/plugins/submit) is no longer supported (09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.2, §7 item 5); the current path is the developer portal https://claude.ai/directory/manage (paid claude.ai plan, GitHub, security scan, human review of a new listing). Per the docs a listing submitted earlier «stays as it is»; moving it (Withdraw + resubmit, or directory@anthropic.com) is the director's call. Whether portal submissions reach the community mirror is UNVERIFIED. `clau.de/plugin-directory-submission` now 302s to https://claude.com/docs/directory/publish, which no longer carries the two old form links. PRs opened directly to either repo are auto-closed (read-only mirrors of Anthropic's internal pipeline). **Do NOT assume a release reaches community-marketplace users: measure the pin.** The nightly `bump-plugin-shas` sweep reached us once — `bump(ru-text): 44c2da92 → 98246bd7` merged 2026-08-09 (`gh pr view 2190 --repo anthropics/claude-plugins-community`) — and is now OFF: the workflow is `disabled_manually` since 2026-08-14, the last bot bump was 2026-08-13, and the ru-text pin is still `98246bd7` (a commit of 2026-08-01, BEFORE v2.1.0), far behind HEAD — count it with `git rev-list --count 98246bd7..HEAD`, not from this note; the only merge seen after the switch-off was manual (#2373). The 2026-08-09 reading «slow, not stuck» is retired (`~/.claude/runbooks/plugin-marketplaces.md` §3.2, §7 item 6). **Never write in user-facing docs that the pin advances within a day.** The listing DESCRIPTION is curator-written («~1,040 rules», «Eight reference files», «Auto-activates on Russian text output» — behaviour 2.2.0 removed), and the Console form was the route to replace it: the director filed a submission carrying our manifest string on 2026-08-12, and platform.claude.com/plugins shows it **Published**. That is the portal's state, not the catalogue's — measured the same hour, the mirror still serves the curator text and the old pin. Approval in the portal is not delivery to users; read the mirror before claiming either. PRs to either repo are still auto-closed — no manual sha-bump path
- **Claude Desktop and Cowork sync this repo as a MARKETPLACE, and a server-side validator gates it — one stricter than ours.** Measured 2026-08-12: sync failed with a UI message carrying no diagnosis («Marketplace sync failed. Check the repository URL and try again.») while the real error sat in `~/Library/Logs/Claude/claude.ai-web.log`: a unicode escape in a SKILL.md frontmatter (`emoji: "\U0001F4DD"`, shipped since v1.6.0) rejects the WHOLE marketplace. `claude plugin validate` does not check for this, so a green local gate and a failing sync coexisted for months. On any external rejection read that log — never guess from the UI.
- **`displayName` exists and we need it**: without it the UI derives a label from `name` and shows «Ru text». Set in both `plugin.json` and the marketplace entry (different surfaces read different ones). `plugin.json` DOES have an `icon` field («Icon for the plugin's listing in Anthropic's directory. Claude Code doesn't read it») and four listing URL fields (`documentationUrl`, `supportUrl`, `privacyPolicyUrl`, `termsOfServiceUrl`); marketplace entries do not know them. The earlier «no icon field» was wrong (09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.1, §7 item 2).
- **Two public installers work on this repo and are documented in INSTALL.md § «Одной командой»**: `npx skills add talkstream/ru-text` (Vercel Labs, installs all three skills, 1.1K installs across them on skills.sh on 09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.9) and `npx skillsbd add talkstream/ru-text/ru-text` (NeuralDeep, one skill, 162). Neither pins a version — both clone `main`, so there is nothing to update on their side. Do not confuse this with the community-marketplace pin, which lags for weeks.
- **Outside Claude Code the frontmatter accepts exactly six keys** (`name, description, license, compatibility, metadata, allowed-tools`) — that is the claude.ai upload, the Skills API and `package_skill.py`. `ru-text` passes; `ru-check` and `ru-score` do not (`disallowed-tools`, `context: fork`, `user-invocable`) and have no business there. The Skills API in Console is a workspace-private store for API and Managed Agents, NOT a catalogue: no public listing. `anthropics/skills` is spec and examples, not a channel — no CONTRIBUTING (404).
- Version bump in plugin.json is REQUIRED for users to get updates (Claude Code uses version for cache invalidation)
- `${CLAUDE_PLUGIN_ROOT}` and `${CLAUDE_SKILL_DIR}` are Claude-Code-only tokens. One sanctioned exception (2.9.4): `ru-check` and `ru-score` name `${CLAUDE_SKILL_DIR}` inside a sentence scoped «In Claude Code», with an explicit fallback to the search when the token arrives unexpanded — other hosts read it as a path they skip, not a broken instruction. The rest of this note is about `${CLAUDE_PLUGIN_ROOT}`. Valid contexts: `.claude-plugin/plugin.json`, hooks, MCP/LSP configs, and any other file consumed only by Claude Code. NEVER use it in `skills/ru-text/SKILL.md` body or other cross-platform skill content — Codex, Cursor, Windsurf, Cline, JetBrains Junie, Continue.dev, Gemini CLI, and GitHub Copilot do not substitute it and would render the literal `${CLAUDE_PLUGIN_ROOT}/...` string in their UI (regression fixed in v1.7.2). In skill bodies, use relative paths like `references/<filename>`; the existing Glob fallback in SKILL.md covers any nonstandard marketplace layout in Claude Code
- `content/originals/` contains pre-compaction backups — gitignored, do not delete
- marketplace.json DOES accept `$schema`, `version` and `description` at the top level (CHANGELOG 2.1.120; without a top-level `description` `validate` warns «No marketplace description provided») — the earlier «does NOT support» was wrong (09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §7 item 3). Do not rely on the `$schema` URL `https://anthropic.com/claude-code/marketplace.schema.json` as a schema: it does not serve one (§8)
- **Codex and ChatGPT now share a plugin system**, and we document only half of it: «Plugins work in Chat and Work across ChatGPT on the web, desktop, and mobile, and in Codex in the ChatGPT desktop app. Codex CLI also has a plugin browser… The IDE extension doesn't support plugins» (learn.chatgpt.com/docs/plugins, 09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.4). ChatGPT Work users install from the **Work** switcher → **Plugins** — an audience our docs never addressed. The CLI also has a NON-interactive install we never documented: `codex plugin add <PLUGIN>@<MARKETPLACE>`, verified against the live 0.144.0 binary
- **Codex ships `claude-plugins-official` as a default marketplace** (`codex plugin marketplace list` on a stock install shows it alongside openai-primary-runtime, openai-bundled and openai-curated). ru-text is NOT in it — we are in `claude-plugins-community`. Promotion to the official tier would deliver ru-text to Codex users with zero setup, so it is worth more than one channel — but there is no way to ask for it (see the Anthropic-marketplaces note above): the decision is Anthropic's alone, and the only lever is the plugin itself
- Codex CLI: self-serve publishing IS now available — the submission portal at platform.openai.com/plugins explicitly accepts «a skills-only plugin that packages reusable workflows», which is what ru-text is (developers.openai.com/plugins/deploy/submission.md, verified 28.07.2026). The old note said it was unavailable as of v0.118.0. A first-party listing also removes the marketplace-add prerequisite the third-party catalogue imposes. **Done: submitted and PUBLISHED 30.07.2026 (2.0.1), re-submitted and published for 2.3.0 on 12.08.2026** — the flow is an uploaded archive, not a repo link, and the portal's Info tab arrives pre-filled from it. Since 09.10.2026 the listing card (`displayName`, `shortDescription`, `longDescription`, `developerName`, `category`, `capabilities`, URLs, icons), `release_notes` and `countries` come FROM THE MANIFEST and are read-only in the portal; `capabilities` is a free-string array (≤20 × ≤120), not a Read/Write chip vocabulary; the Terms of Service URL is required for MCP plugins, not for skills-only (`~/.claude/runbooks/plugin-marketplaces.md` §3.4, §7 items 9-12)
- Codex docs moved and are now split across two hosts: install and usage at learn.chatgpt.com/docs/plugins (developers.openai.com/codex/plugins 308-redirects there), manifest and packaging at developers.openai.com/plugins/build/plugins. Append `.md` to any page URL for raw markdown
- Codex install: the CLI `/plugins` browser is now described without a prior-setup requirement (09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.4); a third-party marketplace is added with `codex plugin marketplace add <owner>/<repo>`, and a new session before the bundled skills load was not re-checked
- awesome-codex-plugins (hashgraph-online): community Codex marketplace where ru-text is listed. Generator-driven — `scripts/generate_plugins_json.py` fetches each plugin's repo HEAD and derives the entry's icon from `interface.composerIcon` (icon lives in `.agents/plugins/marketplace.json`, NOT root `plugins.json`; icon file must be ≤50KB, SVG preferred/PNG accepted). Push `composerIcon` + the icon file to your HEAD BEFORE the mirror PR, else the icon is silently dropped. Gate as of 09.10.2026 (`~/.claude/runbooks/plugin-marketplaces.md` §3.9, §7 item 18): a centralized HOL Plugin Scanner score of at least 80 of 130 is required; `validate-plugin-pr.py` stays in `scripts/` beside new `validate-contribution*.py`. Icon added v1.7.3 (`assets/icon.png`), mirror PR #162 (issue #11). Full mechanics in project memory `reference_awesome_codex_plugins.md`
- GitHub Copilot: reads `.github/skills/`, `.claude/skills/`, `.agents/skills/` — all three. Also `~/.copilot/skills/` global. PRs to github/awesome-copilot target `main`, NOT `staged` (CONTRIBUTING.md:179-190; external plugins go through an issue form) (09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.7)
- Windsurf is now Devin Desktop (09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.10): preferred path `.devin/skills/`, `.windsurf/skills/` is still read as legacy, `.claude/skills/` only when Claude Code config reading is enabled. No public submission channel found; windsurf.run was not re-checked (UNVERIFIED)
- Cline: reads `.cline/skills/` and `.claude/skills/` natively. Skills are enabled by default when discovered (docs.cline.bot/customization/skills.md:101); `.clinerules/skills/` is also read (09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.10). No official marketplace
- JetBrains Junie: reads `.junie/skills/` and `.agents/skills/` (project in a trusted project, and `~/.agents/skills/`) — does NOT auto-read `.claude/skills/` (detects, offers import) (09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.10). Works in all JetBrains IDEs. No skills marketplace
- Continue.dev: reads `.continue/skills/` and `.claude/skills/`. `hub.continue.dev` does not resolve (`dig +short` empty, 09.10.2026), a new address is UNVERIFIED; no skill submissions (`~/.claude/runbooks/plugin-marketplaces.md` §3.10)
- SKILL.md is cross-platform (Claude Code + GitHub Copilot + Windsurf + Cursor + Cline + JetBrains Junie + Continue.dev + Codex + Gemini CLI) — do NOT duplicate it
- Cursor: marketplace at cursor.com/marketplace/publish, manual review. `.cursor-plugin/plugin.json` ready
- Gemini CLI: auto-discovery via `gemini-cli-extension` GitHub topic (added). Gallery at geminicli.com/extensions/
- OpenClaw: natively reads `.claude-plugin/` as bundles. Native manifest `openclaw.plugin.json`. ClawHub: published at clawhub.ai/talkstream/ru-text (the listing does NOT track releases: `clawhub inspect @talkstream/ru-text` → latest=2.3.0 against 2.10.9 in the manifests on 09.10.2026, so publishing is its own step after every release; listing licence is MIT-0 — `~/.claude/runbooks/plugin-marketplaces.md` §3.8). Publish CLI: `npm i -g clawhub && clawhub login && clawhub skill publish ./skills/ru-text --slug ru-text --version <semver>`. **Always pass `--version` explicitly on a minor or major bump.** The old note here said the flag is REQUIRED and that omitting it fails with `Error: --version must be valid semver`. That is false, and false in the direction that ships the wrong number: on clawhub 0.23.1 (npm latest 0.23.3, installed here 0.20.0 as of 09.10.2026) the guard fires only when the flag IS supplied and malformed (`dist/cli/commands/publish.js:44-45`), and omitting it defaults to the registry's NEXT PATCH. Verified by dry run — without the flag it printed «Would publish ru-text@1.10.2» and exited 0, so publishing 2.0.0 without `--version 2.0.0` would silently ship a patch. `skill publish` reads no version from the skill folder or any repo manifest, so bumping `openclaw.plugin.json` is not a safety net. ⚠ **A rehearsal exists again (09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.8, §7 item 15):** `clawhub@0.23.3 skill publish --help` lists `--dry-run` (a dry run printed «Would publish ru-text@2.3.1»); the INSTALLED build here is 0.20.0, which has neither `--dry-run` nor `--no-input` — that was the 10.08.2026 finding. Before publishing: `npm i -g clawhub@latest`, run `--dry-run`, and still pass `--version` explicitly. Install and update refs are owner-qualified: `openclaw skills install @talkstream/ru-text`, `openclaw skills update @talkstream/ru-text` — bare slugs are only tolerated for already-installed or unambiguous skills
- OpenClaw indexes ru-text as a **skill** (not plugin). Users install via `openclaw skills install @talkstream/ru-text`, NOT `openclaw plugins install`; the bare slug is ambiguous (`AMBIGUOUS_SKILL_SLUG`: `@talkstream/ru-text` vs `@monaxamo/ru-text`, 09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.8)
- Cursor: standalone skill path is `~/.cursor/skills/ru-text`. Full plugin local testing: `~/.cursor/plugins/local/ru-text/` (requires `.cursor-plugin/plugin.json`). `.agents/skills/` IS read by Cursor now, at both project and user level — cursor.com/docs/skills lists `.agents/skills/`, `.cursor/skills/`, `~/.agents/skills/`, `~/.cursor/skills/`, plus compatibility with `.claude/skills/` and `.codex/skills/` (verified 28.07.2026; the older note here said the opposite). PR #8 confirmed the bug; `plugins/local/` confirmed by Cursor engineer in cursor/plugin-template#4
- NeuralDeep (neuraldeep.ru): listed and live — the April 2026 submission passed moderation. Catalogue at neuraldeep.ru/skills accepts «формат claude-skill и любые репозитории со SKILL.md»; install CLI `npx skillsbd add owner/repo/skill`. Web form at neuraldeep.ru/submit (login required; an anonymous visitor is offered Yandex ID and RMR (Bitrix24), a GitHub sign-in was not seen — 09.10.2026, `~/.claude/runbooks/plugin-marketplaces.md` §3.9)
- Notion: no plugin architecture. Two integration paths: (1) Notion AI Custom Skill template page in `notion/`, (2) MCP bridge (Claude Code + Notion MCP server). Notion AI Skills require Business/Enterprise plan. Template must be self-contained (no `${CLAUDE_PLUGIN_ROOT}` paths)
