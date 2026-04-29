return {
  "folke/snacks.nvim",
  opts = {
    image = {},
    statuscolumn = { enabled = true },
    picker = {
      sources = {
        explorer = {
          layout = { preview = "main" },
          actions = {
            my_select = function(picker)
              picker:action("select_and_next")
              picker:action("list_up")
            end,
            my_cut = function(picker)
              if #picker.list.selected == 0 then
                picker:action("my_select")
              end
              vim.g.snacks_paste_mode = "cut"
              Snacks.notify("Cut " .. #picker.list.selected .. " item(s)")
            end,
            my_yank = function(picker)
              if #picker.list.selected == 0 then
                picker:action("my_select")
              end
              vim.g.snacks_paste_mode = "copy"
              Snacks.notify("Yanked " .. #picker.list.selected .. " item(s)")
            end,
            my_paste = function(picker, item)
              local A = require("snacks.explorer.actions").actions
              local mode = vim.g.snacks_paste_mode
              vim.g.snacks_paste_mode = nil
              if mode == "cut" then
                A.explorer_move(picker, item)
              elseif mode == "copy" then
                A.explorer_copy(picker, item)
              else
                Snacks.notify.warn("Nothing to paste")
              end
            end,
          },
          win = {
            list = {
              keys = {
                ["x"] = "my_cut",
                ["y"] = "my_yank",
                ["p"] = "my_paste",
                ["v"] = "my_select",
                ["V"] = "my_select",
                ["h"] = "explorer_up",
                ["l"] = "explorer_focus"
              },
            },
          },
        },
      },
    },
  },
}
