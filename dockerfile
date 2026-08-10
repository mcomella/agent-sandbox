FROM node:22-slim

# Install system tools you want Claude to have access to
RUN apt-get update && apt-get install -y \
    git \
    curl \
    grep \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Create workspace directory
RUN mkdir /workspace

WORKDIR /workspace
