# v1.9.0 — Source-priority revision: analysis & audit trail

> **Attribution & IP.** All formulations in this plugin are independently written; no content is
> quoted verbatim from any source. The works and authors referenced below are credited for study
> and as a tribute — they have not endorsed, reviewed, or approved this plugin. Priority/precedence
> notes are this project's own editorial choices by register and do **not** imply endorsement.
> IP notice: Art. 1259(5) of the Russian Civil Code; 17 USC §102(b); Berne Convention.
> «Also appears in the corpus» ≠ origin: cross-references describe where a norm is also stated,
> not who originated it.

## Goal

Clarify which published references take precedence for **general and web text**, consolidate
duplicated rules into single canonical homes, and bring attribution and wording up to date —
without weakening correctness or coverage.

## Method (the «funnel»)

Each rule was classified per-rule into three buckets, then given one verdict:

- **(A) Objective correctness** (orthography, agreement, meaning-changing punctuation, objective
  typographic mechanics). No modern alternative exists → **kept, exempt from removal**.
- **(B) Convention/register** where standards conflict (e.g. percent spacing). Modern web/editorial
  norms may take precedence over older or metrological standards for general/web text.
- **(C) Style / info-style / UX.** Modern web-oriented references lead.

Verdicts: keep · re-state attribution («cf.») · merge to a canonical home + cross-reference ·
demote to a context variant · compress wording · remove. A removal required ≥2 current sources
showing a norm is superseded, plus an adversarial check; otherwise the conservative default was to
keep. Bucket-A correctness had a standing veto against removal.

## Outcome

**No rules were removed; no correctness coverage was reduced.** The corpus is current and
comprehensive; the work was consolidation and attribution, not deletion.

- **Precedence (typography).** For general/web text the project now leads with web/screen
  typography norms (as set out in «Ководство», «Типографика и вёрстка», «Советы»); print-editorial
  handbooks («Справочник издателя и автора», справочники Розенталя) and the metrological ГОСТ apply
  for their own domains or where the web-oriented references are silent.
- **Anti-bureaucratic attribution.** The канцелярит material credits M. Ilyakhov as the modern
  info-style lead alongside the N. Gal / K. Chukovsky precursors (the rules trace to that tradition;
  the modern web operationalization is Ilyakhov's). N. Gal is kept as a cited precursor, not dropped.
- **Consolidation (no loss).** Pleonasms/tautology are canonical in `editorial-grammar.md`
  §E.1/§E.2; the dead→live канцелярит catalog in §H.2; `anti-patterns.md` keeps a short digest and
  cross-references the canonical homes (the same pattern its Typography category already used).
  Unique entries were relocated to the canonical homes before digesting, so nothing was lost. A
  stale count was fixed (READMEs said 139 anti-patterns; the canonical figure is 138).
- **Legal hardening.** Four attributed verbatim quotes were paraphrased so the project's
  «no verbatim quotes» statement holds everywhere; the addenda intro was reworded to drop
  extraction-implying framing.
- **Dogfooding.** ASCII «...» corrected to «…» in examples; minor accuracy fixes.

## Volume & model context (measured before → after)

Measured honestly; the headline is consistency, **not** a context-size reduction.

| Surface | Before (v1.8.1) | After (v1.9.0) | Δ |
|---|---|---|---|
| Always-on `SKILL.md` | 585 words | 585 words | 0 |
| On-demand corpus (9 reference files) | ~15 760 words | ~15 876 words | +0.6% |
| `anti-patterns.md` (diagnostic catalog) | 902 words / 8 260 chars | 825 / 7 363 | −8.5% / −10.9% |
| `editorial-grammar.md` (canonical home) | 1 531 words | 1 633 words | +6.7% |

The always-on per-session context is unchanged. On-demand total is flat by design: consolidation
removed true duplicates and made the diagnostic catalog leaner, but unique rules were **relocated**
to canonical homes rather than deleted — because each rule is concrete detection coverage, not
filler. The release's value is therefore consistency (no count drift), correct attribution, and a
leaner diagnostics file — not a reduction in how much context the rules consume.
