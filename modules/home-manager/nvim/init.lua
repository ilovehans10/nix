-- shortenings of some vim functions
local keyset = vim.keymap.set
local option = vim.opt

-- set mapleaders for mappings
vim.g.mapleader = " "
vim.g.maplocalleader = ","
-- set variable for vimrc location
vim.g.vimrc = vim.fn.resolve(vim.fn.expand("<sfile>:p"))

-- many of my options (TODO sort)
option.foldminlines = 5
option.foldnestmax = 3
option.foldenable = false
option.cursorline = true -- highlight the cursorline based on cursorlineopt
option.cursorlineopt = "number" -- highlight the linenumber of the cursorline
option.completeopt = { "menu", "menuone", "noselect" } -- show selection menus
option.backspace = { "indent", "eol", "start" } -- enable all backspacing in insert mode
option.relativenumber = true -- show the line numbers relative to the cursor
option.number = true -- show the line number of the cursor relative to the file
option.timeout = true -- don't wait forever for keys that are part of remaps
option.timeoutlen = 1000 -- wait for 1 second for the next key in a remap
option.ttimeoutlen = 100 -- wait for .1 seconds for key escape codes to be typed eg. <Right> = ^[[C
option.expandtab = true -- expand tabs into spaces
option.tabstop = 2 -- number of spaces tab counts for
option.shiftwidth = 0 -- makes shiftwidth match tabstop
option.scrolloff = 5 -- number of lines to keep the cursor from the edges
option.linebreak = true -- makes long lines wrap at characters in breakat
option.mouse = "a" -- allow for all mouse functionality
option.directory = { (vim.env.HOME .. "/.local/state/nvim/swap"), ".", "~/tmp", "/var/tmp", "/tmp" } -- swapfiles are made in the first directory possible
option.splitbelow = true -- open horizontal splits on the bottom
option.splitright = true -- open vertical splits on the right
option.undofile = true -- keep a history of modifications to a file for undoing after closing a session
option.ignorecase = true -- ignore case when searching
option.smartcase = true -- unless first letter is capitalized
option.termguicolors = true -- change the method highlighting uses to draw colors
option.nrformats:append({ "alpha" }) -- make incrimenting aphabetic characters possible

-- coc.vim
-- option.hidden = true -- this makes buffers stick around. I am not sure why it is needed so I am testing if it can be removed
option.updatetime = 300 -- after 300 milliseconds write swap to disk
option.signcolumn = "yes" -- show the signcolumn on the left for symbols

-- Fix j and k moving over wrapped lines
keyset("n", "j", "gj")
keyset("n", "k", "gk")

-- Move from window to window with CTRL-movement key
keyset("i", "<C-h>", "<C-\\><C-N><C-w>h")
keyset("i", "<C-j>", "<C-\\><C-N><C-w>j")
keyset("i", "<C-k>", "<C-\\><C-N><C-w>k")
keyset("i", "<C-l>", "<C-\\><C-N><C-w>l")
keyset("t", "<C-h>", "<C-\\><C-N><C-w>h")
keyset("t", "<C-j>", "<C-\\><C-N><C-w>j")
keyset("t", "<C-k>", "<C-\\><C-N><C-w>k")
keyset("t", "<C-l>", "<C-\\><C-N><C-w>l")
keyset("t", "<S-space>", "<space>")

keyset("n", "<ESC><ESC>", ":update<CR>")
keyset("i", "jk", "<ESC>")
keyset("i", "jj", "<ESC>")
keyset("i", "kj", "<ESC>")
keyset("i", "kk", "<ESC>")

-- allow inserting line before/after current
keyset("n", "<leader>j", ":set paste<CR>m`o<ESC>``:set nopaste<CR>") -- insert line after current
keyset("n", "<leader>k", ":set paste<CR>m`O<ESC>``:set nopaste<CR>") -- insert line before current
keyset("n", "<leader>w", "g<C-g>") -- show word count for buffer
keyset("v", "<leader>w", "g<C-g>") -- show word count for visual selection
keyset("n", "<leader>ev", (":tab drop " .. vim.fn.expand("<sfile>:p") .. "<CR>"))
keyset("n", "<leader>ez", "<CMD>tab drop ~/.config/zsh/.zshrc<CR>")
keyset("n", "<leader>ep", "<CMD>tab drop ~/.config/zsh/.zprofile<CR>")
keyset("n", "<leader>et", "<CMD>tab drop ~/.config/zsh/tips<CR>")
keyset("n", "<leader>s", ":sm///g<Left><Left>")
keyset("n", "<leader>S", ":%sm///g<Left><Left>")
keyset("n", "<leader>z", ":set spell!<CR>")
keyset("n", "<leader>Z", "1z=")
keyset("n", "<leader>h", ':let @/=""<CR>')
keyset("n", "<leader>H", ":set hlsearch!<CR>")
keyset("n", "<leader>t", ":vsplit term://zsh<CR>")
keyset("n", "<leader>T", ":vert resize 75<CR>")
keyset("ca", "help", "vert help") -- opens help in vertical windows
keyset("ca", "w!!", "w !sudo tee > /dev/null %") -- allow saving of files with sudo when needed

keyset("t", "<ESC><ESC>", "<C-\\><C-n>")

vim.api.nvim_create_augroup("helpbuffer", {})
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.txt",
	group = "helpbuffer",
	command = "if &buftype == 'help' | vert resize 78 | setlocal nonumber norelativenumber signcolumn=no | endif",
})

vim.api.nvim_create_augroup("clipboardswapper", {})
vim.api.nvim_create_autocmd("FocusLost", {
	pattern = "*",
	group = "clipboardswapper",
	command = 'let @* = @"',
})
vim.api.nvim_create_autocmd("FocusGained", {
	pattern = "*",
	group = "clipboardswapper",
	command = 'let @" = @*',
})

vim.api.nvim_create_augroup("myterm", {})
vim.api.nvim_create_autocmd(
	"TermOpen",
	{ group = "myterm", command = "vert resize 100 | setlocal nonumber norelativenumber nospell signcolumn=no" }
)
vim.api.nvim_create_autocmd("BufEnter", {
	group = "myterm",
	command = "if getwininfo(gettabinfo()[tabpagenr()-1]['windows'][(winnr()-1)])[0]['terminal'] | setlocal nonumber norelativenumber signcolumn=no| startinsert | else | stopinsert | endif",
})

vim.api.nvim_create_augroup("trailingwhitespace", {})
vim.api.nvim_create_autocmd("BufWritePre", {
	group = "trailingwhitespace",
	command = [[ let save_view = winsaveview() | %s/\s\+$//e | call winrestview(save_view) ]],
})

vim.api.nvim_create_augroup("changedirectory", {})
vim.api.nvim_create_autocmd("BufEnter", { pattern = "*", group = "changedirectory", command = [[ silent! lcd %:p:h ]] })

-- =============================================================================
-- Plugin configuration
-- Plugins are installed by Nix (home-manager programs.neovim.plugins).
-- =============================================================================

-- catppuccin — set colorscheme first so other plugins inherit the palette
vim.cmd.colorscheme("catppuccin-mocha")

-- undotree
vim.g.undotree_WindowLayout = 3
keyset("n", "|", "<cmd>UndotreeToggle<cr>")

-- neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require("neo-tree").setup({
	open_files_do_not_replace_types = { "terminal" },
	close_if_last_window = true,
	sources = {
		"filesystem",
		"buffers",
		"git_status",
		"document_symbols",
	},
	source_selector = {
		winbar = true,
		content_layout = "center",
		tabs_layout = "equal",
		show_separator_on_edge = true,
		sources = {
			{ source = "filesystem", display_name = "󰉓 Files" },
			{ source = "buffers", display_name = "󰈙 Buffers" },
			{ source = "git_status", display_name = " Git" },
			{ source = "document_symbols", display_name = " Symbols" },
		},
	},
})
keyset("n", "\\", "<cmd>Neotree toggle<cr>")

-- mini.nvim
require("mini.diff").setup({
	view = {
		style = "sign",
		signs = { add = "+", change = "~", delete = "-" },
	},
})
require("mini.jump").setup({
	delay = { idle_stop = 10000 },
})
require("mini.pairs").setup()
require("mini.indentscope").setup()
require("mini.surround").setup()
require("mini.jump2d").setup()
require("mini.align").setup()

-- vim-tmux-navigator — overrides the plain <C-hjkl> window movement keymaps above
keyset("n", "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>")
keyset("n", "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>")
keyset("n", "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>")
keyset("n", "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>")
keyset("n", "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>")

-- nvim-treesitter — grammars are installed by Nix, no ensure_installed needed
require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
	indent = { enable = true },
})

-- nvim-treesitter-context
keyset("n", "[c", function()
	require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })

-- lazydev — configures Lua LSP for Neovim config, runtime and plugins
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})

-- luasnip — load VSCode-style snippets from friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- blink.cmp
--- @module 'blink.cmp'
--- @type blink.cmp.Config
require("blink.cmp").setup({
	cmdline = {
		completion = {
			menu = { auto_show = true },
			list = { selection = { preselect = false } },
		},
	},
	keymap = {
		preset = "enter",
		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
		["<S-Tab>"] = { "select_prev", "snippet_forward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = {
		list = { selection = { preselect = false, auto_insert = true } },
		documentation = { auto_show = true },
	},
	sources = {
		default = { "lsp", "path", "snippets", "lazydev" },
		providers = {
			lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
		},
	},
	snippets = { preset = "luasnip" },
	fuzzy = { implementation = "prefer_rust" },
	signature = { enabled = true },
})

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
		map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
		map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
		map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
		map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
		map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
		map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
		map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

		---@param client vim.lsp.Client
		---@param method vim.lsp.protocol.Method
		---@param bufnr? integer some lsp support methods only in specific files
		---@return boolean
		local function client_supports_method(client, method, bufnr)
			if vim.fn.has("nvim-0.11") == 1 then
				return client:supports_method(method, bufnr)
			else
				return client.supports_method(method, { bufnr = bufnr })
			end
		end

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if
			client
			and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
		then
			local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})
			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
				end,
			})
		end

		if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[T]oggle Inlay [H]ints")
		end
	end,
})

-- Diagnostic config
vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	} or {},
	virtual_text = {
		source = "if_many",
		spacing = 2,
		format = function(diagnostic)
			local diagnostic_message = {
				[vim.diagnostic.severity.ERROR] = diagnostic.message,
				[vim.diagnostic.severity.WARN] = diagnostic.message,
				[vim.diagnostic.severity.INFO] = diagnostic.message,
				[vim.diagnostic.severity.HINT] = diagnostic.message,
			}
			return diagnostic_message[diagnostic.severity]
		end,
	},
})

-- Apply blink.cmp capabilities to all LSP servers globally
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

require("mason").setup()
-- Automatically enable all Mason-installed LSP servers
require("mason-lspconfig").setup({ automatic_enable = true })

local lua_ls_library = vim.api.nvim_get_runtime_file("", true)
table.insert(lua_ls_library, "${workspaceFolder}")

vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
			workspace = {
				library = lua_ls_library,
			},
			diagnostics = {
				globals = { "vim" },
			},
			runtime = {
				version = "LuaJIT",
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
			},
		},
	},
})

-- Servers managed by Nix (or any other means that puts the binary on PATH)
vim.lsp.enable({ "lua_ls", "rust_analyzer" })

-- telescope
require("telescope").setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown(),
		},
	},
})

pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "ui-select")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

vim.keymap.set("n", "<leader>/", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("n", "<leader>s/", function()
	builtin.live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end, { desc = "[S]earch [/] in Open Files" })

vim.keymap.set("n", "<leader>sn", function()
	builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })

-- lualine
require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = { "neo-tree" },
			winbar = { "neo-tree" },
		},
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "selectioncount", "searchcount", "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	winbar = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_winbar = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = { "diagnostics" },
		lualine_z = {},
	},
	extensions = {},
})

-- bufferline
require("bufferline").setup({
	options = {
		separator_style = "slant",
		indicator = {
			style = "underline",
		},
		offsets = {
			{
				filetype = "neo-tree",
				text = "File Explorer",
				separator = true,
			},
		},
	},
})

-- which-key
require("which-key").setup({
	triggers = { { "<auto>", mode = "nixsoc" } },
})

-- conform.nvim — overrides the <leader>f rustfmt keymap above
require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		local disable_filetypes = { c = true, cpp = true }
		if disable_filetypes[vim.bo[bufnr].filetype] then
			return nil
		else
			return {
				timeout_ms = 500,
				lsp_format = "fallback",
			}
		end
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettier" },
		nix = { "alejandra" },
	},
})
vim.keymap.set("", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })
