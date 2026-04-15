-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- vim.cmd("colorscheme default")
-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
-- vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.g.lazyvim_python_lsp = "basedpyright" --"pyrefly"
-- vim.opt.winborder = "single"
-- 其他选项: "none" | "rounded" | "double" | "solid" | "shadow"
-- ~/.config/nvim/lua/config/options.lua

vim.opt.scrolloff = 0     -- 上下保留行数（默认8），改小
vim.opt.sidescrolloff = 0 -- 左右保留列数

vim.g.suda_smart_edit = 1

-- -- 强制使用系统剪贴板
-- vim.opt.clipboard = "unnamedplus"
--
-- -- 使用 Neovim 0.10+ 原生的 OSC 52 剪贴板提供程序
-- vim.g.clipboard = {
--   name = "OSC 52",
--   copy = {
--     ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
--   },
--   paste = {
--     ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
--   },
-- }
