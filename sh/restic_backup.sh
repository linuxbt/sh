#!/bin/bash

# 检查并安装restic
install_restic() {
    if command -v restic &> /dev/null; then
        echo
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

# 用户输入备份目录和保留的备份份数
read -p "请输入用于存放备份文件的存储库路径 (restic repository): " backup_repo
read -p "请输入需要保留的备份数量 (snapshots 数量): " backup_count
read -p "请输入要备份的数据目录或文件路径 (多个路径用空格隔开): " backup_data

# 初始化 restic 存储库（如果还未初始化）
if [ ! -d "$backup_repo" ]; then
    echo "初始化 restic 存储库..."
    restic init -r "$backup_repo"
fi

# 进行备份
echo "正在进行备份..."
restic backup -r "$backup_repo" $backup_data

# 清理旧的备份，保留指定数量的快照
echo "正在清理旧备份..."
restic forget -r "$backup_repo" --keep-last "$backup_count" --prune

echo "备份完成，本地存储库保留最新的 $backup_count 个快照。"
