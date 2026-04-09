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

## Code of Conduct

Be respectful. We're here to make Russian text better, not to argue about it.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
