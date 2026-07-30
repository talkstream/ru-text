#!/usr/bin/env python3
"""measure-prose-shape.py — the shape of a Russian text, in numbers a person can re-derive.

    tools/measure-prose-shape.py FILE [FILE ...]
    tools/measure-prose-shape.py --compare BEFORE AFTER

Exists to settle one question with evidence instead of opinion: does a ru-check pass leave
a text shorter, or does it leave it FLATTER? (docs/roadmap-v2.1-conservation.md). The
load-bearing number is not the mean sentence length — it is the variance. A text that got
shorter with its variance intact got edited; a text whose variance collapsed got pressed
into one shape, and that shape is itself a machine tell (AD-6).

Deliberately dumb. No parser, no model, no dependency. Every number here can be checked by
hand on the same file, because a measurement that will be used to justify SUPPRESSING
correct findings has to be one nobody can argue with. The cost of that choice is stated
honestly under each metric's limits below.

What it counts, and what each count is worth:

  sentences        Split on . ! ? … followed by space+capital or end. Abbreviations with a
                   full stop («т. д.», «т. е.», «и. о.») and initials («А. С. Пушкин») are
                   protected by an explicit list — without it every «т. д.» invents a
                   sentence boundary and the variance is measured on debris.
                   LIMIT: a full stop inside a quotation still splits. Rare in prose, and it
                   biases BOTH sides of a before/after comparison the same way.

  words            Runs of letters, digits and inner hyphens. «UX-тексты» is one word,
                   «2 289» is two. LIMIT: none that matters — both sides count alike.

  subordination    Occurrences of subordinating conjunctions and relative pronouns from a
                   closed list, per sentence. This is a PROXY for clause structure, not a
                   parse: it cannot see a subordinate clause joined without a conjunction,
                   and it counts «что» in «что-то» — hence the word-boundary match and the
                   pronoun-form list. Directionally sound, absolutely wrong. Use the delta,
                   never the absolute.

  commas/sentence  The cheapest structural signal there is: a sentence with no comma has one
                   clause and no aside. Falls when a text is chopped, and cannot be gamed by
                   a rule that only shortens words.

Reported per file: n, mean, standard deviation, coefficient of variation, and the quartiles.
CV — sd/mean — is what to watch across a before/after pair, because it is scale-free: a text
can lose 30% of its words and hold its CV, and that is the outcome that falsifies the
flattening hypothesis.
"""

import io
import math
import re
import sys
from dataclasses import dataclass
from typing import List

# A full stop that belongs to an abbreviation is not a sentence boundary. This list is the
# difference between measuring prose and measuring debris; it is short on purpose and every
# entry is one that appears in this project's own Russian.
ABBREV = ['т. д', 'т. п', 'т. е', 'т. к', 'и. о', 'см', 'напр', 'стр', 'рис', 'табл',
          'гг', 'вв', 'руб', 'коп', 'млн', 'млрд', 'тыс', 'проф', 'акад', 'англ', 'нем']

# Subordinating conjunctions and relative pronouns. Closed list, matched at word boundaries.
# «что» is included knowing it over-counts (что-то, что-нибудь are excluded by the boundary
# plus the hyphen check); the delta between two texts absorbs a constant bias, the absolute
# number does not, so only the delta is ever reported as meaningful.
SUBORD = ['что', 'чтобы', 'который', 'которая', 'которое', 'которые', 'которых', 'которым',
          'которого', 'которой', 'если', 'когда', 'пока', 'потому', 'поскольку', 'так как',
          'хотя', 'несмотря', 'чем', 'будто', 'словно', 'ибо', 'дабы', 'кто', 'где', 'куда',
          'откуда', 'зачем', 'почему', 'сколько', 'насколько', 'пусть', 'раз']

WORD = re.compile(r'[А-Яа-яЁёA-Za-z0-9]+(?:-[А-Яа-яЁёA-Za-z0-9]+)*')
SUBORD_RE = re.compile(r'(?<![\w-])(?:' + '|'.join(SUBORD) + r')(?![\w-])', re.IGNORECASE)


def strip_markup(text):
    """Remove what is not prose: fenced code, inline code, links' targets, tables, headings.

    A README measured with its code blocks in it is measuring the code. Table rows are
    dropped whole rather than unwrapped — a table is not prose and its rows would register
    as a run of very short 'sentences', which is exactly the signal under study.
    """
    text = re.sub(r'```.*?```', ' ', text, flags=re.S)
    text = re.sub(r'`[^`]*`', ' ', text)
    text = re.sub(r'!?\[([^\]]*)\]\([^)]*\)', r'\1', text)   # keep link text, drop the URL
    text = re.sub(r'^\s*\|.*$', ' ', text, flags=re.M)       # table rows
    text = re.sub(r'^\s*#{1,6}\s.*$', ' ', text, flags=re.M)  # headings
    text = re.sub(r'^\s*[-*+]\s+', '', text, flags=re.M)     # list bullets, keep the item
    text = re.sub(r'[*_>]', '', text)
    return text


def sentences(text):
    """Split into sentences, protecting abbreviations and initials with a placeholder pass."""
    text = strip_markup(text)
    guard = '\x00'
    for a in ABBREV:
        text = text.replace(a + '.', a + guard)
    # An initial: a single capital letter followed by a full stop. «А. С. Пушкин».
    text = re.sub(r'(?<![\w])([А-ЯЁA-Z])\.', r'\1' + guard, text)
    parts = re.split(r'(?<=[.!?…])\s+(?=[«"(\[]?[А-ЯЁA-Z0-9])', text)
    out = []
    for p in parts:
        p = p.replace(guard, '.').strip()
        if len(WORD.findall(p)) >= 2:   # a fragment of one word is a caption, not a sentence
            out.append(p)
    return out


@dataclass
class Stats:
    n: int
    mean: float
    sd: float
    cv: float
    q1: int
    med: int
    q3: int


@dataclass
class Shape:
    path: str
    words: int
    length: Stats
    subord: Stats
    commas: Stats
    para: Stats


def stats(values: List[int]) -> Stats:
    if not values:
        return Stats(0, 0.0, 0.0, 0.0, 0, 0, 0)
    v = sorted(values)
    n = len(v)
    mean = sum(v) / n
    # Population standard deviation: the text IS the population, not a sample of one.
    sd = math.sqrt(sum((x - mean) ** 2 for x in v) / n)

    def q(f: float) -> int:
        return v[min(n - 1, int(f * n))]

    return Stats(n, mean, sd, (sd / mean if mean else 0.0), q(0.25), q(0.5), q(0.75))


def measure(path: str) -> Shape:
    text = io.open(path, encoding='utf-8').read()
    sents = sentences(text)
    lengths = [len(WORD.findall(s)) for s in sents]
    subord = [len(SUBORD_RE.findall(s)) for s in sents]
    commas = [s.count(',') for s in sents]
    paras = [len(sentences(p)) for p in re.split(r'\n\s*\n', text) if sentences(p)]
    return Shape(path, sum(lengths), stats(lengths), stats(subord), stats(commas), stats(paras))


def report(m: Shape) -> None:
    print('\n%s' % m.path)
    print('  слов %d, предложений %d' % (m.words, m.length.n))
    rows = [('длина предложения', m.length), ('подчинение на предложение', m.subord),
            ('запятых на предложение', m.commas), ('предложений в абзаце', m.para)]
    print('  %-28s %7s %7s %7s   %s' % ('', 'среднее', 'ст.откл', 'CV', 'кварт. 25/50/75'))
    for name, s in rows:
        print('  %-28s %7.2f %7.2f %7.3f   %d / %d / %d'
              % (name, s.mean, s.sd, s.cv, s.q1, s.med, s.q3))


def compare(before: str, after: str) -> None:
    a, b = measure(before), measure(after)
    report(a)
    report(b)

    def pct(x: float, y: float) -> float:
        return ((y - x) / x * 100) if x else float('nan')

    print('\nДЕЛЬТА (после − до), в процентах от «до»:')
    print('  %-28s %10s %10s %10s' % ('', 'среднее', 'ст.откл', 'CV'))
    for name, key in [('длина предложения', 'length'), ('подчинение', 'subord'),
                      ('запятые', 'commas'), ('абзац', 'para')]:
        sa: Stats = getattr(a, key)
        sb: Stats = getattr(b, key)
        print('  %-28s %+9.1f%% %+9.1f%% %+9.1f%%'
              % (name, pct(sa.mean, sb.mean), pct(sa.sd, sb.sd), pct(sa.cv, sb.cv)))
    print('  %-28s %+9.1f%%' % ('слов всего', pct(a.words, b.words)))
    print("""
Как читать. Гипотеза уплощения (docs/roadmap-v2.1-conservation.md) предсказывает, что
CV длины предложения СУЖАЕТСЯ, а подчинение падает. Если упало только среднее, а CV устоял,
текст стал короче, но не площе — и гипотеза не подтверждается.""")


if __name__ == '__main__':
    args = sys.argv[1:]
    if not args:
        sys.stderr.write((__doc__ or '').split('\n\n')[1] + '\n')
        sys.exit(2)
    if args[0] == '--compare':
        if len(args) != 3:
            sys.stderr.write('--compare требует ровно два файла: ДО и ПОСЛЕ\n')
            sys.exit(2)
        compare(args[1], args[2])
    else:
        for p in args:
            report(measure(p))
