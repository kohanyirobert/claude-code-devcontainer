# Agent Cost Dashboard Integration Design

**Date:** 2026-03-17
**Status:** Approved

## Summary

Integrate the [agent-cost-dashboard](https://github.com/mrexodia/agent-cost-dashboard) into the devcontainer so it auto-starts on every container start and is accessible via VS Code port forwarding on port 8753.

## Background

`agent-cost-dashboard` is a zero-dependency Python dashboard that reads Claude Code session data from `~/.claude/projects` and displays cost/usage analytics. It runs as a local HTTP server on port 8753.

The devcontainer mounts a persistent volume at `/claude` (the container path), and the Dockerfile creates a symlink so that `~/.claude` points to `/claude/.claude`. The dashboard reads from `~/.claude/projects`, which resolves through that symlink. Session data is therefore available to the dashboard as long as the volume is mounted.

## Environment

- **Python**: Available in the base devcontainer image (`mcr.microsoft.com/devcontainers/base:ubuntu24.04`); no explicit install needed.
- **Git**: Included in the base devcontainer image; no explicit install needed.
- **Dependencies**: None — the dashboard uses only Python's standard library.

## Design

### Approach

**Clone at build time (as root) + `postStartCommand` auto-start.**

- Source is cloned into `/opt/agent-cost-dashboard` as root during image build, using a shallow clone to minimize clone size.
- The server starts automatically on every container start via `postStartCommand` (distinct from `postCreateCommand`, which runs only on first create).
- VS Code forwards port 8753 and notifies the user.

### Changes

#### `.devcontainer/Dockerfile`

Add a shallow clone **before** the `USER vscode` directive, so it runs as root and can write to `/opt/`:

```dockerfile
# Install agent-cost-dashboard
RUN git clone --depth 1 https://github.com/mrexodia/agent-cost-dashboard /opt/agent-cost-dashboard

# Switch to the vscode user ...
USER vscode
```

- Must appear before `USER vscode`
- `--depth 1` reduces clone size (no history)
- `/opt/agent-cost-dashboard` is readable by all users

#### `.devcontainer/devcontainer.json`

Add two new top-level fields alongside the existing `postCreateCommand`:

1. **`postStartCommand`** — fires on every container start (including restarts). On a full rebuild, `postCreateCommand` (existing `setup.sh`) runs first, then `postStartCommand`. Unlike `postCreateCommand`, `postStartCommand` also fires on plain restarts without a rebuild:

```json
"postStartCommand": "nohup python3 /opt/agent-cost-dashboard/cost_dashboard.py --host 0.0.0.0 > /tmp/cost-dashboard.log 2>&1 &"
```

- `--host 0.0.0.0` makes it reachable via VS Code port forwarding
- `nohup` + `&` ensures `postStartCommand` completes immediately and the server runs in the background; the container process namespace is destroyed on stop/restart, so no stale process persists across restarts
- Logs available at `/tmp/cost-dashboard.log` (ephemeral — wiped on each container stop/restart; contains only the log from the most recent start)

2. **Port forwarding** with VS Code notify on auto-forward:

```json
"forwardPorts": [8753],
"portsAttributes": {
  "8753": {
    "label": "Agent Cost Dashboard",
    "onAutoForward": "notify"
  }
}
```

### Data Flow

```
/claude/.claude/projects (persistent volume)
        ↓ (via ~/.claude symlink)
cost_dashboard.py reads session JSON files
        ↓
HTTP server on 0.0.0.0:8753
        ↓
VS Code port forwarding → browser
```

## Out of Scope

- Pinning to a specific git commit (latest HEAD at build time is acceptable)
- Process management / PID files (simple nohup is sufficient)
- Automatic browser open on container start

## Testing

After rebuilding the devcontainer:
1. VS Code should show a notification that port 8753 is forwarded
2. Opening the forwarded URL should show the cost dashboard
3. Dashboard should display data from `~/.claude/projects`
4. Log file at `/tmp/cost-dashboard.log` should show the server started successfully
