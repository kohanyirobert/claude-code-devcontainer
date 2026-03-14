# Makes sure that the command history is saved after each command to survice devcontainer rebuilds
echo 'export PROMPT_COMMAND="history -a;${PROMPT_COMMAND}"' >> /home/vscode/.bashrc

# Create a stable wrapper for the VS Code remote CLI that resolves to the host VS Code window (the commit-hash path changes on updates)
REMOTE_CODE=$(ls /home/vscode/.vscode-server/bin/*/bin/remote-cli/code 2>/dev/null | head -1)
if [ -n "$REMOTE_CODE" ]; then
    sudo ln -sf "$REMOTE_CODE" /usr/local/bin/code
fi
