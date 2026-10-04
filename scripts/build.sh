#!/bin/bash
# -----------------------------------------------------------------------------
# ROS 2 Build & Clean Helper Script - Pixi & Native Dynamic Edition
# -----------------------------------------------------------------------------

# Colors for feedback
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 1. Dynamically Determine Workspace Root
if [ -d "$(pwd)/src" ]; then
    WS_ROOT="$(pwd)"
elif git rev-parse --show-toplevel &>/dev/null && [ -d "$(git rev-parse --show-toplevel)/src" ]; then
    WS_ROOT="$(git rev-parse --show-toplevel)"
elif [ -n "$WORKSPACE_DIR" ] && [ -d "$WORKSPACE_DIR/src" ]; then
    WS_ROOT="$WORKSPACE_DIR"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
    if [ -d "$SCRIPT_DIR/../src" ]; then
        WS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    else
        echo -e "${RED}❌ Error: Workspace root with 'src' directory not found!${NC}"
        return 1 2>/dev/null || exit 1
    fi
fi

cd "$WS_ROOT"

# 2. Determine Colcon command (native colcon or through pixi)
if command -v colcon &>/dev/null; then
    COLCON_CMD="colcon"
elif command -v pixi &>/dev/null; then
    COLCON_CMD="pixi run colcon"
elif [ -f "$HOME/.pixi/bin/pixi" ]; then
    COLCON_CMD="$HOME/.pixi/bin/pixi run colcon"
else
    echo -e "${RED}❌ Error: Neither colcon nor pixi found!${NC}"
    return 1 2>/dev/null || exit 1
fi

# Function to collect and expand packages (supports wildcards like gizmo_*)
collect_packages() {
    local input_pkgs=("$@")
    local expanded_pkgs=""
    local all_pkgs=""
    
    # Pre-fetch all available packages if needed for expansion
    if [[ "$*" == *[*?]* ]]; then
        while IFS= read -r -d '' pxml; do
            all_pkgs+="$(basename "$(dirname "$pxml")") "
        done < <(find "$WS_ROOT/src" -maxdepth 5 -name "package.xml" -print0 2>/dev/null)
    fi

    for p in "${input_pkgs[@]}"; do
        if [[ "$p" == --* ]]; then
            break
        fi
        
        # If the argument contains a wildcard, try to match it against all_pkgs
        if [[ "$p" == *[*?]* ]]; then
            local matches=""
            for available in $all_pkgs; do
                if [[ $available == $p ]]; then
                    matches="$matches $available"
                fi
            done
            
            if [ -n "$matches" ]; then
                expanded_pkgs="$expanded_pkgs $matches"
            else
                expanded_pkgs="$expanded_pkgs $p"
            fi
        else
            expanded_pkgs="$expanded_pkgs $p"
        fi
    done
    echo "$expanded_pkgs"
}

# 3. Logic for "clean" (Supports: clean all OR clean <pkg1> <pkg2> ...)
if [ "$1" == "clean" ]; then
    shift
    
    if [ "$1" == "all" ] || [ -z "$1" ]; then
        echo -e "${YELLOW}🧹 [CLEAN ALL] Wiping build, install, and log folders...${NC}"
        rm -rf build/ install/ log/
        echo -e "${GREEN}✅ Workspace is 100% clean.${NC}"
    else
        PKGS=$(collect_packages "$@")
        for PKG_NAME in $PKGS; do
            echo -e "🪒 [CLEAN PARTIAL] Removing build/install artifacts for: ${CYAN}$PKG_NAME${NC}"
            rm -rf "build/$PKG_NAME" "install/$PKG_NAME"
            rm -rf "install/share/$PKG_NAME" 2>/dev/null || true
            echo -e "${GREEN}✅ Package [$PKG_NAME] cleaned.${NC}"
        done
    fi
    return 0 2>/dev/null || exit 0

# 4. Enhanced Debug Mode (Supports: debug OR debug <pkg1> <pkg2> ...)
elif [ "$1" == "debug" ]; then
    shift 
    
    if [ -z "$1" ] || [[ "$1" == --* ]]; then
        echo -e "${YELLOW}🐞 [DEBUG ALL] Building entire workspace with Debug symbols...${NC}"
        $COLCON_CMD build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "$@"
    else
        PKGS=$(collect_packages "$@")
        while [ -n "$1" ] && [[ "$1" != --* ]]; do shift; done
        
        echo -e "🐞 [DEBUG PARTIAL] Building packages [${CYAN}$PKGS${NC}] with Debug symbols..."
        $COLCON_CMD build --packages-select $PKGS --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "$@"
    fi
    echo -e "${GREEN}✅ Debug build complete.${NC}"

# 5. Build Logic
elif [ "$1" == "all" ]; then
    echo -e "${YELLOW}🏗️  [FORCE ALL] Rebuilding every package (Release)...${NC}"
    shift
    $COLCON_CMD build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "$@"

elif [ -n "$1" ] && [[ "$1" != --* ]]; then
    PKGS=$(collect_packages "$@")
    while [ -n "$1" ] && [[ "$1" != --* ]]; do shift; done
    
    echo -e "📦 [PARTIAL BUILD] Targeting packages: ${CYAN}$PKGS${NC}..."
    $COLCON_CMD build --packages-select $PKGS --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "$@"

else
    echo -e "${YELLOW}⚡ [INCREMENTAL BUILD] Building changes...${NC}"
    $COLCON_CMD build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "$@"
fi

# 6. Re-source the workspace
if [ -f "$WS_ROOT/install/setup.bash" ]; then
    source "$WS_ROOT/install/setup.bash"
    echo -e "${GREEN}🔄 Environment re-sourced.${NC}"
fi

