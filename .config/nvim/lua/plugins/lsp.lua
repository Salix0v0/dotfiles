return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = { enabled = false }, -- 关掉默认那个
        basedpyright = { enabled = false }, -- 打开替代品
        pyrefly = { enabled = true },
      },
    },
  },
}
