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
| `USE_NTFY=1` | Install ntfy.sh notification hook (see below) |
| `DEVCONTAINER_NAME=name` | Set container name (defaults to target directory basename) |

### ntfy.sh notifications (`USE_NTFY=1`)

Installs a Claude Code `Notification` hook that POSTs to your self-hosted [ntfy.sh](https://ntfy.sh) instance whenever Claude asks you a question.

**Prerequisite:** ntfy.sh reachable at `host.docker.internal` on port 80 (the default for a Win11 host running ntfy.sh locally).

The hook is installed into `.claude/hooks/ntfy-notify.sh` and registered in `.claude/settings.json` in the target project. To use non-default connection settings, set these in `containerEnv` in your `devcontainer.json`:

| Variable | Default | Description |
|---|---|---|
| `NTFY_HOST` | `host.docker.internal` | ntfy.sh hostname |
| `NTFY_PORT` | `80` | ntfy.sh port |
| `NTFY_TOPIC` | `claude` | ntfy.sh topic to post to |

Self-install: `./install.sh .`

---

> For contributors and Claude Code users: see [CLAUDE.md](./CLAUDE.md) for architecture details and full configuration reference.
