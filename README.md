# Claude Code Devcontainer

Quick setup for a Claude Code enabled devcontainer in any project.

## Prerequisites

- VS Code with the Dev Containers extension
- WSL2 (on Windows)
- `jq` (`apt install jq`)

## Install

```bash
./install.sh <target-dir>
```

Then open the target folder in VS Code and reopen in the devcontainer when prompted.

## Options

| Variable | Description |
|---|---|
| `USE_REMOTE_ENV=1` | Include `remoteEnv` block for `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` |
| `USE_DOTENV=1` | Include `.env` file support |
| `DEVCONTAINER_NAME=name` | Set container name (defaults to target directory basename) |

Self-install: `./install.sh .`

---

> For contributors and Claude Code users: see [CLAUDE.md](./CLAUDE.md) for architecture details and full configuration reference.
