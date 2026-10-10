# rosseca/tap

Rosseca Homebrew tap.

## Kilo Proxy

[Kilo Proxy](https://github.com/rosseca/kilo-proxy) connects supported editors and agents to your organization's Kilo credits.

| Package | macOS Intel / Apple Silicon | Linux x64 / ARM64 |
| --- | --- | --- |
| `kilo-proxy` cask | Desktop app | — |
| `kilo-proxy-desktop` formula | — | Desktop app, built from source |
| `kilo-proxy-headless` formula | CLI and server | CLI and server |

```sh
brew tap rosseca/tap

# macOS desktop
brew install --cask rosseca/tap/kilo-proxy

# Linux desktop (requires a graphical session)
brew install rosseca/tap/kilo-proxy-desktop
kilo-proxy

# macOS or Linux, without a graphical interface
brew install rosseca/tap/kilo-proxy-headless
kilo-proxy-headless login kilo
kilo-proxy-headless serve
```

The Linux desktop formula compiles the release's exact Git commit against Homebrew's graphical libraries. It needs the system's graphics driver and an X11 or Wayland session with D-Bus. It installs a desktop entry under Homebrew's `share/applications`; desktop environments may need that directory in `XDG_DATA_DIRS` to show it in the applications menu. The headless package uses the official release binaries and needs no graphical session.

The macOS cask uses the official app unchanged. Homebrew does not add Developer ID signing or notarization, and this tap does not disable quarantine or Gatekeeper. See the [upstream installation guide](https://github.com/rosseca/kilo-proxy#readme) for the current signing status and first launch instructions.

Homebrew installation does not start the proxy, install a background service, sign in, or alter your shell/editor profiles. The headless profile is separate from the desktop profile by default. Install the optional terminal wrappers explicitly with `kilo-proxy-headless commands install`.

### Updates

```sh
brew update
brew upgrade --cask rosseca/tap/kilo-proxy       # macOS desktop
brew upgrade rosseca/tap/kilo-proxy-desktop     # Linux desktop
brew upgrade rosseca/tap/kilo-proxy-headless    # macOS / Linux headless
```

Quit the desktop app before upgrading it. If you installed the headless package's own service or terminal wrappers, those commands store the executable's versioned path. Stop and uninstall that service before upgrading, then refresh the wrappers and service afterward using the same `--config-dir`, if you set one:

```sh
kilo-proxy-headless service stop
kilo-proxy-headless service uninstall
brew upgrade rosseca/tap/kilo-proxy-headless
kilo-proxy-headless commands install
kilo-proxy-headless service install
kilo-proxy-headless service start
```

Only run the service commands if you installed that service. This preserves the saved profile and chats. Do not run another supervisor against the same profile.

### Automatic release synchronization

Kilo Proxy's Release workflow calls this tap's reusable [Update Kilo Proxy workflow](https://github.com/rosseca/homebrew-tap/actions/workflows/update-kilo-proxy.yml) after successfully publishing a stable release. There is no polling schedule. The tap workflow can also be run manually as a recovery step. Drafts and prereleases are excluded, and the updater refuses downgrades or changes to an already published version's identity or hashes.

For each new version, it downloads all ten release packages and `SHA256SUMS.txt` without authentication, verifies each file's size and GitHub SHA-256 digest, and checks every package against the manifest. It then updates the two formulae and macOS cask. Before publishing the tap update, CI installs and tests the candidate packages on real macOS Intel / Apple Silicon and Linux x64 / ARM64 runners; desktop self-tests use temporary profiles and synthetic upstreams.

The `GITHUB_TOKEN` stays read-only. Only the final publish job receives `KILO_PROXY_TAP_DEPLOY_KEY`, a dedicated SSH deploy key with write access to this tap alone; no cross-repository personal token is needed. Register this key in the tap and save its private half as an Actions secret in `rosseca/kilo-proxy`; that caller passes the secret explicitly to the reusable workflow. Also save the secret in `rosseca/homebrew-tap` to enable manual recovery runs. Allow deploy keys to bypass only the pull-request review rule. Keep deletion and force-push protections in a separate ruleset without a deploy-key exception. A missing publishing key fails explicitly rather than falling back to another credential.

Updates are serialized and refuse to publish over a changed tap base. Every primary checkout explicitly selects `rosseca/homebrew-tap`, and Homebrew tests register that exact tested workspace rather than relying on the calling repository's identity. A failed download, integrity check, install, or test leaves the previous tap version available. The unchanged-release check makes repeated calls a no-op.

To test or run the updater locally:

```sh
python3 -m unittest discover -s scripts -p 'test_*.py' -v
python3 scripts/update_kilo_proxy.py --check  # offline: check committed definitions
python3 scripts/update_kilo_proxy.py          # fetch, verify and prepare latest stable release
```

## Available Formulae

### `aisi`

[AISI](https://github.com/rosseca/aisi) (AI Shared Intelligence) is a CLI tool for managing AI agent resources (rules, skills, subagents, hooks, MCP configs) from a shared repository to multiple editors: Cursor, Kilo Code, Junie, and Windsurf.

## Installation

```bash
# Add the tap
brew tap rosseca/tap

# Install aisi
brew install aisi

# Or install directly without tapping
brew install rosseca/tap/aisi
```

## Updating

```bash
# Update all packages from this tap
brew upgrade rosseca/tap/aisi

# Or update everything
brew upgrade
```

## Uninstallation

```bash
brew uninstall aisi
brew untap rosseca/tap
```

## License

See individual project repositories for license information.
