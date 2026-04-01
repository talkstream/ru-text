---
name: ru-score
description: Score Russian text quality on a 0.0–10.0 scale across 5 dimensions
allowed-tools: Read, Grep, Glob
context: fork
---

# Russian Text Quality Score

Score the text provided in $ARGUMENTS (or the most recent Russian text output if no arguments) using the ru-text scoring rubric.

## Setup: locate reference files

1. `Glob("**/ru-text/references/scoring.md", path: "~/.claude/plugins/cache/")`
2. The parent directory of the result = REFS (if multiple results, use the last one)
3. All reference files below are at `REFS/<filename>`

## Procedure

1. **Load rubric** — read `REFS/scoring.md` for the full rubric with anchors.

2. **Determine domain** — identify whether the text is UI/interface, business email, article, or general:
   - UI text → also load `REFS/ux-writing.md` for the Reader Precision dimension
   - Business email → also load `REFS/business-writing.md` for the Reader Precision dimension
   - General → use `REFS/info-style.md` only

3. **Evaluate each dimension separately** — score in this order:
   - **T — Типографика** (weight 0.15): quotes, dashes, spaces, special characters per `REFS/typography.md`
   - **Ч — Чистота языка** (weight 0.25): stop-words, bureaucratic language, clichés, passive voice per `REFS/info-style.md` + `REFS/anti-patterns.md`
   - **Г — Грамотность** (weight 0.20): punctuation, agreement, tautology per `REFS/editorial-grammar.md` + `REFS/editorial-punctuation.md`
   - **С — Структура** (weight 0.20): logical flow, paragraphs, transitions, heading use per `REFS/info-style.md` structure section + `REFS/addenda.md`
   - **Ц — Точность для читателя** (weight 0.20): facts, evidence, reader benefit, actionability per domain rules

4. **For each dimension** — assign a score (0.0–10.0) using the rubric anchors in scoring.md. List 1–3 specific issues, quoting the problematic text fragment.

5. **Apply non-compensatory rules:**
   - Any dimension < 3.0 → cap total at 5.0
   - Typography < 4.0 → cap total at 7.0
   - Grammar < 4.0 → cap total at 7.0
   - Use the most restrictive cap when multiple conditions trigger

6. **Compute composite score:**
   ```
   S = round₁(T × 0.15 + Ч × 0.25 + Г × 0.20 + С × 0.20 + Ц × 0.20)
   ```

7. **Short text warning** — if text is under 50 words, prepend a reliability caveat.

## Score labels

| Score | Label |
|---|---|
| 9.0–10.0 | Эталонный |
| 7.0–8.9 | Хороший |
| 5.0–6.9 | Средний |
| 3.0–4.9 | Слабый |
| 0.0–2.9 | Критический |

## Output format

```
## Оценка: X.X / 10 — [label from table above]

| Измерение | Балл | Замечания |
|---|---|---|
| Типографика | X.X | [1–3 specific issues with «quoted fragments»] |
| Чистота языка | X.X | ... |
| Грамотность | X.X | ... |
| Структура | X.X | ... |
| Точность для читателя | X.X | ... |

**Формула:** T×0.15 + Ч×0.25 + Г×0.20 + С×0.20 + Ц×0.20 = X.X
[If non-compensatory cap triggered: «Ограничение: [dimension] ниже порога → итог ≤ X.X»]

### Что оценка не измеряет
Фактическую точность, уместность тона для аудитории, креативность, конверсию, соответствие заданию.
```

If a dimension has no issues, write «Замечаний нет» in the remarks column.
