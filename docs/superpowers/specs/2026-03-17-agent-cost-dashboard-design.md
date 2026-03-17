# Agent Cost Dashboard Integration Design

**Date:** 2026-03-17
**Status:** Approved

## Summary

Integrate the [agent-cost-dashboard](https://github.com/mrexodia/agent-cost-dashboard) into the devcontainer so it auto-starts on every container start and is accessible via VS Code port forwarding on port 8753.

## Background

`agent-cost-dashboard` is a zero-dependency Python dashboard that reads Claude Code session data from `~/.claude/projects` and displays cost/usage analytics. It runs as a local HTTP server on port 8753.

The devcontainer already mounts `~/.claude` as a persistent volume, so session data is available to the dashboard out of the box.

## Design

### Approach

**Clone at build time + `postStartCommand` auto-start.**

- Source is cloned into the image at build time (`/opt/agent-cost-dashboard`) using a shallow clone to minimize image size.
- The server starts automatically on every container start via `postStartCommand`.
- VS Code forwards port 8753 and notifies the user.

### Changes

#### `.devcontainer/Dockerfile`

Add a shallow clone after the existing plugin installs:

```dockerfile
# Install agent-cost-dashboard
RUN git clone --depth 1 https://github.com/mrexodia/agent-cost-dashboard /opt/agent-cost-dashboard
```

- Runs as `vscode` user (already set at that point in the Dockerfile)
- `--depth 1` minimizes image size
- No additional dependencies needed (pure Python stdlib)

#### `.devcontainer/devcontainer.json`

Add:

1. **Port forwarding** with VS Code notify on auto-forward:
```json
"forwardPorts": [8753],
"portsAttributes": {
  "8753": {
    "label": "Agent Cost Dashboard",
    "onAutoForward": "notify"
  }
}
```

2. **`postStartCommand`** to auto-start the dashboard on every container start:
```json
"postStartCommand": "nohup python3 /opt/agent-cost-dashboard/cost_dashboard.py --host 0.0.0.0 > /tmp/cost-dashboard.log 2>&1 &"
```

- `--host 0.0.0.0` makes it reachable via VS Code port forwarding
- `nohup` + `&` runs it as a non-blocking background process
- Logs available at `/tmp/cost-dashboard.log`

### Data Flow

```
~/.claude/projects (persistent volume)
        ↓
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
