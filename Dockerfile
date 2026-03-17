# https://mcr.microsoft.com/en-us/artifact/mar/devcontainers/base
FROM mcr.microsoft.com/devcontainers/base:ubuntu24.04@sha256:4bcb1b466771b1ba1ea110e2a27daea2f6093f9527fb75ee59703ec89b5561cb

# Install extra packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  # For Claude Code's sandboxing
  bubblewrap \
  socat \
  # Common and useful tools for development and debugging
  jq \
  # Basic networking \
  iputils-ping \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

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

# Setting ~/.local/bin for Claude Code and other user-installed tools
ENV PATH="/home/vscode/.local/bin:$PATH"

# Install specific version of Claude Code
ARG CLAUDE_CODE_VERSION=2.1.76
RUN curl -fsSL https://claude.ai/install.sh | bash -s ${CLAUDE_CODE_VERSION}

# Install Superpowers plugin
RUN claude plugin marketplace add anthropics/claude-plugins-official && \
  claude plugin install superpowers@claude-plugins-official

# Install Plannotator plugin
RUN curl -fsSL https://plannotator.ai/install.sh | bash && \
  claude plugin marketplace add backnotprop/plannotator && \
  claude plugin install plannotator@plannotator
