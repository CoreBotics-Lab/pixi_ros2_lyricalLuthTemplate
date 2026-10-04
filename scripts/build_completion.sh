#!/bin/bash
# -----------------------------------------------------------------------------
# Bash Auto-Completion for ROS 2 Workspace (Dynamic & Space-Safe)
# -----------------------------------------------------------------------------

_build_completions()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local ws_path=""

    # 1. Dynamically locate src directory based on current folder or git root
    if [ -d "$(pwd)/src" ]; then
        ws_path="$(pwd)/src"
    elif git rev-parse --show-toplevel &>/dev/null && [ -d "$(git rev-parse --show-toplevel)/src" ]; then
        ws_path="$(git rev-parse --show-toplevel)/src"
    elif [ -n "$WORKSPACE_DIR" ] && [ -d "$WORKSPACE_DIR/src" ]; then
        ws_path="$WORKSPACE_DIR/src"
    else
        return 0
    fi

    # 2. Get list of packages safely without word-splitting on spaces
    local pkgs=""
    while IFS= read -r -d '' pxml; do
        pkgs+="$(basename "$(dirname "$pxml")") "
    done < <(find "$ws_path" -maxdepth 5 -name "package.xml" -print0 2>/dev/null)
    
    # 3. Add special arguments
    local special_args="all clean debug"
    local opts="$pkgs $special_args"
    
    # 4. Generate completion suggestions
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
}

# Bind completion function
complete -F _build_completions build
complete -F _build_completions clean
complete -F _build_completions debug
