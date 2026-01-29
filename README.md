# 🚀 My Neovim Configuration

A modern, well-structured Neovim configuration built with LazyVim and custom plugins.

## ✨ Features

- **🎨 Tokyo Night** colorscheme
- **🚀 Live Development Server** with Vite integration
- **📝 Command Palette** with 1000+ predefined commands
- **🌲 Enhanced Tree-sitter** for all file types
- **⚡ Fast LSP** setup with Mason
- **🖥️ Terminal Integration** with toggleterm
- **📊 Dashboard** with custom ASCII art

## 📁 Structure
```
neovim-config/
├── lua/config/ # Core configuration
├── lua/plugins/ # Plugin configurations
├── lua/custom/ # Custom modules
└── lua/user/ # User preferences
```

## 🚀 Quick Start

1. Backup your current Neovim config:
   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
   ```
Clone this repository:

```bash
git clone https://github.com/yourusername/neovim-config.git ~/.config/nvim
```
Start Neovim and wait for plugins to install:

## ⌨️ Key Mappings

*   **<leader>ls** — Start live server
*   **<leader>lx** — Stop live server
*   **<leader>cp** — Command palette
*   **<leader>np** — New project
*   **<leader>z** — Toggle terminal
*   **gd** — Go to definition
*   **K** — Hover documentation

## 🛠️ Customization

*   **⚙️ Basic Settings** — Edit `lua/config/options.lua`
*   **🧩 Plugin Configs** — Modify `lua/plugins/` for configurations
*   **➕ Add New Plugins** — Add them in `lua/plugins/` directory

## 📦 Included Plugins

*   **🌲 LazyVim** — Starter configuration
*   **🌃 Tokyo Night** — Colorscheme
*   **🌳 nvim-treesitter** — Syntax
*   **🛠️ mason.nvim** — LSP manager
*   **🖥️ toggleterm.nvim** — Terminal
*   **🔧 Custom modules** — For project management
