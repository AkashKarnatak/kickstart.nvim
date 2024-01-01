--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add          = {hl = 'GitSignsAdd'   , text = '▍', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
        change       = {hl = 'GitSignsChange', text = '▍', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
        delete       = {hl = 'GitSignsDelete', text = '契', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
        topdelete    = {hl = 'GitSignsDelete', text = '契', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
        changedelete = {hl = 'GitSignsChange', text = '▍', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
        untracked    = {hl = 'GitSignsAdd'   , text = '▍', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']g', function()
          if vim.wo.diff then return ']g' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true})

        map('n', '[g', function()
          if vim.wo.diff then return '[g' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true})

        -- Actions
        map({'n', 'v'}, '<leader>gs', ':Gitsigns stage_hunk<CR>', { silent = true })
        -- map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
        -- map('n', '<leader>hS', gs.stage_buffer)
        map('n', '<leader>gu', gs.undo_stage_hunk)
        -- map('n', '<leader>hR', gs.reset_buffer)
        map('n', '<leader>gg', gs.preview_hunk)
        map('n', '<leader>gb', function() gs.blame_line{full=true} end)
        -- map('n', '<leader>tb', gs.toggle_current_line_blame)
        map('n', '<leader>gd', gs.diffthis)
        -- map('n', '<leader>hD', function() gs.diffthis('~') end)
        -- map('n', '<leader>td', gs.toggle_deleted)

        -- Text object
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end
    },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato", -- latte, frappe, macchiato, mocha
        background = { -- :h background
          light = "latte",
          dark = "macchiato",
        },
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'catppuccin',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- project manager
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {}
    end
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { '<space>ff', mode = 'n' },
      { '<space>fo', mode = 'n' },
      { '<space>fw', mode = 'n' },
      { '<space>fm', mode = 'n' },
      { '<space>fr', mode = 'n' },
      { '<space>f/', mode = 'n' },
      { '<space>fc', mode = 'n' },
      { '<space>fh', mode = 'n' },
      { '<space>fg', mode = 'n' },
      { '<space>fp', mode = 'n' },
      { '<space>fr', mode = 'n' },
      { '<space>fb', mode = 'n' },
      { '<space>fe', mode = 'n' },
      { '<space>fs', mode = 'n' },
      { 'gd',        mode = 'n' },
      { 'gi',        mode = 'n' },
      { 'gr',        mode = 'n' },
      { '<space>ld', mode = 'n' },
      { '<space>ls', mode = 'n' },
    },
    cmd = "Telescope",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      local actions = require('telescope.actions')
      require('telescope').setup({
        defaults = {
          sorting_strategy = "ascending",
          layout_strategy = "flex",
          layout_config = {
            horizontal = {
              mirror = false,
              prompt_position = "top",
              preview_cutoff = 100,
              preview_width = 0.5,
            },
            vertical = {
              mirror = true,
              prompt_position = "top",
            },
          },
          mappings = {
            i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                -- ["<esc>"] = actions.close,
                -- [";;"] = actions.close,
            },
            n = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<esc>"] = actions.close,
            }
          },
          file_ignore_patterns = { "node_modules", "dist" },
          buffer_previewer_maker = truncate_large_files,
        },
      })
    end
  },


  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

vim.o.hidden = true                                             -- Required to keep multiple buffers open multiple buffers
vim.opt.foldenable = false                                      -- Disable code folding
vim.wo.wrap = false                                             -- Display long lines as just one line
vim.o.pumheight = 10                                            -- Makes popup menu smaller
vim.o.fileencoding = "utf-8"                                    -- The encoding written to file
vim.o.mouse = "a"                                               -- Enable your mouse
vim.o.splitbelow = true                                         -- Horizontal splits will automatically be below
vim.o.splitright = true                                         -- Vertical splits will automatically be to the right
vim.o.termguicolors = true                                      -- set term giu colors most terminals support this
vim.o.expandtab = true                                         -- Converts tabs to spaces
vim.o.smartindent = true                                       -- Makes indenting smart
vim.wo.number = true                                            -- set numbered lines
vim.wo.relativenumber = true                                    -- set relative number
vim.wo.cursorline = false                                       -- Enable highlighting of the current line
vim.o.clipboard = "unnamedplus"                                 -- Copy paste between vim and everything else
vim.o.showtabline = 2                                           -- Always show tabs
vim.wo.signcolumn = "yes"                                       -- Always show the signcolumn, otherwise it would shift the text each time
-- vim.o.updatetime = 200                                       -- Faster completion
vim.o.timeoutlen = 500                                          -- By default timeoutlen is 1000 ms
vim.o.cpoptions = vim.o.cpoptions .. 'y'                        -- Allows yank action to be repeated
vim.o.laststatus = 3                                            -- Global statusline
vim.o.ts = 2                                                    -- Insert 4 spaces for a tab
vim.o.sw = 2                                                    -- Change the number of space characters inserted for indentation
vim.o.so = 10                                                   -- Scroll offset
vim.cmd('command! BD silent! execute "%bd|e#|bd#"')             -- Close all buffers except the active one
vim.cmd([[command! FilePath execute "echo expand('%:p')"]])     -- Display absolute path of the file opened in current buffer

-- resize windows easily
vim.api.nvim_set_keymap('n', '<C-Left>', '<C-w><', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-Down>', '<C-w>-', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-Up>', '<C-w>+', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-Right>', '<C-w>>', {noremap = true, silent = true})

-- Remap 0, $, ^
vim.api.nvim_set_keymap('n', '0', '$',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '$', '^',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '^', '0',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '0', '$h', {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '$', '^',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '^', '0',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('o', '0', '$',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('o', '$', '^',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('o', '^', '0',  {noremap = true, silent = true})

-- Swap ^ and !
vim.api.nvim_set_keymap('n', '!', '0',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '^', '!',  {noremap = true, silent = true})

-- Remap g0, g$, g^
vim.api.nvim_set_keymap('n', 'g0', 'g$',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'g$', 'g^',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'g^', 'g0',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', 'g0', 'g$h', {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', 'g$', 'g^',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', 'g^', 'g0',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('o', 'g0', 'g$',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('o', 'g$', 'g^',  {noremap = true, silent = true})
vim.api.nvim_set_keymap('o', 'g^', 'g0',  {noremap = true, silent = true})

-- Custom text surround integration
for _, char in ipairs({'_', '.', ':', ',', ';', '|', '/', '\\', '*', '+', '%'}) do
    vim.api.nvim_set_keymap('x', 'i'..char, ':<C-u>normal! T'..char..'vt'..char..'<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap('o', 'i'..char, ':normal vi'..char..'<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap('x', 'a'..char, ':<C-u>normal! F'..char..'vf'..char..'<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap('o', 'a'..char, ':normal va'..char..'<CR>', {noremap = true, silent = true})
end

-- << << Text object for CPP
vim.api.nvim_set_keymap('x', 'io', [[":<C-u>execute \"normal ?<<\\\<CR\>3lv/<<\\\<CR\>2h\"<CR>"]], {expr=true, noremap = true, silent = true})
vim.api.nvim_set_keymap('o', 'io', [[":execute \"normal ?<<\\\<CR\>3lv/<<\\\<CR\>2h\"<CR>"]], {expr=true, noremap = true, silent = true})
vim.api.nvim_set_keymap('x', 'ao', [[":<C-u>execute \"normal ?<<\\\<CR\>v/<<\\\<CR\>l\"<CR>"]], {expr=true, noremap = true, silent = true})
vim.api.nvim_set_keymap('o', 'ao', [[":execute \"normal ?<<\\\<CR\>v/<<\\\<CR\>l\"<CR>"]], {expr=true, noremap = true, silent = true})

-- Entire file text object
vim.api.nvim_set_keymap('x', 'ie', ':<C-u>normal! ggvG<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('o', 'ie', ':normal ggvG<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('x', 'ae', ':<C-u>normal! ggVG<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('o', 'ae', ':normal ggVG<CR>', {noremap = true, silent = true})

-- switch buffer
vim.api.nvim_set_keymap('n', 'L', ':bnext<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'H', ':bprevious<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Tab>', ':tabnext<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-Tab>', ':tabprevious<CR>', {noremap = true, silent = true})

-- Remove highlighting
vim.api.nvim_set_keymap('n', '<Esc>', ':noh<CR>:<BS>', {noremap = true})
-- Enter normal mode in terminal
vim.api.nvim_set_keymap('t', '<M-Esc>', '<C-\\><C-n>', {noremap = true})
-- Map Ctrl-Backspace to delete the previous word in insert mode
vim.api.nvim_set_keymap('i', '<C-h>', '<C-w>', {noremap = true})
vim.api.nvim_set_keymap('c', '<C-h>', '<C-w>', {noremap = true})
vim.api.nvim_set_keymap('i', '<C-Bs>', '<C-w>', {noremap = true})
vim.api.nvim_set_keymap('t', '<C-Bs>', '<C-w>', {noremap = true})
vim.api.nvim_set_keymap('c', '<C-Bs>', '<C-w>', {noremap = true})

-- Ctrl p to next item in jumplist
vim.api.nvim_set_keymap('n', '<C-p>', '<C-i>', {noremap = true, silent=true})

-- Add numbered jumps to jumplist
vim.api.nvim_set_keymap('n', 'k', [[(v:count > 1 ? "m'" . v:count : '') . 'k']], {expr = true, noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'j', [[(v:count > 1 ? "m'" . v:count : '') . 'j']], {expr = true, noremap = true, silent = true})

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
-- Mappings
vim.api.nvim_set_keymap('n', '<Leader>ff', ':Telescope find_files<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>fo', ':Telescope oldfiles no_ignore=true<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>fw', ':Telescope live_grep no_ignore=true<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>fm', ':Telescope marks no_ignore=true<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>f/', ':Telescope current_buffer_fuzzy_find<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>fc', [[:Telescope find_files no_ignore=true prompt_title=Nvim\ Config cwd=$HOME/.config/nvim<CR>]], {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>fg', ':Telescope git_status no_ignore=true<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>fh', ':Telescope highlights no_ignore=true<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>fp', ':Telescope projects no_ignore=true<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>fr', ':Telescope resume no_ignore=true<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>fb', ':Telescope buffers no_ignore=true<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>fe', ':Telescope file_browser no_ignore=true<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "gd", ":Telescope lsp_definitions<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "gi", ":Telescope lsp_implementations<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "gr", ":Telescope lsp_references<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>ld", ":Telescope diagnostics<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>ls", ":Telescope lsp_document_symbols<CR>", {noremap = true, silent = true})

-- Highlightings
vim.cmd([[highlight TelescopeSelection      guibg=#383A42 gui=bold]]) -- selected item
vim.cmd([[highlight TelescopeSelectionCaret guifg=#D79921]])          -- selection caret
vim.cmd([[highlight TelescopeMatching       guifg=#D79921]])          -- matched characters

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    -- ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- document existing key chains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require('which-key').register({
  ['<leader>'] = { name = 'VISUAL <leader>' },
  ['<leader>h'] = { 'Git [H]unk' },
}, { mode = 'v' })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  -- lua_ls = {
  --   Lua = {
  --     workspace = { checkThirdParty = false },
  --     telemetry = { enable = false },
  --     -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
  --     -- diagnostics = { disable = { 'missing-fields' } },
  --   },
  -- },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}

require('Comment').setup({
  toggler = {
    line = 'cmm',
  },
  opleader = {
    line = 'cm',
  },
  extra = {
    above = 'cmO',
    below = 'cmo',
    eol = 'cmA',
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
