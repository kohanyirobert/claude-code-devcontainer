# About

Quick setup for a Claude Code enabled devcontainers.

- Install `apt install jq`
- Run `./install.sh <target-dir>` then
  - Run `./install.sh .` to self install
  - Set `USE_REMOTE_ENV=1 ./install.sh` to include `remoteEnv` block
  - Set `USE_DOTENV=1 ./install.sh` to include `.env`
  - They can be combined
- Use in VS Code
  - Connect to WSL
  - Open target folder
