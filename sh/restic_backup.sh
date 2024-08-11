#!/bin/bash

# 检查并安装restic
install_restic() {
    if command -v restic &> /dev/null; then
        return 0
    else
        echo "未找到 restic，正在安装..."
        if [ -x "$(command -v dnf)" ]; then
            sudo dnf install -y restic
        elif [ -x "$(command -v yum)" ]; then
            sudo yum install -y restic
        elif [ -x "$(command -v apt)" ]; then
            sudo apt-get install -y restic
        elif [ -x "$(command -v apk)" ]; then
            sudo apk add restic
        elif [ -x "$(command -v pacman)" ]; then
            sudo pacman -S --noconfirm restic
        else
            echo "无法确定您的包管理器。请手动安装 restic 后再运行此脚本。"
            exit 1
        fi
    fi
}

# 检查并安装 restic
install_restic

# 设置默认参数
backup_repo="${1:-~/k_backup}"
backup_count="${2:-7}"
backup_data="${3:-/data/backup}"

# 创建存储库目录（如果不存在）
mkdir -p "$backup_repo"

# 初始化 restic 存储库（如果还未初始化）
if [ ! -d "$backup_repo/.restic" ]; then
    echo "初始化 restic 存储库..."
    restic init -r "$backup_repo"
fi

# 进行备份
echo "正在进行备份..."
restic backup -r "$backup_repo" $backup_data

# 清理旧的备份，保留指定数量的快照
restic forget -r "$backup_repo" --keep-last "$backup_count" --prune

# 用户输入定时备份间隔时间，确保输入的是数字
while true; do
    read -p "请输入定时备份的间隔时间（分钟数，只能输入数字）: " backup_interval
    if [[ $backup_interval =~ ^[0-9]+$ ]]; then
        break
    else
        echo "请输入有效的数字。"
    fi
done

# 设置定时任务，每隔指定分钟数进行一次备份
(crontab -l 2>/dev/null; echo "*/$backup_interval * * * * $(readlink -f "$0") '$backup_repo' '$backup_count' '$backup_data'") | crontab -

echo "备份完成，本地存储库保留最新的 $backup_count 个快照。自动备份任务已设置为每 $backup_interval 分钟执行一次。"
