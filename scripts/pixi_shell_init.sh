# -----------------------------------------------------------------------------
# CoreBotics ROS 2 Workspace Helper (Isolated inside Pixi environment)
# -----------------------------------------------------------------------------

if [ -n "$PIXI_PROJECT_ROOT" ]; then
    WS_DIR="$PIXI_PROJECT_ROOT"
elif [ -n "$CONDA_PREFIX" ]; then
    WS_DIR="$(cd "$CONDA_PREFIX/../../.." && pwd)"
else
    WS_DIR="$(pwd)"
fi

# Dynamic GPU Vendor Detection (Portability across NVIDIA, AMD, and Intel)
if command -v nvidia-smi &>/dev/null || (command -v lspci &>/dev/null && lspci 2>/dev/null | grep -qi "nvidia"); then
    export __GLX_VENDOR_LIBRARY_NAME="nvidia"
    export __NV_PRIME_RENDER_OFFLOAD="1"
fi

# Functions available ONLY inside pixi shell
build() {
    source "$WS_DIR/scripts/build.sh" "$@"
}

clean() {
    source "$WS_DIR/scripts/build.sh" clean "$@"
}

debug() {
    source "$WS_DIR/scripts/build.sh" debug "$@"
}

_build_completions()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local ws_path=""

    if [ -d "$WS_DIR/src" ]; then
        ws_path="$WS_DIR/src"
    elif [ -d "$(pwd)/src" ]; then
        ws_path="$(pwd)/src"
    else
        return 0
    fi

    local pkgs=""
    while IFS= read -r -d '' pxml; do
        pkgs+="$(basename "$(dirname "$pxml")") "
    done < <(find "$ws_path" -maxdepth 5 -name "package.xml" -print0 2>/dev/null)
    
    local special_args="all clean debug"
    local opts="$pkgs $special_args"
    
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
}

complete -F _build_completions build
complete -F _build_completions clean
complete -F _build_completions debug

# Source workspace install overlay
if [ -f "$WS_DIR/install/setup.bash" ]; then
    source "$WS_DIR/install/setup.bash"
fi

