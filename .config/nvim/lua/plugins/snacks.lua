return {
  "folke/snacks.nvim",
  -- 来自社区 discussion #2140 的验证可用配置
  opts = {
    image = {
      -- your image configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    statuscolumn = {
      enabled = true
    },
    picker = {
      sources = {
        explorer = {
          layout = {
            preview = "main", -- 顶层！
            -- layout = {
            --   backdrop = false,
            --   width = 40,
            --   min_width = 40,
            --   height = 0,
            --   position = "left",
            --   border = "none",
            --   box = "vertical",
            --   { win = "input",   height = 1,          border = "rounded", title = "{title} {live} {flags}", title_pos = "center" },
            --   { win = "list",    border = "none" },
            --   { win = "preview", title = "{preview}", height = 0.4,       border = "top" },
            -- },
          },
        },
      },
    },
  },
}
