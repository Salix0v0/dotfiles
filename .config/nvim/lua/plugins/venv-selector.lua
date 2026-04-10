return {
  {
    "linux-cultist/venv-selector.nvim",
    opts = {
      search = {
        miniconda = {
          command = "fd '/bin/python$' /opt/miniconda3 --full-path --color never -E pkgs", -- exclude path with pkgs
          type =
          "anaconda"                                                                       -- it's anaconda-style environment (also for miniconda)
        }
        -- you can add more searches here
        -- another_search = {
        -- command = ""
        -- }
      }
    }
  }
}
