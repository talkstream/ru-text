# v3.0 — the formative direction

Everything ru-text does today is a refusal. Stop-words, канцелярит, anti-patterns, the
seventeen tells of machine-written prose: the corpus is a list of what not to write, and it
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

## The flattening — moved out of this file, and up a release

The author's 30.07.2026 observation — that texts come out too short and too chopped after a
ru-check pass — lived here for one day. On 31.07.2026 he raised it to a **2.1** release:
too many removals, and they do not always leave the text any skeleton at all.

It belongs in its own file, `roadmap-v2.1-conservation.md`, and the reason is the same one
that makes this file a major version. A brake on rules the corpus already has needs no new
kind of rule, no new dimension and no new score, so it is minor. The formative half needs
all three.

Read that file before adding anything here: if 2.1 lands a conservation principle, several
candidates below change shape, and the **sentence-length variety** candidate in particular
must be read against it. That candidate is about detecting flatness in someone else's text;
2.1 is about not causing it in ours. They are not the same problem and neither solves the
other.

## What is NOT in this direction

The seventeen tells of machine-written prose, the stop-word catalogue, the anti-patterns, the
typography and the punctuation. Those are v2.0 and they are finished. This file is only for
the half that says what to do.
