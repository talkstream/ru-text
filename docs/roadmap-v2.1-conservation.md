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

## The trap, stated so it is not walked into

«Write livelier» is not a rule, and it lands hardest on the two registers the author has
ruled permanently off limits: dry academic and regulatory prose, which are *supposed* to be
flat, and translated or non-native Russian. A brake must be able to leave a deliberately
flat text alone. If it cannot, it is worse than the flattening it was meant to cure.

Kept deliberately apart: the **sentence-length variety** candidate in
`roadmap-v3-formative.md` is about detecting flatness in someone else's text. This file is
about not causing it in ours. The second does not need the first to be solved, and solving
the first would not solve the second.
