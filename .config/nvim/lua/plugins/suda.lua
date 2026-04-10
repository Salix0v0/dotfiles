return {
  "lambdalisue/suda.vim",
  cmd = { "SudaRead", "SudaWrite" },
  init = function()
    -- 智能模式：当编辑需要 root 权限的文件时自动启用 suda
    vim.g.suda_smart_edit = 1
  end,
}
