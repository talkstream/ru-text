# v2.1 — the brake

Reported by the author on 30.07.2026, from using v2.0 on real work: after ru-text, prose
comes out **too short and too chopped** — the filters are so good they kill the liveliness
of the language. On 31.07.2026 he raised it from the v3.0 backlog to a 2.1 release, with
the sharper statement of the problem: *too many removals, and they do not always leave the
text any skeleton at all.*

That escalation is right, and the reason it is right is the reason this file exists apart
from `roadmap-v3-formative.md`. The formative direction adds a new *kind* of rule — one
that says what a sentence should do — and that kind does not fit the current rubric, which
is why it is a major version. This does not. Everything here constrains rules the corpus
already has. It needs no new vocabulary, no new dimension and no new score. It is a brake
on an engine that works, and a brake is a minor version.

## The mechanism, which is not a fault in any single rule

**Every one of the 2 289 atoms is a removal, and nothing in the corpus has a stake in what
stays.** Each atom names something to take out or replace with something shorter. A set
made only of subtractions has exactly one fixed point: the shortest text that violates
nothing. Apply it hard enough and every document walks toward that point, whatever it was
before. No rule causes this. The *set* causes it, and only the set can fix it.

**The scoring model does not resist it.** All five dimensions penalise. A page of eight-word
declaratives with no subordination, no aside and no digression violates nothing in
typography, nothing in clean language, nothing in grammar, nothing in structure and nothing
in precision — so it scores well. The rubric cannot tell «edited» from «eviscerated»,
because it was never given anything to defend.

**Nothing counts the findings against each other.** A finding fires because it is
individually right. Twelve individually right findings in one paragraph are how a paragraph
becomes a husk, and no part of the current design notices that the twelfth arrived.

**And the result is a new tell.** This is the part that makes it urgent rather than merely
unfortunate. Flat uniform brevity without subordination is precisely the register AD-6 and
the rejected rhythm candidates already treat as machine-written. An anti-neuroslop tool that
presses every text into one shape has not removed the machine signature; it has replaced
someone else's with its own — and ours is harder to spot, because it is assembled out of
individually correct edits.

## Step one is a measurement, and it is not optional

The observation comes from the person who knows this corpus better than anyone, which makes
it the best possible reason to look and still not evidence. «The author said so» is not a
basis for shipping a brake that could suppress correct findings.

The prediction is falsifiable and the instrument is cheap. Take texts before and after a
`ru-check` pass and compare the **distributions**, not the means:

| metric | prediction if the flattening is real |
|---|---|
| sentence length, mean | falls |
| sentence length, **variance** | **narrows** — this is the load-bearing one |
| subordinate clauses per sentence | falls |
| clause depth | falls |
| paragraph length in sentences | falls or holds |

If the mean falls and the variance holds, the texts got shorter without getting flatter,
and this whole file is wrong. That outcome must be as publishable as the other one.

`tools/measure-prose-shape.py` is the instrument. It is deliberately dumb — no parser, no
model, only counts that a person can re-derive by hand from the same text — because a
measurement used to justify suppressing findings has to be one nobody can argue with.

## The first measurement: not confirmed — and OVERTURNED the next day, see below

**Read the blind panel first.** Everything in this section is what the instrument said, and
the instrument was measuring the wrong axes. It is kept because the reasoning is the evidence
for how a null result gets manufactured, not because its conclusion stands.

Run 31.07.2026. Five Russian texts that had never been through the skill — the author's own
chat messages, a technical field report, a working plan, an audit and an analytical note,
about 5 400 words of varied register. Provenance was verified rather than assumed: text this
skill has processed carries non-breaking spaces after single-letter prepositions, so
`NBSP > words/60` disqualifies a candidate as a «before». Two candidates failed exactly that
test and were dropped; a third was dropped because the instrument read it as four sentences
averaging 140 words, which is a structured document rather than prose.

Each text was proofread by an agent that read the reference files itself and applied every
finding. Median change across the five:

| metric | change |
|---|---|
| words | +0.0 % |
| sentence length, mean | −0.5 % |
| sentence length, standard deviation | −1.2 % |
| **sentence length, CV** | **+0.0 %** |
| subordinate clauses per sentence | +0.0 % |
| commas per sentence | +0.2 % |

Heading counts matched in every text, so the agents edited rather than rewrote and the rows
are readable.

**The hypothesis is not confirmed on this corpus. It is also not refuted, because this corpus
cannot test it.** The reason is in the finding counts, not in the shape numbers: of 90
findings on one text, 87 were invisible NBSP insertions; of 25 on another, 24 were. The
stop-word catalogue returned one hit across one text and zero across another. Three of the
five agents reported the same thing independently — zero §B hits, zero канцелярит, zero
passive-voice findings, zero neuroslop. There was nothing to remove, so nothing could be
over-removed.

That is a finding about the sample, and it sharpens the question rather than closing it. Prose
written and already edited by people yields almost no removals. The complaint is about drafts
**written by a model** — the population this skill exists for — where the removals are dense.
A second corpus of model-drafted Russian is the test that can actually fail.

## The blind panel: the author was right, and the instrument was blind

01.08.2026. Ten before/after pairs from both corpora, split into files named A1/A2 … J1/J2 with
the order inside each pair alternating, so no judge could learn the convention from the first
pair. Three judges — an attentive reader, a working editor of Russian non-fiction, a
psycholinguist — read all twenty texts and answered one question per pair: **which reads more
like something a person wrote and edited.** «Indistinguishable» was declared a full answer and
worth more than an invented difference. Counting by codepoints was forbidden: the question is
not about typography, and tallying non-breaking spaces would have revealed the after-text
instantly without answering anything.

| more human | votes | of those, high confidence |
|---|---|---|
| **the text BEFORE the check** | **24** | **11** |
| the text after | 4 | 1 |
| indistinguishable | 2 | 0 |

Seven pairs of ten were unanimous for the before-text. Not one pair was unanimous the other way.
Reproduce the tally against `blind-key.json` with the script in the panel report.

And separately: **all seven accusations of damage — «something left here and there is a hole» —
landed on after-texts. Seven of seven.**

**The instrument said the opposite on the same bytes.** `measure-prose-shape.py` returned median
CV changes of +0.0 % and +0.4 % and the roadmap wrote «not confirmed». It measures
sentence-length variance and subordination. The judges were discriminating on intra-sentence
punctuation, on intensifiers and on register loudness — axes it does not count at all. The
finding was not absent; the ruler had no marks there.

One indirect confirmation that this is an effect and not noise: the only «indistinguishable»
pair is the one where almost nothing was edited. Discrimination tracks dose.

**The mechanism is named, and it is countable.** Dashes of one role in a series or an anaphora
are counted separately and cut to zero rather than to the rule's own budget — reproduced at
4→2 and at 3→0 against a stated budget of «1–2 per paragraph». And the intensifiers «честно» and
«реально», removed inside a commitment and inside an admission of fault: the only substantive
deletions in the whole experiment, and every one of them was named as damage by a judge who did
not know which text was which.

**What this costs the earlier section, precisely.** «Not confirmed» was true of the instrument
and false of the product. The honest statement is that the experiment failed to arrange the
flattening it was looking for, and then reported the absence as a property of the corpus. That
is how a null result gets manufactured, and it happened here with every gate green.

**The standing refusal that follows.** No corpus 3, in any of the four shapes the arbiter listed,
until the instrument is repaired: the same median over a thin dose returns zero whatever the
truth, and the last zero was read as a licence within the hour.

## The second blind panel: the dash count moved, the perception did not

01.08.2026, after AD-1.6…AD-1.9 and B.1 were in the corpus. The five texts that had lost the
most dashes were re-checked by agents that read the rules from the files, and the same three
judges read «before» against «after the fix», blind, order alternating.

**The mechanic is fixed, and the instrument shows it.** Texts losing dashes went from five of
five to two of five; eleven of the sixteen cut marks came back; three documents were restored
whole. On one text nothing changed, and the agent said so plainly — the two marks there form no
row, so the carve-out was never meant to save them.

**The perception did not move at all.**

| panel | the BEFORE text called more human | the edited one | indistinguishable |
|---|---|---|---|
| first, these same five texts | **13** | 2 | 0 |
| second, after the fix | **13** | 1 | 1 |

Thirteen and thirteen. Four pairs of five still unanimous for the unedited text.

**And B.1 did not reach the text.** ~~Verified byte for byte: the landing page said «мы честно
скажем», the check made it «мы скажем», and the re-run with the carve-out in place left it «мы
скажем». That is exactly the configuration B.1 describes.~~ **RETRACTED the same day — see
below.** The paragraph is left standing because it is the second manufactured verdict of this
experiment and the two were manufactured differently.

### Retraction: B.1 works, and the probe was outside its jurisdiction

The sentence above tested B.1 with a word B.1 does not govern. «Честно» is not one of the eleven
amplifiers §B lists — очень, крайне, чрезвычайно, максимально, предельно, абсолютно, невероятно,
буквально, реально, действительно, по-настоящему — and B.1's own third paragraph says so in as
many words: a declared-sincerity label «keeps its own charge under AD-10 or AD-7, those words are
not in this catalogue». Bare «честно» is an AD-7 trigger (`addenda.md`, the announced-sincerity
line). So the check deleted it under a different rule, and B.1 had nothing to decline.

On the sentence B.1 does govern it fired exactly as designed. One admission in the whole
experiment carries a §B amplifier — `corpus/04-audit.md`, the line B.1's own text cites — and its
three states settle it:

| state | the line | «реально» |
|---|---|---|
| before | «**Честный** ответ директору: ДА — один баг того же семейства (F3) у нас **реально** есть» | present |
| after, B.1 not yet written | «Ответ директору: да, один баг того же семейства (F3) у нас есть» | **cut** |
| after, B.1 in the corpus | «Ответ директору: ДА — один баг того же семейства (F3) у нас **реально** есть» | **kept** |

`git log -S` puts B.1 in the corpus at 03:23; the re-run wrote that file at 03:40. The
sincerity label «Честный» is gone in both later states, which is AD-10 doing its job and which
B.1 explicitly refuses to undo. The carve-out subtracted one charge and left the other standing,
which is the whole of what it promises.

**The lesson is about the probe, not about transmission.** «A rule in the corpus is not a rule
that works» was the generalisation drawn from this, and it was drawn from a test the rule's own
scope statement excludes — a paragraph I had written and then read past. A rule states what it
covers; the probe comes from that statement, not from the nearest sentence that looks similar.

**One real gap survives the retraction.** B.1 has no positive golden case: the set's only «честно»
is the AD-10.4 dialogue carve-out, and the four cases carrying a §B amplifier all expect it
flagged. The golden criterion is no-loss — findings AFTER ⊇ findings BEFORE — so a carve-out that
never fires cannot fail it. All 108 self-tests pass and none of them says anything about B.1.
That is the gate-narrower-than-the-rule pattern once more, and this time it is the gate's coverage
rather than its logic.

**And the open question is now AD-7's, not B.1's.** «Позвоните, и мы честно скажем, есть ли сейчас
то, что вам нужно, — а если нет, назовём срок» loses «честно» to the announced-sincerity trigger.
A judge who did not know the states called it a hole and put it better than the rule does: without
the word the sentence promises that you will get an answer, which is to say it promises nothing.
Whether that deletion is right turns on which line fired — the trigger list, or AD-7.1's
three-part test, which is stated over «без [vice]» and «[virtue] говоря» forms and does not
obviously reach a manner adverb on a promise about future conduct. Diagnose that before writing
anything.

**What the judges named instead, all three independently:**

*Caps turned into italics.* In a working plan «⚠️ НЕ последовательным вставлением» became «*не*»,
and a judge said what the corpus does not: shouting in that kind of document is not sloppiness,
it is a risk marker. Get the order wrong and twenty-six captions land on the wrong photographs.

*Words of pressure* — «честно», «реально», «максимально» — removed exactly where the author
raised their voice.

*A numeral system applied by halves.* «Не ниже плюс 12… нагрузка до пяти тонн… высота от шести
метров»: three numbers in one sentence, two in words and one in digits. Each is individually
correct by the table and the sentence stumbles.

*Word order.* «Аналогия, которая работает почти всегда, — записная книжка» straightened into
direct order, so the image arrives before the reader knows what it is for.

**The honest conclusion.** The dashes were a real breakage and it is fixed. They were not the
main one. The main one is loudness and stance — caps, intensifiers, and the author's chosen
emphasis — and that is where the next round goes.

## Two defects the run surfaced that are not flattening

Both were raised independently by the agents, and both are the same shape: a rule applied
correctly in a place where it should not have applied at all.

**A date.** R59 prescribes `13.07.2026` and carries no register carve-out, so an ISO-8601 date
was converted inside a field report addressed to a vendor's macOS engineering team. The rule
was obeyed; a machine-readable, unambiguous date became ambiguous for a non-Russian reader.
(One agent applied it; another, on a different text, ran the same candidate down and rejected
it on the grounds that R59 prescribes without prohibiting. Two correct readings of the same
rule text is itself the defect.)

**Invisible characters in strings meant for machines.** In a document three-quarters composed
of quoted source lines with `file:line` citations — strings destined to be find-and-replaced
back into those files — R30 inserts NBSP that breaks exact-string tooling, which is a harm
`ru-check`'s own output-format section already names. The agent withheld them; nothing in the
corpus told it to.

Neither is about volume. Both are about **place**, and 2.1 should answer for both: not only
how much a check removes, but where it is entitled to act at all.

## What 2.1 could ship, once the measurement says it should

None of this is designed yet. Recorded as shapes, ranked by how little new machinery each
needs.

**1. Turn the existing document-level tells on our own output.** ru-check already produces
a corrected text and already owns two document-level rules (AD-14, AD-15) that judge a text
whole. Nothing currently runs them on the *result*. If the corrected text triggers AD-6 —
sameness of rhythm — the check has over-edited, and it can say so before the user reads it.
This adds no rule at all; it points existing rules at a target they were never aimed at.

**2. A findings budget per passage.** Beyond some density of findings per paragraph, the
remainder are reported as advisory rather than as edits, ranked by severity. The user still
sees everything; the *applied* set stops short of demolition. The threshold has to come out
of the measurement, not out of taste.

**3. A protected class.** Structures a finding may not remove: subordination that carries
the logic of the argument, an aside that carries the voice, a long sentence that *is* the
point rather than a failure to stop. Today no atom in the corpus can say «leave this», and
that absence is the whole problem stated in one line.

**4. Restraint as an instruction, not a rule.** The cheapest of all: `ru-check` currently
tells the model to find everything. It does not tell it to prefer the smallest intervention
that fixes the defect. That single instruction may carry a surprising amount of the effect,
and it is testable against the same measurement.

## The damage score the author asked for: there is no number, and that is the answer

Asked 31.07.2026: a quantity the check would use to weigh its own edits, so that «remove»
can be measured against «break». A fourteen-agent panel ran it — five evidence bases, four
designs from incompatible starting points, one adversary each, one synthesis — and an
arbiter ruled on the result. Full proposal:
`~/Projects/_scratch/ru-text-flattening/damage-metric/proposal.md`.

**No number survives, for two reasons that are properties of the subject rather than gaps in
the search.** Everything the tradition counts — HTER, TTR, lexical density, edit distance —
measures the VOLUME of intervention and not the harm: ninety invisible NBSP insertions score
an enormous edit distance and do no damage at all, while one converted date breaks a
document. And a score a check reports about ITSELF is a score it lowers by editing less; the
identity function beats a human reference on BLEU, 59.85 against 43.90 (Sulem 2018).

**What replaces it is a right, not a scale.** Every rule carries one of two dispositions:
*edits* — the finding goes into the corrected text — or *suggests* — it goes into the report
with a ready replacement and leaves the text alone. The label is written once, by a person,
in the file beside the trigger; it is not a judgement made on the run. That is the shape
every comparable tool converged on independently: `Fix safety` in ruff, `Applicability` in
clippy, `fixable` against `hasSuggestions` in ESLint. Cost at the check: zero new judgements
on typography, which is where the findings actually are.

**The criterion, and it was already in the corpus unmarked:** does the prescribed replacement
name a participant, or assert a fact, that the source does not? The passive table was read
line by line — all ten right-hand sides name an agent absent from the left, and the eighth
literally prints `[Кто] сделает [что] до [когда]`. An agent cannot supply that name; the
document does not contain it. So it must not try, and the corpus has been telling it so
without a word for the mechanism.

Default is *edits*. §I, §J, §K, punctuation and typography carry no label at all — those are
error corrections, not removals.

**Refused, each on evidence:** a findings budget per paragraph (the threshold is not derived
from any measurement, and on one golden case «one per paragraph» would apply 3 findings of
10); a protected class of spans (the condition that opens the class is the condition that
lifts it — shown on our own dash case); and any sixth rubric dimension (two byte-identical
texts would score differently, and one note would reach «Хороший» without a single edit —
which is this project's own recorded defect that a rule must not raise its victim's score).

**Ruled: the mechanism ships, the map does not.** The set of rules to label was stated as 25
lines and reproduces as 25 by grep, but that is a floor at roughly 35 % recall — bracketed
placeholders alone are 16 lines in `anti-patterns.md`, an extended grep gives 55, and a
reader's census is about 70. Worse, the label's own first sentence, read alone, captures 35
plain «убрать» lines in §B and would plug the water-removal engine outright; eleven
disjunctive lines («убрать или обосновать») get labelled against the criterion they are
supposed to fail. The census has to be done by eye, the label restricted to its fact form,
and the disjunctive lines given a conditional of their own — before anything is written into
a reference file.

**The uncovered path is named rather than papered over.** Text generated under the always-on
`SKILL.md` never loads a reference file, so no label in a reference file reaches it. For
generation the arbiter agrees the gap cannot be closed by a line — the test has no source to
compare against, because there is no source yet. For editing text already in context it
disagrees with the proposal: a self-contained line in the SKILL.md body is a mechanism of
exactly the kind that fixed the v1.8.1 NBSP defect.

## Correcting one thing said about the first measurement

The «no flattening» result covers the SYNTACTIC axis only — coefficient of variation of
sentence length, subordination, commas, paragraph length. The LEXICAL axis was not measured
at all: type-token ratio and lexical density, which is where the effect has been reported.
That is a real hole in the instrument and it is now on record.

It does not overturn the result, and the reason matters: that zero was load-scoped. One to
five prose edits per text cannot move a type-token ratio any more than they moved a variance.
The lexical axis has to be measured on a corpus that is actually loaded — corpus 3 — and with
NBSP normalised away before tokenisation, or the invisible insertions will dominate the count.

## The five carve-outs: four killed by their own opponents, nothing shipped

Written 31.07.2026, one author each, one adversary each, against the arbiter's ranking that
called them «ready now, zero new machinery». They were not ready. Four came back «переделать»
and the fifth «брать с правками» with three kills of its own. Every kill is verified against
a file in this repository, and the pattern across them is worth more than any of them.

**Passive.** The carve-out exempted «the interface» by name — and `tools/golden/04-ui-copy`
REQUIRES the finding «не может быть обработан — пассив в интерфейсе». One lost finding is a
golden-set failure by `tools/golden/README.md:20`. Its «procedure» clause was worse: title a
document «Порядок рассмотрения обращений» and every agentless канцелярит passive inside it
becomes exempt, which is the register the rule exists for. Its second half turned a frozen
zero-control text red.

**R59, dates.** The carve-out missed the very evidence it was written for. The cell is Russian
prose («2026‑07‑13 · воспроизведение проверено на хосте»), so neither «a program» nor «a
non-Russian engineer» reads it and the exemption never fires; and the date is written with
U+2011 non-breaking hyphens, so a reader applying the letter does not call it an ISO date at
all. Then the loophole: «who reads this» is not a property of the text, it is a claim the
author makes in a heading. `## Отчёт для аудиторов` over a Russian accounting table switches
off the table half of R59 by assertion.

**R30 in machine-read strings.** Measured, and the premise dissolved: in the flagship document
the «Сейчас» column — the half that is actually searched — was already correct 20 out of 20
without any carve-out, because those lines are quotations and `SKILL.md:24` already covers
them. The only clause that suppressed anything suppressed it in the «Предлагаю» column, which
is text destined to become published Russian prose. The carve-out would have shipped hanging
one-letter prepositions into an article.

**Anglicisms and caps.** The anglicism carve-out was not asked for — the arbiter asked for the
COLUMN to be rewritten — and rewriting the column already closes the field case without it.
The caps test was undecidable: it asks which emphasis the surface renders while forbidding the
only evidence the check receives, so it resolves to «the caps stays» by default and silences a
Critical-tier line. Its fixture needed the channel written into the first line of the input to
be decidable at all, which is proof enough.

**G.1, numerals.** «Not flagged, at any value» lets any exact count escape by inversion —
«Нашли расхождений сорок восемь» has the same shape as «минут десять» and is not an
approximation. The approximation lives in the ROUNDNESS the speaker chose, not in the word
order.

**What this changes about the method, not just the batch.** Every one of the four failed the
same way: the carve-out was written from the case that motivated it and not tested against the
cases the rule already protects. The golden set caught two of them, the corpus's own frozen
controls caught a third, and a measurement caught the fourth by showing its premise was false.
A carve-out is a change to a rule's SCOPE, so the acceptance test is not «does it fix my case»
but «which existing finding does it lose» — and that test has to run before the wording is
argued about.

## The trap, stated so it is not walked into

«Write livelier» is not a rule, and it lands hardest on the two registers the author has
ruled permanently off limits: dry academic and regulatory prose, which are *supposed* to be
flat, and translated or non-native Russian. A brake must be able to leave a deliberately
flat text alone. If it cannot, it is worse than the flattening it was meant to cure.

Kept deliberately apart: the **sentence-length variety** candidate in
`roadmap-v3-formative.md` is about detecting flatness in someone else's text. This file is
about not causing it in ours. The second does not need the first to be solved, and solving
the first would not solve the second.
