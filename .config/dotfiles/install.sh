#!/bin/bash
set -e

# ==========================================
# 用户自定义配置区
# ==========================================
REPO_URL="https://github.com/Salix0v0/dotfiles.git"

# ==========================================
# 可安装的应用列表
# ==========================================
CORE_APPS=(fish neovim)
OPTIONAL_APPS=(uv tmux yazi)
ALL_APPS=("${CORE_APPS[@]}" "${OPTIONAL_APPS[@]}")

# ==========================================
# 状态变量
# ==========================================
DOTFILES_MODE="" # overwrite | skip | (empty=ask)
SELECTED_APPS=()
APPS_SPECIFIED=false
PROXY_ADDR=""  # 代理地址（留空=询问，none=不代理）
TARGET_USER="" # 目标用户（留空=询问）

# ==========================================
# 工具函数
# ==========================================
usage() {
  cat <<'USAGE'
Usage: install.sh [OPTIONS]

本脚本需要以 root 身份运行。系统级软件由 root 安装，
dotfiles 和用户配置将应用到指定的目标用户。

Options:
  --user=USERNAME    指定目标用户（dotfiles 和用户配置将应用到该用户）
  --overwrite        覆盖已有 dotfiles（备份冲突文件后强制 checkout）
  --skip-dotfiles    跳过 dotfiles 的克隆和应用步骤
  --all              安装所有应用（含可选应用）
  --apps=LIST        指定安装的应用（逗号分隔），例如: --apps=fish,neovim,uv,tmux,yazi
                     可选值: fish, neovim, uv, tmux, yazi
  --proxy=ADDR       设置 HTTP/HTTPS 代理地址（例如: --proxy=http://127.0.0.1:7890）
  --no-proxy         不使用代理（跳过代理询问）
  -h, --help         显示此帮助信息

示例:
  install.sh                                    # 交互式选择
  install.sh --user=deploy --overwrite --all    # 为 deploy 用户安装全部
  install.sh --user=root --skip-dotfiles --apps=uv,tmux
USAGE
  exit 0
}

contains() {
  local item="$1"
  shift
  for elem in "$@"; do
    [[ "$elem" == "$item" ]] && return 0
  done
  return 1
}

# 以目标用户身份执行命令（保留代理环境变量）
run_as_user() {
  if [[ "$TARGET_USER" == "root" ]]; then
    eval "$@"
  else
    sudo -u "$TARGET_USER" --preserve-env=http_proxy,https_proxy,HTTP_PROXY,HTTPS_PROXY,no_proxy,NO_PROXY \
      bash -c "$@"
  fi
}

# ==========================================
# 权限检查
# ==========================================
if [[ "$(id -u)" -ne 0 ]]; then
  echo "错误: 本脚本需要以 root 身份运行"
  echo "请使用: su -c 'bash install.sh' 或以 root 登录后执行"
  exit 1
fi

# ==========================================
# 解析命令行参数
# ==========================================
for arg in "$@"; do
  case "$arg" in
  --user=*)
    TARGET_USER="${arg#--user=}"
    ;;
  --overwrite)
    DOTFILES_MODE="overwrite"
    ;;
  --skip-dotfiles)
    DOTFILES_MODE="skip"
    ;;
  --all)
    SELECTED_APPS=("${ALL_APPS[@]}")
    APPS_SPECIFIED=true
    ;;
  --apps=*)
    IFS=',' read -ra SELECTED_APPS <<<"${arg#--apps=}"
    APPS_SPECIFIED=true
    ;;
  --proxy=*)
    PROXY_ADDR="${arg#--proxy=}"
    ;;
  --no-proxy)
    PROXY_ADDR="none"
    ;;
  -h | --help)
    usage
    ;;
  *)
    echo "未知参数: $arg"
    echo "使用 --help 查看帮助"
    exit 1
    ;;
  esac
done

# ==========================================
# 交互式选择
# ==========================================

# 0. 代理设置
if [[ -z "$PROXY_ADDR" ]]; then
  echo ""
  echo "========== 代理配置 =========="
  echo "如果你的网络需要通过代理访问外网，请输入完整代理地址"
  echo "例如: http://127.0.0.1:7890 或 socks5://192.168.1.1:1080"
  echo ""
  read -rp "请输入代理地址 (直接回车跳过): " PROXY_ADDR
  if [[ -z "$PROXY_ADDR" ]]; then
    PROXY_ADDR="none"
  fi
fi

if [[ "$PROXY_ADDR" != "none" ]]; then
  echo "🌐 设置代理: $PROXY_ADDR"
  export http_proxy="$PROXY_ADDR"
  export https_proxy="$PROXY_ADDR"
  export HTTP_PROXY="$PROXY_ADDR"
  export HTTPS_PROXY="$PROXY_ADDR"
  export no_proxy="localhost,127.0.0.1"
  export NO_PROXY="localhost,127.0.0.1"
  cat >/etc/apt/apt.conf.d/99proxy <<EOF
Acquire::http::Proxy "$PROXY_ADDR";
Acquire::https::Proxy "$PROXY_ADDR";
EOF
else
  echo "🌐 不使用代理"
  rm -f /etc/apt/apt.conf.d/99proxy
fi

# 1. 目标用户选择
if [[ -z "$TARGET_USER" ]]; then
  echo ""
  echo "========== 目标用户 =========="
  echo "系统软件将由 root 安装，dotfiles 和用户配置将应用到目标用户"
  echo ""
  read -rp "请输入目标用户名 (默认: root): " TARGET_USER
  TARGET_USER="${TARGET_USER:-root}"
fi

# 验证目标用户
if [[ "$TARGET_USER" != "root" ]] && ! id "$TARGET_USER" &>/dev/null; then
  echo "用户 '$TARGET_USER' 不存在"
  read -rp "是否创建该用户? [y/N]: " create_user
  if [[ "$create_user" =~ ^[Yy]$ ]]; then
    adduser --disabled-password --gecos "" "$TARGET_USER"
    echo "✅ 用户 $TARGET_USER 已创建"
  else
    echo "已取消"
    exit 1
  fi
fi

TARGET_HOME=$(eval echo "~$TARGET_USER")
DOTFILES_DIR="$TARGET_HOME/.dotfiles"

echo "📌 目标用户: $TARGET_USER (家目录: $TARGET_HOME)"

# 2. Dotfiles 覆盖策略
if [[ -z "$DOTFILES_MODE" ]]; then
  echo ""
  echo "========== Dotfiles 配置 =========="
  if [[ -d "$DOTFILES_DIR" ]]; then
    echo "检测到已有 dotfiles 仓库 ($DOTFILES_DIR)"
    echo "  1) 覆盖 - 备份冲突文件后重新 checkout"
    echo "  2) 跳过 - 保留现有配置，不做更改"
    echo ""
    while true; do
      read -rp "请选择 [1/2] (默认: 1): " choice
      case "${choice:-1}" in
      1)
        DOTFILES_MODE="overwrite"
        break
        ;;
      2)
        DOTFILES_MODE="skip"
        break
        ;;
      *) echo "无效输入，请输入 1 或 2" ;;
      esac
    done
  else
    echo "未检测到已有 dotfiles，将执行首次安装"
    DOTFILES_MODE="overwrite"
  fi
fi

# 3. 应用选择
if [[ "$APPS_SPECIFIED" != "true" ]]; then
  echo ""
  echo "========== 选择要安装的应用 =========="
  echo "核心应用（默认安装）:"
  for i in "${!CORE_APPS[@]}"; do
    idx=$((i + 1))
    echo "  $idx) ${CORE_APPS[$i]} [*]"
  done
  echo ""
  echo "可选应用:"
  for i in "${!OPTIONAL_APPS[@]}"; do
    idx=$((${#CORE_APPS[@]} + i + 1))
    echo "  $idx) ${OPTIONAL_APPS[$i]} [ ]"
  done
  echo ""
  echo "操作说明:"
  echo "  - 直接回车: 安装所有核心应用"
  echo "  - 输入编号（逗号分隔）: 安装指定应用，例如 1,2,3"
  echo "  - 输入 all: 安装所有应用（含可选）"
  echo ""

  read -rp "请选择: " selection

  if [[ -z "$selection" ]]; then
    SELECTED_APPS=("${CORE_APPS[@]}")
  elif [[ "$selection" == "all" ]]; then
    SELECTED_APPS=("${ALL_APPS[@]}")
  else
    IFS=',' read -ra indices <<<"$selection"
    SELECTED_APPS=()
    for idx in "${indices[@]}"; do
      idx=$(echo "$idx" | tr -d ' ')
      if [[ "$idx" -ge 1 && "$idx" -le "${#ALL_APPS[@]}" ]] 2>/dev/null; then
        SELECTED_APPS+=("${ALL_APPS[$((idx - 1))]}")
      else
        echo "警告: 忽略无效编号 '$idx'"
      fi
    done
  fi
fi

# ==========================================
# 打印安装摘要
# ==========================================
echo ""
echo "========== 安装摘要 =========="
echo "目标用户: $TARGET_USER"
echo "Dotfiles: $([[ "$DOTFILES_MODE" == "skip" ]] && echo "跳过" || echo "安装/覆盖")"
echo "应用: ${SELECTED_APPS[*]:-无}"
echo "=============================="
echo ""

# ==========================================
# 应用安装函数（系统级，以 root 执行）
# ==========================================
install_fish() {
  echo "🐟 安装 Fish Shell..."
  add-apt-repository -y ppa:fish-shell/release-4
  apt update
  apt install -y fish
}

install_neovim() {
  echo "📝 安装 Neovim..."
  add-apt-repository -y ppa:neovim-ppa/unstable
  apt update
  apt install -y neovim
}

install_uv() {
  echo "🐍 安装 uv (Python 包管理器)..."
  run_as_user 'curl -LsSf https://astral.sh/uv/install.sh | sh'
}

install_tmux() {
  echo "🖥️ 安装 tmux..."
  apt install -y tmux
}

install_yazi() {
  echo "📂 安装 yazi (终端文件管理器)..."
  apt install -y ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick
  curl -LsSf https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip -o /tmp/yazi.zip
  unzip -o /tmp/yazi.zip -d /tmp/yazi
  install -m 755 /tmp/yazi/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/yazi
  install -m 755 /tmp/yazi/yazi-x86_64-unknown-linux-gnu/ya /usr/local/bin/ya
  rm -rf /tmp/yazi /tmp/yazi.zip
}

# 用户级配置函数（以目标用户执行）
setup_fish() {
  echo "🐟 初始化 Fisher 与 Fish 插件..."
  run_as_user 'fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"'
  run_as_user 'fish -c "fisher update"'

  local current_shell
  current_shell=$(getent passwd "$TARGET_USER" | cut -d: -f7)
  if [[ "$current_shell" != "$(which fish)" ]]; then
    echo "🐚 将 Fish 设置为 $TARGET_USER 的默认 Shell..."
    chsh -s "$(which fish)" "$TARGET_USER"
  fi
}

setup_neovim() {
  echo "🌙 初始化 LazyVim 与 Neovim 插件 (这可能需要几分钟)..."
  run_as_user 'nvim --headless "+Lazy! sync" +qa'
}

# ==========================================
# 开始执行
# ==========================================
echo "📦 1. 安装基础依赖..."
apt update
apt install -y git curl unzip sudo software-properties-common

# 配置目标用户的 sudo 权限
if [[ "$TARGET_USER" != "root" ]]; then
  if ! groups "$TARGET_USER" | grep -qw sudo; then
    echo "🔑 将 $TARGET_USER 添加到 sudo 组..."
    usermod -aG sudo "$TARGET_USER"
  fi
fi

# ==========================================
# Dotfiles（以目标用户身份操作）
# ==========================================
if [[ "$DOTFILES_MODE" == "skip" ]]; then
  echo "⏭️  2. 跳过 Dotfiles 配置"
else
  echo "📥 2. 克隆并应用 Dotfiles..."

  run_as_user "grep -qxF '.dotfiles' '$TARGET_HOME/.gitignore' 2>/dev/null || echo '.dotfiles' >> '$TARGET_HOME/.gitignore'"

  if [[ -d "$DOTFILES_DIR" ]]; then
    echo "检测到已有仓库，执行 fetch 更新..."
    run_as_user "/usr/bin/git --git-dir='$DOTFILES_DIR/' --work-tree='$TARGET_HOME' fetch --all"
  else
    echo "正在克隆 dotfiles 仓库..."
    run_as_user "git clone --bare '$REPO_URL' '$DOTFILES_DIR'"
  fi

  BACKUP_DIR="$TARGET_HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
  run_as_user "mkdir -p '$BACKUP_DIR'"
  echo "⚙️ 尝试应用配置..."

  if run_as_user "/usr/bin/git --git-dir='$DOTFILES_DIR/' --work-tree='$TARGET_HOME' checkout" 2>/dev/null; then
    echo "✅ 配置应用成功！"
  else
    echo "⚠️ 发现冲突文件，正在备份到 $BACKUP_DIR..."
    run_as_user "/usr/bin/git --git-dir='$DOTFILES_DIR/' --work-tree='$TARGET_HOME' checkout 2>&1" | grep -E "\s+\." | awk '{print $1}' | while read -r file; do
      run_as_user "mkdir -p '$BACKUP_DIR/$(dirname "$file")' && mv '$TARGET_HOME/$file' '$BACKUP_DIR/$file'"
    done

    echo "🔄 备份完成，重新应用配置..."
    run_as_user "/usr/bin/git --git-dir='$DOTFILES_DIR/' --work-tree='$TARGET_HOME' checkout"
  fi

  run_as_user "/usr/bin/git --git-dir='$DOTFILES_DIR/' --work-tree='$TARGET_HOME' config --local status.showUntrackedFiles no"
fi

# ==========================================
# 安装选中的应用（系统级）
# ==========================================
echo ""
echo "🛠️ 3. 安装选中的应用..."

APT_UPDATED=false

if contains "fish" "${SELECTED_APPS[@]}"; then
  install_fish
  APT_UPDATED=true
fi

if contains "neovim" "${SELECTED_APPS[@]}"; then
  install_neovim
  APT_UPDATED=true
fi

if contains "tmux" "${SELECTED_APPS[@]}"; then
  if [[ "$APT_UPDATED" != "true" ]]; then
    apt update
  fi
  install_tmux
fi

if contains "uv" "${SELECTED_APPS[@]}"; then
  install_uv
fi

if contains "yazi" "${SELECTED_APPS[@]}"; then
  install_yazi
fi

# ==========================================
# 后置配置（用户级）
# ==========================================
echo ""
echo "⚙️ 4. 进行后置环境配置..."

if contains "fish" "${SELECTED_APPS[@]}"; then
  setup_fish
fi

if contains "neovim" "${SELECTED_APPS[@]}"; then
  setup_neovim
fi

# ==========================================
# 完成
# ==========================================
echo ""
echo "🎉 全部完成！"
if [[ "$TARGET_USER" != "root" ]]; then
  echo "🔑 $TARGET_USER 已加入 sudo 组"
fi
if contains "fish" "${SELECTED_APPS[@]}"; then
  echo "🐟 请重新登录终端以使用 Fish Shell"
fi
echo "已安装: ${SELECTED_APPS[*]:-无}"
echo ""
if [[ "$TARGET_USER" != "root" ]]; then
  echo "切换到目标用户: su - $TARGET_USER"
fi
