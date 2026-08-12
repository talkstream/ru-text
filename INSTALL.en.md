# Installing ru-text by hand

**Languages:** [Русский](INSTALL.md) | English

You usually do not need this file. The [README](README.en.md) carries one sentence you can
hand to an AI agent, and it installs the skill itself. Come here in three cases: no agent at
hand, the agent got it wrong, or the platform installs through its own tool rather than a
file copy.

Every path below comes from the vendor's documentation and is recorded machine-readably in
[`tools/install-paths.tsv`](tools/install-paths.tsv), with the source URL and the date it was
last read. To check that a skill actually landed where it should:
`tools/probe-install.sh check <sandbox> <platform>`.

## The shared directory

Four platforms converged on one location: **`~/.agents/skills/`** for a user-level install and
**`.agents/skills/`** inside a project.

| Platform | Reads `~/.agents/skills/` | Reads `.agents/skills/` |
|---|---|---|
| Codex CLI | yes | yes |
| Cursor | yes | yes |
| Windsurf | yes | yes |
| GitHub Copilot | yes | yes |
| Google Antigravity | no | yes |

So one install covers most of the field:

```bash
git clone https://github.com/talkstream/ru-text.git
mkdir -p ~/.agents/skills
cp -r ru-text/skills/ru-text ~/.agents/skills/ru-text
```

A skill copied into `~/.agents/skills/` is read by three Codex surfaces: the CLI itself, the ChatGPT desktop app in Codex mode, and the IDE extension. Plugins are not available in the IDE extension but standalone skills are, so copying reaches further than installing as a plugin.

Windows (PowerShell):

```powershell
git clone https://github.com/talkstream/ru-text.git
New-Item -ItemType Directory -Force "$env:USERPROFILE\.agents\skills" | Out-Null
Copy-Item -Recurse ru-text\skills\ru-text "$env:USERPROFILE\.agents\skills\ru-text"
```

## One command

Two public installers take the skill straight from this repository, with no cloning. Both read
the `main` branch, so what they install is always current: they pin nothing, and there is
nothing to update on their side.

**skills** — the Vercel Labs catalogue. Installs all three skills at once:

```bash
npx skills add talkstream/ru-text
```

Without flags it asks which skills to install and into which agents; `-y --all` answers for
you, and `-g` installs at user level instead of into the project. By default they land in
`.agents/skills/` inside the project, with links from `.claude/skills/`.

**skillsbd** — the NeuralDeep catalogue. Installs one named skill:

```bash
npx skillsbd add talkstream/ru-text/ru-text
```

It goes to `.skills/ru-text/`. The corpus references come across in full either way.

Verified 12.08.2026 by a sandboxed run: both commands exited 0, and `skills` reported
«Found 3 skills → Installed 3 skills».

## Exceptions

These platforms either do not read the shared directory, or read more than it.

| Platform | Directory | Scope |
|---|---|---|
| Google Antigravity | `~/.gemini/config/skills/` | user; read by Antigravity, Antigravity IDE and Antigravity CLI |
| Windsurf | `~/.codeium/windsurf/skills/` | user, Cascade's native directory |
| Windsurf | `.windsurf/skills/` | project |
| Cursor | `~/.cursor/skills/` | user |
| Cursor | `.cursor/skills/` | project |
| GitHub Copilot | `~/.copilot/skills/` | user |
| GitHub Copilot | `.github/skills/` | project |
| JetBrains Junie | `.junie/skills/` | project, the only option |
| Continue.dev | `.continue/skills/` | project |
| Cline | `.cline/skills/` | project |

Junie does not read the shared directory at all — it needs `.junie/skills/` specifically.

## Platforms with their own installer

Copying files here is pointless: the platform has its own mechanism.

### Claude Code

```
/plugin marketplace add anthropics/claude-plugins-community
/plugin install ru-text@claude-community
```

Those are **terminal CLI** commands. In the Claude Desktop app, plugins install through the
interface: the **+** button next to the prompt box → **Plugins** → **Add plugin**, where the
marketplace can be added as well. One install serves the CLI, the app (local and SSH
sessions), VS Code and JetBrains.

### Codex and ChatGPT

They share plugins: "Plugins are available with ChatGPT Work on the web and with ChatGPT Work
or Codex in the ChatGPT desktop app. Codex CLI also has a plugin browser"
([learn.chatgpt.com/docs/plugins](https://learn.chatgpt.com/docs/plugins)). On ChatGPT web and
in the ChatGPT desktop app, plugins install from the interface: the **Work** switcher →
**Plugins**. What follows is about Codex CLI.

Add the marketplace first, then install. Both commands are non-interactive:

```bash
codex plugin marketplace add hashgraph-online/awesome-codex-plugins
codex plugin add ru-text@awesome-codex-plugins
```

The plugin browser works too: `/plugins` in a session, find ru-text, install. Either way,
**start a new session**: a plugin's bundled skills are loaded at session start.

Codex ships with the `claude-plugins-official` marketplace already configured, which
`codex plugin marketplace list` shows. ru-text is not in it yet: it is listed in Anthropic's
community catalogue, not the official one.

### Gemini CLI

```bash
gemini extensions install https://github.com/talkstream/ru-text
```

### OpenClaw

```bash
openclaw skills install @talkstream/ru-text
```

Owner-qualified, not a bare slug: bare slugs are accepted only for already-installed or
unambiguous skills. Published on [ClawHub](https://clawhub.ai/talkstream/ru-text).

### Notion

Two paths; details in [notion/README.md](notion/README.md).

**The Notion AI skill** requires a Business or Enterprise plan. Copy
[the template page](notion/ru-text-notion-skill.md) into Notion, open the page menu (three
dots) → **Use with AI** → **Use as AI skill**. Then select text and pick «ru-text» from the
menu, or type `@ru-text` in an agent chat.

**Notion via MCP** works with Claude Code and does not depend on the plan: install ru-text in
Claude Code, connect the [Notion MCP server](https://developers.notion.com/guides/mcp/get-started-with-mcp),
and ask Claude Code to read and edit pages.

### claude.ai, the Claude app and the Claude API

These take the skill as an archive, and the archive is already built: `ru-text-skill.zip`
from the [latest release](https://github.com/talkstream/ru-text/releases/latest). It holds a
single top-level folder, `ru-text/` — the shape both surfaces require — and 284 KB against
their 30 MB ceiling.

**claude.ai and the app.** Settings → Features → upload the archive. It needs a paid plan
(Pro, Max, Team or Enterprise) with code execution enabled. The skill is yours alone: it is
not shared with a team and admins cannot manage it centrally.

**The Claude API.** The same archive goes to `POST /v1/skills` with the `skills-2025-10-02`
beta header; the skill then joins a request through `container.skills` alongside the code
execution tool. The store is private to your workspace — there is no public catalogue.

⚠ Only the main `ru-text` skill goes there. `ru-check` and `ru-score` do not pass and are
not needed: their slash invocation, forked context and tool restrictions are Claude Code
mechanics that these surfaces do not have. Frontmatter there accepts exactly six fields, and
those two commands carry fields outside that list.

### Managed Agents

An agent with a mounted repository reads skills only from a root `.claude/skills/`, which is
why this repository ships a link at `.claude/skills/ru-text` pointing at `skills/ru-text`.
One corpus, no copy.

The other route is the same archive through the Skills API, then a reference to the skill in
the agent's configuration, up to twenty skills per agent.

⚠ We have not run this channel live: the link resolves in a clone, but how Anthropic's
repository mount treats it is something we did not measure.

### NeuralDeep

A Russian-language skills catalogue:

```bash
npx skillsbd add talkstream/ru-text/ru-text
```

The command writes the skill to `<cwd>/.skills/ru-text`, which **no agent reads**, so move the
directory afterwards to wherever your platform looks (see the tables above). The catalogue
pins no version and always installs the current state of `main`.

## What an agent cannot work out for itself

Four facts trial and error cannot discover, because they are negative.

**ru-text is not in the Cursor marketplace.** `/add-plugin` exists and works, but the search
finds nothing: we walked the whole catalogue and ru-text is not in it. Install by copying.

**Claude Code cloud sessions do not inherit the plugin.** A user-scope install does not carry
over. Declare the plugin under `enabledPlugins` in the repository's `.claude/settings.json`,
and it is installed at session start. WSL sessions have no plugins at all.

**The Anthropic community-marketplace pin trails the release, by months.** The marketplace
pins the plugin to a specific commit rather than tracking releases. The pin is moved by a
nightly sweep that updates up to 30 plugins per run against a catalogue of more than 2,000
entries, walking it roughly alphabetically. `claude plugins list` shows what you have. If you
need the current version now, install by copying or from source.

**`npx skills add talkstream/ru-text` installs three skills**, not one: `ru-text`, `ru-check`
and `ru-score`. In Claude Code the latter two are slash commands; elsewhere they are
standalone skills. Without `-y` the command opens an interactive picker in an ordinary
terminal, so in a script it installs nothing. The install is project-scoped; add `-g` for a
user-level one. It populates `.windsurf/skills`, `.junie/skills` and `.continue/skills` only
when those directories already exist — it never creates them.

## Updating

A one-shot install has no update mechanism: the agent installed the skill and forgot about
it. Come back every few months.

A copy install — **re-running the same command does NOT overwrite the directory.** `cp -r`
places the new version inside the old one, the previous release stays on top, and the agent
reads the file on top, so it goes on working from the older corpus. Verified by command:
after a repeat, `ru-text/ru-text/SKILL.md` appears.

Update by replacing the contents instead. This command leaves no nested copies and does not
depend on what was in the directory before:

```bash
rsync -a --delete ru-text/skills/ru-text/ ~/.agents/skills/ru-text/
```

The trailing slashes on both paths are required. Substitute your own destination — the one you
installed to. The replacement also removes any edits you made. No `rsync`? Delete the
destination directory by hand and copy again; what matters is that the old directory is gone.

After updating, make sure the skill is installed **exactly once**: a copy in a neighbouring
directory stays alive and feeds the agent the older corpus.

```bash
find ~ -name SKILL.md -path '*ru-text*' -not -path '*/node_modules/*' 2>/dev/null
```

```bash
npx skills add talkstream/ru-text -y        # skills CLI, project scope; installs three skills
npx skills add talkstream/ru-text -y -g     # the same, user scope
codex plugin marketplace upgrade
gemini extensions update ru-text
openclaw skills update @talkstream/ru-text
claude plugins marketplace update claude-community
claude plugins update ru-text@claude-community
```

The update goes to the same scope as the install: if you installed with `-g`, update with `-g`
too, or a project-scoped run reports success while the user-level copy stays old.

The current version and the list of changes are in the [CHANGELOG](CHANGELOG.md).
