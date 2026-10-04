#!/bin/bash
# -----------------------------------------------------------------------------
# Environment Activation Helper for ROS 2 Workspaces
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"

# Define build/clean/debug wrapper functions
build() {
    source "$SCRIPT_DIR/build.sh" "$@"
}

clean() {
    source "$SCRIPT_DIR/build.sh" clean "$@"
}

debug() {
    source "$SCRIPT_DIR/build.sh" debug "$@"
}

export -f build clean debug 2>/dev/null || true

# Source tab completions
if [ -f "$SCRIPT_DIR/build_completion.sh" ]; then
    source "$SCRIPT_DIR/build_completion.sh"
fi

# Source workspace install overlay if available
if [ -d "$SCRIPT_DIR/../install" ] && [ -f "$SCRIPT_DIR/../install/setup.bash" ]; then
    source "$SCRIPT_DIR/../install/setup.bash"
fi

