# Установка ru-text вручную

**Языки:** Русский | [English](INSTALL.en.md)

Обычно этот файл не нужен. В [README](README.md) есть одна фраза, которую достаточно дать
ИИ-агенту, и он поставит навык сам. Сюда стоит заглянуть в трёх случаях: агента под рукой
нет, агент ошибся, или площадка ставит навык не файлом, а своим установщиком.

Все пути ниже взяты из документации вендоров и записаны машиночитаемо в
[`tools/install-paths.tsv`](tools/install-paths.tsv) — с адресом источника и датой, когда
его читали. Проверить, что навык лёг куда надо, можно командой
`tools/probe-install.sh check <песочница> <площадка>`.

## Общий каталог

Четыре площадки сошлись на одном месте: **`~/.agents/skills/`** для установки на уровне
пользователя и **`.agents/skills/`** внутри проекта.

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

## Одной командой

Два публичных установщика ставят навык прямо из этого репозитория, без клонирования. Оба
читают ветку `main`, поэтому версия у них всегда свежая: закреплённых копий они не
держат и обновлять там нечего.

**skills** — каталог Vercel Labs. Ставит все три навыка сразу:

```bash
npx skills add talkstream/ru-text
```

Без флагов команда спросит, какие навыки и в каких агентов ставить; `-y --all` отвечает
за вас, `-g` кладёт навыки на уровень пользователя вместо проекта. По умолчанию они
ложатся в `.agents/skills/` внутри проекта, со ссылками из `.claude/skills/`.

**skillsbd** — каталог NeuralDeep. Ставит один названный навык:

```bash
npx skillsbd add talkstream/ru-text/ru-text
```

Кладёт его в `.skills/ru-text/`. Справочники корпуса переносятся целиком в обоих случаях.

Проверено 12.08.2026 прогоном в песочнице: обе команды вернули код 0, и `skills` отчитался
«Found 3 skills → Installed 3 skills».

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

Это команды **терминального CLI**. В приложении Claude Desktop плагины ставятся через
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

### claude.ai, приложение Claude и Claude API

Здесь навык загружают архивом, и архив уже собран: `ru-text-skill.zip` из [последнего
релиза](https://github.com/talkstream/ru-text/releases/latest). Внутри одна папка `ru-text/`
на верхнем уровне — именно та форма, которой требуют обе поверхности, и 284 КБ в распакованном виде против их потолка в 30 МБ, который меряется тоже
распакованным.

**claude.ai и приложение.** Customize → Skills → «+ Create skill» → «Upload a skill»
([claude.ai/customize/skills](https://claude.ai/customize/skills); [справка](https://support.claude.com/en/articles/12512180-use-skills-in-claude)). Нужен платный тариф
(Pro, Max, Team или Enterprise) и включённое исполнение кода. Навык виден только вам:
на команду он не раздаётся и администратором не управляется.

**Claude API.** Тот же архив уходит в `POST /v1/skills` с бета-заголовком
`skills-2025-10-02`, дальше навык подключается к запросу через `container.skills` вместе
с инструментом исполнения кода — для него нужен второй заголовок, `code-execution-2025-08-25`
([документация](https://platform.claude.com/docs/en/build-with-claude/skills-guide)). Хранилище приватно для рабочего пространства: публичного
каталога у него нет.

⚠ Форму архива мы сверили с документацией, но живой загрузки ни в claude.ai, ни в API
не делали: требование «одна папка на верхнем уровне» взято из их текста, а не из нашего
опыта.

⚠ Загружается только основной навык `ru-text`. `ru-check` и `ru-score` туда не проходят
и не нужны: их слэш-вызов, форк контекста и запрет инструментов — механика Claude Code,
которой в этих поверхностях нет. Фронтматтер там принимает ровно шесть полей, и у двух
команд есть поля вне этого списка.

### Managed Agents

Агент, которому смонтирован репозиторий, читает навыки только из корневого
`.claude/skills/` — поэтому в репозитории лежит ссылка `.claude/skills/ru-text`
на `skills/ru-text`. Корпус остаётся один, копии нет.

Второй путь — тот же архив через Skills API, а затем ссылка на навык в конфигурации
агента ([документация](https://platform.claude.com/docs/en/managed-agents/skills)).

⚠ Живым прогоном этот канал мы не проверяли: ссылка ведёт куда надо и разрешается
в клоне, но как её разбирает монтирование репозитория у Anthropic, мы не измеряли.

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

**В маркетплейсе Cursor ru-text нет.** Команда `/add-plugin` существует и работает, но
поиск ничего не найдёт: каталог мы перебрали целиком, нашего плагина в нём нет. Ставьте копированием.

**Облачные сессии Claude Code плагин не наследуют.** Установка на уровне пользователя туда
не переносится. Объявите плагин в поле `enabledPlugins` файла `.claude/settings.json` в
репозитории — тогда он ставится при старте сессии. В WSL-сессиях плагины недоступны вовсе.

**Пин в community-маркетплейсе Anthropic отстаёт от релиза, и надолго.** Маркетплейс
закрепляет плагин на конкретном коммите, а не следит за релизами. Закрепление двигает ночной
сводный прогон, обновляющий до 30 плагинов за раз при более чем 2 тыс. записей в каталоге, и
обход алфавитный. Что стоит у вас, покажет `claude plugins list`. Нужна свежая версия
сразу — ставьте копированием или из исходников.

**`npx skills add talkstream/ru-text` ставит три навыка**, а не один: `ru-text`, `ru-check` и
`ru-score`. В Claude Code последние два — слэш-команды, на остальных площадках отдельные
навыки. Без флага `-y` в обычном терминале команда открывает интерактивное меню, поэтому в
скрипте не поставит ничего. Установка проектная; для пользовательской добавьте `-g`. Каталоги
`.windsurf/skills`, `.junie/skills` и `.continue/skills` команда наполняет, только если они
уже существуют. Сама она их не создаёт.

## Обновление

У разовой установки нет механизма обновления: агент поставил навык и забыл о нём. Раз в
несколько месяцев стоит вернуться.

Три новых канала обновляются иначе, и это стоит знать заранее. В claude.ai обновление —
повторная загрузка архива поверх старого. В Claude API — новая версия через тот же
Skills API: версия там не дельта, а полный снимок. У Managed Agents, которым смонтирован
репозиторий, обновление происходит само, но только при старте сессии: коммиты, пришедшие
в середине, эта сессия не увидит.


Копирование — **повтор той же команды каталог НЕ перезаписывает.** `cp -r` кладёт новую версию
внутрь старой, и наверху остаётся прежняя; агент читает верхний файл, то есть продолжает работать
на старом корпусе. Проверено командой: после повтора появляется `ru-text/ru-text/SKILL.md`.

Обновляйте заменой содержимого — эта команда не оставляет вложенных копий и не зависит от того,
что лежало в каталоге раньше:

```bash
rsync -a --delete ru-text/skills/ru-text/ ~/.agents/skills/ru-text/
```

Косые черты в конце обоих путей обязательны. Путь назначения подставьте свой — тот, куда ставили.
Замена снесёт и ваши правки, если вы их вносили. Нет `rsync` — удалите каталог назначения вручную
и скопируйте заново; главное, чтобы старого каталога не осталось на месте.

После обновления убедитесь, что навык стоит **ровно один раз**: копия в соседнем каталоге
остаётся жить и подсовывает агенту старый корпус.

```bash
find ~ -name SKILL.md -path '*ru-text*' -not -path '*/node_modules/*' 2>/dev/null
```

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
