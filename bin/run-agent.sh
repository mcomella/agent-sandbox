#!/usr/bin/env bash
# Runs an agent in a sandbox at the given path.

usage() {
    echo "usage: run-agent.sh [--override-path-check] <repo-path>"
    echo ""
    echo "  --override-path-check  skip the ~/dev and -agent suffix requirements"
}

OVERRIDE_PATH_CHECK=0
REPO_PATH_ARG=""
for arg in "$@"; do
    case "$arg" in
        --override-path-check)
            OVERRIDE_PATH_CHECK=1
            ;;
        *)
            REPO_PATH_ARG="$arg"
            ;;
    esac
done

if [ -z "$REPO_PATH_ARG" ]; then
    usage
    exit 1
fi

if [ ! -e "$REPO_PATH_ARG" ]; then
    echo "error: '$REPO_PATH_ARG' is not a valid, existing path"
    usage
    exit 1
fi

set -euo pipefail

REPO_PATH="$(realpath "$REPO_PATH_ARG")"
REPO_NAME="$(basename "$REPO_PATH")"

if [ "$OVERRIDE_PATH_CHECK" -eq 0 ]; then
    case "$REPO_PATH" in
        "$HOME/dev"/*) ;;
        *)
            echo "error: path must start with ~/dev"
            usage
            exit 1
            ;;
    esac

    case "$REPO_NAME" in
        *-agent) ;;
        *)
            echo "error: final directory must end with '-agent'"
            usage
            exit 1
            ;;
    esac
fi

CONFIG_ROOT="$HOME/.config/agent-sandbox"

# Ideally, we'd just mount ~/.claude and ~/.claude.json. However, the latter
# is written via write and rename so it's written atomically. We can't mount
# the tmp file used because it has a random suffix so we have to mount the
# entire home directory instead.
CLAUDE_HOME="$CONFIG_ROOT/home"
mkdir -p "$CLAUDE_HOME"

# Mount known caches separately from the home directory so it's easier to purge.
CACHE_ROOT="$HOME/.cache/agent-sandbox/$REPO_NAME"
mkdir -p \
    "$CACHE_ROOT/cargo" \
    "$CACHE_ROOT/gradle" \
    "$CACHE_ROOT/konan" \
    "$CACHE_ROOT/npm" \
    "$CACHE_ROOT/openjfx" \
    "$CACHE_ROOT/pip"

docker run -it --rm \
    --name "claude-${REPO_NAME}" \
    --cap-drop ALL \
    --security-opt no-new-privileges \
    --read-only --tmpfs /tmp \
    -v "${REPO_PATH}:/workspace:rw" \
    -v "${CLAUDE_HOME}:/root:rw" \
    -v "$CACHE_ROOT/cargo:/root/.cargo/registry" \
    -v "$CACHE_ROOT/gradle:/root/.gradle" \
    -v "$CACHE_ROOT/konan:/root/.konan" \
    -v "$CACHE_ROOT/npm:/root/.npm" \
    -v "$CACHE_ROOT/openjfx:/root/.openjfx" \
    -v "$CACHE_ROOT/pip:/root/.cache/pip" \
    agent-sandbox
