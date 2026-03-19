# rosseca/tap

Rosseca Homebrew tap.

## Available Formulae

### `aisi`

[AISI](https://github.com/rosseca/aisi) (AI Shared Intelligence) is a CLI tool for managing AI agent resources (rules, skills, subagents, hooks, MCP configs) from a shared repository to multiple editors: Cursor, Kilo Code, Junie, and Windsurf.

### `codemagic-watch`

[Codemagic Watch](https://github.com/akmarinov/codemagic-watch) is a small CLI that polls the Codemagic Builds API, prints status transitions, emits JSON events, and exits with meaningful codes for automation.

## Installation

```bash
# Add the tap
brew tap rosseca/tap

# Install aisi
brew install aisi

# Install codemagic-watch
brew install codemagic-watch

# Or install directly without tapping
brew install rosseca/tap/aisi
brew install rosseca/tap/codemagic-watch
```

## Updating

```bash
# Update all packages from this tap
brew upgrade rosseca/tap/aisi
brew upgrade rosseca/tap/codemagic-watch

# Or update everything
brew upgrade
```

## Uninstallation

```bash
brew uninstall aisi
brew uninstall codemagic-watch
brew untap rosseca/tap
```

## License

See individual project repositories for license information.
