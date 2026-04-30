return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = { enabled = false }, -- 关掉默认那个
        basedpyright = {},             -- 打开替代品
      },
    },
  },
}
