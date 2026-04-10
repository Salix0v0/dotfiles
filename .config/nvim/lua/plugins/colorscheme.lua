return {
  -- 安装两个主题
--   { "mhinz/vim-janah",
--     -- init = function()
--     -- vim.api.nvim_create_autocmd("ColorScheme", {
--     --   pattern = "*",
--     --   callback = function()
--     --     vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--     --     vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
--     --     vim.api.nvim_set_hl(0, "NormalNC",    { bg = "none" })
--     --     vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
--     --     vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })

--     --     vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
--     --     vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" })
--     --     vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })
--     --   end,
--     -- })
--   -- end
-- },
--   {"KabbAmine/yowish.vim"},
--   -- {"RRethy/base16-nvim"},
--   {"ellisonleao/gruvbox.nvim"},

--   {"folke/tokyonight.nvim",
-- opts = {
--       transparent = true, -- 开启主体透明背景
--       styles = {
--         sidebars = "transparent", -- 让侧边栏（如 neo-tree）也透明
--         floats = "transparent",   -- 让浮动窗口（如 which-key, 弹窗）也透明
--       },
--     }},
--   {
--     "catppuccin/nvim",
--     name = "catppuccin",
--     opts = {
--       transparent_background = true, -- 开启透明背景
--     },
--   },
--   {"rebelot/kanagawa.nvim"},
--   {"EdenEast/nightfox.nvim"},
  {'Mofiqul/vscode.nvim'},
  -- 设置默认主题（改成任意一个即可）
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vscode", -- 或 "yowish"
    },
  },

}