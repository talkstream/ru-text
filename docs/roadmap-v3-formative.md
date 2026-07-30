# v3.0 — the formative direction

Everything ru-text does today is a refusal. Stop-words, канцелярит, anti-patterns, the
sixteen tells of machine-written prose: the corpus is a list of what not to write, and it
is good at it. v3.0 adds the other half — what a living, literate Russian sentence *does*,
stated so that a checker can point at it.

This file is the backlog for that direction. Nothing here is scheduled and nothing here is
a rule yet. It exists so the direction survives the session that named it.

## Why, and on what evidence

The author ran the formative approach on a different project — guidance written as what to
do rather than what to avoid — and reports it as an unambiguous quality win. That is one
practitioner's experience, deliberately recorded as such: it is the reason to open the
direction, not the evidence that any particular rule belongs in it. Each rule below still
has to earn its place through the same cycle every rule in this corpus went through —
evidence channels read blind to each other, a panel, a golden case, a judge.

There is a second, measured reason. On 28.07.2026 a single probe of the "positive craft"
axis — repetition of a full noun phrase where the language would use a pronoun — found a
gap on the first attempt. One probe, one hole is not a coverage estimate, but it is not
nothing either: the refusal half has been swept many times, and this half has not been
swept at all.

## What makes this hard, and why it is a separate version

A refusal is cheap to check and cheap to be wrong about. «Осуществлять» is on a list or it
is not; a false positive costs the reader one dismissed line. A formative rule is the
opposite on both counts. «Use a concrete noun instead of a category noun» has no list to
match against, its judgement depends on what the sentence is doing, and a false positive
tells a competent writer their good sentence is wrong — which is how a tool loses a user.

Three constraints follow, and they are why this is v3.0 and not a patch to v2.0:

**Every formative rule must be demonstrable on a fragment.** If the guidance cannot be
shown by quoting six words and explaining the alternative in two lines, it is taste, and
taste does not belong in a corpus that claims to be checkable. This is the same bar the
neuroslop work used to reject nine of its own candidates.

**The scoring model does not fit as it stands.** The five dimensions are built to subtract:
each anchor describes degrees of wrongness. A rule that rewards a well-chosen verb has
nowhere to land — adding points for virtue invites exactly the optimisation the five
orthogonal dimensions exist to prevent (see `scoring.md`, «Why context-aware evaluation»).
Whether the formative half scores at all, or only advises, is the first design question of
v3.0 and it precedes any rule.

**The prohibitions of v2.0 must survive intact.** Two classes are off limits by the
director's standing decision and stay off limits here: dry academic and regulatory register
as such, and translated or non-native Russian. A formative rule that reads «write livelier»
lands on both of them harder than any refusal ever did.

## Candidate areas, unranked and unearned

Recorded as directions to investigate, not as rules. Each needs the full cycle before it is
anything.

- **The concrete noun over the category noun** — «поставщик» where the text means «пекарня
  на Мясницкой». Carve-out: legal and regulatory texts name categories on purpose.
- **The verb over the copula** — «является поставщиком» → «поставляет». Adjacent to the
  existing §B entry for «является», but as a positive pattern rather than a banned word.
- **The named actor in the active voice** — not «было принято решение» but who decided.
  Partly covered by the passive-voice anti-pattern; the formative half is the naming.
- **Word order carrying emphasis** — тема before рема, the stressed element last. Well
  described in the tradition, and genuinely hard to check without misfiring on inversion
  used deliberately.
- **Register fit of the individual word** — a word from the wrong stratum inside an
  otherwise consistent sentence.
- **Sound defects of written prose** — accidental rhyme, a run of sibilants, a collision of
  identical syllables across a word boundary. Objective, demonstrable, and absent from the
  corpus.
- **Sentence-length variety** — flagged here with an explicit warning: even rhythm was
  examined and **rejected** during the neuroslop work, because it is what dry regulatory
  prose legitimately looks like. Any candidate in this area must first show how it differs
  from the rejected one, or it is the rejected one.

## The flattening — the observation that reframes this whole direction

Reported by the author on 30.07.2026, from using v2.0 on real texts: after ru-text, prose
comes out **too short and too chopped**. His words: the tool is so good at its filters that
it kills the liveliness of the language.

Take this seriously before deciding whether it is true, because the mechanism that would
produce it is already in the design, and it is not a bug in any single rule.

**Every rule in the corpus is a removal, and nothing in it has a stake in what stays.** Over
2 000 atoms, and each one names something to take out or replace with something shorter. A
checker built only of subtractions has one fixed point: the shortest text that violates
nothing. Run it hard enough and every document walks toward that point, whatever it was
before. No rule causes this. The *set* causes it, and only the set can fix it.

**The scoring model does not resist it either.** All five dimensions penalise. A text of
eight-word declaratives with no subordination, no aside and no digression violates nothing
in typography, nothing in clean language, nothing in grammar, nothing in structure and
nothing in precision — so it scores well. The rubric cannot tell «edited» from
«eviscerated», because it was never given anything to defend.

**And the result is a new tell.** This is the sharp part. Uniform short declaratives with a
flat rhythm and no subordination is exactly the register the neuroslop work already treats
as suspicious — AD-6 and the rhythm candidates exist because sameness reads as machine. An
anti-neuroslop tool that presses every text into one shape has not removed the machine
signature; it has replaced someone else's with its own. Ours would be harder to spot,
because it is made of individually correct edits.

**Measure it before building anything on it.** The observation is an impression from the
person who knows the corpus best, which makes it the best possible reason to look and still
not evidence. The measurement is cheap and the prediction is falsifiable: take a corpus of
texts before and after a ru-check pass and compare the *distributions* — sentence length
(mean and, more importantly, variance), subordinate clauses per sentence, clause depth,
paragraph length. If the flattening is real, the variance narrows and the depth drops while
the mean falls. If the variance holds, the texts got shorter without getting flatter, and
this section is wrong. Do that first; it decides whether v3.0 needs a conservation half at
all, and «the author said so» is not a substitute for it.

**If it is real, what v3.0 owes it is not another rule — it is a conservation principle.**
Sketches, none of them earned yet:

- **A protected class.** Some structures must be named as things a finding may not touch:
  subordination that carries the logic of the argument, an aside that carries voice, a long
  sentence that *is* the point rather than a failure to stop. Today nothing in the corpus
  can say «leave this».
- **A budget rather than a verdict.** A finding fires today because it is individually
  right. It could instead be suppressed when applying it would push the passage past a
  measured variety floor — the same shape as the document-level tells AD-14 and AD-15,
  which already judge a text whole rather than a fragment.
- **A check that reads the OUTPUT.** Every gate we have reads the source. None asks the
  question this section is about: does the edited text now look edited? That is a
  document-level rule about our own effect, and it is the most honest thing this direction
  could produce.

**The trap, stated so it is not walked into.** «Write livelier» is not a rule, and it lands
hardest on the two registers the director has ruled permanently off limits — dry academic
and regulatory prose, which are *supposed* to be flat, and translated Russian. A
conservation principle must be able to leave a deliberately flat text alone. If it cannot,
it is worse than the flattening it was meant to cure.

Related and deliberately kept apart: the **sentence-length variety** candidate below is
about detecting flatness in someone else's text. This section is about not *causing* it in
ours. The second does not need the first to be solved.

## What is NOT in this direction

The sixteen tells of machine-written prose, the stop-word catalogue, the anti-patterns, the
typography and the punctuation. Those are v2.0 and they are finished. This file is only for
the half that says what to do.
