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

Reported per file: n, p90, mean adjacent step, standard deviation, CV and the quartiles.

THE HEADLINE IS p90, and CV is NOT a verdict metric. That reversal is measured, not stylistic.
CV — sd/mean — was chosen here because it is scale-free, and scale-freedom is exactly the
blindness: chopping a sentence in half divides sd and mean in the same proportion, so their
ratio does not move. Dose-response run of 09.08.2026 over tools' own splitter on a graded
fixture (5 real texts, 4 rungs, long sentences chopped at the nearest comma): absolute spread
fell on 5 texts of 5, and CV was monotone on ZERO of them — rising on two. p90 was strictly
monotone on 5 of 5. The fixture and the numbers live in
~/Projects/_scratch/ru-text-flattening/dose/.

This matters beyond a column heading: two «not reproduced» verdicts were reported from median
CV while three blind judges voted 24 to 4 for the unchecked text. The metric could not have
shown otherwise. Read the delta inside a pair, never the absolute between texts.
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

# The em dash as an intonation mark. Counted because the blind panel found the check cutting
# parallel rows of them to zero against a rule whose own budget is one to two per paragraph:
# 4 -> 2 and 3 -> 0, measured. A hyphen inside a compound is not one of these; the pattern
# requires whitespace on the left, which a compound never has.
DASH_RE = re.compile(r'(?<=[\s\u00a0])[\u2014\u2013](?=[\s\u00a0])')

# Intensifiers and hedges — the voice-carrying words. «Честно» and «реально» inside a
# commitment and an admission of fault were the ONLY substantive deletions in the whole
# experiment, and every one was called damage by a judge who did not know which text was
# which. Closed list on purpose: this is a counter, not a rule, and a counter that guesses
# is worse than none.
INTENS_RE = re.compile(
    r'(?<![А-Яа-яЁё-])('
    r'честно|реально|правда|прямо|вообще|совсем|очень|крайне|весьма|довольно|'
    r'просто|буквально|разумеется|конечно|пожалуй|кажется|похоже|скорее|вроде|'
    r'наверное|видимо|как\s?бы|всё\s?же|всё-таки|как\s?раз|именно'
    r')(?![А-Яа-яЁё-])', re.IGNORECASE)
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
    p90: int = 0
    step: float = 0.0


@dataclass
class Shape:
    path: str
    words: int
    length: Stats
    subord: Stats
    commas: Stats
    para: Stats
    dashes: int = 0
    intens: int = 0


def stats(values: List[int]) -> Stats:
    if not values:
        return Stats(0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0.0)
    # The step is computed on the ORIGINAL order: it is the rhythm of alternation, and
    # sorting would destroy exactly what it measures.
    step = (sum(abs(values[i] - values[i + 1]) for i in range(len(values) - 1))
            / (len(values) - 1)) if len(values) > 1 else 0.0
    v = sorted(values)
    n = len(v)
    mean = sum(v) / n
    # Population standard deviation: the text IS the population, not a sample of one.
    sd = math.sqrt(sum((x - mean) ** 2 for x in v) / n)

    def q(f: float) -> int:
        return v[min(n - 1, int(f * n))]

    return Stats(n, mean, sd, (sd / mean if mean else 0.0), q(0.25), q(0.5), q(0.75),
                 q(0.90), step)


class Unreadable(Exception):
    """The file is not UTF-8 text. Raised so a batch loses one file, not the rest."""


def measure(path: str) -> Shape:
    try:
        text = io.open(path, encoding='utf-8').read()
    except (UnicodeDecodeError, OSError) as e:
        raise Unreadable('%s: %s' % (path, e))
    sents = sentences(text)
    lengths = [len(WORD.findall(s)) for s in sents]
    subord = [len(SUBORD_RE.findall(s)) for s in sents]
    commas = [s.count(',') for s in sents]
    # Paragraphs are split from the STRIPPED text. Splitting the raw text and then calling
    # sentences() — which strips again, per paragraph — let a code block or a table count as
    # a paragraph on one path and vanish on the other; the two paths disagreed by 37 % on a
    # document with fenced blocks. The instrument has to walk one text, not two.
    stripped = strip_markup(text)
    paras = [len(sentences(p)) for p in re.split(r'\n\s*\n', stripped) if sentences(p)]
    # Dashes and intensifiers are the axes the blind panel of 01.08.2026 discriminated on,
    # 24 votes to 4, while this file returned +0.0 % and the roadmap wrote «not confirmed».
    # A ruler that has no marks where the effect lives reports the effect as absent.
    dashes = len(DASH_RE.findall(stripped))
    intens = len(INTENS_RE.findall(stripped))
    return Shape(path, sum(lengths), stats(lengths), stats(subord), stats(commas), stats(paras),
                 dashes, intens)


def report(m: Shape) -> None:
    print('\n%s' % m.path)
    print('  слов %d, предложений %d' % (m.words, m.length.n))
    rows = [('длина предложения', m.length), ('подчинение на предложение', m.subord),
            ('запятых на предложение', m.commas), ('предложений в абзаце', m.para)]
    print('  %-28s %6s %7s %7s %7s   %s'
          % ('', 'p90', 'перепад', 'ст.откл', 'CV*', 'кварт. 25/50/75'))
    for name, s in rows:
        print('  %-28s %6d %7.2f %7.2f %7.3f   %d / %d / %d'
              % (name, s.p90, s.step, s.sd, s.cv, s.q1, s.med, s.q3))
    print('  * CV слеп к рубке — не использовать для вердиктов, см. докстринг.')


def compare(before: str, after: str) -> None:
    a, b = measure(before), measure(after)
    report(a)
    report(b)

    def pct(x: float, y: float) -> float:
        return ((y - x) / x * 100) if x else float('nan')

    print('\nДЕЛЬТА (после − до), в процентах от «до»:')
    print('  %-28s %10s %10s %10s %10s' % ('', 'p90', 'перепад', 'ст.откл', 'CV*'))
    for name, key in [('длина предложения', 'length'), ('подчинение', 'subord'),
                      ('запятые', 'commas'), ('абзац', 'para')]:
        sa: Stats = getattr(a, key)
        sb: Stats = getattr(b, key)
        print('  %-28s %+9.1f%% %+9.1f%% %+9.1f%% %+9.1f%%'
              % (name, pct(sa.p90, sb.p90), pct(sa.step, sb.step),
                 pct(sa.sd, sb.sd), pct(sa.cv, sb.cv)))
    print('  %-28s %+9.1f%%' % ('слов всего', pct(a.words, b.words)))
    print("""
Как читать. Головная метрика — p90 длины предложения: где кончается длинное дыхание текста.
Вторичные — средний перепад соседних длин (ритм чередования) и абсолютное ст.откл. Гипотеза
уплощения предсказывает, что все три падают. Смотреть дельту внутри пары, никогда абсолют
между текстами.

CV в вердиктах НЕ участвует. Замер на dose/ 09.08.2026: при механической рубке предложений
разброс упал на 5 текстах из 5, а CV не сдвинулся ни на одном и на двух вырос. Причина
арифметическая: рубка делит и ст.откл, и среднее примерно поровну, а CV — их частное.""")


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
        # One unreadable file must not take the batch down with it: the point of passing
        # several paths is to compare them, and a traceback on the second loses the rest.
        bad = 0
        for p in args:
            try:
                report(measure(p))
            except Unreadable as e:
                sys.stderr.write('measure-prose-shape: пропущен — %s\n' % e)
                bad += 1
        if bad and bad == len(args):
            sys.exit(1)
