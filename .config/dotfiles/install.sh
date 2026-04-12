#!/bin/bash
set -e
# ==========================================
# 用户自定义配置区
# ==========================================
# 替换为你的 GitHub/GitLab 仓库地址 (推荐在新电脑上先配置好 SSH 密钥，或者用 HTTPS 地址)
REPO_URL="https://github.com/Salix0v0/dotfiles.git"
# 定义裸仓库的存放路径
DOTFILES_DIR="$HOME/.dotfiles"
# 定义冲突文件的备份路径
BACKUP_DIR="$HOME/.dotfiles-backup"

# ==========================================
# 执行逻辑区
# ==========================================
echo "📦 1. 安装基础依赖..."
apt update
apt install -y git curl
echo "📥 2. 克隆 Dotfiles..."
# if ! command -v git &>/dev/null; then
#   echo "❌ 错误: 未找到 Git，请先安装 Git。"
#   exit 1
# fi
#
# 2. 将 .dotfiles 添加到系统的 .gitignore 中，防止递归问题
grep -qxF '.dotfiles' "$HOME/.gitignore" || echo ".dotfiles" >>"$HOME/.gitignore"
# 3. 克隆裸仓库到本地
echo "📦 正在克隆 dotfiles 仓库..."
git clone --bare "$REPO_URL" "$DOTFILES_DIR"

# 4. 定义临时函数，代替我们平时用的 alias
function dotfiles {
  /usr/bin/git --git-dir="$DOTFILES_DIR/" --work-tree="$HOME" "$@"
}

# 5. 尝试将配置文件检出到家目录，并捕获错误
mkdir -p "$BACKUP_DIR"
echo "⚙️ 尝试应用配置..."

if dotfiles checkout; then
  echo "✅ 配置应用成功！"
else
  echo "⚠️ 发现现有配置文件发生冲突。正在自动备份到 $BACKUP_DIR..."
  # 提取冲突的文件名，并将其移动到备份文件夹
  dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv "$HOME/{}" "$BACKUP_DIR/{}"

  echo "🔄 备份完成，重新应用配置..."
  dotfiles checkout
fi

# 6. 设置隐藏未跟踪文件（非常关键的一步）
dotfiles config --local status.showUntrackedFiles no

echo "🛠️ 3. 安装核心生产力工具..."

# 安装 Fish

# 安装 Neovim (注意：LazyVim 需要 Neovim >= 0.9.0)
# Ubuntu 默认源的 nvim 可能太老，建议通过 PPA 或直接下载二进制文件
apt-add-repository ppa:fish-shell/release-4
add-apt-repository ppa:neovim-ppa/unstable -y
apt update
apt install -y fish
apt install -y neovim

echo "⚙️ 4. 进行后置环境配置..."

# 4.1 安装 Fisher 并同步 Fish 插件
# 此时 ~/.config/fish/fish_plugins 已经通过 Dotfiles 检出了，直接安装 Fisher 并 update 即可
echo "🐟 初始化 Fisher 与 Fish 插件..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher update"

# 4.2 初始化 LazyVim 插件
# 此时 ~/.config/nvim 已经通过 Dotfiles 检出。使用 headless 模式自动下载并同步所有插件、LSP 和 Treesitter 解析器
echo "🌙 初始化 LazyVim 与 Neovim 插件 (这可能需要几分钟)..."
nvim --headless "+Lazy! sync" +qa

# 4.3 切换默认 Shell 为 Fish
if [ "$SHELL" != "$(which fish)" ]; then
  echo "🐚 将 Fish 设置为默认 Shell..."
  # 更改默认 shell 需要输入当前用户的密码
  chsh -s $(which fish)
fi

echo "🎉 全部完成！请重新登录终端以享受全新的 Fish + LazyVim 环境！"
