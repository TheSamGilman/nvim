# Neovim Configuration

## Overview

Leader key is `<Space>`. Tabs are 2 spaces. Format-on-save is enabled for Python, JS/TS, CSS, JSON, Markdown, YAML, and Lua via LSP. Files changed on disk are auto-reloaded. Cursor position is restored on file open via shada. The Nord colorscheme is used throughout.

## Keybindings

| Key | Mode | Action |
|-----|------|--------|
| `<Space>c` | n/v | Copy to system clipboard |
| `<Space>f` | n | Telescope find files |
| `<Space>g` | n | Telescope live grep |
| `<Space>t` | n | Toggle floating terminal |
| `<Space>e` | n | Show diagnostic float for current line |
| `gt` / `gT` | n | Next / previous buffer tab |
| `]d` / `[d` | n | Jump to next / previous diagnostic |
| `K` | n | Hover docs (type info, documentation) |
| `<C-t>` | n | Toggle floating terminal |
| `<Esc>` | — | Close telescope picker / close terminal window |
| `<Tab>` / `<S-Tab>` | i | Cycle through completion menu |
| `<CR>` | i | Confirm completion selection |
| `<C-n>` / `<C-p>` | i | Next / prev completion item |
| `<C-k>` | i | Signature help (show function parameters) |
| `<C-Space>` | i | Accept Copilot suggestion |
| `<C-f>` | i | Accept Copilot word |
| `<C-l>` | i | Accept Copilot line |
| `<C-j>` / `<C-b>` | i | Next / prev Copilot suggestion |
| `gc` / `gcc` | n | Toggle comment (motion / current line) |

## Plugins

| Plugin | Description |
|--------|-------------|
| [packer.nvim](https://github.com/wbthomason/packer.nvim) | Plugin manager (manages itself) |
| [nord.nvim](https://github.com/shaunsingh/nord.nvim) | Nord colorscheme with brighter comment highlight |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP client configs; pyright (Python) + ts_ls (JS/TS) |
| [none-ls.nvim](https://github.com/nvimtools/none-ls.nvim) | Injects formatters as LSP sources (black, prettier, stylua) |
| [prettier.nvim](https://github.com/MunifTanjim/prettier.nvim) | Prettier formatter wrapper |
| [copilot.lua](https://github.com/zbirenbaum/copilot.lua) | GitHub Copilot with auto-trigger suggestions |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim) | Toggle comments with gc/gcc motions |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting for lua, python, js, ts |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy file finder and live grep (uses plenary.nvim) |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline with Nord theme (uses nvim-web-devicons) |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | File type icons used by lualine and bufferline |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Tab-style buffer bar at the top |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Floating terminal toggled with `<Space>t` or `<C-t>` |
| [nvim-osc52](https://github.com/ojroques/nvim-osc52) | OSC52 clipboard support for remote/SSH sessions |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Autocompletion engine with sources: cmp-nvim-lsp, cmp-buffer, cmp-path, cmp-cmdline, LuaSnip, cmp_luasnip |

## LSP Setup

Uses lspconfig directly. Servers: pyright for Python, ts_ls (or tsserver on older lspconfig) for JS/TS. Hover docs and signature help are bound to `K` and `<C-k>` with rounded float styling. Diagnostics are shown via `<Space>e` and navigated with `]d`/`[d`. Float windows use a distinct background and wrap long lines.

## Installation

### 1. Build dependencies

```bash
# Linux
sudo apt install cmake make gcc unzip gettext curl git

# macOS
xcode-select --install && brew install cmake make unzip gettext curl git
```

### 2. Neovim from source

```bash
git clone https://github.com/neovim/neovim.git
cd neovim && make CMAKE_BUILD_TYPE=Release && sudo make install
```

### 3. Toolchains (version managers)

**Rust** (needed for stylua):
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

**Node.js** (needed for pyright, typescript-language-server, prettier, copilot):
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
nvm install --lts
```

**Python** (needed for black):
```bash
curl https://pyenv.run | bash
pyenv install 3 && pyenv global 3
```

### 4. CLI tools

```bash
# Linux
sudo apt install ripgrep fd-find   # or: cargo install ripgrep fd-find

# macOS
brew install ripgrep fd
```

### 5. LSP servers & formatters

```bash
npm install -g pyright typescript typescript-language-server prettier
pip install black
cargo install stylua
```

### 6. Packer bootstrap

```bash
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

### 7. First launch

Open nvim, run `:PackerSync`, restart, then `:TSUpdate`.
