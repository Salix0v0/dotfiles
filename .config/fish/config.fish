bind \cy redo

if status is-interactive
    set -g fish_greeting ""
    # Commands to run in interactive sessions can go here

    # >>> mamba initialize >>>
    # !! Contents within this block are managed by 'mamba shell init' !!
    set -gx MAMBA_EXE /opt/miniconda3/bin/mamba
    set -gx MAMBA_ROOT_PREFIX /opt/miniconda3
    $MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
    # <<< mamba initialize <<<
    alias conda='mamba'
    # starship init fish | source
end
# alias source='bass source'
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# if test -f /opt/miniconda3/bin/conda
#     eval /opt/miniconda3/bin/conda "shell.fish" "hook" $argv | source
# else
#     if test -f "/opt/miniconda3/etc/fish/conf.d/conda.fish"
#         . "/opt/miniconda3/etc/fish/conf.d/conda.fish"
#     else
#         set -x PATH "/opt/miniconda3/bin" $PATH
#     end
# end
# <<< conda initialize <<<

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
# 补充：如果你发现在可视模式下按 0 (行首) 和 $ (行尾) 也不管用，可以一并加上：
bind -M visual 0 beginning-of-line
bind -M visual '$' end-of-line
function _ghostty_open_scrollback
    sleep 0.1
    set path (commandline)
    commandline "nvim $path"
    commandline -f execute
end

bind --mode insert ctrl-shift-h _ghostty_open_scrollback
set -g theme_display_vi no
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lazydot='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
fish_add_path "/home/salix/.local/bin"
fish_add_path "/home/salix/.local/share/npm/bin"
# 有已存在的 session 就 attach，没有就新建
# 自动进入 tmux（防嵌套 + 防非交互式 shell）
# if status is-interactive
#     and command -q tmux
#     and not set -q TMUX
#     tmux new-session
# end
