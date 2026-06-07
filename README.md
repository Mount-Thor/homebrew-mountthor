# Mount Thor public Homebrew tap

Public Homebrew tap for the **Mount Thor customer CLI** (`mthr`).

## Install

```sh
brew install Mount-Thor/mountthor/mthr
```

That single command taps the formula and installs the binary. Upgrades:

```sh
brew upgrade mthr
```

## Other install channels

- **Linux or non-Homebrew macOS:** `curl -fsSL https://get.mountthor.com/install.sh | sh`
- **Windows (PowerShell):** `powershell -c "irm https://get.mountthor.com/install.ps1 | iex"`

## What `mthr` is

`mthr` is the customer-facing CLI for [Mount Thor](https://mountthor.com), a neocloud for dedicated Apple silicon Mac fleets. The CLI handles registration, API keys, sessions, customer compute context rendering, bare-metal leases, and VM workflows.

Source: <https://github.com/Mount-Thor/mount-thor/tree/main/operator-tools/mthr-cli>.

## How this tap stays current

`Formula/mthr.rb` is **auto-committed** by [`cargo-dist`](https://opensource.axo.dev/cargo-dist/) in the [`Mount-Thor/mount-thor`](https://github.com/Mount-Thor/mount-thor) release workflow whenever an `mthr-v*` tag is pushed. Do not hand-edit the formula — your changes will be overwritten on the next release.

`mthr` is the only supported Homebrew formula. Do not add a legacy full-name
formula or alias; it conflicts with the canonical `mthr` binary.
