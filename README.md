# ru-text

[![Version](https://img.shields.io/github/v/release/talkstream/ru-text?label=version&color=2ea44f)](https://github.com/talkstream/ru-text/releases/latest) [![License](https://img.shields.io/github/license/talkstream/ru-text?label=license&color=blue)](LICENSE) [![GitHub stars](https://img.shields.io/github/stars/talkstream/ru-text?style=flat&label=stars)](https://github.com/talkstream/ru-text/stargazers)

[English](README.en.md) · [Установка](INSTALL.md) · [Что изменилось](CHANGELOG.md) · [Источники](skills/ru-text/references/sources.md)

ИИ-агент уже записывает ваши мысли по-русски, и это видно: прямые кавычки вместо ёлочек, дефис вместо тире, «в целях повышения эффективности», «Отличный вопрос!». Мысль ваша, а звучит как машина.

ru-text — навык вычитки русского текста для ИИ-агентов. Он работает внутри агента и чистит это по ходу дела: типографику, канцелярит и 17 признаков машинного текста (нейрослоп). На каждую правку даёт цитату и правило, по которому она сделана.

Ваши слова, стиль и тон он не трогает: это не ошибки. И ваш файл он не перепишет, пока вы сами не попросите.

## Установка

Дайте эту фразу своему ИИ-агенту:

> Установи навык https://github.com/talkstream/ru-text глобально и вызывай его, когда работа идёт над качеством русского текста: вычитка, типографика, очистка от нейрослопа, редактура, UX-тексты, деловая переписка — или по прямому упоминанию ru-text.

Обычно этого достаточно: где его площадка держит навыки, агент знает лучше, чем инструкция, написанная год назад. Работает в Claude Code, Codex и ChatGPT, Cursor, GitHub Copilot, Gemini CLI, Google Antigravity, Windsurf, Continue.dev, Cline, JetBrains Junie, OpenClaw и Notion.

Если привычнее команда — навык ставят два установщика: `npx skills add talkstream/ru-text` кладёт в проект все три навыка, `npx skillsbd add talkstream/ru-text/ru-text` — один, в свой каталог. Подробности и флаги — в [INSTALL.md](INSTALL.md#одной-командой).

В ChatGPT эта фраза не нужна — там есть карточка в каталоге плагинов:

[![Установить в ChatGPT и Codex](https://img.shields.io/badge/%D0%A3%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%82%D1%8C_%D0%B2_ChatGPT_%D0%B8_Codex-000000?style=for-the-badge)](https://chatgpt.com/plugins/plugins_6a6b66a0142c81918659256b4a12adba)

Откройте её и нажмите «плюс». Навык станет доступен в ChatGPT — в браузере, в десктопном приложении и на телефоне. В Codex он работает внутри того же десктопного приложения; в Codex CLI его ставит фраза выше.

Агент подхватывает навыки при старте сессии, поэтому начните новую. Проверьте на живом тексте: дайте агенту абзац и попросите «вычитай». В ответе придут исправленный вариант и список правок. Списка нет — навык не поднялся, смотрите [INSTALL.md](INSTALL.md).

## Как это выглядит в работе

Каждый день — три коротких действия.

**Пишете сами — просите вычитать.** «Вычитай это письмо». Вернётся исправленный текст и список: что заменено и по какому правилу. Согласиться можно не со всем, правило названо и спорить есть с чем.

**Пишет агент — он чистит на ходу.** В тексте, который агент пишет сам, типографику навык ставит молча: кавычки, тире, неразрывные пробелы. Это норма языка, и сообщать о ней нечего.

**Перед публикацией — просите балл.** «Оцени этот текст по ru-text»: 0–10 по пяти шкалам, к каждому замечанию — цитата и правило. Балл можно проверить построчно и оспорить.

Рубрика печатает и то, чего она не мерила: фактическую точность, попадание в аудиторию, авторский голос, оригинальность, эффективность, соответствие брифу. Голос в балл не входит: 8,0 у осторожного текста и 8,0 у резкого значат одно и то же.

Два верхних ярлыка, «Эталонный» и «Хороший», не достаются документу, который остался стенограммой чата или писался для поисковика: такой текст бывает чист в каждой фразе и бесполезен целиком.

В Claude Code у этих действий есть команды: `/ru-text:ru-check` — разбор с правилом на каждую находку, `/ru-text:ru-score` — балл. На остальных площадках достаточно слов.

## Что он ловит

Ловить модель по словарю бесполезно: словарь у неё наш. Выдаёт её манера. Она хвалит ваш вопрос и спорит с тем, чего никто не говорил.

Вот пять предложений, в которых нет ни одного факта:

> Отличный вопрос! Сейчас всё объясню — коротко, без воды и по делу. Скажу честно: тут есть нюанс. Давайте разберёмся, как это работает. Дело не в скорости, а в предсказуемости.

Тот же ответ, когда автору есть что сказать:

> Под нагрузкой система замедляется предсказуемо: очередь растёт линейно до 800 запросов в секунду, дальше отказы. Вот замеры.

Приёмы по порядку:

- «Отличный вопрос!» — сервисная реплика ассистента;
- «коротко, без воды и по делу» — похвала себе за краткость;
- «скажу честно» — объявленная искренность;
- «давайте разберёмся» — пустой зачин;
- «дело не в скорости, а в предсказуемости» — ложная антитеза: отрицается то, чего никто не утверждал.

Первый вариант я вижу каждый день — в чужих README и в своих черновиках. Он читается гладко и ничего не сообщает.

Прежде чем сделать замечание, навык смотрит оговорки. В цитате, в разборе чужого текста и в юридической формуле приём законен. А триада, любимый у модели ритм из трёх, законна, когда элементов правда три.

Всего таких признаков 17. Два предъявляются документу целиком, потому что правкой на месте не лечатся: текст, оставшийся стенограммой диалога с нейросетью, и текст, который писали под поисковый запрос.

Канцелярит навык разбирает так же: «в целях повышения эффективности взаимодействия» становится «чтобы отделы работали быстрее», «осуществляется контроль» — «следит Петрова». Отглагольные существительные снова становятся глаголами, у безличного контроля появляется фамилия. Фактов навык не сочиняет: фамилию он спросит у вас.

Кроме прозы он знает интерфейсы и переписку: кнопка называет действие — «Отмена» вместо «Нет»; ошибка говорит, что случилось и что делать дальше; тема письма начинается с дела; «довожу до сведения» разворачивается в «сообщаю».

В лендинге и документации вместо «команды профессионалов» встаёт то, что можно проверить, вывод поднимается наверх, а ссылка говорит, куда ведёт.

## Что решаете вы

**Правила уступают вашей просьбе.** Скажете «пиши разговорно» — будет разговорно. Академический, юридический, SEO, литературный — то же. Это умолчания, ваша прямая просьба их отменяет.

**Мандат выдаёте вы.** Фраза установки просит вызывать навык, когда работа идёт над качеством русского текста или когда вы прямо упоминаете ru-text. Нужен мандат поуже: «вызывай ru-text, только когда я прошу вычитку». Нужен пошире: «вызывай ru-text на любом русском тексте». Агент исполняет вашу формулировку.

**Ничего не переписывается молча.** При проверке навык возвращает исправленный вариант и список изменений; правит файл, только если вы прямо об этом попросили.

**Чужой текст остаётся чужим.** Цитаты, код, чужие фрагменты внутри вашего документа воспроизводятся как есть: замечание — возможно, правка — никогда.

**Выключается одной командой.** В Claude Code — `/plugin`; на остальных площадках удалите каталог навыка.

## Сколько это стоит контекста

ru-text не гоняет корпус целиком на каждый абзац: это было бы расточительством за ваш счёт.

Постоянно в контексте висит один файл (4 килобайта): таблица типографики и верхушка стоп-слов. Справочники лежат рядом и подгружаются, когда до них доходит дело. Скажете «вычитай» — навык читает весь корпус.

Когда агент проверяет себя сам, идёт быстрый проход: типографика и стоп-слова — то, что решается по одной строке. Наберётся пять замечаний или мелькнёт след машинного текста — проход сам разворачивается в полную вычитку. Признаки машинного текста он не судит: у каждого есть оговорка, где приём законен, а оговорки живут только в полном справочнике. И полной вычиткой быстрый проход себя никогда не называет.

## Корпус

Более 2 000 лингвистических атомов: правил, пар «плохо → хорошо», словарных статей и исключений. Это пол, а не точное число, и он считается командой:

```bash
tools/extract-atoms.sh skills/ru-text | wc -l
```

Раньше я вписывал это число руками, оно разъехалось по девяти файлам, и в записи о правке я ошибся даже в числе файлов. Теперь его печатает скрипт.

Корпус лежит в 10 справочниках, они подгружаются по запросу. Откройте любой и посчитайте правила сами.

- [`typography.md`](skills/ru-text/references/typography.md) — кавычки, тире, неразрывные пробелы, разрядка чисел, сокращения
- [`info-style.md`](skills/ru-text/references/info-style.md) — каталог из 92 стоп-слов, структура текста, факты вместо оценок
- [`editorial-punctuation.md`](skills/ru-text/references/editorial-punctuation.md) — сложные предложения, запятые-ловушки, вводные слова
- [`editorial-grammar.md`](skills/ru-text/references/editorial-grammar.md) — согласование, плеоназмы, управление, деепричастия, омофоны
- [`ux-writing.md`](skills/ru-text/references/ux-writing.md) — кнопки, ошибки, пустые состояния, формы, уведомления, диалоги подтверждения
- [`business-writing.md`](skills/ru-text/references/business-writing.md) — письма, мессенджеры, тон, заметки к встречам
- [`anti-patterns.md`](skills/ru-text/references/anti-patterns.md) — пары «плохо → хорошо» по степени серьёзности
- [`addenda.md`](skills/ru-text/references/addenda.md) — 17 признаков машинного текста с оговорками
- [`scoring.md`](skills/ru-text/references/scoring.md) — рубрика оценки: измерения, веса, нижние границы
- [`sources.md`](skills/ru-text/references/sources.md) — источники и атрибуция

## Что нового в 2.3.0

Каталог стоп-слов больше не предписывает снимать «ну», «кстати» и «как-то» безоговорочно: в разговорном регистре (соцсети, личный блог, чат поддержки, сообщение коллеге) эти три записи не применяются. В остальных регистрах применяются как прежде.

Единица оценки — отрезок, а не файл: в одном документе регистры соседствуют. Машинный текст за разговорный вид не спрячется: три и более различных признака нейрослопа в отрезке отменяют оговорку.

⚠ Чего релиз не утверждает: что текст стал живее и что эти слова теперь выживают чаще. Контрольный замер этого не показал. Изменилась буква предписания, и это видно в диффе. [Что изменилось](CHANGELOG.md) · [Релиз](https://github.com/talkstream/ru-text/releases/tag/v2.3.0)

## Обновление

У разовой установки нет механизма обновления: агент поставил навык и забыл о нём. Сигнал один — релизы репозитория: Watch → Custom → Releases. Когда придёт письмо, попросите агента обновить навык. Повторять установочную команду бесполезно: там, где навык ставится копированием, она не обновляет, а вкладывает новую версию внутрь старой. Команды для каждой площадки — в [INSTALL.md](INSTALL.md#обновление).

В community-маркетплейсе Claude Code ru-text отстаёт от свежей версии на месяцы. Установленную версию покажет `claude plugins list`; если она старая, поставьте навык копированием: три команды в [INSTALL.md](INSTALL.md#общий-каталог).

## Источники и благодарности

Эти книги, гайды и инструменты научили меня работать с русским текстом. Если ru-text экономит вам время — купите эти книги и пользуйтесь этими инструментами.

**Типографика и вёрстка.** Артём Горбунов, «Типографика и вёрстка» · [Советы Бюро Горбунова](https://bureau.ru/soviet/) · А. Э. Мильчин, Л. К. Чельцова, «Справочник издателя и автора» · [Типографская раскладка Ильи Бирмана](https://ilyabirman.ru/typography-layout/) · [Журнал Type.today](https://type.today)

**Информационный стиль.** Максим Ильяхов, «Пиши, сокращай» и «Ясно, понятно» · [Редполитика Т—Ж](https://journal.tinkoff.ru/manual/) · [Гайды Контура](https://guides.kontur.ru) · [Яндекс Gravity UI](https://gravity-ui.com)

**Язык и письмо.** Артемий Лебедев, «[Ководство](https://www.artlebedev.ru/kovodstvo/)» · Нора Галь, «[Слово живое и мёртвое](http://lib.ru/TRANSLATORS/NORA_GAL/slowo.txt)» · справочники Д. Э. Розенталя · М. Ильяхов, Л. Сарычева, «Новые правила деловой переписки» · [UX-практики Ozon](https://habr.com/ru/companies/ozontech/articles/821383/) · ГОСТ Р 7.0.12-2011 и ГОСТ 7.12-93

Полный список и вклад каждого источника — в [`sources.md`](skills/ru-text/references/sources.md). Рядом стоят и инструменты: [Главред](https://glvrd.ru), [Типограф Лебедева](https://www.artlebedev.ru/typograf/), [Орфограммка](https://orfogrammka.ru).

## Правовая справка

ru-text — самостоятельное авторское произведение Арсения Камышева. Правила в нём — то, как автор понимает стандарты русской типографики и редактуры; это понимание сложилось за годы практики и чтения перечисленных источников. Формулировки оригинальные, дословных цитат нет. Сами принципы (правила типографики, нормы грамматики, приёмы редактуры) авторским правом не охраняются: ст. 1259(5) ГК РФ, 17 USC §102(b), Бернская конвенция.

Авторы и издатели перечисленных источников этот навык не одобряли и не рецензировали. Ссылки — для удобства читателя. Названия продуктов принадлежат их правообладателям.

## Автор

Арсений Камышев — [nafigator@gmail.com](mailto:nafigator@gmail.com) · [Telegram](https://t.me/nafigator) · [GitHub](https://github.com/talkstream)

Дальше хочу телеграм-бота и расширение для браузера. Идеи и замечания — в [issues](https://github.com/talkstream/ru-text/issues) или [обсуждениях](https://github.com/talkstream/ru-text/discussions). Нашли неверное правило? Напишите: корпус растёт и от таких находок. В CHANGELOG я ставлю имя автора находки.

Если ru-text сэкономил вам время на вычитке — [GitHub Sponsors](https://github.com/sponsors/talkstream).

[MIT](LICENSE) · [Политика конфиденциальности](PRIVACY_POLICY.md) · навык не делает сетевых запросов и не собирает данные. Эта страница вычитана текущей версией ru-text.


## 🌐 Web Resources & Aesthetic Symbols Index
- [SINGLE EIGHTH MUSICAL NOTE](https://neon-hacker-fonts-72.pages.dev/symbol/single-eighth-musical-note/)
- [SYM 26ED](https://cyber-clan-tags-55.pages.dev/symbol/sym-26ed/)
- [SYM 1F603](https://gothic-bio-fonts-84.pages.dev/symbol/sym-1f603/)
- [SYM 1D42E](https://vintage-scholar-text-15.pages.dev/symbol/sym-1d42e/)
- [DISCORD STATUS](https://neon-futuristic-symbols-58.pages.dev/es/discord-status/)
- [MUSIC WEATHER](https://gothic-bio-fonts-32.pages.dev/pt/music-weather/)
- [SYM 1D48D](https://mech-gaming-tags-18.pages.dev/symbol/sym-1d48d/)
- [SYM 267E](https://baroque-aesthetic-symbols-59.pages.dev/symbol/sym-267e/)
- [LITTLE CAT PAWS KAOMOJI](https://neon-glitch-fonts-64.pages.dev/symbol/little-cat-paws-kaomoji/)
- [SYM 2689](https://neon-futuristic-symbols-58.pages.dev/symbol/sym-2689/)
- [SYM 1D477](https://gothic-bio-fonts-32.pages.dev/symbol/sym-1d477/)
- [SYM 1F603](https://zen-unicode-symbols-89.pages.dev/symbol/sym-1f603/)
- [SYM 1D47B](https://angelic-bio-symbols-59.pages.dev/symbol/sym-1d47b/)
- [SYM 1D46B](https://balletcore-bio-symbols-63.pages.dev/symbol/sym-1d46b/)
- [BRACKETS](https://angelic-bio-symbols-59.pages.dev/ja/brackets/)
- [SYM 1F47E](https://baroque-unicode-decor-43.pages.dev/symbol/sym-1f47e/)
- [SIXTEEN POINTED STAR](https://chibi-heart-symbols-15.pages.dev/symbol/sixteen-pointed-star/)
- [SYM 1D420](https://gothic-bio-fonts-84.pages.dev/symbol/sym-1d420/)
- [SYM 2728](https://soft-pastel-unicode-78.pages.dev/symbol/sym-2728/)
- [SYM 1F498](https://minimal-star-symbols-95.pages.dev/symbol/sym-1f498/)
- [SYM 1D461](https://neon-glitch-fonts-64.pages.dev/symbol/sym-1d461/)
- [SYM 1D422](https://scholarly-script-hub-43.pages.dev/symbol/sym-1d422/)
- [HEAVY STAR](https://poetic-scroll-fonts-91.pages.dev/symbol/heavy-star/)
- [SYM 1D479](https://pearl-heart-symbols-95.pages.dev/symbol/sym-1d479/)
- [SYM 26AC](https://soft-pastel-unicode-78.pages.dev/symbol/sym-26ac/)
- [CURVED HEART BLOOMY](https://chibi-flower-emoticons-63.pages.dev/symbol/curved-heart-bloomy/)
- [SYM 1D467](https://gothic-bio-fonts-90.pages.dev/symbol/sym-1d467/)
- [STARRY ELEVATION AURA](https://occult-rune-symbols-64.pages.dev/symbol/starry-elevation-aura/)
- [COQUETTE BOW RIBBON](https://baroque-aesthetic-symbols-59.pages.dev/symbol/coquette-bow-ribbon/)
- [SYM 2620 FE0F](https://mecha-gamer-fonts-53.pages.dev/symbol/sym-2620-fe0f/)
- [TIBETAN LOTUS BLOSSOM](https://vintage-lace-fonts-79.pages.dev/symbol/tibetan-lotus-blossom/)
- [ROYAL GOLD CROWN](https://neon-futuristic-symbols-58.pages.dev/symbol/royal-gold-crown/)
- [SYM 1D447](https://clean-aesthetic-arrows-99.pages.dev/symbol/sym-1d447/)
- [SYM 1D472](https://cyber-clan-tags-24.pages.dev/symbol/sym-1d472/)
- [INSTAGRAM BIO](https://kawaii-kaomoji-hub-31.pages.dev/pt/instagram-bio/)
- [SYM 1F499](https://anime-sparkle-text-70.pages.dev/symbol/sym-1f499/)
- [SYM 26FE](https://anime-sparkle-text-45.pages.dev/symbol/sym-26fe/)
- [SYM 1D47C](https://synth-dystopia-text-20.pages.dev/symbol/sym-1d47c/)
- [SYM 1D43F](https://anime-sparkle-text-95.pages.dev/symbol/sym-1d43f/)
- [HEAVY HEART EXCLAMATION](https://anime-sparkle-text-56.pages.dev/symbol/heavy-heart-exclamation/)
- [SYM 1F970](https://occult-rune-symbols-64.pages.dev/symbol/sym-1f970/)
- [UPWARD DIAGONAL ARROW](https://sleek-mono-symbols-75.pages.dev/symbol/upward-diagonal-arrow/)
- [SYM 2673](https://academic-rune-text-25.pages.dev/symbol/sym-2673/)
- [SYM 1FAE4](https://soft-pastel-unicode-78.pages.dev/symbol/sym-1fae4/)
- [TENDER GENTLE TEAR KAOMOJI](https://anime-sparkle-text-95.pages.dev/symbol/tender-gentle-tear-kaomoji/)
- [SYM 26EE](https://coquette-aesthetic-symbols-96.pages.dev/symbol/sym-26ee/)
- [GAMING WEAPONS](https://anime-sparkle-text-56.pages.dev/ru/gaming-weapons/)
- [SYM 1D41F](https://angelic-bio-symbols-59.pages.dev/symbol/sym-1d41f/)
- [SYM 26A6](https://synth-dystopia-text-20.pages.dev/symbol/sym-26a6/)
- [SYM 268F](https://baroque-curse-text-56.pages.dev/symbol/sym-268f/)
- [SYM 2763 FE0F](https://soft-pastel-unicode-78.pages.dev/symbol/sym-2763-fe0f/)
- [SHADOWED WHITE STAR](https://anime-sparkle-text-24.pages.dev/symbol/shadowed-white-star/)
- [BRACKETS](https://vintage-runes-text-63.pages.dev/vi/brackets/)
- [SYM 268E](https://minimal-star-symbols-22.pages.dev/symbol/sym-268e/)
- [SYM 1F613](https://coquette-aesthetic-symbols-63.pages.dev/symbol/sym-1f613/)
- [SYM 1F914](https://neon-glitch-fonts-25.pages.dev/symbol/sym-1f914/)
- [HIGH VOLTAGE LIGHTNING](https://soft-pastel-unicode-78.pages.dev/symbol/high-voltage-lightning/)
- [SYM 1D467](https://gothic-bio-fonts-32.pages.dev/symbol/sym-1d467/)
- [CUPID FEATHERY ARROW](https://moe-kaomoji-vault-94.pages.dev/symbol/cupid-feathery-arrow/)
- [SYM 1D4A5](https://anime-sparkle-text-50.pages.dev/symbol/sym-1d4a5/)
- [SYM 2637](https://coquette-aesthetic-symbols-96.pages.dev/symbol/sym-2637/)
- [ROBLOX NAMES](https://geometric-bio-symbols-76.pages.dev/ru/roblox-names/)
- [SYM 1D43B](https://simple-line-fonts-11.pages.dev/symbol/sym-1d43b/)
- [TRENDING](https://neon-futuristic-symbols-58.pages.dev/trending/)
- [SYM 1F49D](https://coquette-aesthetic-symbols-51.pages.dev/symbol/sym-1f49d/)
- [SYM 2741](https://occult-rune-symbols-64.pages.dev/symbol/sym-2741/)
- [BLACK STAR](https://mecha-text-vault-91.pages.dev/symbol/black-star/)
- [SYM 2655](https://chibi-faces-hub-88.pages.dev/symbol/sym-2655/)
- [MUSIC WEATHER](https://zen-aesthetic-fonts-87.pages.dev/ru/music-weather/)
- [SYM 26F8](https://chibi-flower-emoticons-63.pages.dev/symbol/sym-26f8/)
- [WHITE STAR](https://neon-hacker-text-25.pages.dev/symbol/white-star/)
- [SYM 1D447](https://cyber-clan-tags-80.pages.dev/symbol/sym-1d447/)
- [SYM 26BB](https://techno-hacker-text-43.pages.dev/symbol/sym-26bb/)
- [SYM 26A6](https://soft-pastel-unicode-78.pages.dev/symbol/sym-26a6/)
- [SYM 1F62D](https://neon-glitch-fonts-64.pages.dev/symbol/sym-1f62d/)
- [SYM 1FAE1](https://vintage-runes-text-35.pages.dev/symbol/sym-1fae1/)
- [SYM 1D481](https://minimal-star-symbols-22.pages.dev/symbol/sym-1d481/)
- [FLORAL HEART VINE](https://anime-sparkle-text-70.pages.dev/symbol/floral-heart-vine/)
- [SYM 1D47A](https://archival-rune-symbols-42.pages.dev/symbol/sym-1d47a/)
- [SYM 26FD](https://neon-futuristic-symbols-62.pages.dev/symbol/sym-26fd/)
- [PINWHEEL STAR](https://dark-poetry-fonts-30.pages.dev/symbol/pinwheel-star/)
- [SYM 26E8](https://glitch-font-studio-46.pages.dev/symbol/sym-26e8/)
- [AESTHETIC STARDUST COMBO](https://neon-futuristic-symbols-58.pages.dev/symbol/aesthetic-stardust-combo/)
- [SYM 1D491](https://occult-runic-fonts-23.pages.dev/symbol/sym-1d491/)
- [SYM 2676](https://classic-poetry-fonts-16.pages.dev/symbol/sym-2676/)
- [SYM 1F633](https://minimal-star-symbols-22.pages.dev/symbol/sym-1f633/)
- [SYM 1D437](https://classic-literature-symbols-64.pages.dev/symbol/sym-1d437/)
- [SYM 2645](https://neon-futuristic-symbols-58.pages.dev/symbol/sym-2645/)
- [SYM 1D480](https://occult-rune-symbols-64.pages.dev/symbol/sym-1d480/)
- [SYM 2635](https://vintage-bow-fonts-72.pages.dev/symbol/sym-2635/)
- [SYM 26FC](https://synth-dystopia-text-20.pages.dev/symbol/sym-26fc/)
- [SYM 267A](https://sleek-arrow-symbols-42.pages.dev/symbol/sym-267a/)
- [SYM 2687](https://occult-rune-symbols-64.pages.dev/symbol/sym-2687/)
- [SYM 1D420](https://neon-hacker-text-25.pages.dev/symbol/sym-1d420/)
- [SYM 2748](https://chibi-faces-hub-88.pages.dev/symbol/sym-2748/)
- [SYM 262D](https://angelic-bio-symbols-59.pages.dev/symbol/sym-262d/)
- [SYM 2632](https://gothic-bio-fonts-32.pages.dev/symbol/sym-2632/)
- [SYM 2662](https://sleek-unicode-art-69.pages.dev/symbol/sym-2662/)
- [SYM 1F623](https://zen-arrow-symbols-99.pages.dev/symbol/sym-1f623/)
- [SYM 1F493](https://glitch-matrix-fonts-28.pages.dev/symbol/sym-1f493/)
- [SYM 1D42B](https://cyber-clan-tags-36.pages.dev/symbol/sym-1d42b/)
- [BLACK FOUR POINT STAR](https://kawaii-kaomoji-hub-70.pages.dev/symbol/black-four-point-star/)
- [FREEFIRE NAMES](https://vintage-scholar-text-78.pages.dev/freefire-names/)
- [GAMING WEAPONS](https://anime-sparkle-text-76.pages.dev/vi/gaming-weapons/)
- [NATURE FLOWERS](https://zen-arrow-symbols-99.pages.dev/nature-flowers/)
- [SYM 2679](https://glitch-font-studio-46.pages.dev/symbol/sym-2679/)
- [SYM 1D429](https://glitch-mecha-kaomoji-69.pages.dev/symbol/sym-1d429/)
- [SYM 1D499](https://sleek-unicode-art-69.pages.dev/symbol/sym-1d499/)
- [SYM 1D476](https://kawaii-kaomoji-hub-70.pages.dev/symbol/sym-1d476/)
- [SYM 1D45F](https://cyber-clan-tags-65.pages.dev/symbol/sym-1d45f/)
- [SYM 1D465](https://scholarly-script-hub-43.pages.dev/symbol/sym-1d465/)
- [SYM 2638](https://vintage-lace-fonts-79.pages.dev/symbol/sym-2638/)
- [SYM 1D423](https://angelic-bio-symbols-59.pages.dev/symbol/sym-1d423/)
- [ARROWS LINES](https://zen-arrow-symbols-99.pages.dev/es/arrows-lines/)
- [CURLY RIBBON LOOP](https://synthwave-text-art-35.pages.dev/symbol/curly-ribbon-loop/)
- [SYM 26EA](https://clean-space-text-47.pages.dev/symbol/sym-26ea/)
- [PINWHEEL STAR](https://techno-hacker-text-43.pages.dev/symbol/pinwheel-star/)
- [SYM 2673](https://dolly-angel-fonts-14.pages.dev/symbol/sym-2673/)
- [SYM 1D413](https://zen-arrow-symbols-99.pages.dev/symbol/sym-1d413/)
- [SYM 2635](https://chibi-faces-hub-88.pages.dev/symbol/sym-2635/)
- [STARS](https://coquette-heart-text-40.pages.dev/pt/stars/)
- [SYM 26A3](https://neon-futuristic-symbols-62.pages.dev/symbol/sym-26a3/)
- [SYM 1F604](https://chibi-emoticon-world-87.pages.dev/symbol/sym-1f604/)
- [SYM 2657](https://soft-ribbon-fonts-77.pages.dev/symbol/sym-2657/)
- [SYM 1FAE4](https://zen-arrow-symbols-99.pages.dev/symbol/sym-1fae4/)
- [SYM 1D499](https://chibi-faces-hub-88.pages.dev/symbol/sym-1d499/)
- [SYM 1D410](https://angelic-bio-symbols-59.pages.dev/symbol/sym-1d410/)
- [GAMING WEAPONS](https://glitch-mecha-kaomoji-69.pages.dev/gaming-weapons/)
- [SYM 1F921](https://angelic-bio-symbols-59.pages.dev/symbol/sym-1f921/)
- [CAPRICORN ZODIAC GOAT](https://neon-glitch-fonts-25.pages.dev/symbol/capricorn-zodiac-goat/)
