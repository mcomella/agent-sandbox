FROM debian:trixie-slim

RUN apt-get update && apt-get install -y \
    curl git build-essential \
    tmux \
    unzip jq \
    ripgrep \
    vim \
    npm \
    openjdk-21-jdk \
    openjdk-25-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code
