# Contributing to ru-text

Thank you for your interest in improving Russian text quality for AI coding agents.

## How to contribute

### Report issues

Found a wrong rule, a missing pattern, or a plugin bug? [Open an issue](https://github.com/talkstream/ru-text/issues/new/choose).

### Suggest rules

New rules go to `skills/ru-text/references/addenda.md` (AD-1, AD-2, ...), not to domain reference files. Include:
- The rule itself (wrong/correct pair)
- Which domain it belongs to
- A published source if applicable

### Fix or improve existing rules

1. Fork the repository
2. Edit the relevant file in `skills/ru-text/references/`
3. Submit a pull request with a clear description

### Important conventions

- **All formulations must be original** — no verbatim quotes from any source
- **Never imply source authors endorse this plugin**
- **Never use author names in section headers** (e.g., use "Clean language principles, cf. N. Gal" not "Nora Gal's principles")
- **Comments in code: English.** Rule content: Russian where appropriate
- **Reference files over 100 lines must have a Table of Contents**
- **The plugin must follow its own typography rules** (dogfooding)

### What you don't need

- No build step, no dependencies — this is a pure Markdown plugin
- No test suite to run (though we welcome suggestions for automated rule validation)

### Commit messages

Use [conventional commits](https://www.conventionalcommits.org/):
- `fix:` for rule corrections
- `feat:` for new rules or features
- `docs:` for README/documentation changes

## What this repository accepts, and what it does not

This repository holds **the corpus — rules written as prose — and the tools that check this
repository against itself**. Every script under `tools/` reads files whose paths are hard-wired
here; none of them takes arbitrary text and hands back a corrected version.

That is a deliberate line, not an accident of history, so a pull request that crosses it will
be declined however good it is: **a deterministic corrector for arbitrary user text does not
belong here.** If you want to build one from these rules, you are free to — the corpus is MIT,
and that includes commercial use. It simply lives in your repository rather than this one.

What is very welcome: new rules and corrections to existing ones (see the rule-acceptance
criteria in `skills/ru-text/references/addenda.md`), counter-examples that keep a rule from
firing on live speech, translations, and reports of false positives with the text that caused
them.

## Code of Conduct

Be respectful. We're here to make Russian text better, not to argue about it. This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md) — please read it before participating.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
