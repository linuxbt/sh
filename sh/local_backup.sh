#!/bin/bash

# 获取脚本的绝对路径
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

# 检查并安装 tar
install_tar() {
    if ! command -v tar &> /dev/null; then
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

# 确保脚本具有执行权限
ensure_script_permissions() {
    chmod +x "$script_path"
}

# 用户输入备份参数
get_backup_params() {
    # 设置默认参数
    default_backup_dir="${HOME}/k_backup"
    default_backup_count=7
    default_backup_data="/data/backup"
    default_backup_interval=30  # 默认间隔时间为 30 分钟

    # 用户输入备份目录
    read -p "请输入备份目录路径 (默认: $default_backup_dir, 末尾不用带斜杆): " backup_dir
    backup_dir=${backup_dir:-$default_backup_dir}

    # 用户输入保留备份数量
    read -p "请输入需要保留的备份数量 (默认: $default_backup_count): " backup_count
    backup_count=${backup_count:-$default_backup_count}

    # 用户输入备份数据目录
    read -p "请输入要备份的数据目录或文件 (多个路径用空格隔开, 默认: $default_backup_data): " backup_data
    backup_data=${backup_data:-$default_backup_data}

    # 用户输入定时备份间隔时间，确保输入的是数字
    while true; do
        read -p "请输入定时备份的间隔时间（分钟数，只能输入数字，默认: $default_backup_interval 分钟）: " backup_interval
        if [[ -z "$backup_interval" ]]; then
            backup_interval=$default_backup_interval
            break
        elif [[ $backup_interval =~ ^[0-9]+$ ]]; then
            break
        else
            echo "请输入有效的数字。"
        fi
    done
}

# 检查备份和数据目录
check_directories() {
    if [ ! -d "$backup_dir" ]; then
        echo "备份目录 $backup_dir 不存在。请检查路径是否正确。"
        exit 1
    fi

    for path in $backup_data; do
        if [ ! -e "$path" ]; then
            echo "数据目录或文件 $path 不存在。"
            exit 1
        fi
    done
}

# 执行备份操作
perform_backup() {
    echo "正在备份..."
    if ! cd "$backup_dir" || ! tar czvf "data_$(date +"%Y%m%d%H%M%S").tar.gz" $backup_data > /dev/null 2>&1; then
        echo "备份失败。请检查目录和文件路径是否正确。"
        exit 1
    fi

    # 删除旧备份，保留用户指定的备份数量
    if ! cd "$backup_dir" || ! ls -t *.tar.gz | tail -n +$(($backup_count + 1)) | xargs -I {} rm {} > /dev/null 2>&1; then
        echo "删除旧备份失败。"
        exit 1
    fi
}

# 设置定时任务
set_cron_job() {
    # 创建新的 crontab 条目
    cron_job="*/$backup_interval * * * * $script_path"
    
    # 清空现有 crontab 任务并添加新的任务
    (crontab -l 2>/dev/null | grep -v "$script_path"; echo "$cron_job") | crontab -
}

# 主程序
install_tar
ensure_script_permissions
get_backup_params
check_directories
perform_backup
set_cron_job

echo "备份完成，并保留最新的 $backup_count 份备份。自动备份任务已设置为每 $backup_interval 分钟执行一次。"
