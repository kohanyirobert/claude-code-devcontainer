# Agent Cost Dashboard Integration Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate agent-cost-dashboard into the devcontainer so it auto-starts on every container start and is accessible on port 8753 via VS Code port forwarding.

**Architecture:** The dashboard source is shallow-cloned into `/opt/agent-cost-dashboard` during the Docker image build (as root, before `USER vscode`). On every container start, `postStartCommand` in `devcontainer.json` launches the server as a background process. VS Code is configured to forward port 8753 and notify the user.

**Tech Stack:** Dockerfile (Ubuntu 24.04 base), devcontainer.json (VS Code devcontainer spec), Python 3 (stdlib only, no pip install needed), git (available in base image).

**Spec:** `docs/superpowers/specs/2026-03-17-agent-cost-dashboard-design.md`

---

## Chunk 1: Dockerfile and devcontainer.json changes

### Task 1: Add agent-cost-dashboard clone to Dockerfile

**Files:**
- Modify: `.devcontainer/Dockerfile:13-27` (insert new RUN block before `USER vscode`)

The clone must run as root (before `USER vscode`) so it can write to `/opt/`.

Current structure around the insertion point (lines 13–27):

```dockerfile
# Set up directories and permissions to ensure command history, etc. is persistent across devcontainer rebuilds
RUN mkdir -p \
  ...

# Switch to the vscode user to ensure that subsequent commands are run with the correct permissions
USER vscode
```

- [ ] **Step 1.1: Insert the git clone RUN block**

Add the following block immediately before the `USER vscode` line (after the `RUN mkdir -p ...` block):

```dockerfile
# Install agent-cost-dashboard
RUN git clone --depth 1 https://github.com/mrexodia/agent-cost-dashboard /opt/agent-cost-dashboard
```

The Dockerfile should look like this after the edit (lines 13–30 approx):

```dockerfile
# Set up directories and permissions to ensure command history, etc. is persistent across devcontainer rebuilds
RUN mkdir -p \
  /cmdhistory \
  /claude \
  /claude/.claude \
  /home/vscode/.config/gh && \
    touch /cmdhistory/.bash_history && \
      ln -sv /cmdhistory/.bash_history /home/vscode/.bash_history && \
    echo '{}' >> /claude/.claude.json && \
      ln -sv /claude/.claude.json /home/vscode/.claude.json && \
      ln -sv /claude/.claude /home/vscode/.claude && \
  chown -R vscode:vscode /cmdhistory /claude /home/vscode/.config/gh

# Install agent-cost-dashboard
RUN git clone --depth 1 https://github.com/mrexodia/agent-cost-dashboard /opt/agent-cost-dashboard

# Switch to the vscode user to ensure that subsequent commands are run with the correct permissions
USER vscode
```

- [ ] **Step 1.2: Verify the edit**

Read `.devcontainer/Dockerfile` and confirm:
- The `RUN git clone --depth 1 ...` line is present
- It appears **before** `USER vscode`
- It appears **after** the `RUN mkdir -p ...` block

- [ ] **Step 1.3: Commit**

```bash
git add .devcontainer/Dockerfile
git commit -m "feat: install agent-cost-dashboard in devcontainer image"
```

---

### Task 2: Update devcontainer.json

**Files:**
- Modify: `.devcontainer/devcontainer.json` (add `postStartCommand`, `forwardPorts`, `portsAttributes`)

Current `devcontainer.json` (20 lines):
```json
{
  "name": "claude-code-devcontainer",
  "build": { "dockerfile": "Dockerfile" },
  "features": { ... },
  "mounts": [ ... ],
  "postCreateCommand": "bash .devcontainer/setup.sh",
  "remoteEnv": { ... }
}
```

- [ ] **Step 2.1: Add `postStartCommand`**

Add the following field after `"postCreateCommand"`:

```json
"postStartCommand": "nohup python3 /opt/agent-cost-dashboard/cost_dashboard.py --host 0.0.0.0 > /tmp/cost-dashboard.log 2>&1 &",
```

- [ ] **Step 2.2: Add `forwardPorts` and `portsAttributes`**

Add the following fields (after `postStartCommand`):

```json
"forwardPorts": [8753],
"portsAttributes": {
  "8753": {
    "label": "Agent Cost Dashboard",
    "onAutoForward": "notify"
  }
},
```

The final `devcontainer.json` should be:

```json
{
  "name": "claude-code-devcontainer",
  "build": {
    "dockerfile": "Dockerfile"
  },
  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/devcontainers/features/docker-outside-of-docker": {}
  },
  "mounts": [
    "source=devc-${localWorkspaceFolderBasename}-cmdhistory-${devcontainerId},target=/cmdhistory,type=volume",
    "source=devc-${localWorkspaceFolderBasename}-claude-${devcontainerId},target=/claude,type=volume",
    "source=devc-${localWorkspaceFolderBasename}-gh-${devcontainerId},target=/home/vscode/.config/gh,type=volume"
  ],
  "postCreateCommand": "bash .devcontainer/setup.sh",
  "postStartCommand": "nohup python3 /opt/agent-cost-dashboard/cost_dashboard.py --host 0.0.0.0 > /tmp/cost-dashboard.log 2>&1 &",
  "forwardPorts": [8753],
  "portsAttributes": {
    "8753": {
      "label": "Agent Cost Dashboard",
      "onAutoForward": "notify"
    }
  },
  "remoteEnv": {
    "ANTHROPIC_BASE_URL": "${localEnv:ANTHROPIC_BASE_URL}",
    "ANTHROPIC_AUTH_TOKEN": "${localEnv:ANTHROPIC_AUTH_TOKEN}"
  }
}
```

- [ ] **Step 2.3: Verify the edit**

Read `.devcontainer/devcontainer.json` and confirm:
- `"postStartCommand"` is present with the correct value
- `"forwardPorts": [8753]` is present
- `"portsAttributes"` block is present with label "Agent Cost Dashboard" and `"onAutoForward": "notify"`
- JSON is valid (no trailing commas on last fields, correct nesting)

- [ ] **Step 2.4: Commit**

```bash
git add .devcontainer/devcontainer.json
git commit -m "feat: auto-start agent-cost-dashboard and forward port 8753"
```

---

## Manual Verification (after devcontainer rebuild)

After rebuilding the devcontainer (VS Code: "Dev Containers: Rebuild Container"):

1. VS Code should display a notification: "Your application running on port 8753 is available."
2. Open the forwarded URL — the Agent Cost Dashboard should load in the browser.
3. If data from `~/.claude/projects` exists, it should appear in the dashboard.
4. Check startup log: `cat /tmp/cost-dashboard.log` — should show the server bound to `0.0.0.0:8753`.
