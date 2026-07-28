# v3.0 — the grammar layer the corpus does not have

A separate file from `roadmap-v3-formative.md` on purpose. That one opens the formative
half — what a living sentence *does* — and declares the prohibitive half finished. This one
says the prohibitive half is **not** finished, in one specific place, and the two would
contradict each other under a single heading.

## What was measured

On 28.07.2026 four evidence channels were read blind to each other and every candidate was
screened by a second agent against the corpus, by command. The finding was not where it was
expected. Style is covered thoroughly — info-style, канцелярит, anti-patterns, sixteen tells
of machine prose, 96 typography rules, 88 punctuation rules. **Grammar in the narrow sense
is close to empty**: government, participial commas, declension of compound numerals and
surnames, verb aspect. Verified absent with greps recorded in the dossier.

That matters because Г carries weight 0.20 and `scoring.md:77` calls it «hard (objective)».

## The cost is not what it looks like

The obvious reading — the tool is blind to «согласно приказа» — is wrong, and the arbiter
was right to correct it. ru-text is executed by a language model, and a model flags that
phrase with or without a rule. What is missing is the **support for the verdict**: a finding
with no rule ID, no golden anchor, no reproducible ground in the one dimension that claims
to be objective.

So the work here is not to reproduce Rozental. It is to give the most frequent indisputable
errors something to stand on.

## Shipped in v2.0

Three positions, one panel, one judge — the narrow package the arbiter allowed:

- **A gerund phrase whose subject is not the sentence's subject.** «Подъезжая к станции, у
  меня слетела шляпа». Mechanical test: the doer of the gerund and the grammatical subject
  must be the same. Carve-outs: an impersonal clause with an infinitive («Подъезжая к
  станции, следует смотреть в окно»), and the forms that have hardened into prepositions —
  «судя по», «исходя из», «несмотря на», «начиная с».
- **Government, by closed list only.** «Согласно приказа» → «приказу», «оплатить за проезд»
  → «оплатить проезд», «заведующий отделом», «преимущество перед», «уверенность в». A closed
  list because the open form — checking every case after every preposition — is a detector of
  non-native Russian, which this project is forbidden to build.
- **Different government under shared dependents.** «Организовать и руководить работой»:
  two verbs, one object, incompatible cases.

## Backlog, in the arbiter's order

**Contextual homophones** — «в течение / в течении», «чтобы / что бы», «также / так же»,
«ввиду / в виду». A closed list of about ten pairs with a decidable rule for each («в
течение» + genitive of time). Spellcheckers do not catch these because both spellings exist.
Conditionally in v2.0; first to drop if the release is overloaded.

**Participial and adverbial commas.** «Файл загруженный вчера содержит ошибку». Genuinely
absent and genuinely an error — and deliberately deferred, because it is an open class
(uточнения, приложения, сравнительные оборот) with no natural boundary, and because every
comma becomes a finding. In an ordinary draft the commas would outnumber and bury the
stylistic findings, which turns an editor into a school tutor. If it is ever done, it needs
a way to report «twelve comma issues» as one finding.

**Declension: compound numerals, «полтора», masculine surnames.** «С шестистами рублями» →
«шестьюстами»; «письмо Кравчук Игорю» → «Кравчуку». One channel only, and half the family
was amputated during screening: place names in -о and the gender of abbreviations were
dropped as contested. In written text digits hide most numeral errors, so the real frequency
is below the estimate.

**Aspect and tense mismatch under coordinated predicates.** «Он открыл файл и сохранял
изменения». Passed one screen, and only with the trigger narrowed — in its raw form it flags
correct sentences, and a false positive inside a hard dimension costs more than a miss.

**Paronyms, by closed list.** Надеть / одеть, представить / предоставить, роспись / подпись,
абонент / абонемент. The channels split two against two. The business pairs are objective
and do not touch the protected registers, but context decides — «роспись на стене» is
correct — so the list has to carry its condition with each pair.

## Rejected, with the reason, so it is not re-proposed

- **Wandering pronoun / ambiguous reference.** The channels split 2–2, and that split is
  itself the evidence: the trigger is a judgement about whether context resolves the
  reference. Same ground as the amphiboly rejection.
- **Syntactic ambiguity (amphiboly).** One of its two mechanical triggers is already taken
  (genitive chains, `editorial-grammar.md:271`, `:351`); the other fires on masses of
  unambiguous phrases, because «который» resolves to the nearest noun by default.
- **Contamination of set phrases** («играть значение»). Not covered by anything — and not
  reproducible without a dictionary of set collocations.
- **Speech insufficiency** («отредактировал и опубликовал в блог»). Not covered either, and
  rejected for reasons of its own rather than coverage.
- **Stacked «который» clauses**, **collisions of function words**, **accidental rhyme in
  prose** — protected register, overlap with a rejected candidate, or not objective.

Three of these were labelled «covered» in the first draft of the dossier. They are not
covered; they are rejected, which is a different thing and a more dangerous mislabel — a
reader concludes there is no hole.
