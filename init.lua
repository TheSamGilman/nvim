-- Packer
require("packer").startup(function(use)
	use({ "akinsho/bufferline.nvim", tag = "*" })
	use({ "akinsho/toggleterm.nvim", tag = "*" })
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"nvim-telescope/telescope.nvim",
		},
	})
	use("nvimtools/none-ls.nvim")
	use("MunifTanjim/prettier.nvim")
	use("neovim/nvim-lspconfig")
	use("numToStr/Comment.nvim")
	use({ "nvim-lualine/lualine.nvim", requires = { "nvim-tree/nvim-web-devicons" } })
	use({ "nvim-telescope/telescope.nvim", tag = "0.1.8", requires = { "nvim-lua/plenary.nvim" } })
	use("nvim-tree/nvim-web-devicons")
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use("MeanderingProgrammer/render-markdown.nvim")
	use("shaunsingh/nord.nvim")
	use("wbthomason/packer.nvim")
	use("zbirenbaum/copilot.lua")
	use({ "ojroques/nvim-osc52" })
end)

-- Neovim configuration
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.mouse = "a"
vim.opt.clipboard = ""
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.scrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.undofile = true
vim.opt.termguicolors = true
vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shada = "'1000,<50,s10,h"
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.updatetime = 100
vim.opt.textwidth = 0
vim.opt.autoread = true
vim.o.pumblend = 40

vim.api.nvim_set_keymap("v", "<leader>c", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>c", '"+y', { noremap = true, silent = true })

vim.keymap.set("n", "gt", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "gT", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>t", "<cmd>1ToggleTerm direction=float<CR>", { noremap = true, silent = true })

-- auto cmd for shada
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		local line = vim.fn.line
		if line("'\"") > 0 and line("'\"") <= line("$") then
			vim.cmd('normal! g`"')
		end
	end,
})

-- Protected plugin loading
local ok_null_ls, null_ls = pcall(require, "null-ls")
if ok_null_ls then
	null_ls.setup({
		sources = {
			null_ls.builtins.formatting.black,
			null_ls.builtins.formatting.prettier,
			null_ls.builtins.formatting.stylua,
		},
	})
end

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.py",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.css", "*.json", "*.md", "*.yaml", "*.ts", "*.tsx" },
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.lua",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "*",
	callback = function()
		local opts = { noremap = true, silent = true, buffer = 0 }
		vim.keymap.set("t", "<Esc>", function()
			vim.api.nvim_command("close")
		end, opts)
	end,
})

-- Poll for external file changes every 1s (fires even when nvim is unfocused)
local checktime_timer = vim.uv.new_timer()
checktime_timer:start(
	1000,
	1000,
	vim.schedule_wrap(function()
		if vim.api.nvim_get_mode().mode == "n" then
			pcall(vim.cmd, "silent! checktime")
		end
	end)
)

vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	command = "setlocal formatoptions-=cro",
})

-- Treesitter setup with protection
local ok_treesitter, treesitter = pcall(require, "nvim-treesitter.configs")
if ok_treesitter then
	treesitter.setup({
		ensure_installed = { "lua", "python", "javascript", "typescript" },
		highlight = { enable = true },
	})
end

-- LSP setup with protection
local function enable_server(name, opts)
	opts = opts or {}
	if vim.lsp and vim.lsp.config and vim.lsp.enable then
		vim.lsp.config(name, opts)
		vim.lsp.enable(name)
		return true
	else
		local ok, lspconfig = pcall(require, "lspconfig")
		if ok and lspconfig[name] and lspconfig[name].setup then
			lspconfig[name].setup(opts)
			return true
		end
	end
	return false
end

enable_server("pyright", {})
if not enable_server("ts_ls", {}) then
	enable_server("tsserver", {})
end

-- Lualine setup with protection
local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
	lualine.setup({
		options = {
			theme = "nord",
		},
	})
end

-- Render-markdown setup with protection
local ok_rm, render_markdown = pcall(require, "render-markdown")
if ok_rm then
	render_markdown.setup({
		checkbox = {
			unchecked = { icon = "󰄱 " },
			checked = { icon = "󰱒 ", scope_highlight = "@markup.strikethrough" },
			custom = {
				cancelled = { raw = "[-]", rendered = "󰜺 ", highlight = "RenderMarkdownError" },
			},
		},
	})
end

-- Prettier setup with protection
local ok_prettier, prettier = pcall(require, "prettier")
if ok_prettier then
	prettier.setup({
		bin = "prettier",
		filetypes = { "*" },
	})
end

-- Colorscheme
pcall(vim.cmd, [[colorscheme nord]])
vim.api.nvim_set_hl(0, "@comment", { fg = "#93A0BA" })

-- CMP setup with protection
local ok_cmp, cmp = pcall(require, "cmp")
local ok_luasnip, luasnip = pcall(require, "luasnip")

if ok_cmp and ok_luasnip then
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

	cmp.setup.cmdline("/", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer" },
		},
	})

	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = "path" },
		}, {
			{ name = "cmdline" },
		}),
	})
end

-- Bufferline setup with protection
local ok_bufferline, bufferline = pcall(require, "bufferline")
if ok_bufferline then
	bufferline.setup({
		options = {
			show_buffer_close_icons = false,
			show_close_icon = false,
			separator_style = "thin",
		},
	})
end

-- Toggleterm setup with protection
local ok_toggleterm, toggleterm = pcall(require, "toggleterm")
if ok_toggleterm then
	toggleterm.setup({
		open_mapping = [[<C-t>]],
		direction = "float",
	})
end

-- Telescope setup with protection
local ok_telescope, telescope = pcall(require, "telescope")
local ok_builtin, builtin = pcall(require, "telescope.builtin")

if ok_telescope and ok_builtin then
	vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Find Files" })
	vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Live Grep" })

	telescope.setup({
		defaults = {
			file_ignore_patterns = { "node_modules", ".git", "build", "dist", "%.jpg", "%.jpeg", "%.png" },
			mappings = {
				i = {
					["<esc>"] = require("telescope.actions").close,
				},
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
			sorting_strategy = "ascending",
		},
	})
end

-- OSC52 setup with protection
local ok_osc52, osc52 = pcall(require, "osc52")
if ok_osc52 then
	osc52.setup({
		max_length = 0,
		silent = true,
		trim = true,
	})
end

-- Resize handlers
local function handle_resize()
	vim.schedule(function()
		vim.cmd("mode")
		vim.cmd("redraw!")
	end)
end

vim.api.nvim_create_autocmd({ "VimResized", "VimEnter", "WinEnter" }, {
	callback = handle_resize,
})
