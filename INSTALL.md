# Установка ru-text вручную

**Языки:** Русский | [English](INSTALL.en.md)

Обычно этот файл не нужен. В [README](README.md) есть одна фраза, которую достаточно дать
ИИ-агенту, и он поставит навык сам. Сюда стоит заглянуть в трёх случаях: агента под рукой
нет, агент ошибся, или площадка ставит навык не файлом, а своим установщиком.

Все пути ниже взяты из документации вендоров и записаны машиночитаемо в
[`tools/install-paths.tsv`](tools/install-paths.tsv) — с адресом источника и датой, когда
его читали. Проверить, что навык лёг куда надо, можно командой
`tools/probe-install.sh check <песочница> <площадка>`.

## Общий каталог

Четыре площадки сошлись на одном месте: **`~/.agents/skills/`** для установки на уровне
пользователя и **`.agents/skills/`** внутри проекта.

| Площадка | Читает `~/.agents/skills/` | Читает `.agents/skills/` |
|---|---|---|
| Codex CLI | да | да |
| Cursor | да | да |
| Windsurf | да | да |
| GitHub Copilot | да | да |
| Google Antigravity | нет | да |

Поэтому одна установка закрывает почти всё:

```bash
git clone https://github.com/talkstream/ru-text.git
mkdir -p ~/.agents/skills
cp -r ru-text/skills/ru-text ~/.agents/skills/ru-text
```

Навык, скопированный в `~/.agents/skills/`, читают три поверхности Codex: сам CLI, приложение ChatGPT в режиме Codex и IDE-расширение. Плагины в IDE-расширении недоступны, а отдельные навыки — да, так что копирование достаёт дальше, чем установка плагином.

Windows (PowerShell):

```powershell
git clone https://github.com/talkstream/ru-text.git
New-Item -ItemType Directory -Force "$env:USERPROFILE\.agents\skills" | Out-Null
Copy-Item -Recurse ru-text\skills\ru-text "$env:USERPROFILE\.agents\skills\ru-text"
```

## Исключения

Эти площадки в общий каталог не смотрят или смотрят не только туда.

| Площадка | Каталог | Область |
|---|---|---|
| Google Antigravity | `~/.gemini/config/skills/` | пользователь; читают Antigravity, Antigravity IDE и Antigravity CLI |
| Windsurf | `~/.codeium/windsurf/skills/` | пользователь, родной каталог Cascade |
| Windsurf | `.windsurf/skills/` | проект |
| Cursor | `~/.cursor/skills/` | пользователь |
| Cursor | `.cursor/skills/` | проект |
| GitHub Copilot | `~/.copilot/skills/` | пользователь |
| GitHub Copilot | `.github/skills/` | проект |
| JetBrains Junie | `.junie/skills/` | проект, единственный вариант |
| Continue.dev | `.continue/skills/` | проект |
| Cline | `.cline/skills/` | проект |

Junie в общий каталог не смотрит вовсе — ему нужен именно `.junie/skills/`.

## Площадки со своим установщиком

Здесь копировать файлы бессмысленно: у платформы есть собственный механизм.

### Claude Code

```
/plugin marketplace add anthropics/claude-plugins-community
/plugin install ru-text@claude-community
```

Это команды **терминального CLI**. В приложении Claude Desktop плагины ставятся через
интерфейс: кнопка **+** рядом с полем ввода → **Plugins** → **Add plugin**; там же
добавляется маркетплейс. Одна установка обслуживает CLI, приложение (локальные и
SSH-сессии), VS Code и JetBrains.

### Codex и ChatGPT

Плагины у них общие: «Plugins are available with ChatGPT Work on the web and with ChatGPT
Work or Codex in the ChatGPT desktop app. Codex CLI also has a plugin browser»
([learn.chatgpt.com/docs/plugins](https://learn.chatgpt.com/docs/plugins)). В вебе
и в десктопном приложении ChatGPT плагины ставятся из интерфейса: переключатель **Work** →
**Plugins**. Ниже — про Codex CLI.

Сначала подключите маркетплейс, потом ставьте. Обе команды неинтерактивные:

```bash
codex plugin marketplace add hashgraph-online/awesome-codex-plugins
codex plugin add ru-text@awesome-codex-plugins
```

Можно и через браузер плагинов: `/plugins` в сессии, найти ru-text, установить. В обоих
случаях **начните новую сессию**: навыки плагина подхватываются при старте.

Codex из коробки уже подключает маркетплейс `claude-plugins-official`, что видно по
`codex plugin marketplace list`. ru-text там пока нет: он в community-каталоге Anthropic,
а не в официальном.

### Gemini CLI

```bash
gemini extensions install https://github.com/talkstream/ru-text
```

### OpenClaw

```bash
openclaw skills install @talkstream/ru-text
```

Ссылка с владельцем, а не голый слаг: голый принимается только для уже установленных или
однозначных навыков. Плагин опубликован на [ClawHub](https://clawhub.ai/talkstream/ru-text).

### Notion

Два пути, подробности — в [notion/README.md](notion/README.md).

**Навык Notion AI** требует тарифа Business или Enterprise. Скопируйте
[шаблон-страницу](notion/ru-text-notion-skill.md) в Notion, откройте меню страницы (три
точки) → **Use with AI** → **Use as AI skill**. Дальше выделяете текст и выбираете «ru-text»
из меню, либо пишете `@ru-text` в чате агента.

**Notion через MCP** работает с Claude Code и не зависит от тарифа: поставьте ru-text в
Claude Code, подключите [Notion MCP-сервер](https://developers.notion.com/guides/mcp/get-started-with-mcp)
и просите Claude Code читать и править страницы.

### NeuralDeep

Русскоязычный каталог навыков:

```bash
npx skillsbd add talkstream/ru-text/ru-text
```

Команда кладёт навык в `<текущий каталог>/.skills/ru-text` — оттуда его **не читает ни один
агент**, так что после установки перенесите каталог туда, где ваша площадка его ищет
(см. таблицы выше). Каталог версий не закрепляет и всегда ставит текущее состояние ветки
`main`.

## Что агент не узнает сам

Четыре факта, которые нельзя открыть перебором, потому что они отрицательные.

**В маркетплейсе Cursor ru-text нет.** Команда `/add-plugin` существует и работает, но
поиск ничего не найдёт: каталог мы перебрали целиком, нашего плагина в нём нет. Ставьте копированием.

**Облачные сессии Claude Code плагин не наследуют.** Установка на уровне пользователя туда
не переносится. Объявите плагин в поле `enabledPlugins` файла `.claude/settings.json` в
репозитории — тогда он ставится при старте сессии. В WSL-сессиях плагины недоступны вовсе.

**Пин в community-маркетплейсе Anthropic отстаёт от релиза, и надолго.** Маркетплейс
закрепляет плагин на конкретном коммите, а не следит за релизами. Закрепление двигает ночной
сводный прогон, обновляющий до 30 плагинов за раз при более чем 2 тыс. записей в каталоге, и
обход алфавитный. Что стоит у вас, покажет `claude plugins list`. Нужна свежая версия
сразу — ставьте копированием или из исходников.

**`npx skills add talkstream/ru-text` ставит три навыка**, а не один: `ru-text`, `ru-check` и
`ru-score`. В Claude Code последние два — слэш-команды, на остальных площадках отдельные
навыки. Без флага `-y` в обычном терминале команда открывает интерактивное меню, поэтому в
скрипте не поставит ничего. Установка проектная; для пользовательской добавьте `-g`. Каталоги
`.windsurf/skills`, `.junie/skills` и `.continue/skills` команда наполняет, только если они
уже существуют, — сама она их не создаёт.

## Обновление

У разовой установки нет механизма обновления: агент поставил навык и забыл о нём. Раз в
несколько месяцев стоит вернуться.

Копирование — повторите ту же команду, она перезапишет каталог. Помните, что перезапишет и
ваши правки, если вы их вносили.

```bash
npx skills add talkstream/ru-text -y        # skills CLI, проектная область; ставит три навыка
npx skills add talkstream/ru-text -y -g     # он же, пользовательская
codex plugin marketplace upgrade
gemini extensions update ru-text
openclaw skills update @talkstream/ru-text
claude plugins marketplace update claude-community
claude plugins update ru-text@claude-community
```

Обновление идёт в ту же область, что и установка: если ставили с `-g`, обновляйте тоже с
`-g`, иначе проектный запуск отчитается об успехе, а пользовательская копия останется старой.

Свежую версию и список изменений смотрите в [CHANGELOG](CHANGELOG.md).
