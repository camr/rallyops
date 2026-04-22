# Contributing to RallyOps App

Thank you for contributing to the RallyOps app! This document provides guidelines for contributing to the project.

## Commit Message Format

This repository follows the [Conventional Commits](https://www.conventionalcommits.org/) specification. All commit messages should be structured as follows:

```
<type>: <description>

[optional body]

[optional footer(s)]
```

### Commit Types

- **feat**: A new feature
- **fix**: A bug fix
- **chore**: Routine tasks, maintenance, or minor changes
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **docs**: Documentation only changes
- **test**: Adding or correcting tests
- **style**: Changes that don't affect code meaning (formatting, whitespace, etc.)

### Examples

```
feat: add dark mode support
fix: prevent crash when deleting completed habits
chore: update SwiftUI dependencies
docs: add architecture documentation
refactor: simplify date helper methods
test: add unit tests for CoreValue model
```

### Automatic Normalization

A git hook automatically normalizes commit messages written in plain imperative mood:

- `Add new feature` → `feat: new feature`
- `Fix bug in calendar` → `fix: bug in calendar`
- `Update documentation` → `chore: documentation`
- `Remove old config` → `chore: old config`
- `Improve search results` → `feat: search results`
- `Rename helper method` → `refactor: helper method`
- `Bump version to 2.0` → `chore: version to 2.0`

The hook recognizes common prefixes (Add, Create, Implement, Improve, Enhance, Support, Enable, Fix, Update, Modify, Change, Remove, Delete, Clean/Cleanup, Disable, Bump, Refactor, Rename, Move, Migrate, Document, Test, Style) and converts them to the appropriate conventional commit type. It also skips fixup, squash, and amend commits.

### Setup

To install hooks and the commit message template:

```bash
scripts/setup-hooks.sh
git config commit.template .gitmessage
```

## Development Guidelines

- Write clear, descriptive commit messages
- Keep commits focused and atomic
- Test your changes before committing
- Follow Swift and SwiftUI best practices
- Maintain consistency with existing code style

## Questions?

If you have questions about contributing, please open an issue for discussion.
