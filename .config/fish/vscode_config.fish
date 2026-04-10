if status is-interactive
    # set -g fish_greeting ""
    # # Commands to run in interactive sessions can go here

    # # >>> mamba initialize >>>
    # # !! Contents within this block are managed by 'mamba shell init' !!
    # set -gx MAMBA_EXE "/opt/miniconda3/bin/mamba"
    # set -gx MAMBA_ROOT_PREFIX "/opt/miniconda3"
    # $MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
    # # <<< mamba initialize <<<
    # alias conda='mamba'
    # starship init fish | source
end

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

function source
    # 检查第一个参数是否包含 activate 路径
    if string match -q "*/bin/activate" "$argv[1]"
        if set -q argv[2]
            # 如果有第二个参数（环境名），直接用 conda activate
            conda activate $argv[2]
        else
            # 如果没有参数，默认激活 base
            conda activate base
        end
    else
        # 否则，回归 Fish 原生的 source 逻辑
        builtin source $argv
    end
end
# alias source='bass source'


