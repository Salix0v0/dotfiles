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
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lazydot='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
fish_add_path "/home/salix/.local/bin"
fish_add_path "/home/salix/.local/share/npm/bin"
