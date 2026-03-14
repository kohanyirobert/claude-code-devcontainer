# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a devcontainer setup repository for Claude Code. It provides a standardized development environment that can be installed into any target directory to enable Claude Code development within VS Code devcontainers.

## Architecture

The repository contains a minimal but complete devcontainer configuration:

- **Dockerfile**: Ubuntu 24.04 base with Claude Code pre-installed, persistent volume mounts for command history, Claude config, and GitHub CLI
- **devcontainer.json**: Container configuration with GitHub CLI feature and volume mounts for persistence
- **install.sh**: Installation script that copies devcontainer files to target directories with optional environment variable support
- **setup.sh**: Post-creation script that sets up command history persistence and VS Code CLI wrapper
- **remote-env.json**: Optional environment variable configuration for ANTHROPIC_BASE_URL and ANTHROPIC_AUTH_TOKEN

## Installation Commands

Install devcontainer to a target directory:
```bash
./install.sh <target-dir>
```

Install with environment variables support:
```bash
USE_REMOTE_ENV=1 ./install.sh <target-dir>
```

Install with .env file support:
```bash
USE_DOTENV=1 ./install.sh <target-dir>
```

Install with a custom devcontainer name (defaults to target directory basename):
```bash
DEVCONTAINER_NAME=my-project ./install.sh <target-dir>
```

Combine both options:
```bash
USE_REMOTE_ENV=1 USE_DOTENV=1 ./install.sh <target-dir>
```

Self-install in current directory:
```bash
./install.sh .
```

## Development Environment

The devcontainer includes:
- Claude Code v1.0.58 pre-installed in ~/.local/bin
- GitHub CLI for repository operations
- jq for JSON processing
- Persistent volumes for command history, Claude configuration, and GitHub CLI config
- VS Code CLI wrapper at /usr/local/bin/code

## Environment Configuration

Set up authentication by either:
1. Using environment variables (with USE_REMOTE_ENV=1): ANTHROPIC_BASE_URL, ANTHROPIC_AUTH_TOKEN
2. Using .env file (with USE_DOTENV=1): Copy and modify .env.sample

## Usage

After installation:
1. Open target folder in VS Code
2. Connect to WSL if on Windows
3. VS Code will prompt to reopen in devcontainer
4. Claude Code will be available in the terminal