return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = { enabled = false }, -- 关掉默认那个
        basedpyright = { enabled = true }, -- 打开替代品
      },
    },
  },
}
