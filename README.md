# agent-sandbox
Run your AI agent in a sandboxed environment.

Each execution runs in its own container based on a shared docker image. Some directories are shared between all containers (the container's home directory contains Claude configuration files) and some are shared only with the specific repository you're working in (repository files, known dependency caches).

### Motivation & threat model
I'm concerned that AI may naively (i.e. not maliciously):
1. Read personal information and exfiltrate it
1. Modify my system configuration

Claude provides some sandbox tools: it automatically sandboxes itself to the current directory and provides [an optional wrapper that uses OS sandboxing](https://code.claude.com/docs/en/sandbox-environments#sandbox-runtime). However, these may have bugs due to the rapid pace of AI development and that macOS' `sandbox-exec` is deprecated so I prefer to use a 3rd party tool.

I'd probably use [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) to solve this problem but it doesn't support Intel Macs.

**Out of scope:** malicious intent such as a malicious AI, prompt injection, AI installation and execution of untrusted code, or malicious use of [Claude Remote Control](https://code.claude.com/docs/en/remote-control).

## Prerequisites
- Docker Desktop (or equivalent)

## Usage
First, **build** the shared docker image:
```sh
docker build -t agent-sandbox .
```

Then **run** the agent on a given directory:
```sh
./bin/run-agent.sh <path>
```

To discourage use in unintended directories, the script expects the given path to be a descendent of `~/dev` and to end in `-agent`. To ignore this check, add `--ignore-path-check`.

The program uses the following directories:
- `~/.config/agent-sandbox`: Claude and other configuration files
- `~/.cache/agent-sandbox`: cached files that can be regenerated, e.g. application dependencies

### Recommended usage
Keep a **separate clone** of your repository, either in GitHub or on your drive, so you can verify unintended changes (e.g. the AI rewrites the history of the `main` branch).

To **develop using multiple agents**, either:
1. Use Claude's agents view
2. Add the `--shell` flag, start `tmux`, and start each parallel Claude using a separate worktree: `claude -w <worktree-name>`

To provide **configuration files** in the sandbox such as a `.gitconfig` so your agent commits with your username, add them to `~/.config/agent-sandbox/home`, laying it out like a home directory.

## Limitations
- To update Claude Code, you need to rebuild the Docker container
- Voice mode doesn't work. I record my voice in https://claude.ai and copy-paste it back

## Potential improvements
- Limit network access to further mitigate exfiltration risk
- Use built-in agent sandboxing to add defense in depth

Docker pain points:
- Reduced performance, uses a lot of memory: 2.6 GiB just started with one Claude attached
- Unknown shell integration so it's difficult to configure certain commands guest->host (copy-paste, voice)
