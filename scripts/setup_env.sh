#!/bin/bash
# Automatically install isolated bash completions into the local Pixi environment
if [ -n "$CONDA_PREFIX" ] && [ -n "$PIXI_PROJECT_ROOT" ]; then
    mkdir -p "$CONDA_PREFIX/share/bash-completion/completions"
    cp -f "$PIXI_PROJECT_ROOT/scripts/pixi_shell_init.sh" "$CONDA_PREFIX/share/bash-completion/completions/build"
fi

# Automatically source built workspace overlay for both 'pixi run' and 'pixi shell'
if [ -n "$PIXI_PROJECT_ROOT" ] && [ -f "$PIXI_PROJECT_ROOT/install/setup.bash" ]; then
    source "$PIXI_PROJECT_ROOT/install/setup.bash"
fi
