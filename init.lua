vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = false
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.showmode = false
vim.o.winborder = "rounded"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.lsp.enable("luals")
vim.diagnostic.config({ virtual_lines = { current_line = true } })
vim.keymap.set("n", "gq", vim.lsp.buf.format, { desc = "Lsp format" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Lsp definition" })

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		'git', 'clone', '--filter=blob:none',
		'https://github.com/echasnovski/mini.nvim', mini_path
	}
	vim.fn.system(clone_cmd)
	vim.cmd('packadd mini.nvim | helptags ALL')
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = path_package } })

-- Auto format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(args)
		local clients = vim.lsp.get_clients({ bufnr = args.buf })
		if next(clients) ~= nil then
			vim.lsp.buf.format({ async = false })
		end
	end,
})

local add = MiniDeps.add

-- Color scheme
add({
	source = 'rose-pine/neovim',
})
require('rose-pine').setup({
	variant = "dawn",
	styles = {
		bold = false,
		italic = false,
	},
})
vim.cmd("colorscheme rose-pine")

-- Jumping
add({
	source = 'ggandor/leap.nvim'
})
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>s', '<Plug>(leap)')
vim.keymap.set('n', '<leader>S', '<Plug>(leap-from-window)')

-- Treesitter
add({
	source = 'nvim-treesitter/nvim-treesitter',
	-- Use 'master' while monitoring updates in 'main'
	checkout = 'master',
	monitor = 'main',
	-- Perform action after every checkout
	hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
})
require('nvim-treesitter.configs').setup({
	ensure_installed = { 'lua', 'vimdoc', 'markdown', 'markdown_inline', 'yaml', 'toml', 'json' },
	highlight = { enable = true },
})

-- LSP code actions
add({
	source = "rachartier/tiny-code-action.nvim",
	depends = {
		"nvim-lua/plenary.nvim",
	}
})
local code_action = require("tiny-code-action")
code_action.setup({
	picker = "select"
})
vim.keymap.set({ "n", "x" }, "gca", function()
	code_action.code_action()
end, { noremap = true, silent = true })

-- Dart and flutter stuff
add({
	source = "dart-lang/dart-vim-plugin",
})
add({
	source = "nvim-flutter/flutter-tools.nvim",
	depends = {
		"nvim-lua/plenary.nvim",
	},
})
require("flutter-tools").setup({
	root_patterns = { ".git", "pubspec.yaml" }, -- patterns to find the root of your flutter project
	fvm = false,                             -- takes priority over path, uses <workspace>/.fvm/flutter_sdk if enabled
	default_run_args = nil,                  -- Default options for run command (i.e `{ flutter = "--no-version-check" }`). Configured separately for `dart run` and `flutter run`.
	widget_guides = {
		enabled = false,
	},
	closing_tags = {
		highlight = "ErrorMsg", -- highlight for the closing tag
		prefix = ":: ",   -- character to use for close tag e.g. > Widget
		priority = 10,    -- priority of virtual text in current line
		-- consider to configure this when there is a possibility of multiple virtual text items in one line
		-- see `priority` option in |:help nvim_buf_set_extmark| for more info
		enabled = true -- set to false to disable
	},
	outline = {
		open_cmd = "30vnew",
		auto_open = false
	},
	lsp = {
		settings = {
			showTodos = false,
			completeFunctionCalls = true,
			analysisExcludedFolders = { vim.env.HOME .. "/flutter" },
			renameFilesWithClasses = "always", -- "always"
			enableSnippets = true,
			updateImportsOnRename = true, -- Whether to update imports and other directives when files are renamed. Required for `FlutterRename` command.
		}
	}
})

-- mini stuff
require('mini.icons').setup()
require('mini.statusline').setup()
require('mini.surround').setup()
require('mini.comment').setup()
require('mini.snippets').setup()
require('mini.completion').setup()
require('mini.cursorword').setup()
require('mini.pairs').setup()
local git = require('mini.git')
git.setup()
local hipatterns = require('mini.hipatterns')
hipatterns.setup({
	highlighters = {
		-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
		fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
		hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
		todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
		note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

		-- Highlight hex color strings (`#rrggbb`) using that color
		hex_color = hipatterns.gen_highlighter.hex_color(),
	},
})
local pick = require('mini.pick')
pick.setup()
local extra = require('mini.extra')
extra.setup()

vim.keymap.set('n', '<leader>ff', function()
	local git_data = git.get_buf_data(0)
	if (git_data ~= nil and next(git_data) ~= nil) then
		pick.builtin.files({ tool = 'git' })
	else
		pick.builtin.files()
	end
end, { noremap = true })

vim.keymap.set('n', '<leader>fg', pick.builtin.grep_live, { noremap = true })
vim.keymap.set('n', '<leader>fc', extra.pickers.commands, { noremap = true })
vim.keymap.set('n', '<leader>fd', extra.pickers.diagnostic, { noremap = true })
vim.keymap.set('n', '<leader>fk', extra.pickers.keymaps, { noremap = true })
vim.keymap.set('n', '<leader>fw', function()
	extra.pickers.lsp({ scope = 'workspace_symbol' })
end, { noremap = true })
vim.keymap.set('n', '<leader>fW', function()
	extra.pickers.lsp({ scope = 'document_symbol' })
end, { noremap = true })
vim.keymap.set('n', '<leader>fr', function()
	extra.pickers.lsp({ scope = 'references' })
end, { noremap = true })
