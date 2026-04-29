return {
  -- 安装 vscode.nvim
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local c = require("vscode.colors").get_colors()

      require("vscode").setup({
        -- 主题风格：'dark' 或 'light'
        -- style = 'dark',

        -- ✅ 开启透明背景（保持终端背景色）
        transparent = true,

        -- 开启斜体注释
        italic_comments = false,

        -- 开启斜体 inlay hints
        italic_inlayhints = true,

        -- 链接下划线
        underline_links = true,

        -- 禁用 nvim-tree 的背景色（透明时建议开启）
        disable_nvimtree_bg = true,

        -- 将主题色应用到终端
        terminal_colors = false,

        -- 覆盖颜色（可选）
        -- color_overrides = {
        --   vscLineNumber = '#FFFFFF',
        -- },

        -- 覆盖高亮组（可选）
        -- group_overrides = {
        --   Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
        -- },
      })
      vim.cmd.colorscheme("vscode")

      -- -- 区分激活窗口
      -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "#141414" })
      -- vim.api.nvim_set_hl(0, "LineNrNC", { bg = "#141414", fg = "#4a4a4a" })
      -- vim.api.nvim_set_hl(0, "SignColumnNC", { bg = "#141414" })
      -- vim.api.nvim_set_hl(0, "EndOfBufferNC", { bg = "#141414" })
      -- vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#007acc", bold = true })
      --
      -- -- CursorLine 必须放在 colorscheme 之后
      -- vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2a2d2e" })
      -- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff", bg = "#2a2d2e", bold = true })
      -- vim.cmd.colorscheme("vscode")
    end,
  },

  -- 告诉 LazyVim 使用这个主题
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vscode",
    },
  },
}
