if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end

bind \cy redo

# uv
fish_vi_key_bindings
# === 手动补全 Visual 模式下的缺失键位 ===

# 让可视模式下的 gg 移动到光标/命令行的最前端
bind -M visual gg beginning-of-buffer

# 让可视模式下的 G 移动到光标/命令行的最后端
bind -M visual G end-of-buffer
# 绑定 y 复制到系统剪贴板（visual 模式）
bind -M visual y 'fish_clipboard_copy; commandline -f end-selection repaint-mode'

# 绑定 p 从系统剪贴板粘贴（normal 模式）
bind -M normal p fish_clipboard_paste
bind -M visual p fish_clipboard_paste
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.local/share/npm/bin"

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lazydot='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
# 有已存在的 session 就 attach，没有就新建
# 自动进入 tmux（防嵌套 + 防非交互式 shell）
# if status is-interactive
#     and command -q tmux
#     and not set -q TMUX
#     tmux new-session
# end
