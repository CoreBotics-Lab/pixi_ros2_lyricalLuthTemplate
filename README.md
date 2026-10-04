# Pixi ROS 2 Lyrical Workspace Template 🤖⚡

A reproducible, fully isolated **ROS 2 Lyrical + RoboStack** development template powered by [Pixi](https://pixi.sh).

Provides Docker-like workspace isolation with **100% native hardware access** (NVIDIA/AMD GPUs, displays, USB sensors, serial devices) and zero host system pollution.

---

## ✨ Features

- **Isolated & Reproducible**: Powered by RoboStack Lyrical and Pixi. No `sudo apt` or `rosdep` pollution on the host.
- **Dynamic Fast Builds**: Custom build scripts supporting single packages, wildcards (`build my_pkg*`), and clean builds (`clean all`).
- **Tab Autocompletion**: Package name completion works automatically inside `pixi shell` (`build <TAB>`).
- **VS Code Pre-configured**:
  - C++ IntelliSense via **Clangd** with automatic compile command indexing.
  - Python diagnostics via **Pyrefly** & Pylance.
  - Interactive Debugging for C++ nodes, Python nodes, and GDB attach.
  - Recommended extensions bundle in `.vscode/extensions.json`.
- **Wayland / Multi-Monitor Fix**: Built-in environment activation variables that eliminate Qt/OGRE viewport flickering in RViz2 and Gazebo Harmonic on high-DPI and fractional scaling setups.

---

## 🚀 Quick Start

### 1. Prerequisites
Install [Pixi](https://pixi.sh) on your host machine (if not already installed):
```bash
curl -fsSL https://pixi.sh/install.sh | bash
```

### 2. Setup Workspace
Clone or download this template, then initialize the environment:
```bash
cd pixi_ros2_lyricalLuthTemplate
pixi install
```

### 3. Enter Environment & Build
```bash
pixi shell
```
Inside the shell, your ROS 2 environment is active and custom helper commands are ready:
```bash
# Build all packages with symlink-install
build

# Build specific packages (supports TAB completion)
build <package_name>

# Build with debug symbols
debug <package_name>

# Clean build artifacts
clean all
```

---

## 📁 Workspace Structure

```text
├── .vscode/               # Pre-configured tasks, launch profiles, and recommended extensions
├── scripts/               # Build and autocompletion helper scripts
├── src/                   # Place your ROS 2 packages here
├── pixi.toml              # Pixi environment & dependencies specification
├── pixi.lock              # Reproducible dependency lockfile
└── pyrefly.toml           # Python type-checking configuration
```
