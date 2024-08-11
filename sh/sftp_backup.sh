#!/bin/bash

# 检查并安装tar
install_tar() {
    if command -v tar &> /dev/null; then
        echo
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
read -p "请输入存放备份文件的本地目录路径: " backup_dir
read -p "请输入需要保留的备份数量: " backup_count
read -p "请输入要备份的数据目录或文件路径 (多个路径用空格隔开): " backup_data

# 用户输入远程SFTP服务器信息（与SSH信息一致）
read -p "请输入SFTP服务器的用户名（与SSH用户名一致）: " sftp_user
read -p "请输入SFTP服务器的IP地址（与SSH IP地址一致）: " sftp_ip
read -p "请输入SFTP服务器的端口（通常为22，与SSH端口一致）: " sftp_port
read -p "请输入远程服务器上存放备份文件的路径: " remote_backup_dir

# 打包备份目录
backup_file="data_$(date +"%Y%m%d%H%M%S").tar.gz"
cd "$backup_dir" && tar czvf "$backup_file" $backup_data > /dev/null 2>&1

# 保留本地备份文件，删除多余的备份
cd "$backup_dir" && ls -t "$backup_dir"/*.tar.gz | tail -n +$(($backup_count + 1)) | xargs -I {} rm {}

# 传输备份文件到远程SFTP服务器
sftp -P "$sftp_port" "$sftp_user@$sftp_ip" << EOF
mkdir -p "$remote_backup_dir"
put "$backup_file" "$remote_backup_dir/$backup_file"
EOF

# 删除远程旧备份，保留用户指定的备份数量
sftp -P "$sftp_port" "$sftp_user@$sftp_ip" << EOF
cd "$remote_backup_dir"
ls -t *.tar.gz | tail -n +$(($backup_count + 1)) | xargs -I {} rm {}
EOF

echo "备份完成，本地和远程服务器上各保留最新的 $backup_count 份备份。"
