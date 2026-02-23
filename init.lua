-- ── Plugins (packer) ─────────────────────────────────────────────────────────
require("packer").startup(function(use)
	use("wbthomason/packer.nvim") -- packer manages itself
	use("shaunsingh/nord.nvim") -- colorscheme
	use("neovim/nvim-lspconfig") -- LSP configs for built-in client
	use("nvimtools/none-ls.nvim") -- formatters/linters via LSP interface
	use("MunifTanjim/prettier.nvim") -- prettier integration
	use("zbirenbaum/copilot.lua") -- GitHub Copilot
	use("numToStr/Comment.nvim") -- toggle comments with gc/gcc
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }) -- syntax highlighting
	use({ "nvim-telescope/telescope.nvim", tag = "0.1.8", requires = { "nvim-lua/plenary.nvim" } }) -- fuzzy finder
	use({ "nvim-lualine/lualine.nvim", requires = { "nvim-tree/nvim-web-devicons" } }) -- statusline
	use("nvim-tree/nvim-web-devicons") -- file icons
	use({ "akinsho/bufferline.nvim", tag = "*" }) -- tab-style buffer bar
	use({ "akinsho/toggleterm.nvim", tag = "*" }) -- floating terminal
	use({ "ojroques/nvim-osc52" }) -- OSC52 clipboard (remote copy)
	use({ -- autocompletion engine + sources
		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
	})
end)

-- ── General options ──────────────────────────────────────────────────────────
vim.g.mapleader = " " -- space as leader key
vim.g.maplocalleader = " "
vim.opt.number = true -- absolute line numbers
vim.opt.relativenumber = false
vim.opt.cursorline = true -- highlight current line
vim.opt.mouse = "a" -- enable mouse in all modes
vim.opt.clipboard = "" -- don't auto-sync with system clipboard
vim.opt.tabstop = 2 -- 2-space tabs
vim.opt.shiftwidth = 2
vim.opt.expandtab = true -- spaces instead of tabs
vim.opt.scrolloff = 8 -- keep 8 lines visible above/below cursor
vim.opt.ignorecase = true -- case-insensitive search...
vim.opt.smartcase = true -- ...unless query has uppercase
vim.opt.hlsearch = true -- highlight search matches
vim.opt.incsearch = true -- show matches as you type
vim.opt.undofile = true  -- persist undo history across sessions
vim.opt.swapfile = false -- disable swap files (undofile covers crash recovery)
vim.opt.termguicolors = true -- 24-bit color
vim.opt.wrap = false -- no line wrapping
vim.opt.shada = "'1000,<50,s10,h" -- remember 1000 marks, 50 register lines
vim.opt.updatetime = 100 -- faster CursorHold events (ms)
vim.opt.textwidth = 0 -- don't hard-wrap text
vim.o.pumblend = 40 -- popup menu transparency (%)

-- ── Keymaps ──────────────────────────────────────────────────────────────────
-- copy to system clipboard with <leader>c
vim.api.nvim_set_keymap("v", "<leader>c", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>c", '"+y', { noremap = true, silent = true })

-- buffer navigation via bufferline
vim.keymap.set("n", "gt", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "gT", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })

-- toggle floating terminal
vim.keymap.set("n", "<leader>t", "<cmd>1ToggleTerm direction=float<CR>", { noremap = true, silent = true })

-- diagnostics
vim.keymap.set("n", "<leader>e", function()
	vim.diagnostic.open_float({ border = "rounded" })
end, { desc = "Show diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })

-- LSP hover and signature help
vim.keymap.set("n", "K", function()
	vim.lsp.buf.hover({ border = "rounded", max_width = 80 })
end, { desc = "Hover docs" })
vim.keymap.set("i", "<C-k>", function()
	vim.lsp.buf.signature_help({ border = "rounded", max_width = 80 })
end, { desc = "Signature help" })

-- ── Autocmds ─────────────────────────────────────────────────────────────────
-- restore cursor position from shada on file open
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		local line = vim.fn.line
		if line("'\"") > 0 and line("'\"") <= line("$") then
			vim.cmd('normal! g`"')
		end
	end,
})

-- format on save for supported filetypes (via LSP)
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.py", "*.js", "*.jsx", "*.ts", "*.tsx", "*.css", "*.json", "*.md", "*.yaml", "*.lua" },
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

-- <Esc> closes terminal windows
vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "*",
	callback = function()
		local opts = { noremap = true, silent = true, buffer = 0 }
		vim.keymap.set("t", "<Esc>", function()
			vim.api.nvim_command("close")
		end, opts)
	end,
})

-- auto-reload files changed outside of nvim
vim.api.nvim_create_autocmd({ "CursorHold", "FocusGained", "BufEnter" }, {
	pattern = "*",
	command = "checktime",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
	pattern = "*",
	command = "echohl WarningMsg | echo 'File changed on disk. Reloading...' | echohl None | edit!",
})

-- disable auto-comment continuation on new lines
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	command = "setlocal formatoptions-=cro",
})

-- enable line wrap in floating windows (overrides global wrap=false)
vim.api.nvim_create_autocmd("WinEnter", {
	callback = function()
		if vim.api.nvim_win_get_config(0).relative ~= "" then
			vim.wo.wrap = true
		end
	end,
})

-- force redraw on resize/window events
local function handle_resize()
	vim.schedule(function()
		vim.cmd("mode")
		vim.cmd("redraw!")
	end)
end

vim.api.nvim_create_autocmd({ "VimResized", "VimEnter", "WinEnter" }, {
	callback = handle_resize,
})

-- ── Colorscheme ──────────────────────────────────────────────────────────────
vim.cmd([[colorscheme nord]])
vim.api.nvim_set_hl(0, "@comment", { fg = "#93A0BA" })        -- brighter comment color
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#3B4252" })     -- float background (nord1)
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#000000", bg = "#3B4252" }) -- float border (black)


-- ── Formatters (none-ls) ─────────────────────────────────────────────────────
local null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.black, -- python
		null_ls.builtins.formatting.prettier, -- js/ts/css/json/md/yaml
		null_ls.builtins.formatting.stylua, -- lua
	},
})

require("prettier").setup({
	bin = "prettier",
	filetypes = { "*" },
})

-- ── LSP ──────────────────────────────────────────────────────────────────────
local lspconfig = require("lspconfig")

lspconfig.pyright.setup({})

-- tsserver was renamed to ts_ls in newer lspconfig
if lspconfig.ts_ls then
	lspconfig.ts_ls.setup({})
else
	lspconfig.tsserver.setup({})
end

-- ── Treesitter ───────────────────────────────────────────────────────────────
require("nvim-treesitter.configs").setup({
	ensure_installed = { "lua", "python", "javascript", "typescript" },
	highlight = { enable = true },
})

-- ── Copilot ──────────────────────────────────────────────────────────────────
require("copilot").setup({
	filetypes = { ["*"] = true }, -- enable for all filetypes
	suggestion = {
		auto_trigger = true,
		keymap = {
			accept = "<C-Space>",
			accept_word = "<C-f>",
			accept_line = "<C-l>",
			next = "<C-j>",
			prev = "<C-b>",
		},
	},
})

-- ── Completion (nvim-cmp) ────────────────────────────────────────────────────
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}, {
		{ name = "buffer" },
	}),
})

-- search (/) completion from buffer
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = { { name = "buffer" } },
})

-- command (:) completion from path + cmdline
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

-- ── Bufferline ───────────────────────────────────────────────────────────────
require("bufferline").setup({
	options = {
		show_buffer_close_icons = false,
		show_close_icon = false,
		separator_style = "thin",
	},
})

-- ── Toggleterm ───────────────────────────────────────────────────────────────
require("toggleterm").setup({
	open_mapping = [[<C-t>]], -- Ctrl-T also opens terminal
	direction = "float",
})

-- ── Telescope ────────────────────────────────────────────────────────────────
local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")

vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Live Grep" })

telescope.setup({
	defaults = {
		file_ignore_patterns = { "node_modules", ".git", "build", "dist", "%.jpg", "%.jpeg", "%.png" },
		mappings = {
			i = { ["<esc>"] = actions.close }, -- single Esc closes telescope
		},
		layout_config = {
			prompt_position = "top",
			horizontal = {
				preview_width = function(_, cols, _)
					return math.floor(cols * 0.66)
				end,
				height = 0.98,
				width = 0.98,
			},
			vertical = {
				preview_height = 0.5,
				height = 0.98,
				width = 0.98,
			},
		},
		sorting_strategy = "ascending", -- results top-to-bottom
	},
})

-- ── Lualine ──────────────────────────────────────────────────────────────────
require("lualine").setup({
	options = { theme = "nord" },
})

-- ── OSC52 clipboard ──────────────────────────────────────────────────────────
require("osc52").setup({
	max_length = 0, -- no limit
	silent = true,
	trim = true,
})
