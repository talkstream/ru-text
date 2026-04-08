# ru-text for Notion

Two ways to use ru-text with Notion: as a Notion AI Custom Skill (standalone) or via MCP bridge (with Claude Code).

## Option A: Notion AI Custom Skill

Turn any Notion page into a Russian text quality assistant. Requires Notion Business or Enterprise plan.

### Setup

1. Open [`ru-text-notion-skill.md`](ru-text-notion-skill.md) on GitHub
2. Copy the entire content
3. Create a new Notion page in your workspace
4. Paste the content (Notion converts markdown automatically)
5. Open page settings (three-dot menu) and select **Use as AI skill**
6. Name the skill «ru-text»

### Usage

1. Select text in any Notion page
2. Click **Ask AI** or press `Ctrl+J` / `Cmd+J`
3. Choose the «ru-text» skill from the menu
4. Notion AI applies typography rules, flags stop-words, and suggests improvements

### What's included

The skill template contains ~1,450 words of condensed rules:
- 12 typography rules (always applied)
- 92 stop-words across 8 categories with replacements
- 30 anti-patterns (bureaucratic language, passive voice, bloat, pleonasms)
- Quality checklist

For the full set of ~1,040 rules across 7 domains, use the [complete plugin](https://github.com/talkstream/ru-text) with Claude Code, Codex CLI, Gemini CLI, Cursor, or OpenClaw.

## Option B: Notion via MCP (Claude Code)

Use the full ru-text plugin with Notion pages through Claude Code and the official Notion MCP server. This gives you access to all ~1,040 rules with progressive loading.

### Setup

1. Install ru-text in Claude Code: `/plugin install ru-text`
2. Connect the Notion MCP server ([setup guide](https://developers.notion.com/guides/mcp/get-started-with-mcp))
3. Grant Claude Code access to the relevant Notion pages

### Usage

Ask Claude Code to work with your Notion content:

```
Read my Notion page "Landing copy" and apply ru-text rules.
Fix typography, remove stop-words, then update the page.
```

```
Score the text quality of my Notion page "About us" using /ru-text:ru-score.
```

### Requirements

- Claude Code with ru-text plugin installed
- Notion MCP server connected and authorized
- Any Notion plan (MCP works with all plans)

---

# ru-text для Notion

Два способа использовать ru-text с Notion: как навык Notion AI (автономный) или через MCP-мост (с Claude Code).

## Способ А: навык Notion AI

Любая страница Notion превращается в ассистента по качеству русского текста. Нужен Notion Business или Enterprise.

### Настройка

1. Откройте [`ru-text-notion-skill.md`](ru-text-notion-skill.md) на GitHub
2. Скопируйте содержимое полностью
3. Создайте новую страницу Notion в рабочем пространстве
4. Вставьте содержимое (Notion автоматически конвертирует Markdown)
5. Откройте настройки страницы (меню с тремя точками) и выберите **Use as AI skill**
6. Назовите навык «ru-text»

### Использование

1. Выделите текст на любой странице Notion
2. Нажмите **Ask AI** или `Ctrl+J` / `Cmd+J`
3. Выберите навык «ru-text» в меню
4. Notion AI применит правила типографики, отметит стоп-слова и предложит улучшения

### Что входит

Шаблон навыка содержит ~1450 слов сжатых правил:
- 12 правил типографики (применяются всегда)
- 92 стоп-слова в 8 категориях с заменами
- 30 антипаттернов (канцелярит, пассивный залог, многословие, плеоназмы)
- Чеклист качества

Полный набор из ~1 040 правил в 7 доменах доступен через [полную версию плагина](https://github.com/talkstream/ru-text) для Claude Code, Codex CLI, Gemini CLI, Cursor или OpenClaw.

## Способ Б: Notion через MCP (Claude Code)

Полный плагин ru-text для работы со страницами Notion через Claude Code и официальный Notion MCP-сервер. Доступны все ~1 040 правил с прогрессивной загрузкой.

### Настройка

1. Установите ru-text в Claude Code: `/plugin install ru-text`
2. Подключите Notion MCP-сервер ([инструкция](https://developers.notion.com/guides/mcp/get-started-with-mcp))
3. Предоставьте Claude Code доступ к нужным страницам Notion

### Использование

Попросите Claude Code работать с содержимым Notion:

```
Прочитай мою страницу Notion «Текст для лендинга» и примени правила ru-text.
Исправь типографику, убери стоп-слова, затем обнови страницу.
```

```
Оцени качество текста на моей странице Notion «О компании» через /ru-text:ru-score.
```

### Требования

- Claude Code с установленным плагином ru-text
- Notion MCP-сервер подключён и авторизован
- Любой тарифный план Notion (MCP работает со всеми планами)
