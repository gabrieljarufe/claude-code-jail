FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Sistema base
RUN apt-get update && apt-get install -y \
    curl wget git vim nano build-essential \
    ca-certificates gnupg lsb-release \
    openssh-client zsh htop unzip \
    && rm -rf /var/lib/apt/lists/*

# Node.js (obrigatório pro Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Docker CLI (para o Claude Code controlar o DinD)
RUN curl -fsSL https://get.docker.com | sh

# Claude Code
RUN npm install -g @anthropic-ai/claude-code

WORKDIR /workspace

# Agent instructions baked into the image (outside the /workspace volume)
COPY CLAUDE.md /opt/claude-jail/CLAUDE.md
COPY github-setup.sh /opt/claude-jail/github-setup.sh
RUN chmod +x /opt/claude-jail/github-setup.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
