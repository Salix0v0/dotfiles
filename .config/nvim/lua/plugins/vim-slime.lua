return {
  "jpalardy/vim-slime",
  init = function()
    vim.g.slime_target = "tmux"

    vim.g.slime_default_config = {
      socket_name = "default",
      target_pane = "{marked}",
    }

    vim.g.slime_dont_ask_default = 1

    -- 关键：让 tmux 用 bracketed paste 方式粘贴
    vim.g.slime_bracketed_paste = 1

    -- 如果右侧是 IPython，也加上
    vim.g.slime_python_ipython = 1
  end,
}
