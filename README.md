# agent-sandbox
Run your AI agent in a sandboxed environment.

Each execution of the script runs in its own container based on a shared docker image. Some directories are shared between all containers (container user home directory = Claude configuration files) and some are shared only with the specific repository you're working in (repository files, known dependency caches).

### Motivation & threat model
I'd probably use Docker Sandboxes but it doesn't support Intel Macs. I don't trust agents because they're effectively executing untrusted code. I'm skeptical of their self sandboxing. I'm more concerned about accidental bugs rather than a malicious adversary. As such, I isolate the rest of my filesystem to prevent the agent from accidentally deleting or exfiltrating personal information.

I'm considering **increasing the scope** of the threat model due to the possibility of malicious adversaries from capabilities such as prompt injection and the feature to continue queries from your phone.

## Prerequisites
- Docker Desktop (or equivalent)

## Usage
First, **build** the docker image:
```sh
docker build -t agent-sandbox .
```

Then **run** the agent on a given directory:
```sh
./bin/run-agent.sh <path>
```

## Recommended directory layout for worktrees
To allow agents to work in `git worktree`s, I recommend the following directory layout:
```
~/dev/dev-repo/         # your own checkout — the agent never touches this
~/dev/dev-repo-agent/
  bare/                 # bare clone, canonical repo for the agent's worktrees
  feature-x/            # a worktree of bare/, checked out for the agent
  feature-y/
```

The benefit of keeping a separate clone of the repository outside the sandbox (and regularly pulling changes into it) is that if the agent accidentally damages the .git metadata, it won't completely destroy the repository state.

## Potential improvements
- Limit network access to further mitigate exfiltration risk
- Use built-in agent sandboxing to add defense in depth

Docker pain points:
- Reduced performance, uses a lot of memory: 2.6 GiB just started with one Claude attached. I remember seeing 6+ at one point.
- Unknown shell integration so it's difficult to configure certain commands guest->host (copy-paste, voice)
