#!/bin/bash

# 检查并安装tar
install_tar() {
    if command -v tar &> /dev/null; then
        echo "tar 已安装"
    else
        echo "未找到 tar，正在安装..."
        if [ -x "$(command -v dnf)" ]; then
            sudo dnf install -y tar
        elif [ -x "$(command -v yum)" ]; then
            sudo yum install -y tar
        elif [ -x "$(command -v apt)" ]; then
            sudo apt-get install -y tar
        elif [ -x "$(command -v apk)" ]; then
            sudo apk add tar
        elif [ -x "$(command -v pacman)" ]; then
            sudo pacman -S --noconfirm tar
        else
            echo "无法确定您的包管理器。请手动安装 tar 后再运行此脚本。"
            exit 1
        fi
    fi
}

# 检查并安装 tar
install_tar

# 用户输入备份目录和保留的备份份数
read -p "请输入备份目录路径,末尾不用带斜杆: " backup_dir
read -p "请输入需要保留的备份数量: " backup_count
read -p "请输入要备份的数据目录或文件 (多个路径用空格隔开): " backup_data

# 打包备份目录
cd "$backup_dir" && tar czvf "data_$(date +"%Y%m%d%H%M%S").tar.gz" $backup_data > /dev/null 2>&1

# 删除旧备份，保留用户指定的备份数量
cd "$backup_dir" && ls -t "$backup_dir"/*.tar.gz | tail -n +$(($backup_count + 1)) | xargs -I {} rm {} > /dev/null 2>&1

echo "备份完成，并保留最新的 $backup_count 份备份。"
