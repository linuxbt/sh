#!/bin/bash

sh_v="3.0.3"

huang='\033[33m'
bai='\033[0m'
lv='\033[0;32m'
lan='\033[0;34m'
hong='\033[31m'
kjlan='\033[96m'
hui='\e[37m'



permission_granted="true"


CheckFirstRun_true() {
    if grep -q '^permission_granted="true"' /usr/local/bin/k > /dev/null 2>&1; then
        sed -i 's/^permission_granted="false"/permission_granted="true"/' ~/k.sh
        sed -i 's/^permission_granted="false"/permission_granted="true"/' /usr/local/bin/k
    fi
}

CheckFirstRun_true


ENABLE_STATS="true"

send_stats() {

    if [ "$ENABLE_STATS" == "false" ]; then
        return
    fi

    country=$(curl -s ipinfo.io/country)
    os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '"')
    cpu_arch=$(uname -m)
#    curl -s -X POST "https://api.linuxbt.pro/api/log" \
#         -H "Content-Type: application/json" \
#         -d "{\"action\":\"$1\",\"timestamp\":\"$(date -u '+%Y-%m-%d %H:%M:%S')\",\"country\":\"$country\",\"os_info\":\"$os_info\",\"cpu_arch\":\"$cpu_arch\",\"version\":\"$sh_v\"}" &>/dev/null &
}


yinsiyuanquan1() {

if grep -q '^ENABLE_STATS="true"' /usr/local/bin/k > /dev/null 2>&1; then
    status_message="${lv}正在采集数据${bai}"
elif grep -q '^ENABLE_STATS="false"' /usr/local/bin/k > /dev/null 2>&1; then
    status_message="${hui}采集已关闭${bai}"
else
    status_message="无法确定的状态"
fi

}


yinsiyuanquan2() {

if grep -q '^ENABLE_STATS="false"' /usr/local/bin/k > /dev/null 2>&1; then
    sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' ./k.sh
    sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' /usr/local/bin/k
fi

}



yinsiyuanquan2
cp ./k.sh /usr/local/bin/k > /dev/null 2>&1





CheckFirstRun_false() {
    if grep -q '^permission_granted="false"' /usr/local/bin/k > /dev/null 2>&1; then
        UserLicenseAgreement
    fi
}

# 提示用户同意条款
UserLicenseAgreement() {
    clear
    echo -e "${kjlan}欢迎使用K脚本工具箱${bai}"
    echo "首次使用脚本，请先阅读并同意用户许可协议:"
    echo "用户许可协议: https://blog.linuxbt.pro/user-license-agreement/"
    echo -e "----------------------"
    read -r -p "是否同意以上条款？(y/n): " user_input


    if [ "$user_input" = "y" ] || [ "$user_input" = "Y" ]; then
        send_stats "许可同意"
        sed -i 's/^permission_granted="false"/permission_granted="true"/' ~/k.sh
        sed -i 's/^permission_granted="false"/permission_granted="true"/' /usr/local/bin/k
    else
        send_stats "许可拒绝"
        clear
        exit 1
    fi
}

CheckFirstRun_false



ip_address() {
ipv4_address=$(curl -s ipv4.ip.sb)
ipv6_address=$(curl -s --max-time 1 ipv6.ip.sb)
}


install() {
    if [ $# -eq 0 ]; then
        echo "未提供软件包参数!"
        return 1
    fi

    local success=0

    for package in "$@"; do
        if ! command -v "$package" &>/dev/null; then
            echo "正在安装 $package..."
            if command -v dnf &>/dev/null; then
	        dnf install -y epel-release
                dnf install -y "$package" || success=1
            elif command -v yum &>/dev/null; then
	        yum -y install epel-release
                yum -y install "$package" || success=1
            elif command -v apt &>/dev/null; then
                apt install -y "$package" || success=1
            elif command -v apk &>/dev/null; then
                apk add "$package" || success=1
            elif command -v pacman &>/dev/null; then
                pacman -S --noconfirm "$package" || success=1
            elif command -v zypper &>/dev/null; then
                zypper install -y "$package" || success=1
            else
                echo "未知的包管理器!"
                return 1  
            fi
        else
            echo -e "${lv}$package 已经安装${bai}"
        fi
    done

    return $success
}



install_dependency() {
      clear
      install wget socat unzip tar
}


remove() {
    if [ $# -eq 0 ]; then
        echo "未提供软件包参数!"
        return 1
    fi

    for package in "$@"; do
        echo -e "${huang}正在卸载 $package...${bai}"
        if command -v dnf &>/dev/null; then
            dnf remove -y "${package}"*
        elif command -v yum &>/dev/null; then
            yum remove -y "${package}"*
        elif command -v apt &>/dev/null; then
            apt purge -y "${package}"*
        elif command -v apk &>/dev/null; then
            apk del "${package}*"
        elif command -v pacman &>/dev/null; then
            pacman -Rns --noconfirm "${package}"
        elif command -v zypper &>/dev/null; then
            zypper remove -y "${package}"
        else
            echo "未知的包管理器!"
            return 1
        fi
    done

    return 0
}


# 通用 systemctl 函数，适用于各种发行版
systemctl() {
    COMMAND="$1"
    SERVICE_NAME="$2"

    if command -v apk &>/dev/null; then
        service "$SERVICE_NAME" "$COMMAND"
    else
        /bin/systemctl "$COMMAND" "$SERVICE_NAME"
    fi
}


# 重启服务
restart() {
    systemctl restart "$1"
    if [ $? -eq 0 ]; then
        echo "$1 服务已重启。"
    else
        echo "错误：重启 $1 服务失败。"
    fi
}

# 启动服务
start() {
    systemctl start "$1"
    if [ $? -eq 0 ]; then
        echo "$1 服务已启动。"
    else
        echo "错误：启动 $1 服务失败。"
    fi
}

# 停止服务
stop() {
    systemctl stop "$1"
    if [ $? -eq 0 ]; then
        echo "$1 服务已停止。"
    else
        echo "错误：停止 $1 服务失败。"
    fi
}

# 查看服务状态
status() {
    systemctl status "$1"
    if [ $? -eq 0 ]; then
        echo "$1 服务状态已显示。"
    else
        echo "错误：无法显示 $1 服务状态。"
    fi
}


enable() {
    SERVICE_NAME="$1"
    if command -v apk &>/dev/null; then
        rc-update add "$SERVICE_NAME" default
    else
       /bin/systemctl enable "$SERVICE_NAME"
    fi

    echo "$SERVICE_NAME 已设置为开机自启。"
}

# 使用示例
# enable <service_name>


break_end() {
      echo -e "${lv}操作完成${bai}"
      echo "按任意键继续..."
      read -n 1 -s -r -p ""
      echo ""
      clear
}

linuxbt() {
            k || ./k.sh
            exit
}

check_port() {
    # 定义要检测的端口
    PORT=80

    # 检查端口占用情况
    result=$(ss -tulpn | grep ":\b$PORT\b")

    # 判断结果并输出相应信息
    if [ -n "$result" ]; then
        is_nginx_container=$(docker ps --format '{{.Names}}' | grep 'nginx')

        # 判断是否是Nginx容器占用端口
        if [ -n "$is_nginx_container" ]; then
            :
        else
            clear
            echo -e "${hong}注意：${bai}端口 ${huang}$PORT${hong} 已被占用，无法安装环境，卸载以下程序后重试！"
            echo "$result"
            break_end
            linuxbt

        fi
    fi
}



install_add_docker_guanfang() {
country=$(curl -s ipinfo.io/country)
if [ "$country" = "CN" ]; then
    cd ~
    curl -sS -O https://raw.githubusercontent.com/linuxbt/docker/main/install && chmod +x install
    sh install --mirror Aliyun
    rm -f install
    cat > /etc/docker/daemon.json << EOF
{
    "registry-mirrors": ["https://mirrors.aliyun.com/docker-ce"]
}
EOF

else
    curl -fsSL https://get.docker.com | sh
fi
systemctl enable docker
systemctl start docker

}



install_add_docker() {

    if  [ -f /etc/os-release ] && grep -q "Fedora" /etc/os-release; then
        install_add_docker_guanfang
    elif command -v dnf &>/dev/null; then
        dnf update -y
        dnf install -y yum-utils device-mapper-persistent-data lvm2
        rm -f /etc/yum.repos.d/docker*.repo > /dev/null
        country=$(curl -s ipinfo.io/country)
        arch=$(uname -m)
        if [ "$country" = "CN" ]; then
            if [ "$arch" = "x86_64" ]; then
                curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo | tee /etc/yum.repos.d/docker-ce.repo > /dev/null
            elif [ "$arch" = "aarch64" ]; then
                curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/centos/arm64/docker-ce.repo | tee /etc/yum.repos.d/docker-ce.repo > /dev/null
            fi
        else
            if [ "$arch" = "x86_64" ]; then
                yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo > /dev/null
            elif [ "$arch" = "aarch64" ]; then
                yum-config-manager --add-repo https://download.docker.com/linux/centos/arm64/docker-ce.repo > /dev/null
            fi
        fi
        dnf install -y docker-ce docker-ce-cli containerd.io
        systemctl enable docker
        systemctl start docker

    elif [ -f /etc/os-release ] && grep -q "Kali" /etc/os-release; then
        apt update
        apt upgrade -y
        apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        rm -f /usr/share/keyrings/docker-archive-keyring.gpg
        country=$(curl -s ipinfo.io/country)
        arch=$(uname -m)
        if [ "$country" = "CN" ]; then
            if [ "$arch" = "x86_64" ]; then
                sed -i '/^deb \[arch=amd64 signed-by=\/etc\/apt\/keyrings\/docker-archive-keyring.gpg\] https:\/\/mirrors.aliyun.com\/docker-ce\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
                echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            elif [ "$arch" = "aarch64" ]; then
                sed -i '/^deb \[arch=arm64 signed-by=\/etc\/apt\/keyrings\/docker-archive-keyring.gpg\] https:\/\/mirrors.aliyun.com\/docker-ce\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
                echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            fi
        else
            if [ "$arch" = "x86_64" ]; then
                sed -i '/^deb \[arch=amd64 signed-by=\/usr\/share\/keyrings\/docker-archive-keyring.gpg\] https:\/\/download.docker.com\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
                echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            elif [ "$arch" = "aarch64" ]; then
                sed -i '/^deb \[arch=arm64 signed-by=\/usr\/share\/keyrings\/docker-archive-keyring.gpg\] https:\/\/download.docker.com\/linux\/debian bullseye stable/d' /etc/apt/sources.list.d/docker.list > /dev/null
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg > /dev/null
                echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            fi
        fi
        apt update
        apt install -y docker-ce docker-ce-cli containerd.io
        systemctl enable docker
        systemctl start docker

    elif command -v apt &>/dev/null || command -v yum &>/dev/null; then
        install_add_docker_guanfang
    else
        install docker docker-compose
        systemctl enable docker
        systemctl start docker
    fi
    sleep 2
}


install_docker() {
    if ! command -v docker &>/dev/null; then
        install_add_docker
    else
        echo "Docker环境已经安装"
    fi
}



check_crontab_installed() {
    if command -v crontab >/dev/null 2>&1; then
        echo "crontab 已经安装。"
        return 1
    else
        install_crontab
        return 0
    fi
}



install_crontab() {

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|kali)
                apt update
                apt install -y cron
                systemctl enable cron
                systemctl start cron
                ;;
            centos|rhel|almalinux|rocky|fedora)
                yum install -y cronie
                systemctl enable crond
                systemctl start crond
                ;;
            alpine)
                apk add --no-cache cronie
                rc-update add crond
                rc-service crond start
                ;;
            arch|manjaro)
                pacman -S --noconfirm cronie
                systemctl enable cronie
                systemctl start cronie
                ;;
            opensuse|suse|opensuse-tumbleweed)
                zypper install -y cron
                systemctl enable cron
                systemctl start cron
                ;;
  
            *)
                echo "不支持的发行版: $ID"
                exit 1
                ;;
        esac
    else
        echo "无法确定操作系统。"
        exit 1
    fi

    echo "crontab 已安装且 cron 服务正在运行。"
}



docker_ipv6_on() {
mkdir -p /etc/docker &>/dev/null

cat > /etc/docker/daemon.json << EOF

{
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64"
}

EOF

k restart docker

echo "Docker已开启v6访问"

}


docker_ipv6_off() {

rm -rf etc/docker/daemon.json &>/dev/null

k restart docker

echo "Docker已关闭v6访问"

}



iptables_open() {
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F

    ip6tables -P INPUT ACCEPT
    ip6tables -P FORWARD ACCEPT
    ip6tables -P OUTPUT ACCEPT
    ip6tables -F

}



add_swap() {
    # 获取当前系统中所有的 swap 分区
    swap_partitions=$(grep -E '^/dev/' /proc/swaps | awk '{print $1}')

    # 遍历并删除所有的 swap 分区
    for partition in $swap_partitions; do
      swapoff "$partition"
      wipefs -a "$partition"  # 清除文件系统标识符
      mkswap -f "$partition"
    done

    # 确保 /swapfile 不再被使用
    swapoff /swapfile > /dev/null 2>&1

    # 删除旧的 /swapfile
    rm -f /swapfile > /dev/null 2>&1

    # 创建新的 swap 分区
    dd if=/dev/zero of=/swapfile bs=1M count=$new_swap
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    if [ -f /etc/alpine-release ]; then
        echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
        echo "nohup swapon /swapfile" >> /etc/local.d/swap.start
        chmod +x /etc/local.d/swap.start
        rc-update add local
    else
        echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
    fi

    echo -e "虚拟内存大小已调整为${huang}${new_swap}${bai}MB"
}

check_swap() {

swap_total=$(free -m | awk 'NR==3{print $2}')

 # 判断是否需要创建虚拟内存
if [ "$swap_total" -gt 0 ]; then
    :
else
    new_swap=1024
    add_swap
fi

}


ldnmp_v() {

      # 获取nginx版本
      nginx_version=$(docker exec nginx nginx -v 2>&1)
      nginx_version=$(echo "$nginx_version" | grep -oP '(?:openresty|nginx)/\K[\d.]+')
      echo -n -e "nginx : ${huang}v$nginx_version${bai}"

      # 获取mysql版本
      dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
      mysql_version=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SELECT VERSION();" 2>/dev/null | tail -n 1)
      echo -n -e "            mysql : ${huang}v$mysql_version${bai}"

      # 获取php版本
      php_version=$(docker exec php php -v 2>/dev/null | grep -oP "PHP \K[0-9]+\.[0-9]+\.[0-9]+")
      echo -n -e "            php : ${huang}v$php_version${bai}"

      # 获取redis版本
      redis_version=$(docker exec redis redis-server -v 2>&1 | grep -oP "v=+\K[0-9]+\.[0-9]+")
      echo -e "            redis : ${huang}v$redis_version${bai}"

      echo "------------------------"
      echo ""

}


install_ldnmp() {

      check_swap
      # 创建用户和组（使用 UID 82 和 GID 82）
      groupadd -g 82 www-data || true
      useradd -u 82 -g www-data -s /bin/bash www-data || true
      #确保nginx相关目录权限
      chown -R 82:82 /home/web/conf.d /home/web/certs /home/web/html /home/web/log /home/web/nginx.conf
      cd /home/web && docker compose up -d
      clear
      echo "正在配置LDNMP环境，请耐心稍等……"

      # 定义要执行的命令
      commands=(
          #"docker exec nginx chmod -R 777 /var/www/html"
          "docker restart nginx > /dev/null 2>&1"

          # "docker exec php sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories > /dev/null 2>&1"
          # "docker exec php74 sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories > /dev/null 2>&1"

          "docker exec php apk update > /dev/null 2>&1"
          "docker exec php74 apk update > /dev/null 2>&1"

          # php安装包管理
          "curl -sL https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -o /usr/local/bin/install-php-extensions > /dev/null 2>&1"
          "docker exec -u 0 php mkdir -p /usr/local/bin/ > /dev/null 2>&1"
          "docker exec -u 0 php74 mkdir -p /usr/local/bin/ > /dev/null 2>&1"
          "docker cp /usr/local/bin/install-php-extensions php:/usr/local/bin/ > /dev/null 2>&1"
          "docker cp /usr/local/bin/install-php-extensions php74:/usr/local/bin/ > /dev/null 2>&1"
	  "docker exec -u 0 php chown -R www-data:www-data /usr/local/bin/install-php-extensions > /dev/null 2>&1"
          "docker exec -u 0 php74 chown -R www-data:www-data /usr/local/bin/install-php-extensions > /dev/null 2>&1"
          "docker exec -u 0 php chmod +x /usr/local/bin/install-php-extensions > /dev/null 2>&1"
          "docker exec -u 0 php74 chmod +x /usr/local/bin/install-php-extensions > /dev/null 2>&1"

          # php安装扩展
          "docker exec -u 0 php install-php-extensions imagick > /dev/null 2>&1"
          "docker exec -u 0 php install-php-extensions mysqli > /dev/null 2>&1"
          "docker exec -u 0 php install-php-extensions pdo_mysql > /dev/null 2>&1"
          "docker exec -u 0 php install-php-extensions gd > /dev/null 2>&1"
          "docker exec -u 0 php install-php-extensions intl > /dev/null 2>&1"
          "docker exec -u 0 php install-php-extensions zip > /dev/null 2>&1"
          "docker exec -u 0 php install-php-extensions exif > /dev/null 2>&1"
          "docker exec -u 0 php install-php-extensions bcmath > /dev/null 2>&1"
          "docker exec -u 0 php install-php-extensions opcache > /dev/null 2>&1"
          "docker exec -u 0 php install-php-extensions redis > /dev/null 2>&1"


          # php配置参数
          "docker exec -u 0 php sh -c 'echo \"upload_max_filesize=50M \" > /usr/local/etc/php/conf.d/uploads.ini' > /dev/null 2>&1"
          "docker exec -u 0 php sh -c 'echo \"post_max_size=50M \" > /usr/local/etc/php/conf.d/post.ini' > /dev/null 2>&1"
          "docker exec -u 0 php sh -c 'echo \"memory_limit=256M\" > /usr/local/etc/php/conf.d/memory.ini' > /dev/null 2>&1"
          "docker exec -u 0 php sh -c 'echo \"max_execution_time=1200\" > /usr/local/etc/php/conf.d/max_execution_time.ini' > /dev/null 2>&1"
          "docker exec -u 0 php sh -c 'echo \"max_input_time=600\" > /usr/local/etc/php/conf.d/max_input_time.ini' > /dev/null 2>&1"

          # php重启
          #"docker exec php chmod -R 777 /var/www/html"
          "docker restart php > /dev/null 2>&1"

          # php7.4安装扩展
          "docker exec -u 0 php74 install-php-extensions imagick > /dev/null 2>&1"
          "docker exec -u 0 php74 install-php-extensions mysqli > /dev/null 2>&1"
          "docker exec -u 0 php74 install-php-extensions pdo_mysql > /dev/null 2>&1"
          "docker exec -u 0 php74 install-php-extensions gd > /dev/null 2>&1"
          "docker exec -u 0 php74 install-php-extensions intl > /dev/null 2>&1"
          "docker exec -u 0 php74 install-php-extensions zip > /dev/null 2>&1"
          "docker exec -u 0 php74 install-php-extensions exif > /dev/null 2>&1"
          "docker exec -u 0 php74 install-php-extensions bcmath > /dev/null 2>&1"
          "docker exec -u 0 php74 install-php-extensions opcache > /dev/null 2>&1"
          "docker exec -u 0 php74 install-php-extensions redis > /dev/null 2>&1"

          # php7.4配置参数
          "docker exec -u 0 php74 sh -c 'echo \"upload_max_filesize=50M \" > /usr/local/etc/php/conf.d/uploads.ini' > /dev/null 2>&1"
          "docker exec -u 0 php74 sh -c 'echo \"post_max_size=50M \" > /usr/local/etc/php/conf.d/post.ini' > /dev/null 2>&1"
          "docker exec -u 0 php74 sh -c 'echo \"memory_limit=256M\" > /usr/local/etc/php/conf.d/memory.ini' > /dev/null 2>&1"
          "docker exec -u 0 php74 sh -c 'echo \"max_execution_time=1200\" > /usr/local/etc/php/conf.d/max_execution_time.ini' > /dev/null 2>&1"
          "docker exec -u 0 php74 sh -c 'echo \"max_input_time=600\" > /usr/local/etc/php/conf.d/max_input_time.ini' > /dev/null 2>&1"

          # php7.4重启
          #"docker exec php74 chmod -R 777 /var/www/html"
          "docker restart php74 > /dev/null 2>&1"

          # redis调优
          "docker exec -it redis redis-cli CONFIG SET maxmemory 512mb > /dev/null 2>&1"
          "docker exec -it redis redis-cli CONFIG SET maxmemory-policy allkeys-lru > /dev/null 2>&1"

          # 最后一次php重启
          "docker restart php > /dev/null 2>&1"
          "docker restart php74 > /dev/null 2>&1"


      )

      total_commands=${#commands[@]}  # 计算总命令数

      for ((i = 0; i < total_commands; i++)); do
          command="${commands[i]}"
          eval $command  # 执行命令

          # 打印百分比和进度条
          percentage=$(( (i + 1) * 100 / total_commands ))
          completed=$(( percentage / 2 ))
          remaining=$(( 50 - completed ))
          progressBar="["
          for ((j = 0; j < completed; j++)); do
              progressBar+="#"
          done
          for ((j = 0; j < remaining; j++)); do
              progressBar+="."
          done
          progressBar+="]"
          echo -ne "\r[${lv}$percentage%${bai}] $progressBar"
      done

      echo  # 打印换行，以便输出不被覆盖


      clear
      echo "LDNMP环境安装完毕"
      echo "------------------------"
      ldnmp_v

}


install_certbot() {

    install certbot

    cd ~

    # 下载并使脚本可执行
    mkdir ~/.k_certs && cd ~/.k_certs
    curl -sS -O https://raw.githubusercontent.com/linuxbt/sh/main/auto_cert_renewal.sh
    chmod +x auto_cert_renewal.sh

    # 设置定时任务字符串
    check_crontab_installed
    cron_job="0 0 * * * ~/.k_certs/auto_cert_renewal.sh"

    # 检查是否存在相同的定时任务
    existing_cron=$(crontab -l 2>/dev/null | grep -F "$cron_job")

    # 如果不存在，则添加定时任务
    if [ -z "$existing_cron" ]; then
        (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
        echo "续签任务已添加"
    fi
}


install_ssltls() {
      docker stop nginx > /dev/null 2>&1
      cd ~
      certbot_version=$(certbot --version 2>&1 | grep -oP "\d+\.\d+\.\d+")

      version_ge() {
          [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$1" ]
      }

      if version_ge "$certbot_version" "1.17.0"; then
          certbot certonly --standalone -d $yuming --email your@email.com --agree-tos --no-eff-email --force-renewal --key-type ecdsa
      else
          certbot certonly --standalone -d $yuming --email your@email.com --agree-tos --no-eff-email --force-renewal
      fi

      cp /etc/letsencrypt/live/$yuming/fullchain.pem /home/web/certs/${yuming}_cert.pem > /dev/null 2>&1
      cp /etc/letsencrypt/live/$yuming/privkey.pem /home/web/certs/${yuming}_key.pem > /dev/null 2>&1
      docker start nginx > /dev/null 2>&1
      certs_status
}



install_ssltls_text() {
    echo -e "${huang}$yuming 公钥信息${bai}"
    cat /etc/letsencrypt/live/$yuming/fullchain.pem
    echo ""
    echo -e "${huang}$yuming 私钥信息${bai}"
    cat /etc/letsencrypt/live/$yuming/privkey.pem
    echo ""
    echo -e "${huang}证书存放路径${bai}"
    echo "公钥: /etc/letsencrypt/live/$yuming/fullchain.pem"
    echo "私钥: /etc/letsencrypt/live/$yuming/privkey.pem"
    echo ""
}



add_ssl() {

add_yuming
install_certbot
install_ssltls
install_ssltls_text
ssl_ps
}


ssl_ps() {
    echo -e "${huang}已申请的证书到期情况${bai}"
    echo "站点信息                      证书到期时间"
    echo "------------------------"
    for cert_dir in /etc/letsencrypt/live/*; do
      cert_file="$cert_dir/fullchain.pem"
      if [ -f "$cert_file" ]; then
        domain=$(basename "$cert_dir")
        expire_date=$(openssl x509 -noout -enddate -in "$cert_file" | awk -F'=' '{print $2}')
        formatted_date=$(date -d "$expire_date" '+%Y-%m-%d')
        printf "%-30s%s\n" "$domain" "$formatted_date"
      fi
    done
    echo ""
}




default_server_ssl() {
install openssl

if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
    openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -keyout /home/web/certs/default_server.key -out /home/web/certs/default_server.crt -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
else
    openssl genpkey -algorithm Ed25519 -out /home/web/certs/default_server.key
    openssl req -x509 -key /home/web/certs/default_server.key -out /home/web/certs/default_server.crt -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
fi


}


nginx_status() {

    sleep 1

    nginx_container_name="nginx"

    # 获取容器的状态
    container_status=$(docker inspect -f '{{.State.Status}}' "$nginx_container_name" 2>/dev/null)

    # 获取容器的重启状态
    container_restart_count=$(docker inspect -f '{{.RestartCount}}' "$nginx_container_name" 2>/dev/null)

    # 检查容器是否在运行，并且没有处于"Restarting"状态
    if [ "$container_status" == "running" ]; then
        echo ""
    else
        rm -r /home/web/html/$yuming >/dev/null 2>&1
        rm /home/web/conf.d/$yuming.conf >/dev/null 2>&1
        rm /home/web/certs/${yuming}_key.pem >/dev/null 2>&1
        rm /home/web/certs/${yuming}_cert.pem >/dev/null 2>&1
        docker restart nginx >/dev/null 2>&1

        dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
        docker exec mysql mysql -u root -p"$dbrootpasswd" -e "DROP DATABASE $dbname;" 2> /dev/null

        echo -e "${hong}注意：${bai}检测到域名证书申请失败，请检测域名是否正确解析或更换域名重新尝试！"
    fi

}

repeat_add_yuming() {

domain_regex="^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$"
if [[ $yuming =~ $domain_regex ]]; then
  :
else
  echo -e "${huang}注意：${bai}域名格式不正确，请重新输入"
  break_end
  linuxbt
fi

if [ -e /home/web/conf.d/$yuming.conf ]; then
    echo -e "${huang}注意：${bai}当前 ${yuming} 域名已被使用，请前往31站点管理，删除站点，再部署 ${webname} ！"
    break_end
    linuxbt
fi

}


add_yuming() {
      ip_address
      echo -e "先将域名解析到本机IP: ${huang}$ipv4_address  $ipv6_address${bai}"
      read -p "请输入你解析的域名: " yuming
      repeat_add_yuming

}

remove_ssl() {
	# 注释掉SSL相关配置
	sed -i 's/^\s*listen 443 ssl;/#&/' /home/web/conf.d/$yuming.conf
	sed -i 's/^\s*listen\s*\[::\]:443\s*ssl;/#&/' /home/web/conf.d/$yuming.conf
	sed -i 's/^\s*ssl_certificate/#ssl_certificate/' /home/web/conf.d/$yuming.conf
	sed -i 's/^\s*ssl_certificate_key/#ssl_certificate_key/' /home/web/conf.d/$yuming.conf
	sed -i 's/^\s*return 301 https/#return 301 https/' /home/web/conf.d/$yuming.conf
	sed -i '/server_name/i\    listen 80;\n    listen [::]:80;' /home/web/conf.d/$yuming.conf	  
	sed -i '1,8s/^/#/' /home/web/conf.d/$yuming.conf
}


certs_status() {

    sleep 1
    file_path="/etc/letsencrypt/live/$yuming/fullchain.pem"
    if [ -f "$file_path" ]; then
        send_stats "域名证书申请成功"
    else
        send_stats "域名证书申请失败"
        echo -e "${hong}注意: ${bai}检测到域名证书申请失败，请检测域名是否正确解析或更换域名重新尝试！"
        break_end
        linux_ldnmp
    fi

}

add_db() {
      dbname=$(echo "$yuming" | sed -e 's/[^A-Za-z0-9]/_/g')
      dbname="${dbname}"

      dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
      dbuse=$(grep -oP 'MYSQL_USER:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
      dbusepasswd=$(grep -oP 'MYSQL_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
      docker exec mysql mysql -u root -p"$dbrootpasswd" -e "CREATE DATABASE $dbname; GRANT ALL PRIVILEGES ON $dbname.* TO \"$dbuse\"@\"%\";"
}

reverse_proxy() {
      ip_address
      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/reverse-proxy.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      sed -i "s/0.0.0.0/$ipv4_address/g" /home/web/conf.d/$yuming.conf
      sed -i "s/0000/$duankou/g" /home/web/conf.d/$yuming.conf
      docker restart nginx
}

restart_ldnmp() {
      #docker exec nginx chmod -R 777 /var/www/html
      #docker exec php chmod -R 777 /var/www/html
      #docker exec php74 chmod -R 777 /var/www/html

      docker restart nginx
      docker restart php
      docker restart php74

}

install_leichi() {
      STREAM=1 bash -c "$(curl -fsSLk https://waf-ce.chaitin.cn/release/latest/setup.sh)"    
}


has_ipv4_has_ipv6() {

ip_address
if [ -z "$ipv4_address" ]; then
    has_ipv4=false
else
    has_ipv4=true
fi

if [ -z "$ipv6_address" ]; then
    has_ipv6=false
else
    has_ipv6=true
fi


}

docker_app() {
send_stats "搭建$docker_name"
has_ipv4_has_ipv6
if docker inspect "$docker_name" &>/dev/null; then
    clear
    echo "$docker_name 已安装，访问地址: "
    if $has_ipv4; then
        echo "http:$ipv4_address:$docker_port"
    fi
    if $has_ipv6; then
        echo "http:[$ipv6_address]:$docker_port"
    fi
    echo ""
    echo "应用操作"
    echo "------------------------"
    echo "1. 更新应用             2. 卸载应用"
    echo "------------------------"
    echo "0. 返回上一级选单"
    echo "------------------------"
    read -p "请输入你的选择: " sub_choice

    case $sub_choice in
        1)
            clear
            docker rm -f "$docker_name"
            docker rmi -f "$docker_img"

            $docker_rum
            clear
            echo "$docker_name 已经安装完成"
            echo "------------------------"
            echo "您可以使用以下地址访问:"
            if $has_ipv4; then
                echo "http:$ipv4_address:$docker_port"
            fi
            if $has_ipv6; then
                echo "http:[$ipv6_address]:$docker_port"
            fi
            echo ""
            $docker_use
            $docker_passwd
            ;;
        2)
            clear
            docker rm -f "$docker_name"
            docker rmi -f "$docker_img"
            rm -rf "/home/docker/$docker_name"
            echo "应用已卸载"
            ;;
        0)
            # 跳出循环，退出菜单
            ;;
        *)
            # 跳出循环，退出菜单
            ;;
    esac
else
    clear
    echo "安装提示"
    echo "$docker_describe"
    echo "$docker_url"
    echo ""

    # 提示用户确认安装
    read -p "确定安装吗？(Y/N): " choice
    case "$choice" in
        [Yy])
            clear
            # 安装 Docker（请确保有 install_docker 函数）
            install_docker
            $docker_rum
            clear
            echo "$docker_name 已经安装完成"
            echo "------------------------"
            echo "您可以使用以下地址访问:"
            if $has_ipv4; then
                echo "http:$ipv4_address:$docker_port"
            fi
            if $has_ipv6; then
                echo "http:[$ipv6_address]:$docker_port"
            fi
            echo ""
            $docker_use
            $docker_passwd
            ;;
        [Nn])
            # 用户选择不安装
            ;;
        *)
            # 无效输入
            ;;
    esac
fi

}

cluster_python3() {
    cd ~/cluster/
    curl -sS -O https://raw.githubusercontent.com/linuxbt/python-for-vps/main/cluster/$py_task
    python3 ~/cluster/$py_task
}

tmux_run() {
    # Check if the session already exists
    tmux has-session -t $SESSION_NAME 2>/dev/null
    # $? is a special variable that holds the exit status of the last executed command
    if [ $? != 0 ]; then
      # Session doesn't exist, create a new one
      tmux new -s $SESSION_NAME
    else
      # Session exists, attach to it
      tmux attach-session -t $SESSION_NAME
    fi
}


tmux_run_d() {

base_name="tmuxd"
tmuxd_ID=1

# 检查会话是否存在的函数
session_exists() {
  tmux has-session -t $1 2>/dev/null
}

# 循环直到找到一个不存在的会话名称
while session_exists "$base_name-$tmuxd_ID"; do
  tmuxd_ID=$((tmuxd_ID + 1))
done

# 创建新的 tmux 会话
tmux new -d -s "$base_name-$tmuxd_ID" "$tmuxd"


}



f2b_status() {
     docker restart fail2ban
     sleep 3
     docker exec -it fail2ban fail2ban-client status
}

f2b_status_xxx() {
    docker exec -it fail2ban fail2ban-client status $xxx
}

f2b_install_sshd() {

    docker run -d \
        --name=fail2ban \
        --net=host \
        --cap-add=NET_ADMIN \
        --cap-add=NET_RAW \
        -e PUID=1000 \
        -e PGID=1000 \
        -e TZ=Etc/UTC \
        -e VERBOSITY=-vv \
        -v /path/to/fail2ban/config:/config \
        -v /var/log:/var/log:ro \
        -v /home/web/log/nginx/:/remotelogs/nginx:ro \
        --restart unless-stopped \
        lscr.io/linuxserver/fail2ban:latest

    sleep 3
    if grep -q 'Alpine' /etc/issue; then
        cd /path/to/fail2ban/config/fail2ban/filter.d
        curl -sS -O https://raw.githubusercontent.com/linuxbt/config/main/fail2ban/alpine-sshd.conf
        curl -sS -O https://raw.githubusercontent.com/linuxbt/config/main/fail2ban/alpine-sshd-ddos.conf
        cd /path/to/fail2ban/config/fail2ban/jail.d/
        curl -sS -O https://raw.githubusercontent.com/linuxbt/config/main/fail2ban/alpine-ssh.conf
    elif command -v dnf &>/dev/null; then
        cd /path/to/fail2ban/config/fail2ban/jail.d/
        curl -sS -O https://raw.githubusercontent.com/linuxbt/config/main/fail2ban/centos-ssh.conf
    else
        install rsyslog
        systemctl start rsyslog
        systemctl enable rsyslog
        cd /path/to/fail2ban/config/fail2ban/jail.d/
        curl -sS -O https://raw.githubusercontent.com/linuxbt/config/main/fail2ban/linux-ssh.conf
    fi
}

f2b_sshd() {
    if grep -q 'Alpine' /etc/issue; then
        xxx=alpine-sshd
        f2b_status_xxx
    elif command -v dnf &>/dev/null; then
        xxx=centos-sshd
        f2b_status_xxx
    else
        xxx=linux-sshd
        f2b_status_xxx
    fi
}




server_reboot() {

    read -p "$(echo -e "${huang}提示：${bai}现在重启服务器吗？(Y/N): ")" rboot
    case "$rboot" in
      [Yy])
        echo "已重启"
        reboot
        ;;
      [Nn])
        echo "已取消"
        ;;
      *)
        echo "无效的选择，请输入 Y 或 N。"
        ;;
    esac


}

output_status() {
    output=$(awk 'BEGIN { rx_total = 0; tx_total = 0 }
        NR > 2 { rx_total += $2; tx_total += $10 }
        END {
            rx_units = "Bytes";
            tx_units = "Bytes";
            if (rx_total > 1024) { rx_total /= 1024; rx_units = "KB"; }
            if (rx_total > 1024) { rx_total /= 1024; rx_units = "MB"; }
            if (rx_total > 1024) { rx_total /= 1024; rx_units = "GB"; }

            if (tx_total > 1024) { tx_total /= 1024; tx_units = "KB"; }
            if (tx_total > 1024) { tx_total /= 1024; tx_units = "MB"; }
            if (tx_total > 1024) { tx_total /= 1024; tx_units = "GB"; }

            printf("总接收: %.2f %s\n总发送: %.2f %s\n", rx_total, rx_units, tx_total, tx_units);
        }' /proc/net/dev)

}


ldnmp_install_status_one() {

   if docker inspect "php" &>/dev/null; then
    echo -e "${huang}LDNMP环境已安装。无法再次安装。可以使用37. 更新LDNMP环境${bai}"
    break_end
    linuxbt
   else
    echo
   fi

}


ldnmp_install_status() {

   if docker inspect "php" &>/dev/null; then
    echo "LDNMP环境已安装，开始部署 $webname"
   else
    echo -e "${huang}LDNMP环境未安装，请先安装LDNMP环境，再部署网站${bai}"
    break_end
    linuxbt

   fi

}


nginx_install_status() {

   if docker inspect "nginx" &>/dev/null; then
    echo "nginx环境已安装，开始部署 $webname"
   else
    echo -e "${huang}nginx未安装，请先安装nginx环境，再部署网站${bai}"
    break_end
    linuxbt

   fi

}

set_wordpress() {
# wordpress设置文件权限
WEB_ROOT="/home/web/html/$yuming"
find $WEB_ROOT -type d -exec chmod 755 {} \;
find $WEB_ROOT -type f -exec chmod 644 {} \;
chmod -R 755 $WEB_ROOT/wp-content/themes
chmod -R 755 $WEB_ROOT/wp-content/plugins
chmod -R 755 $WEB_ROOT/wp-content/uploads
chmod -R 755 $WEB_ROOT/wp-includes
chmod -R 755 $WEB_ROOT/wp-admin
chown -R 82:82 $WEB_ROOT
}

set_maccms() {
# maccms设置文件权限
WEB_ROOT="/home/web/html/$yuming"
find $WEB_ROOT -type d -exec chmod 755 {} \;
find $WEB_ROOT -type f -exec chmod 644 {} \;
chmod -R 755 $WEB_ROOT/runtime/
chmod -R 755 $WEB_ROOT/upload/
chmod -R 755 $WEB_ROOT/application/
chmod -R 755 $WEB_ROOT/addons/
chown -R 82:82 $WEB_ROOT
}

set_permissions() {
# 通用文件权限设置
WEB_ROOT="/home/web/html/$yuming"
chmod -R 755 $WEB_ROOT
chown -R 82:82 $WEB_ROOT
}


ldnmp_web_on() {
      clear
      echo "您的 $webname 搭建好了！"
      echo "http://$yuming"
      echo "------------------------"
      echo "$webname 安装信息如下: "

}

nginx_web_on() {
      clear
      echo "您的 $webname 搭建好了！"
      echo "http://$yuming"

}

leichi_waf_on() {
      clear
       echo "雷池WAF面板已经安装完成"
       echo "------------------------"
       echo "您可以使用以下地址访问:"
       ip_address
       echo "https://$ipv4_address:9443"       
       docker exec safeline-mgt resetadmin
       echo "---------------------------------------------"
       echo "------记得登录修改默认密码，和设置两步验证---------" 
       echo "测试旁入nginx是否成功，使用：http://你的站点域名/shell.php  提示403则说明对接成功"
       echo "-------------------------------------------------------------------------"
}

install_panel() {
            send_stats "搭建$panelname "
            if $lujing ; then
                clear
                echo "$panelname 已安装，应用操作"
                echo ""
                echo "------------------------"
                echo "1. 管理$panelname          2. 卸载$panelname"
                echo "------------------------"
                echo "0. 返回上一级选单"
                echo "------------------------"
                read -p "请输入你的选择: " sub_choice

                case $sub_choice in
                    1)
                        clear
                        $gongneng1
                        $gongneng1_1
                        ;;
                    2)
                        clear
                        $gongneng2
                        $gongneng2_1
                        $gongneng2_2
                        ;;
                    0)
                        break  # 跳出循环，退出菜单
                        ;;
                    *)
                        break  # 跳出循环，退出菜单
                        ;;
                esac
            else
                clear
                echo "安装提示"
                echo "如果您已经安装了其他面板工具或者LDNMP建站环境，建议先卸载，再安装 $panelname！"
                echo "会根据系统自动安装，支持Debian，Ubuntu，Centos"
                echo "官网介绍: $panelurl "
                echo ""

                read -p "确定安装 $panelname 吗？(Y/N): " choice
                case "$choice" in
                    [Yy])
                        install wget
                        if grep -q 'Alpine' /etc/issue; then
                            $ubuntu_mingling
                            $ubuntu_mingling2
                        elif command -v dnf &>/dev/null; then
                            $centos_mingling
                            $centos_mingling2
                        elif grep -qi 'Ubuntu' /etc/os-release; then
                            $ubuntu_mingling
                            $ubuntu_mingling2
                        elif grep -qi 'Debian' /etc/os-release; then
                            $ubuntu_mingling
                            $ubuntu_mingling2
                        else
                            echo "Unsupported OS"
                        fi
                                                    ;;
                    [Nn])
                        ;;
                    *)
                        ;;
                esac

            fi

}


current_timezone() {
    if grep -q 'Alpine' /etc/issue; then
       date +"%Z %z"
    else
       timedatectl | grep "Time zone" | awk '{print $3}'
    fi

}


set_timedate() {
    shiqu="$1"
    if grep -q 'Alpine' /etc/issue; then
        install tzdata
        cp /usr/share/zoneinfo/${shiqu} /etc/localtime
        hwclock --systohc
    else
        timedatectl set-timezone ${shiqu}
    fi
}


wait_for_lock() {
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        echo "等待dpkg锁释放..."
        sleep 1
    done
}

# 修复dpkg中断问题
fix_dpkg() {
    DEBIAN_FRONTEND=noninteractive dpkg --configure -a
}



linux_update() {
    echo "正在系统更新..."
    if command -v dnf &>/dev/null; then
        dnf -y update
    elif command -v yum &>/dev/null; then
        yum -y update
    elif command -v apt &>/dev/null; then
        wait_for_lock
        fix_dpkg
        DEBIAN_FRONTEND=noninteractive apt update -y
        DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
    elif command -v apk &>/dev/null; then
        apk update && apk upgrade
    elif command -v pacman &>/dev/null; then
        pacman -Syu --noconfirm
    else
        echo "未知的包管理器!"
        return 1
    fi
}


linux_clean() {
    echo "正在系统清理..."
    if command -v dnf &>/dev/null; then
        dnf autoremove -y
        dnf clean all
        dnf makecache
        journalctl --rotate
        journalctl --vacuum-time=1s
        journalctl --vacuum-size=50M
        dnf remove $(dnf repoquery --installonly --latest-limit=-1 -q) -y

    elif command -v yum &>/dev/null; then
        yum autoremove -y
        yum clean all
        yum makecache
        journalctl --rotate
        journalctl --vacuum-time=1s
        journalctl --vacuum-size=50M
        yum remove $(rpm -q kernel | grep -v $(uname -r)) -y

    elif command -v apt &>/dev/null; then
        wait_for_lock
        fix_dpkg
        apt autoremove --purge -y
        apt clean -y
        apt autoclean -y
        apt remove --purge $(dpkg -l | awk '/^rc/ {print $2}') -y
        journalctl --rotate
        journalctl --vacuum-time=1s
        journalctl --vacuum-size=50M
        apt remove --purge $(dpkg -l | awk '/^ii linux-(image|headers)-[^ ]+/{print $2}' | grep -v $(uname -r | sed 's/-.*//') | xargs) -y

    elif command -v apk &>/dev/null; then
        apk del --purge $(apk info --installed | awk '{print $1}' | grep -v $(apk info --available | awk '{print $1}'))
        apk autoremove
        apk cache clean
        rm -rf /var/log/*
        rm -rf /var/cache/apk/*

    elif command -v pacman &>/dev/null; then
        pacman -Rns $(pacman -Qdtq) --noconfirm
        pacman -Scc --noconfirm
        journalctl --rotate
        journalctl --vacuum-time=1s
        journalctl --vacuum-size=50M

    else
        echo "未知的包管理器!"
        return 1
    fi

    return 0
}




bbr_on() {

cat > /etc/sysctl.conf << EOF
net.core.default_qdisc=fq_pie
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl -p

}


set_dns() {

# 检查机器是否有IPv6地址
ipv6_available=0
if [[ $(ip -6 addr | grep -c "inet6") -gt 0 ]]; then
    ipv6_available=1
fi

echo "nameserver $dns1_ipv4" > /etc/resolv.conf
echo "nameserver $dns2_ipv4" >> /etc/resolv.conf


if [[ $ipv6_available -eq 1 ]]; then
    echo "nameserver $dns1_ipv6" >> /etc/resolv.conf
    echo "nameserver $dns2_ipv6" >> /etc/resolv.conf
fi

echo "DNS地址已更新"
echo "------------------------"
cat /etc/resolv.conf
echo "------------------------"

}


restart_ssh() {
    restart sshd
}
restart_nginx() {
docker restart nginx
}
add_t1k() {
cd /home/web/conf.d/ && wget -O t1k.conf https://github.com/linuxbt/nginx/raw/main/t1k.conf
}
new_ssh_port() {


  # 备份 SSH 配置文件
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

  sed -i 's/^\s*#\?\s*Port/Port/' /etc/ssh/sshd_config

  # 替换 SSH 配置文件中的端口号
  sed -i "s/Port [0-9]\+/Port $new_port/g" /etc/ssh/sshd_config

  rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*

  # 重启 SSH 服务
  restart_ssh
  echo "SSH 端口已修改为: $new_port"

  #iptables_open
  remove iptables-persistent ufw firewalld iptables-services > /dev/null 2>&1

}



add_sshkey() {

# ssh-keygen -t rsa -b 4096 -C "xxxx@gmail.com" -f /root/.ssh/sshkey -N ""
ssh-keygen -t ed25519 -C "xxxx@gmail.com" -f /root/.ssh/sshkey -N ""

cat ~/.ssh/sshkey.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys


ip_address
echo -e "私钥信息已生成，务必复制保存，可保存成 ${huang}${ipv4_address}_ssh.key${bai} 文件，用于以后的SSH登录"

echo "--------------------------------"
cat ~/.ssh/sshkey
echo "--------------------------------"

sed -i -e 's/^\s*#\?\s*PermitRootLogin .*/PermitRootLogin prohibit-password/' \
       -e 's/^\s*#\?\s*PasswordAuthentication .*/PasswordAuthentication no/' \
       -e 's/^\s*#\?\s*PubkeyAuthentication .*/PubkeyAuthentication yes/' \
       -e 's/^\s*#\?\s*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*
echo -e "${lv}ROOT私钥登录已开启，已关闭ROOT密码登录，重连将会生效${bai}"

}


add_sshpasswd() {

echo "设置你的ROOT密码"
passwd
sed -i 's/^\s*#\?\s*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sed -i 's/^\s*#\?\s*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*
restart_ssh
echo -e "${lv}ROOT登录设置完毕！${bai}"

}


root_use() {
clear
[ "$EUID" -ne 0 ] && echo -e "${huang}注意：${bai}该功能需要root用户才能运行！" && break_end && linuxbt
}



dd_xitong() {
        send_stats "重装系统"
        dd_xitong_MollyLau() {
          country=$(curl -s ipinfo.io/country)
          if [ "$country" = "CN" ]; then
              wget --no-check-certificate -qO InstallNET.sh 'https://gitee.com/mb9e8j2/Tools/raw/master/Linux_reinstall/InstallNET.sh' && chmod a+x InstallNET.sh
          else
              wget --no-check-certificate -qO InstallNET.sh 'https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh' && chmod a+x InstallNET.sh
          fi
        }

        dd_xitong_bin456789() {
          country=$(curl -s ipinfo.io/country)
          if [ "$country" = "CN" ]; then
              curl -O https://mirror.ghproxy.com/https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh
          else
              curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh
          fi
        }


        dd_xitong_1() {
          echo -e "重装后初始用户名: ${huang}root${bai}  初始密码: ${huang}LeitboGi0ro${bai}  初始端口: ${huang}22${bai}"
          echo -e "按任意键继续..."
          read -n 1 -s -r -p ""
          install wget
          dd_xitong_MollyLau
        }

        dd_xitong_2() {
          echo -e "重装后初始用户名: ${huang}Administrator${bai}  初始密码: ${huang}Teddysun.com${bai}  初始端口: ${huang}3389${bai}"
          echo -e "按任意键继续..."
          read -n 1 -s -r -p ""
          install wget
          dd_xitong_MollyLau
        }

        dd_xitong_3() {
          echo -e "重装后初始用户名: ${huang}root${bai}  初始密码: ${huang}123@@@${bai}  初始端口: ${huang}22${bai}"
          echo -e "按任意键继续..."
          read -n 1 -s -r -p ""
          dd_xitong_bin456789
        }

        dd_xitong_4() {
          echo -e "重装后初始用户名: ${huang}Administrator${bai}  初始密码: ${huang}123@@@${bai}  初始端口: ${huang}3389${bai}"
          echo -e "按任意键继续..."
          read -n 1 -s -r -p ""
          dd_xitong_bin456789
        }

          while true; do
            root_use
	    echo -e "${hui}请备份数据，将为你重装系统，预计花费15分钟。${bai}"
	    echo -e "${hui}感谢MollyLau大佬和bin456789大佬的脚本支持！${bai}"
	    echo -e "${bai}------------------------${bai}"
	    echo -e "${lv}1. Debian 12                  2. Debian 11${bai}"
	    echo -e "${lv}3. Debian 10                  4. Debian 9${bai}"
	    echo -e "${bai}------------------------${bai}"
	    echo -e "${lan}11. Ubuntu 24.04              12. Ubuntu 22.04${bai}"
	    echo -e "${lan}13. Ubuntu 20.04              14. Ubuntu 18.04${bai}"
	    echo -e "${bai}------------------------${bai}"
	    echo -e "${hong}21. Rocky Linux 9             22. Rocky Linux 8${bai}"
	    echo -e "${hong}23. Alma Linux 9              24. Alma Linux 8${bai}"
	    echo -e "${hong}25. oracle Linux 9            26. oracle Linux 8${bai}"
	    echo -e "${hong}27. Fedora Linux 40           28. Fedora Linux 39${bai}"
	    echo -e "${hong}29. CentOS 7${bai}"
	    echo -e "${bai}------------------------${bai}"
	    echo -e "${lv}31. Alpine Linux              32. Arch Linux${bai}"
	    echo -e "${lv}33. Kali Linux                34. openEuler${bai}"
	    echo -e "${lv}35. openSUSE Tumbleweed${bai}"
	    echo -e "${bai}------------------------${bai}"
	    echo -e "${kjlan}41. Windows 11                42. Windows 10${bai}"
	    echo -e "${kjlan}43. Windows 7                 44. Windows Server 2022${bai}"
	    echo -e "${kjlan}45. Windows Server 2019       46. Windows Server 2016${bai}"
	    echo -e "${bai}------------------------${bai}"
	    echo -e "${bai}0. 返回上一级选单${bai}"
	    echo -e "${bai}------------------------${bai}"
            read -p "请选择要重装的系统: " sys_choice
            case "$sys_choice" in
              1)
                send_stats "重装debian 12"
                dd_xitong_1
                bash InstallNET.sh -debian 12
                reboot
                exit
                ;;
              2)
                send_stats "重装debian 11"
                dd_xitong_1
                bash InstallNET.sh -debian 11
                reboot
                exit
                ;;
              3)
                send_stats "重装debian 10"
                dd_xitong_1
                bash InstallNET.sh -debian 10
                reboot
                exit
                ;;
              4)
                send_stats "重装debian 9"
                dd_xitong_1
                bash InstallNET.sh -debian 9
                reboot
                exit
                ;;
              11)
                send_stats "重装ubuntu 24.04"
                dd_xitong_1
                bash InstallNET.sh -ubuntu 24.04
                reboot
                exit
                ;;
              12)
                send_stats "重装ubuntu 22.04"
                dd_xitong_1
                bash InstallNET.sh -ubuntu 22.04
                reboot
                exit
                ;;
              13)
                send_stats "重装ubuntu 20.04"
                dd_xitong_1
                bash InstallNET.sh -ubuntu 20.04
                reboot
                exit
                ;;
              14)
                send_stats "重装ubuntu 18.04"
                dd_xitong_1
                bash InstallNET.sh -ubuntu 18.04
                reboot
                exit
                ;;


              21)
                send_stats "重装rockylinux9"
                dd_xitong_3
                bash reinstall.sh rocky
                reboot
                exit
                ;;

              22)
                send_stats "重装rockylinux8"
                dd_xitong_3
                bash reinstall.sh rocky 8
                reboot
                exit
                ;;

              23)
                send_stats "重装alma9"
                dd_xitong_3
                bash reinstall.sh alma
                reboot
                exit
                ;;

              24)
                send_stats "重装alma8"
                dd_xitong_3
                bash reinstall.sh alma 8
                reboot
                exit
                ;;

              25)
                send_stats "重装oracle9"
                dd_xitong_3
                bash reinstall.sh oracle
                reboot
                exit
                ;;

              26)
                send_stats "重装oracle8"
                dd_xitong_3
                bash reinstall.sh oracle 8
                reboot
                exit
                ;;

              27)
                send_stats "重装fedora40"
                dd_xitong_3
                bash reinstall.sh fedora
                reboot
                exit
                ;;

              28)
                send_stats "重装fedora39"
                dd_xitong_3
                bash reinstall.sh fedora 39
                reboot
                exit
                ;;

              29)
                send_stats "重装centos 7"
                dd_xitong_1
                bash InstallNET.sh -centos 7
                reboot
                exit
                ;;

              31)
                send_stats "重装alpine"
                dd_xitong_1
                bash InstallNET.sh -alpine
                reboot
                exit
                ;;

              32)
                send_stats "重装arch"
                dd_xitong_3
                bash reinstall.sh arch
                reboot
                exit
                ;;

              33)
                send_stats "重装kali"
                dd_xitong_3
                bash reinstall.sh kali
                reboot
                exit
                ;;

              34)
                send_stats "重装openeuler"
                dd_xitong_3
                bash reinstall.sh openeuler
                reboot
                exit
                ;;

              35)
                send_stats "重装opensuse"
                dd_xitong_3
                bash reinstall.sh opensuse
                reboot
                exit
                ;;

              41)
                send_stats "重装windows11"
                dd_xitong_2
                bash InstallNET.sh -windows 11 -lang "cn"
                reboot
                exit
                ;;
              42)
                dd_xitong_2
                send_stats "重装windows10"
                bash InstallNET.sh -windows 10 -lang "cn"
                reboot
                exit
                ;;
              43)
                send_stats "重装windows7"
                dd_xitong_4
                URL="https://massgrave.dev/windows_7_links"
                web_content=$(wget -q -O - "$URL")
                iso_link=$(echo "$web_content" | grep -oP '(?<=href=")[^"]*cn[^"]*windows_7[^"]*professional[^"]*x64[^"]*\.iso')
                # bash reinstall.sh windows --image-name 'Windows 7 Professional' --lang zh-cn
                # bash reinstall.sh windows --iso='$iso_link' --image-name='Windows 7 PROFESSIONAL'
                bash reinstall.sh windows --iso="$iso_link" --image-name='Windows 7 PROFESSIONAL'
                reboot
                exit
                ;;
              44)
                send_stats "重装windows server 22"
                dd_xitong_4
                URL="https://massgrave.dev/windows_server_links"
                web_content=$(wget -q -O - "$URL")
                iso_link=$(echo "$web_content" | grep -oP '(?<=href=")[^"]*cn[^"]*windows_server[^"]*2022[^"]*x64[^"]*\.iso')
                bash reinstall.sh windows --iso="$iso_link" --image-name='Windows Server 2022 SERVERDATACENTER'
                reboot
                exit
                ;;
              45)
                send_stats "重装windows server 19"
                dd_xitong_2
                bash InstallNET.sh -windows 2019 -lang "cn"
                reboot
                exit
                ;;
              46)
                send_stats "重装windows server 16"
                dd_xitong_2
                bash InstallNET.sh -windows 2016 -lang "cn"
                reboot
                exit
                ;;
              0)
                break
                ;;
              *)
                echo "无效的选择，请重新输入。"
                break
                ;;
            esac
          done
}


bbrv3() {
          root_use
          send_stats "bbrv3管理"
          if dpkg -l | grep -q 'linux-xanmod'; then
            while true; do
                  clear
                  kernel_version=$(uname -r)
                  echo "您已安装xanmod的BBRv3内核"
                  echo "当前内核版本: $kernel_version"

                  echo ""
                  echo "内核管理"
                  echo "------------------------"
                  echo "1. 更新BBRv3内核              2. 卸载BBRv3内核"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                        apt purge -y 'linux-*xanmod1*'
                        update-grub

                        # wget -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes
                        wget -qO - https://raw.githubusercontent.com/linuxbt/sh/main/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes

                        # 步骤3：添加存储库
                        echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list

                        # version=$(wget -q https://dl.xanmod.org/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')
                        version=$(wget -q https://raw.githubusercontent.com/linuxbt/sh/main/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')

                        apt update -y
                        apt install -y linux-xanmod-x64v$version

                        echo "XanMod内核已更新。重启后生效"
                        rm -f /etc/apt/sources.list.d/xanmod-release.list
                        rm -f check_x86-64_psabi.sh*

                        server_reboot

                          ;;
                      2)
                        apt purge -y 'linux-*xanmod1*'
                        update-grub
                        echo "XanMod内核已卸载。重启后生效"
                        server_reboot
                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;

                  esac
            done
        else

          clear
          echo "请备份数据，将为你升级Linux内核开启BBR3"
          echo "官网介绍: https://xanmod.org/"
          echo "------------------------------------------------"
          echo "仅支持Debian/Ubuntu 仅支持x86_64架构"
          echo "VPS是512M内存的，请提前添加1G虚拟内存，防止因内存不足失联！"
          echo "------------------------------------------------"
          read -p "确定继续吗？(Y/N): " choice

          case "$choice" in
            [Yy])
            if [ -r /etc/os-release ]; then
                . /etc/os-release
                if [ "$ID" != "debian" ] && [ "$ID" != "ubuntu" ]; then
                    echo "当前环境不支持，仅支持Debian和Ubuntu系统"
                    break_end
                    linuxbt
                fi
            else
                echo "无法确定操作系统类型"
                break_end
                linuxbt
            fi

            # 检查系统架构
            arch=$(dpkg --print-architecture)
            if [ "$arch" != "amd64" ]; then
              echo "当前环境不支持，仅支持x86_64架构"
              break
            fi

            check_swap
            add_swap
            install wget gnupg

            # wget -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes
            wget -qO - https://raw.githubusercontent.com/linuxbt/sh/main/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes

            # 步骤3：添加存储库
            echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list

            # version=$(wget -q https://dl.xanmod.org/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')
            version=$(wget -q https://raw.githubusercontent.com/linuxbt/sh/main/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')

            apt update -y
            apt install -y linux-xanmod-x64v$version

            bbr_on

            echo "XanMod内核安装并BBR3启用成功。重启后生效"
            rm -f /etc/apt/sources.list.d/xanmod-release.list
            rm -f check_x86-64_psabi.sh*
            server_reboot

              ;;
            [Nn])
              echo "已取消"
              ;;
            *)
              echo "无效的选择，请输入 Y 或 N。"
              ;;
          esac
        fi



}


elrepo_install() {
    # 导入 ELRepo GPG 公钥
    echo "导入 ELRepo GPG 公钥..."
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    # 检测系统版本
    os_version=$(rpm -q --qf "%{VERSION}" $(rpm -qf /etc/os-release) 2>/dev/null | awk -F '.' '{print $1}')
    os_name=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    # 确保我们在一个支持的操作系统上运行
    if [[ "$os_name" != *"Red Hat"* && "$os_name" != *"AlmaLinux"* && "$os_name" != *"Rocky"* && "$os_name" != *"Oracle"* && "$os_name" != *"CentOS"* ]]; then
        echo "不支持的操作系统：$os_name"
        break_end
        linuxbt
    fi
    # 打印检测到的操作系统信息
    echo "检测到的操作系统: $os_name $os_version"
    # 根据系统版本安装对应的 ELRepo 仓库配置
    if [[ "$os_version" == 8 ]]; then
        echo "安装 ELRepo 仓库配置 (版本 8)..."
        yum -y install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
    elif [[ "$os_version" == 9 ]]; then
        echo "安装 ELRepo 仓库配置 (版本 9)..."
        yum -y install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm
    else
        echo "不支持的系统版本：$os_version"
        break_end
        linuxbt
    fi
    # 启用 ELRepo 内核仓库并安装最新的主线内核
    echo "启用 ELRepo 内核仓库并安装最新的主线内核..."
    yum -y --enablerepo=elrepo-kernel install kernel-ml
    echo "已安装 ELRepo 仓库配置并更新到最新主线内核。"
    server_reboot

}


elrepo() {
          root_use
          send_stats "红帽内核管理"
          if uname -r | grep -q 'elrepo'; then
            while true; do
                  clear
                  kernel_version=$(uname -r)
                  echo "您已安装elrepo内核"
                  echo "当前内核版本: $kernel_version"

                  echo ""
                  echo "内核管理"
                  echo "------------------------"
                  echo "1. 更新elrepo内核              2. 卸载elrepo内核"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                        dnf remove -y elrepo-release
                        rpm -qa | grep elrepo | grep kernel | xargs rpm -e --nodeps
                        elrepo_install
                        send_stats "更新红帽内核"
                        server_reboot

                          ;;
                      2)
                        dnf remove -y elrepo-release
                        rpm -qa | grep elrepo | grep kernel | xargs rpm -e --nodeps
                        echo "elrepo内核已卸载。重启后生效"
                        send_stats "卸载红帽内核"
                        server_reboot

                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;

                  esac
            done
        else

          clear
          echo "请备份数据，将为你升级Linux内核"
          echo "官网介绍: https://elrepo.org/"
          echo "------------------------------------------------"
          echo "仅支持红帽系列发行版 CentOS/RedHat/Alma/Rocky/oracle "
          echo "升级Linux内核可提升系统性能和安全，建议有条件的尝试，生产环境谨慎升级！"
          echo "------------------------------------------------"
          read -p "确定继续吗？(Y/N): " choice

          case "$choice" in
            [Yy])
              check_swap
              add_swap
              elrepo_install
              send_stats "升级红帽内核"
              server_reboot
              ;;
            [Nn])
              echo "已取消"
              ;;
            *)
              echo "无效的选择，请输入 Y 或 N。"
              ;;
          esac
        fi

}


clamav_freshclam() {
    echo -e "${huang}正在更新病毒库...${bai}"
    docker run --rm \
        --name clamav \
        --mount source=clam_db,target=/var/lib/clamav \
        clamav/clamav:latest \
        freshclam
}

clamav_scan() {
    if [ $# -eq 0 ]; then
        echo "请指定要扫描的目录。"
        return 1
    fi

    echo -e "${huang}正在扫描目录$@... ${bai}"

    # 构建 mount 参数
    MOUNT_PARAMS=""
    for dir in "$@"; do
        MOUNT_PARAMS+="--mount type=bind,source=${dir},target=/mnt/host${dir} "
    done

    # 构建 clamscan 命令参数
    SCAN_PARAMS=""
    for dir in "$@"; do
        SCAN_PARAMS+="/mnt/host${dir} "
    done

    mkdir -p /home/docker/clamav/log/ > /dev/null 2>&1
    > /home/docker/clamav/log/scan.log > /dev/null 2>&1

    # 执行 Docker 命令
    docker run -it --rm \
        --name clamav \
        --mount source=clam_db,target=/var/lib/clamav \
        $MOUNT_PARAMS \
        -v /home/docker/clamav/log/:/var/log/clamav/ \
        clamav/clamav:latest \
        clamscan -r --log=/var/log/clamav/scan.log $SCAN_PARAMS

    echo -e "${lv}$@ 扫描完成，病毒报告存放在${huang}/home/docker/clamav/log/scan.log${bai}"
    echo -e "${lv}如果有病毒请在${huang}scan.log${lv}文件中搜索FOUND关键字确认病毒位置 ${bai}"

}


clamav() {
          root_use
          send_stats "病毒扫描管理"
          while true; do
                clear
                echo "clamav病毒扫描工具"
                echo "------------------------"
                echo "是一个开源的防病毒软件工具，主要用于检测和删除各种类型的恶意软件。"
                echo "包括病毒、特洛伊木马、间谍软件、恶意脚本和其他有害软件。"
                echo -e "${huang}提示: ${bai} 目前该工具仅支持x86架构系统，不支持ARM架构！"
                echo "------------------------"
                echo -e "${lv}1. 全盘扫描 ${bai}             ${huang}2. 重要目录扫描 ${bai}            ${kjlan} 3. 自定义目录扫描 ${bai}"
                echo "------------------------"
                echo "0. 返回上一级选单"
                echo "------------------------"
                read -p "请输入你的选择: " sub_choice
                case $sub_choice in
                    1)
                      send_stats "全盘扫描"
                      install_docker
                      docker volume create clam_db > /dev/null 2>&1
                      clamav_freshclam
                      clamav_scan /
                      break_end

                        ;;
                    2)
                      send_stats "重要目录扫描"
                      install_docker
                      docker volume create clam_db > /dev/null 2>&1
                      clamav_freshclam
                      clamav_scan /etc /var /usr /home /root
                      break_end
                        ;;
                    3)
                      send_stats "自定义目录扫描"
                      read -p "请输入要扫描的目录，用空格分隔（例如：/etc /var /usr /home /root）: " directories
                      install_docker
                      clamav_freshclam
                      clamav_scan $directories
                      break_end
                        ;;
                    0)
                        break
                        ;;
                    *)
                        break  # 跳出循环，退出菜单
                        ;;
                esac
          done

}


download_hmscan() {
	# 封装河马webshell扫描，创建目录，下载解压，扫描
	mkdir -p /opt/hmscan  && cd /opt/hmscan
	wget -O  hm.tgz  https://dl.shellpub.com/hm/latest/hm-linux-amd64.tgz?version=1.8.3
	tar -xf hm.tgz
}


hmscan() {
          root_use
          send_stats "河马webshell扫描管理"
          while true; do
                clear
                echo "河马webshell扫描工具"
                echo "------------------------"
                echo "本工具主要用于检测各种类型的webshell文件。"
                echo "绿色软件，无需安装，下载完解压即可执行。"
                echo "------------------------"
                echo -e "${kjlan} 1. 目录扫描 ${bai}"
                echo -e "${huang}2. 大文件放后台扫描 ${bai}"
                echo -e "${lv}3. 查看扫描进度 ${bai}"
                echo -e "${lan}4. 查看扫描结果 ${bai}"		
                echo "------------------------"
                echo "0. 返回上一级选单"
                echo "------------------------"
                read -p "请输入你的选择: " sub_choice
                case $sub_choice in
                    1)
                      send_stats "目录扫描"
                      read -p "请输入要扫描的目录，用空格分隔（例如：/etc /var /usr /home /root）: " directories
                      download_hmscan
                      ./hm scan $directories
                      break_end
                        ;;

                    2)
                      send_stats "大文件后台扫描"
                      read -p "请输入要扫描的目录，用空格分隔（例如：/etc /var /usr /home /root）: " directories
                      download_hmscan
                      nohup ./hm scan $directories &
                      break_end
                        ;;

                    3)
                      send_stats "查看扫描进度"
                      cd /opt/hmscan
                      tail -f  nohup.out
                      break_end
                        ;;

                    4)
                      send_stats "查看扫描结果"
                      cd /opt/hmscan
                      cat result.csv || cat nohup.out
                      break_end
                        ;;

                    0)
                        break
                        ;;
                    *)
                        break  # 跳出循环，退出菜单
                        ;;
                esac
          done

}



# 高性能模式优化函数
optimize_high_performance() {
    echo -e "${lv}切换到${tiaoyou_moshi}...${bai}"

    echo -e "${lv}优化文件描述符...${bai}"
    ulimit -n 65535

    echo -e "${lv}优化虚拟内存...${bai}"
    sysctl -w vm.swappiness=10 2>/dev/null
    sysctl -w vm.dirty_ratio=15 2>/dev/null
    sysctl -w vm.dirty_background_ratio=5 2>/dev/null
    sysctl -w vm.overcommit_memory=1 2>/dev/null
    sysctl -w vm.min_free_kbytes=65536 2>/dev/null

    echo -e "${lv}优化网络设置...${bai}"
    sysctl -w net.core.rmem_max=16777216 2>/dev/null
    sysctl -w net.core.wmem_max=16777216 2>/dev/null
    sysctl -w net.core.netdev_max_backlog=250000 2>/dev/null
    sysctl -w net.core.somaxconn=4096 2>/dev/null
    sysctl -w net.ipv4.tcp_rmem='4096 87380 16777216' 2>/dev/null
    sysctl -w net.ipv4.tcp_wmem='4096 65536 16777216' 2>/dev/null
    sysctl -w net.ipv4.tcp_congestion_control=htcp 2>/dev/null
    sysctl -w net.ipv4.tcp_max_syn_backlog=8192 2>/dev/null
    sysctl -w net.ipv4.tcp_tw_reuse=1 2>/dev/null
    sysctl -w net.ipv4.ip_local_port_range='1024 65535' 2>/dev/null

    echo -e "${lv}优化缓存管理...${bai}"
    sysctl -w vm.vfs_cache_pressure=50 2>/dev/null

    echo -e "${lv}优化CPU设置...${bai}"
    sysctl -w kernel.sched_autogroup_enabled=0 2>/dev/null

    echo -e "${lv}其他优化...${bai}"
    # 禁用透明大页面，减少延迟
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    # 禁用 NUMA balancing
    sysctl -w kernel.numa_balancing=0 2>/dev/null


}

# 均衡模式优化函数
optimize_balanced() {
    echo -e "${lv}切换到均衡模式...${bai}"

    echo -e "${lv}优化文件描述符...${bai}"
    ulimit -n 32768

    echo -e "${lv}优化虚拟内存...${bai}"
    sysctl -w vm.swappiness=30 2>/dev/null
    sysctl -w vm.dirty_ratio=20 2>/dev/null
    sysctl -w vm.dirty_background_ratio=10 2>/dev/null
    sysctl -w vm.overcommit_memory=0 2>/dev/null
    sysctl -w vm.min_free_kbytes=32768 2>/dev/null

    echo -e "${lv}优化网络设置...${bai}"
    sysctl -w net.core.rmem_max=8388608 2>/dev/null
    sysctl -w net.core.wmem_max=8388608 2>/dev/null
    sysctl -w net.core.netdev_max_backlog=125000 2>/dev/null
    sysctl -w net.core.somaxconn=2048 2>/dev/null
    sysctl -w net.ipv4.tcp_rmem='4096 87380 8388608' 2>/dev/null
    sysctl -w net.ipv4.tcp_wmem='4096 32768 8388608' 2>/dev/null
    sysctl -w net.ipv4.tcp_congestion_control=cubic 2>/dev/null
    sysctl -w net.ipv4.tcp_max_syn_backlog=4096 2>/dev/null
    sysctl -w net.ipv4.tcp_tw_reuse=1 2>/dev/null
    sysctl -w net.ipv4.ip_local_port_range='1024 49151' 2>/dev/null

    echo -e "${lv}优化缓存管理...${bai}"
    sysctl -w vm.vfs_cache_pressure=75 2>/dev/null

    echo -e "${lv}优化CPU设置...${bai}"
    sysctl -w kernel.sched_autogroup_enabled=1 2>/dev/null

    echo -e "${lv}其他优化...${bai}"
    # 还原透明大页面
    echo always > /sys/kernel/mm/transparent_hugepage/enabled
    # 还原 NUMA balancing
    sysctl -w kernel.numa_balancing=1 2>/dev/null


}

# 还原默认设置函数
restore_defaults() {
    echo -e "${lv}还原到默认设置...${bai}"

    echo -e "${lv}还原文件描述符...${bai}"
    ulimit -n 1024

    echo -e "${lv}还原虚拟内存...${bai}"
    sysctl -w vm.swappiness=60 2>/dev/null
    sysctl -w vm.dirty_ratio=20 2>/dev/null
    sysctl -w vm.dirty_background_ratio=10 2>/dev/null
    sysctl -w vm.overcommit_memory=0 2>/dev/null
    sysctl -w vm.min_free_kbytes=16384 2>/dev/null

    echo -e "${lv}还原网络设置...${bai}"
    sysctl -w net.core.rmem_max=212992 2>/dev/null
    sysctl -w net.core.wmem_max=212992 2>/dev/null
    sysctl -w net.core.netdev_max_backlog=1000 2>/dev/null
    sysctl -w net.core.somaxconn=128 2>/dev/null
    sysctl -w net.ipv4.tcp_rmem='4096 87380 6291456' 2>/dev/null
    sysctl -w net.ipv4.tcp_wmem='4096 16384 4194304' 2>/dev/null
    sysctl -w net.ipv4.tcp_congestion_control=cubic 2>/dev/null
    sysctl -w net.ipv4.tcp_max_syn_backlog=2048 2>/dev/null
    sysctl -w net.ipv4.tcp_tw_reuse=0 2>/dev/null
    sysctl -w net.ipv4.ip_local_port_range='32768 60999' 2>/dev/null

    echo -e "${lv}还原缓存管理...${bai}"
    sysctl -w vm.vfs_cache_pressure=100 2>/dev/null

    echo -e "${lv}还原CPU设置...${bai}"
    sysctl -w kernel.sched_autogroup_enabled=1 2>/dev/null

    echo -e "${lv}还原其他优化...${bai}"
    # 还原透明大页面
    echo always > /sys/kernel/mm/transparent_hugepage/enabled
    # 还原 NUMA balancing
    sysctl -w kernel.numa_balancing=1 2>/dev/null

}



# 网站搭建优化函数
optimize_web_server() {
    echo -e "${lv}切换到网站搭建优化模式...${bai}"

    echo -e "${lv}优化文件描述符...${bai}"
    ulimit -n 65536

    echo -e "${lv}优化虚拟内存...${bai}"
    sysctl -w vm.swappiness=10 2>/dev/null
    sysctl -w vm.dirty_ratio=20 2>/dev/null
    sysctl -w vm.dirty_background_ratio=10 2>/dev/null
    sysctl -w vm.overcommit_memory=1 2>/dev/null
    sysctl -w vm.min_free_kbytes=65536 2>/dev/null

    echo -e "${lv}优化网络设置...${bai}"
    sysctl -w net.core.rmem_max=16777216 2>/dev/null
    sysctl -w net.core.wmem_max=16777216 2>/dev/null
    sysctl -w net.core.netdev_max_backlog=5000 2>/dev/null
    sysctl -w net.core.somaxconn=4096 2>/dev/null
    sysctl -w net.ipv4.tcp_rmem='4096 87380 16777216' 2>/dev/null
    sysctl -w net.ipv4.tcp_wmem='4096 65536 16777216' 2>/dev/null
    sysctl -w net.ipv4.tcp_congestion_control=htcp 2>/dev/null
    sysctl -w net.ipv4.tcp_max_syn_backlog=8192 2>/dev/null
    sysctl -w net.ipv4.tcp_tw_reuse=1 2>/dev/null
    sysctl -w net.ipv4.ip_local_port_range='1024 65535' 2>/dev/null

    echo -e "${lv}优化缓存管理...${bai}"
    sysctl -w vm.vfs_cache_pressure=50 2>/dev/null

    echo -e "${lv}优化CPU设置...${bai}"
    sysctl -w kernel.sched_autogroup_enabled=0 2>/dev/null

    echo -e "${lv}其他优化...${bai}"
    # 禁用透明大页面，减少延迟
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    # 禁用 NUMA balancing
    sysctl -w kernel.numa_balancing=0 2>/dev/null


}



linux_ps() {

    clear
    send_stats "系统信息查询"

    ip_address

    cpu_info=$(lscpu | awk -F': +' '/Model name:/ {print $2; exit}')

    cpu_usage_percent=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf "%.0f\n", (($2+$4-u1) * 100 / (t-t1))}' \
        <(grep 'cpu ' /proc/stat) <(sleep 1; grep 'cpu ' /proc/stat))

    cpu_cores=$(nproc)

    mem_info=$(free -b | awk 'NR==2{printf "%.2f/%.2f MB (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')

    disk_info=$(df -h | awk '$NF=="/"{printf "%s/%s (%s)", $3, $2, $5}')

    ipinfo=$(curl -s ipinfo.io)
    country=$(echo "$ipinfo" | grep 'country' | awk -F': ' '{print $2}' | tr -d '",')
    city=$(echo "$ipinfo" | grep 'city' | awk -F': ' '{print $2}' | tr -d '",')
    isp_info=$(echo "$ipinfo" | grep 'org' | awk -F': ' '{print $2}' | tr -d '",')


    cpu_arch=$(uname -m)

    hostname=$(hostname)

    kernel_version=$(uname -r)

    congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
    queue_algorithm=$(sysctl -n net.core.default_qdisc)

    # 尝试使用 lsb_release 获取系统信息
    os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '"')

    output_status

    current_time=$(date "+%Y-%m-%d %I:%M %p")


    swap_info=$(free -m | awk 'NR==3{used=$3; total=$2; if (total == 0) {percentage=0} else {percentage=used*100/total}; printf "%dMB/%dMB (%d%%)", used, total, percentage}')

    runtime=$(cat /proc/uptime | awk -F. '{run_days=int($1 / 86400);run_hours=int(($1 % 86400) / 3600);run_minutes=int(($1 % 3600) / 60); if (run_days > 0) printf("%d天 ", run_days); if (run_hours > 0) printf("%d时 ", run_hours); printf("%d分\n", run_minutes)}')

    timezone=$(current_timezone)


    echo ""
    echo "系统信息查询"
    echo "------------------------"
    echo "主机名: $hostname"
    echo "运营商: $isp_info"
    echo "------------------------"
    echo "系统版本: $os_info"
    echo "Linux版本: $kernel_version"
    echo "------------------------"
    echo "CPU架构: $cpu_arch"
    echo "CPU型号: $cpu_info"
    echo "CPU核心数: $cpu_cores"
    echo "------------------------"
    echo "CPU占用: $cpu_usage_percent%"
    echo "物理内存: $mem_info"
    echo "虚拟内存: $swap_info"
    echo "硬盘占用: $disk_info"
    echo "------------------------"
    echo "$output"
    echo "------------------------"
    echo "网络拥堵算法: $congestion_algorithm $queue_algorithm"
    echo "------------------------"
    echo "公网IPv4地址: $ipv4_address"
    echo "公网IPv6地址: $ipv6_address"
    echo "------------------------"
    echo "地理位置: $country $city"
    echo "系统时区: $timezone"
    echo "系统时间: $current_time"
    echo "------------------------"
    echo "系统运行时长: $runtime"
    echo



}



linux_tools() {

  while true; do
      clear
      send_stats "常用工具"
	echo -e "${huang}▶ 安装常用工具${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${lv}1. curl 下载工具${bai}"
	echo -e "${lv}2. wget 下载工具${bai}"
	echo -e "${lv}3. sudo 超级管理权限工具${bai}"
	echo -e "${lv}4. socat 通信连接工具 （申请域名证书必备）${bai}"
	echo -e "${lv}5. htop 系统监控工具${bai}"
	echo -e "${lv}6. iftop 网络流量监控工具${bai}"
	echo -e "${lv}7. unzip ZIP压缩解压工具${bai}"
	echo -e "${lv}8. tar GZ压缩解压工具${bai}"
	echo -e "${lv}9. tmux 多路后台运行工具${bai}"
	echo -e "${lv}10. ffmpeg 视频编码直播推流工具${bai}"
	echo -e "${lv}11. btop 现代化监控工具${bai}"
	echo -e "${lv}12. ranger 文件管理工具${bai}"
	echo -e "${lv}13. gdu|ncdu 磁盘占用查看工具${bai}"
	echo -e "${lv}14. fzf 全局搜索工具${bai}"
	echo -e "${lv}15. vim 文本编辑器${bai}"
	echo -e "${lv}16. nano 文本编辑器${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${huang}21. cmatrix 黑客帝国屏保${bai}"
	echo -e "${huang}22. sl 跑火车屏保${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${lan}26. 俄罗斯方块小游戏${bai}"
	echo -e "${lan}27. 贪吃蛇小游戏${bai}"
	echo -e "${lan}28. 太空入侵者小游戏${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${kjlan}31. 全部安装${bai}"
	echo -e "${kjlan}32. 全部卸载${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${hui}41. 安装指定工具${bai}"
	echo -e "${hui}42. 卸载指定工具${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${bai}0. 返回主菜单${bai}"
	echo -e "${bai}------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in
          1)
              clear
              install curl
              clear
              echo "工具已安装，使用方法如下："
              curl --help
              send_stats "安装curl"
              ;;
          2)
              clear
              install wget
              clear
              echo "工具已安装，使用方法如下："
              wget --help
              send_stats "安装wget"
              ;;
            3)
              clear
              install sudo
              clear
              echo "工具已安装，使用方法如下："
              sudo --help
              send_stats "安装sudo"
              ;;
            4)
              clear
              install socat
              clear
              echo "工具已安装，使用方法如下："
              socat -h
              send_stats "安装socat"
              ;;
            5)
              clear
              install htop
              clear
              htop
              send_stats "安装htop"
              ;;
            6)
              clear
              install iftop
              clear
              iftop
              send_stats "安装iftop"
              ;;
            7)
              clear
              install unzip
              clear
              echo "工具已安装，使用方法如下："
              unzip
              send_stats "安装unzip"
              ;;
            8)
              clear
              install tar
              clear
              echo "工具已安装，使用方法如下："
              tar --help
              send_stats "安装tar"
              ;;
            9)
              clear
              install tmux
              clear
              echo "工具已安装，使用方法如下："
              tmux --help
              send_stats "安装tmux"
              ;;
            10)
              clear
              install ffmpeg
              clear
              echo "工具已安装，使用方法如下："
              ffmpeg --help
              send_stats "安装ffmpeg"
              ;;

            11)
              clear
              install btop
              clear
              btop
              send_stats "安装btop"
              ;;
            12)
              clear
              install ranger
              cd /
              clear
              ranger
              cd ~
              send_stats "安装ranger"
              ;;
            13)
              clear
              install gdu || install ncdu
              cd /
              clear
              gdu || ncdu
              cd ~
              send_stats "安装gdu|ncdu"
              ;;
            14)
              clear
              install fzf
              cd /
              clear
              fzf
              cd ~
              send_stats "安装fzf"
              ;;
            15)
              clear
              install vim
              cd /
              clear
              vim -h
              cd ~
              send_stats "安装vim"
              ;;
            16)
              clear
              install nano
              cd /
              clear
              nano -h
              cd ~
              send_stats "安装nano"
              ;;

            21)
              clear
              install cmatrix
              clear
              cmatrix
              send_stats "安装cmatrix"
              ;;
            22)
              clear
              install sl
              clear
              sl
              send_stats "安装sl"
              ;;
            26)
              clear
              install bastet
              clear
              bastet
              send_stats "安装bastet"
              ;;
            27)
              clear
              install nsnake
              clear
              nsnake
              send_stats "安装nsnake"
              ;;
            28)
              clear
              install ninvaders
              clear
              ninvaders
              send_stats "安装ninvaders"

              ;;

          31)
              clear
              send_stats "全部安装"
              install curl wget sudo socat htop iftop unzip tar tmux ffmpeg btop ranger gdu fzf cmatrix sl bastet nsnake ninvaders vim nano
              ;;

          32)
              clear
              send_stats "全部卸载"
              remove htop iftop unzip tmux ffmpeg btop ranger gdu fzf cmatrix sl bastet nsnake ninvaders vim nano
              ;;

          41)
              clear
              read -p "请输入安装的工具名（wget curl sudo htop）: " installname
              install $installname
              send_stats "安装指定软件"
              ;;
          42)
              clear
              read -p "请输入卸载的工具名（htop ufw tmux cmatrix）: " removename
              remove $removename
              send_stats "卸载指定软件"
              ;;

          0)
              linuxbt

              ;;

          *)
              echo "无效的输入!"
              ;;
      esac
      break_end
  done




}


linux_bbr() {
    clear
    send_stats "bbr管理"
    if [ -f "/etc/alpine-release" ]; then
        while true; do
              clear
              congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
              queue_algorithm=$(sysctl -n net.core.default_qdisc)
              echo "当前TCP阻塞算法: $congestion_algorithm $queue_algorithm"

              echo ""
              echo "BBR管理"
              echo "------------------------"
              echo "1. 开启BBRv3              2. 关闭BBRv3（会重启）"
              echo "------------------------"
              echo "0. 返回上一级选单"
              echo "------------------------"
              read -p "请输入你的选择: " sub_choice

              case $sub_choice in
                  1)
                    bbr_on
                    send_stats "alpine开启bbr3"
                      ;;
                  2)
                    sed -i '/net.core.default_qdisc=fq_pie/d' /etc/sysctl.conf
                    sed -i '/net.ipv4.tcp_congestion_control=bbr/d' /etc/sysctl.conf
                    sysctl -p
                    reboot
                      ;;
                  0)
                      break  # 跳出循环，退出菜单
                      ;;

                  *)
                      break  # 跳出循环，退出菜单
                      ;;

              esac
        done
    else
        install wget
        wget --no-check-certificate -O tcpx.sh https://raw.githubusercontent.com/linuxbt/sh/main/sh/install_kernel.sh
        chmod +x tcpx.sh
        ./tcpx.sh
    fi


}


linux_remote() {
    while true; do
      clear
      send_stats "linux远程桌面"
      echo "▶ ${kjlan}Linux远程桌面"
      echo "K脚本将为你提供常用的linux远程桌面"
      echo -e "${huang}告别繁琐: 一键安装。"
      echo "------------------------"
      echo "1. debian | ubuntu 远程桌面"
      echo "2. redhat系列（centos,rocky,alma）远程桌面"
      echo "------------------------"
      echo "0. 返回主菜单"
      echo -e "------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in

          1)
              clear
              send_stats "debian | ubuntu 远程桌面"
              bash <(curl -sSL https://raw.githubusercontent.com/linuxbt/sh/main/sh/debian_remote.sh)

              ;;

          2)
              clear
              send_stats "redhat系列 | rockcy,alma,centos 远程桌面"
              bash <(curl -sSL https://raw.githubusercontent.com/linuxbt/sh/main/sh/redhat_remote.sh)

              ;;

          0)
              linuxbt
              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end

    done
}


linux_vpn() {
    while true; do
      clear
      send_stats "linux科学上网工具"
      echo -e "▶ ${kjlan}Linux科学上网一键脚本"
      echo "K脚本为你提供：各种linux科学上网一键脚本"
      echo -e "${huang}告别繁琐: 一键安装。"
      echo "------------------------"
      echo "1. wireguard | 带管理面板，轻量安全"
      echo "2. hysteria | hy2 协议"
      echo "3. 3x-ui 面板| 多个大佬维护版  "
      echo "4. x-ui 面板| 经典版  "       
      echo "------------------------"
      echo "0. 返回主菜单"
      echo -e "------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in

          1)
              clear
              send_stats "wireguard | 带控制面板 "
              bash <(curl -sSL https://raw.githubusercontent.com/linuxbt/sh/main/sh/install_wg-easy.sh)

              ;;

          2)
              clear
              send_stats "hysteria | hy2 一键脚本 "
              bash <(curl -sSL https://raw.githubusercontent.com/linuxbt/sh/main/sh/install_hy2.sh)

              ;;

          3)
              clear
              send_stats "3x-ui 面板 "
              bash <(curl -Ls https://raw.githubusercontent.com/linuxbt/sh/main/sh/install_3x-ui.sh)

              ;;

          4)
              clear
              send_stats "x-ui 面板"
              bash <(curl -Ls https://raw.githubusercontent.com/wangwenzhiwwz/x-ui/master/install.sh)

              ;;


          0)
              linuxbt
              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end

    done
}

linux_tunnel() {
    while true; do
      clear
      send_stats "linux组网工具"
      echo -e "▶ ${kjlan}Linux组网一键脚本"
      echo "K脚本为你提供：各种组网工具脚本"
      echo -e "${huang}告别繁琐: 一键安装。"
      echo "------------------------"
      echo "1. candy | 推荐，低延迟-无需配置"
      echo "2. zerotier | 流行的组网工具"    
      echo "------------------------"
      echo "0. 返回主菜单"
      echo -e "------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in

          1)
              clear
              send_stats "candy | 低延迟组网工具 "
              bash <(curl -sSL https://raw.githubusercontent.com/linuxbt/sh/main/sh/install_candy_client.sh)

              ;;

          2)
              clear
              send_stats "zerotier | 流行的组网工具 "
              bash <(curl -sSL https://raw.githubusercontent.com/linuxbt/sh/main/sh/install_zerotier_client.sh)

              ;;


          0)
              linuxbt
              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end

    done
}

linux_backup() {
    while true; do
      clear
      send_stats "linux文件传输｜备份工具"
      echo -e "▶ ${kjlan}Linux文件传输｜备份脚本"
      echo "K脚本为你提供：各种备份工具脚本"
      echo -e "${huang}告别繁琐: 一键安装。"
      echo "------------------------"
      echo "1. local | 本地备份"
      echo "2. rsync | 本地和远程备份" 
      echo "3. sftp | 远程备份"
      echo "4. restic | 本地和远程加密备份"      
      echo "------------------------"
      echo "0. 返回主菜单"
      echo -e "------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in

          1)
              clear
              send_stats "local 本地备份 "
              curl -sS -O https://raw.githubusercontent.com/linuxbt/sh/main/sh/local_backup.sh && chmod +x local_backup.sh && ./local_backup.sh

              ;;

          2)
              clear
              send_stats "rsync 备份工具 "
              bash <(curl -sSL https://raw.githubusercontent.com/linuxbt/sh/main/sh/rsync_backup.sh)

              ;;

          3)
              clear
              send_stats "sftp 备份工具 "
              bash <(curl -sSL https://raw.githubusercontent.com/linuxbt/sh/main/sh/sftp_backup.sh)

              ;;

          4)
              clear
              send_stats "restic 备份工具 "
	      curl -sS -O https://raw.githubusercontent.com/linuxbt/sh/main/sh/restic_backup.sh && chmod +x restic_backup.sh && ./restic_backup.sh
	      

              ;;

          0)
              linuxbt
              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end

    done
}

bip39_manage() {
    while true; do
      clear
      echo -e "▶ ${kjlan}助记词安全管理工具"
      echo "K脚本为你提供：各种命令行工具脚本"
      echo -e "${huang}拒绝繁琐: 只需一键。"
      echo "------------------------"
      echo "1. 安卓 | Termux 版本"
      echo "2. 苹果 | iSH 版本 -- 请先安装curl和bash"
      echo "苹果 iSH 环境必备依赖 -- 安装命令如下: "
      echo "apk add curl bash openssl python3 coreutils"
      echo "------------------------"
      echo "0. 返回主菜单"
      echo "q. 退出"      
      echo -e "------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in

          1)
              clear
              send_stats "安卓手机 | 助记词安全管理工具 "
              bash <(curl -sSL https://raw.githubusercontent.com/linuxbt/sh/refs/heads/main/sh/bip39_encry.sh)

              ;;

          2)
              clear
              send_stats "苹果手机 | 助记词安全管理工具 "
	      curl -O https://raw.githubusercontent.com/linuxbt/sh/refs/heads/main/sh/bip39_encry_ios.sh && bash bip39_encry_ios.sh

              ;;


          0)
              linuxbt
              ;;
          q | Q)
              echo "正在退出..."
              exit 0
              ;;	      
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end

    done
}

linux_docker() {

    while true; do
      clear
      # send_stats "docker管理"
	echo -e "${huang}▶ Docker管理器${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${lv}1. 安装更新Docker环境${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${lv}2. 查看Docker全局状态${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${lan}3. Docker容器管理 ▶${bai}"
	echo -e "${lan}4. Docker镜像管理 ▶${bai}"
	echo -e "${lan}5. Docker网络管理 ▶${bai}"
	echo -e "${lan}6. Docker卷管理 ▶${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${hong}7. 清理无用的docker容器和镜像网络数据卷${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${lv}8. 更换Docker源${bai}"
	echo -e "${lv}9. 编辑daemon.json文件${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${kjlan}11. 开启Docker-ipv6访问${bai}"
	echo -e "${kjlan}12. 关闭Docker-ipv6访问${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${huang}20. 卸载Docker环境${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${hui}0. 返回主菜单${bai}"
	echo -e "${bai}------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in
          1)
            clear
            send_stats "安装docker环境"
            install_add_docker

              ;;
          2)
              clear
              send_stats "docker全局状态"
              echo "Docker版本"
              docker -v
              docker compose version

              echo ""
              echo "Docker镜像列表"
              docker image ls
              echo ""
              echo "Docker容器列表"
              docker ps -a
              echo ""
              echo "Docker卷列表"
              docker volume ls
              echo ""
              echo "Docker网络列表"
              docker network ls
              echo ""

              ;;
          3)
              while true; do
                  clear
                  send_stats "Docker容器管理"
                  echo "Docker容器列表"
                  docker ps -a
                  echo ""
                  echo "容器操作"
                  echo "------------------------"
                  echo "1. 创建新的容器"
                  echo "------------------------"
                  echo "2. 启动指定容器             6. 启动所有容器"
                  echo "3. 停止指定容器             7. 暂停所有容器"
                  echo "4. 删除指定容器             8. 删除所有容器"
                  echo "5. 重启指定容器             9. 重启所有容器"
                  echo "------------------------"
                  echo "11. 进入指定容器           12. 查看容器日志           13. 查看容器网络"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                          send_stats "新建容器"
                          read -p "请输入创建命令: " dockername
                          $dockername
                          ;;

                      2)
                          send_stats "启动指定容器"
                          read -p "请输入容器名: " dockername
                          docker start $dockername
                          ;;
                      3)
                          send_stats "停止指定容器"
                          read -p "请输入容器名: " dockername
                          docker stop $dockername
                          ;;
                      4)
                          send_stats "删除指定容器"
                          read -p "请输入容器名: " dockername
                          docker rm -f $dockername
                          ;;
                      5)
                          send_stats "重启指定容器"
                          read -p "请输入容器名: " dockername
                          docker restart $dockername
                          ;;
                      6)
                          send_stats "启动所有容器"
                          docker start $(docker ps -a -q)
                          ;;
                      7)
                          send_stats "停止所有容器"
                          docker stop $(docker ps -q)
                          ;;
                      8)
                          send_stats "删除所有容器"
                          read -p "$(echo -e "${hong}注意：${bai}确定删除所有容器吗？(Y/N): ")" choice
                          case "$choice" in
                            [Yy])
                              docker rm -f $(docker ps -a -q)
                              ;;
                            [Nn])
                              ;;
                            *)
                              echo "无效的选择，请输入 Y 或 N。"
                              ;;
                          esac
                          ;;
                      9)
                          send_stats "重启所有容器"
                          docker restart $(docker ps -q)
                          ;;
                      11)
                          send_stats "进入容器"
                          read -p "请输入容器名: " dockername
                          docker exec -it $dockername /bin/sh
                          break_end
                          ;;
                      12)
                          send_stats "查看容器日志"
                          read -p "请输入容器名: " dockername
                          docker logs $dockername
                          break_end
                          ;;
                      13)
                          send_stats "查看容器网络"
                          echo ""
                          container_ids=$(docker ps -q)

                          echo "------------------------------------------------------------"
                          printf "%-25s %-25s %-25s\n" "容器名称" "网络名称" "IP地址"

                          for container_id in $container_ids; do
                              container_info=$(docker inspect --format '{{ .Name }}{{ range $network, $config := .NetworkSettings.Networks }} {{ $network }} {{ $config.IPAddress }}{{ end }}' "$container_id")

                              container_name=$(echo "$container_info" | awk '{print $1}')
                              network_info=$(echo "$container_info" | cut -d' ' -f2-)

                              while IFS= read -r line; do
                                  network_name=$(echo "$line" | awk '{print $1}')
                                  ip_address=$(echo "$line" | awk '{print $2}')

                                  printf "%-20s %-20s %-15s\n" "$container_name" "$network_name" "$ip_address"
                              done <<< "$network_info"
                          done

                          break_end
                          ;;

                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done
              ;;
          4)
              while true; do
                  clear
                  send_stats "Docker镜像管理"
                  echo "Docker镜像列表"
                  docker image ls
                  echo ""
                  echo "镜像操作"
                  echo "------------------------"
                  echo "1. 获取指定镜像             3. 删除指定镜像"
                  echo "2. 更新指定镜像             4. 删除所有镜像"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                          send_stats "拉取镜像"
                          read -p "请输入镜像名: " dockername
                          docker pull $dockername
                          ;;
                      2)
                          send_stats "更新镜像"
                          read -p "请输入镜像名: " dockername
                          docker pull $dockername
                          ;;
                      3)
                          send_stats "删除镜像"
                          read -p "请输入镜像名: " dockername
                          docker rmi -f $dockername
                          ;;
                      4)
                          send_stats "删除所有镜像"
                          read -p "$(echo -e "${hong}注意：${bai}确定删除所有镜像吗？(Y/N): ")" choice
                          case "$choice" in
                            [Yy])
                              docker rmi -f $(docker images -q)
                              ;;
                            [Nn])

                              ;;
                            *)
                              echo "无效的选择，请输入 Y 或 N。"
                              ;;
                          esac
                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done
              ;;

          5)
              while true; do
                  clear
                  send_stats "Docker网络管理"
                  echo "Docker网络列表"
                  echo "------------------------------------------------------------"
                  docker network ls
                  echo ""

                  echo "------------------------------------------------------------"
                  container_ids=$(docker ps -q)
                  printf "%-25s %-25s %-25s\n" "容器名称" "网络名称" "IP地址"

                  for container_id in $container_ids; do
                      container_info=$(docker inspect --format '{{ .Name }}{{ range $network, $config := .NetworkSettings.Networks }} {{ $network }} {{ $config.IPAddress }}{{ end }}' "$container_id")

                      container_name=$(echo "$container_info" | awk '{print $1}')
                      network_info=$(echo "$container_info" | cut -d' ' -f2-)

                      while IFS= read -r line; do
                          network_name=$(echo "$line" | awk '{print $1}')
                          ip_address=$(echo "$line" | awk '{print $2}')

                          printf "%-20s %-20s %-15s\n" "$container_name" "$network_name" "$ip_address"
                      done <<< "$network_info"
                  done

                  echo ""
                  echo "网络操作"
                  echo "------------------------"
                  echo "1. 创建网络"
                  echo "2. 加入网络"
                  echo "3. 退出网络"
                  echo "4. 删除网络"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                          send_stats "创建网络"
                          read -p "设置新网络名: " dockernetwork
                          docker network create $dockernetwork
                          ;;
                      2)
                          send_stats "加入网络"
                          read -p "加入网络名: " dockernetwork
                          read -p "那些容器加入该网络: " dockername
                          docker network connect $dockernetwork $dockername
                          echo ""
                          ;;
                      3)
                          send_stats "退出网络"
                          read -p "退出网络名: " dockernetwork
                          read -p "那些容器退出该网络: " dockername
                          docker network disconnect $dockernetwork $dockername
                          echo ""
                          ;;

                      4)
                          send_stats "删除网络"
                          read -p "请输入要删除的网络名: " dockernetwork
                          docker network rm $dockernetwork
                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done
              ;;

          6)
              while true; do
                  clear
                  send_stats "Docker卷管理"
                  echo "Docker卷列表"
                  docker volume ls
                  echo ""
                  echo "卷操作"
                  echo "------------------------"
                  echo "1. 创建新卷"
                  echo "2. 删除卷"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                          send_stats "新建卷"
                          read -p "设置新卷名: " dockerjuan
                          docker volume create $dockerjuan

                          ;;
                      2)
                          send_stats "删除卷"
                          read -p "输入删除卷名: " dockerjuan
                          docker volume rm $dockerjuan

                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done
              ;;
          7)
              clear
              send_stats "Docker清理"
              read -p "$(echo -e "${huang}注意：${bai}将清理无用的镜像容器网络，包括停止的容器，确定清理吗？(Y/N): ")" choice
              case "$choice" in
                [Yy])
                  docker system prune -af --volumes
                  ;;
                [Nn])
                  ;;
                *)
                  echo "无效的选择，请输入 Y 或 N。"
                  ;;
              esac
              ;;
          8)
              clear
              send_stats "Docker源"
              bash <(curl -sSL https://linuxmirrors.cn/docker.sh)
              ;;

          9)
              clear
              install nano
              mkdir -p /etc/docker && nano /etc/docker/daemon.json
              restart docker
              ;;

          11)
              clear
              send_stats "Docker v6 开"
              docker_ipv6_on
              ;;

          12)
              clear
              send_stats "Docker v6 关"
              docker_ipv6_off
              ;;

          20)
              clear
              send_stats "Docker卸载"
              read -p "$(echo -e "${hong}注意：${bai}确定卸载docker环境吗？(Y/N): ")" choice
              case "$choice" in
                [Yy])
                  docker rm $(docker ps -a -q) && docker rmi $(docker images -q) && docker network prune
                  k remove docker docker-compose

                  ;;
                [Nn])
                  ;;
                *)
                  echo "无效的选择，请输入 Y 或 N。"
                  ;;
              esac
              ;;

          0)
              linuxbt
              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end


    done


}



linux_test() {

    while true; do
      clear
      # send_stats "测试脚本合集"
	echo -e "${lv}▶ 测试脚本合集${bai}"
	echo ""
	echo -e "${lan}----IP及解锁状态检测-----------${bai}"
	echo -e "${huang}1. ChatGPT解锁状态检测${bai}"
	echo -e "${huang}2. Region流媒体解锁测试${bai}"
	echo -e "${huang}3. yeahwu流媒体解锁检测${bai}"
	echo -e "${huang}4. xykt_IP质量体检脚本${bai}"
	echo ""
	echo -e "${lan}----网络线路测速-----------${bai}"
	echo -e "${kjlan}11. besttrace三网回程延迟路由测试${bai}"
	echo -e "${kjlan}12. mtr_trace三网回程线路测试${bai}"
	echo -e "${kjlan}13. Superspeed三网测速${bai}"
	echo -e "${kjlan}14. nxtrace快速回程测试脚本${bai}"
	echo -e "${kjlan}15. nxtrace指定IP回程测试脚本${bai}"
	echo -e "${kjlan}16. ludashi2020三网线路测试${bai}"
	echo -e "${kjlan}17. i-abc多功能测速脚本${bai}"
	echo ""
	echo -e "${lan}----硬件性能测试----------${bai}"
	echo -e "${lan}21. yabs性能测试${bai}"
	echo -e "${lan}22. icu/gb5 CPU性能测试脚本${bai}"
	echo ""
	echo -e "${lan}----综合性测试-----------${bai}"
	echo -e "${bai}31. bench性能测试${bai}"
	echo -e "${bai}32. spiritysdx融合怪测评${bai}"
	echo ""
	echo -e "${lan}------------------------${bai}"
	echo -e "${bai}0. 返回主菜单${bai}"
	echo -e "${lan}------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in
          1)
              clear
              send_stats "ChatGPT解锁状态检测"
              bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/OpenAI-Checker/openai.sh)
              ;;
          2)
              clear
              send_stats "Region流媒体解锁测试"
              bash <(curl -L -s check.unlock.media)
              ;;
          3)
              clear
              send_stats "yeahwu流媒体解锁检测"
              install wget
              wget -qO- https://github.com/yeahwu/check/raw/main/check.sh | bash
              ;;
          4)
              clear
              send_stats "xykt_IP质量体检脚本"
              bash <(curl -Ls IP.Check.Place)
              ;;
          11)
              clear
              send_stats "besttrace三网回程延迟路由测试"
              install wget
              wget -qO- git.io/besttrace | bash
              ;;
          12)
              clear
              send_stats "mtr_trace三网回程线路测试"
              curl https://raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh | bash
              ;;
          13)
              clear
              send_stats "Superspeed三网测速"
              bash <(curl -Lso- https://git.io/superspeed_uxh)
              ;;
          14)
              clear
              send_stats "nxtrace快速回程测试脚本"
              curl nxtrace.org/nt |bash
              nexttrace --fast-trace --tcp
              ;;
          15)
              clear
              send_stats "nxtrace指定IP回程测试脚本"
              echo "可参考的IP列表"
              echo "------------------------"
              echo "北京电信: 219.141.136.12"
              echo "北京联通: 202.106.50.1"
              echo "北京移动: 221.179.155.161"
              echo "上海电信: 202.96.209.133"
              echo "上海联通: 210.22.97.1"
              echo "上海移动: 211.136.112.200"
              echo "广州电信: 58.60.188.222"
              echo "广州联通: 210.21.196.6"
              echo "广州移动: 120.196.165.24"
              echo "成都电信: 61.139.2.69"
              echo "成都联通: 119.6.6.6"
              echo "成都移动: 211.137.96.205"
              echo "湖南电信: 36.111.200.100"
              echo "湖南联通: 42.48.16.100"
              echo "湖南移动: 39.134.254.6"
              echo "------------------------"

              read -p "输入一个指定IP: " testip
              curl nxtrace.org/nt |bash
              nexttrace $testip
              ;;

          16)
              clear
              send_stats "ludashi2020三网线路测试"
              curl https://raw.githubusercontent.com/ludashi2020/backtrace/main/install.sh -sSf | sh
              ;;

          17)
              clear
              send_stats "i-abc多功能测速脚本"
              bash <(curl -sL bash.icu/speedtest)
              ;;


          21)
              clear
              send_stats "yabs性能测试"
              check_swap
              add_swap
              curl -sL yabs.sh | bash -s -- -i -5
              ;;
          22)
              clear
              send_stats "icu/gb5 CPU性能测试脚本"
              check_swap
              add_swap
              bash <(curl -sL bash.icu/gb5)
              ;;

          31)
              clear
              send_stats "bench性能测试"
              curl -Lso- bench.sh | bash
              ;;
          32)
              send_stats "spiritysdx融合怪测评"
              clear
              curl -L https://gitlab.com/spiritysdx/za/-/raw/main/ecs.sh -o ecs.sh && chmod +x ecs.sh && bash ecs.sh
              ;;

          0)
              linuxbt

              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end

    done


}


linux_Oracle() {


     while true; do
      clear
      send_stats "甲骨文云脚本合集"
	echo -e "${lv}▶ 甲骨文云脚本合集${bai}"
	echo -e "${kjlan}------------------------${bai}"
	echo -e "${lan}1. 安装闲置机器活跃脚本${bai}"
	echo -e "${lan}2. 卸载闲置机器活跃脚本${bai}"
	echo -e "${kjlan}------------------------${bai}"
	echo -e "${huang}3. DD重装系统脚本${bai}"
	echo -e "${huang}4. R探长开机脚本${bai}"
	echo -e "${kjlan}------------------------${bai}"
	echo -e "${lan}5. 开启ROOT密码登录模式${bai}"
	echo -e "${kjlan}------------------------${bai}"
	echo -e "${lan}0. 返回主菜单${bai}"
	echo -e "${kjlan}------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in
          1)
              clear
              echo "活跃脚本: CPU占用10-20% 内存占用20% "
              read -p "确定安装吗？(Y/N): " choice
              case "$choice" in
                [Yy])

                  install_docker

                  # 设置默认值
                  DEFAULT_CPU_CORE=1
                  DEFAULT_CPU_UTIL="10-20"
                  DEFAULT_MEM_UTIL=20
                  DEFAULT_SPEEDTEST_INTERVAL=120

                  # 提示用户输入CPU核心数和占用百分比，如果回车则使用默认值
                  read -p "请输入CPU核心数 [默认: $DEFAULT_CPU_CORE]: " cpu_core
                  cpu_core=${cpu_core:-$DEFAULT_CPU_CORE}

                  read -p "请输入CPU占用百分比范围（例如10-20） [默认: $DEFAULT_CPU_UTIL]: " cpu_util
                  cpu_util=${cpu_util:-$DEFAULT_CPU_UTIL}

                  read -p "请输入内存占用百分比 [默认: $DEFAULT_MEM_UTIL]: " mem_util
                  mem_util=${mem_util:-$DEFAULT_MEM_UTIL}

                  read -p "请输入Speedtest间隔时间（秒） [默认: $DEFAULT_SPEEDTEST_INTERVAL]: " speedtest_interval
                  speedtest_interval=${speedtest_interval:-$DEFAULT_SPEEDTEST_INTERVAL}

                  # 运行Docker容器
                  docker run -itd --name=lookbusy --restart=always \
                      -e TZ=Asia/Shanghai \
                      -e CPU_UTIL="$cpu_util" \
                      -e CPU_CORE="$cpu_core" \
                      -e MEM_UTIL="$mem_util" \
                      -e SPEEDTEST_INTERVAL="$speedtest_interval" \
                      fogforest/lookbusy
                  send_stats "甲骨文云安装活跃脚本"

                  ;;
                [Nn])

                  ;;
                *)
                  echo "无效的选择，请输入 Y 或 N。"
                  ;;
              esac
              ;;
          2)
              clear
              docker rm -f lookbusy
              docker rmi fogforest/lookbusy
              send_stats "甲骨文云卸载活跃脚本"
              ;;

          3)
          clear
          echo "请备份数据，将为你重装系统，预计花费15分钟。"
          read -p "确定继续吗？(Y/N): " choice

          case "$choice" in
            [Yy])
              while true; do
                read -p "请选择要重装的系统:  1. Debian12 | 2. Ubuntu20.04 : " sys_choice

                case "$sys_choice" in
                  1)
                    xitong="-d 12"
                    break  # 结束循环
                    ;;
                  2)
                    xitong="-u 20.04"
                    break  # 结束循环
                    ;;
                  *)
                    echo "无效的选择，请重新输入。"
                    ;;
                esac
              done

              read -p "请输入你重装后的密码: " vpspasswd
              install wget
              bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') $xitong -v 64 -p $vpspasswd -port 22
              send_stats "甲骨文云重装系统脚本"
              ;;
            [Nn])
              echo "已取消"
              ;;
            *)
              echo "无效的选择，请输入 Y 或 N。"
              ;;
          esac
              ;;

          4)
              clear
              echo "该功能处于开发阶段，敬请期待！"
              ;;
          5)
              clear
              add_sshpasswd

              ;;
          0)
              linuxbt

              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end

    done



}






linux_ldnmp() {

  while true; do
    clear
    # send_stats "LDNMP建站"
    echo -e "${huang}▶ LDNMP建站${bai}"
    echo -e  "------------------------"
    echo -e  "1. 安装LDNMP环境"
    echo -e  "${bai}------------------------${bai}"
    echo -e  "${lv}2. 安装WordPress${bai}"
    echo -e  "${lv}3. 安装Discuz论坛${bai}"
    echo -e  "${lv}4. 安装可道云桌面${bai}"
    echo -e  "${lv}5. 安装苹果CMS网站${bai}"
    echo -e  "${lv}6. 安装独角数发卡网${bai}"
    echo -e  "${lv}7. 安装flarum论坛网站${bai}"
    echo -e  "${lv}8. 安装typecho轻量博客网站${bai}"
    echo -e  "${lv}9. 安装雷池WAF旁入版${bai}"
    echo -e  "${lv}20. 自定义动态站点${bai}"
    echo -e  "------------------------"
    echo -e  "${huang}21. 仅安装nginx${bai}"
    echo -e  "${huang}22. 站点重定向${bai}"
    echo -e  "${huang}23. 站点反向代理-IP+端口${bai}"
    echo -e  "${huang}24. 站点反向代理-域名${bai}"
    echo -e  "${huang}25. 自定义静态站点${bai}"
    echo -e  "${huang}26. 安装Bitwarden密码管理平台${bai}"
    echo -e  "${huang}27. 安装Halo博客网站${bai}"
    echo -e  "------------------------"
    echo -e  "${lan}31. 站点数据管理${bai}"
    echo -e  "${lan}32. 备份全站数据${bai}"
    echo -e  "${lan}33. 定时远程备份${bai}"
    echo -e  "${lan}34. 还原全站数据${bai}"
    echo -e  "------------------------"
    echo -e  "${kjlan}35. 站点防御程序${bai}"
    echo -e  "------------------------"
    echo -e  "${hui}36. 优化LDNMP环境${bai}"
    echo -e  "${hui}37. 更新LDNMP环境${bai}"
    echo -e  "${hui}38. 卸载LDNMP环境${bai}"
    echo -e  "------------------------"
    echo -e  "0. 返回主菜单"
    echo -e  "------------------------"
    read -p "请输入你的选择: " sub_choice


    case $sub_choice in
      1)
      send_stats "安装LDNMP环境"
      root_use
      ldnmp_install_status_one
      check_port
      install_dependency
      install_docker
      #install_certbot

      # 创建必要的目录和文件
      cd /home && mkdir -p web/html web/mysql web/certs web/conf.d web/redis web/log/nginx && touch web/docker-compose.yml

      wget -O /home/web/nginx.conf https://raw.githubusercontent.com/linuxbt/nginx/main/nginx10.conf
      wget -O /home/web/conf.d/default.conf https://raw.githubusercontent.com/linuxbt/nginx/main/default10.conf
      default_server_ssl

      # 下载 docker-compose.yml 文件并进行替换
      wget -O /home/web/docker-compose.yml https://raw.githubusercontent.com/linuxbt/docker/main/LNMP-docker-compose-10.yml

      dbrootpasswd=$(openssl rand -base64 16) && dbuse=$(openssl rand -hex 4) && dbusepasswd=$(openssl rand -base64 8)

      # 在 docker-compose.yml 文件中进行替换
      sed -i "s#webroot#$dbrootpasswd#g" /home/web/docker-compose.yml
      sed -i "s#linuxbtYYDS#$dbusepasswd#g" /home/web/docker-compose.yml
      sed -i "s#linuxbt#$dbuse#g" /home/web/docker-compose.yml

      install_ldnmp

        ;;
      2)
      clear
      # wordpress
      webname="WordPress"
      send_stats "安装$webname"

      ldnmp_install_status
      add_yuming
      #install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/wordpress.com.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      remove_ssl

      cd /home/web/html
      mkdir $yuming
      cd $yuming
      wget -O latest.zip https://cn.wordpress.org/latest-zh_CN.zip
      unzip latest.zip
      rm latest.zip

      echo "define('FS_METHOD', 'direct'); define('WP_REDIS_HOST', 'redis'); define('WP_REDIS_PORT', '6379');" >> /home/web/html/$yuming/wordpress/wp-config-sample.php
      set_wordpress
      restart_ldnmp

      ldnmp_web_on
      echo "数据库名: $dbname"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "数据库地址: mysql"
      echo "表前缀: wp_"
      nginx_status
        ;;

      3)
      clear
      # Discuz论坛
      webname="Discuz论坛"
      send_stats "安装$webname"
      ldnmp_install_status
      add_yuming
      #install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/discuz.com.conf

      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      remove_ssl

      cd /home/web/html
      mkdir $yuming
      cd $yuming
      wget -O latest.zip https://github.com/linuxbt/Website_source_code/raw/main/Discuz_X3.5_SC_UTF8_20240520.zip
      unzip latest.zip
      rm latest.zip      
      set_permissions
      restart_ldnmp


      ldnmp_web_on
      echo "数据库地址: mysql"
      echo "数据库名: $dbname"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "表前缀: discuz_"
      nginx_status

        ;;

      4)
      clear
      # 可道云桌面
      webname="可道云桌面"
      send_stats "安装$webname"
      ldnmp_install_status
      add_yuming
      #install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/kdy.com.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      remove_ssl

      cd /home/web/html
      mkdir $yuming
      cd $yuming
      wget -O latest.zip https://github.com/kalcaddle/kodbox/archive/refs/tags/1.50.02.zip
      unzip -o latest.zip
      rm latest.zip
      mv /home/web/html/$yuming/kodbox* /home/web/html/$yuming/kodbox
      set_permissions
      restart_ldnmp

      ldnmp_web_on
      echo "数据库地址: mysql"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "数据库名: $dbname"
      echo "redis主机: redis"
      nginx_status
        ;;

      5)
      clear
      # 苹果CMS
      webname="苹果CMS"
      send_stats "安装$webname"
      ldnmp_install_status
      add_yuming
      #install_ssltls
      add_db
      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/maccms.com.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      remove_ssl


      cd /home/web/html
      mkdir $yuming
      cd $yuming
      wget https://github.com/magicblack/maccms_down/raw/master/maccms10.zip && unzip maccms10.zip && mv maccms10-*/* . && rm -r maccms10-* && rm maccms10.zip
      cd /home/web/html/$yuming/template/ && wget https://github.com/linuxbt/Website_source_code/raw/main/DYXS2.zip && unzip DYXS2.zip && rm /home/web/html/$yuming/template/DYXS2.zip
      cp /home/web/html/$yuming/template/DYXS2/asset/admin/Dyxs2.php /home/web/html/$yuming/application/admin/controller
      cp /home/web/html/$yuming/template/DYXS2/asset/admin/dycms.html /home/web/html/$yuming/application/admin/view/system
      mv /home/web/html/$yuming/admin.php /home/web/html/$yuming/vip.php && wget -O /home/web/html/$yuming/application/extra/maccms.php https://raw.githubusercontent.com/linuxbt/Website_source_code/main/maccms.php
      sed -i 's/127\.0\.0\.1/redis/g' /home/web/html/$yuming/thinkphp/library/think/cache/driver/Redis.php
      sed -i 's/127\.0\.0\.1/redis/g' /home/web/html/$yuming/thinkphp/library/think/session/driver/Redis.php
      set_maccms
      restart_ldnmp
      ldnmp_web_on
      echo "数据库地址: mysql"
      echo "数据库端口: 3306"
      echo "数据库名: $dbname"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "数据库前缀: mac_"
      echo "------------------------"
      echo "安装成功后登录后台地址"
      echo "http://$yuming/vip.php"
      echo "------------------------"
      echo "请确保已经在本地hosts文件中添加了以下内容："
      echo "服务器IP $yuming"
      nginx_status
      break_end
      linux_ldnmp
        ;;


      6)
      clear
      # 独脚数卡
      webname="独脚数卡"
      send_stats "安装$webname"
      ldnmp_install_status
      add_yuming
      #install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/dujiaoka.com.conf

      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      remove_ssl

      cd /home/web/html
      mkdir $yuming
      cd $yuming
      wget https://github.com/assimon/dujiaoka/releases/download/2.0.6/2.0.6-antibody.tar.gz && tar -zxvf 2.0.6-antibody.tar.gz && rm 2.0.6-antibody.tar.gz
      set_permissions
      restart_ldnmp


      ldnmp_web_on
      echo "数据库地址: mysql"
      echo "数据库端口: 3306"
      echo "数据库名: $dbname"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo ""
      echo "redis地址: redis"
      echo "redis密码: 默认不填写"
      echo "redis端口: 6379"
      echo ""
      echo "网站url: https://$yuming"
      echo "后台登录路径: /admin"
      echo "------------------------"
      echo "用户名: admin"
      echo "密码: admin"
      echo "------------------------"
      echo "登录时右上角如果出现红色error0请使用如下命令: "
      echo "我也很气愤独角数卡为啥这么麻烦，会有这样的问题！"
      echo "sed -i 's/ADMIN_HTTPS=false/ADMIN_HTTPS=true/g' /home/web/html/$yuming/dujiaoka/.env"
      nginx_status
        ;;

      7)
      clear
      # flarum论坛
      webname="flarum论坛"
      send_stats "安装$webname"
      ldnmp_install_status
      add_yuming
      #install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/flarum.com.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      remove_ssl

      cd /home/web/html
      mkdir $yuming
      cd $yuming

      docker exec php sh -c "php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\""
      docker exec php sh -c "php composer-setup.php"
      docker exec php sh -c "php -r \"unlink('composer-setup.php');\""
      docker exec php sh -c "mv composer.phar /usr/local/bin/composer"

      docker exec php composer create-project flarum/flarum /var/www/html/$yuming
      docker exec php sh -c "cd /var/www/html/$yuming && composer require flarum-lang/chinese-simplified"
      docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/polls"
      set_permissions
      restart_ldnmp


      ldnmp_web_on
      echo "数据库地址: mysql"
      echo "数据库名: $dbname"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "表前缀: flarum_"
      echo "管理员信息自行设置"
      nginx_status
        ;;

      8)
      clear
      # typecho
      webname="typecho"
      send_stats "安装$webname"
      ldnmp_install_status
      add_yuming
      #install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/typecho.com.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      remove_ssl

      cd /home/web/html
      mkdir $yuming
      cd $yuming
      wget -O latest.zip https://github.com/typecho/typecho/releases/latest/download/typecho.zip
      unzip latest.zip
      rm latest.zip
      set_permissions
      restart_ldnmp


      clear
      ldnmp_web_on
      echo "数据库前缀: typecho_"
      echo "数据库地址: mysql"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "数据库名: $dbname"
      nginx_status
        ;;
      9)
      clear
      # 雷池WAF-ldnmp旁入版
      webname="雷池WAF旁入版"
      send_stats "安装$webname"
      ldnmp_install_status
      # 使用官方一键脚本安装最新版流式检测版雷池
      install_leichi
      # nginx添加挂载
      cd /home/web
      grep -q 'resources/detector' docker-compose.yml || sed -i '16a\      - /data/safeline/resources/detector:/opt/detector' docker-compose.yml
      docker compose down nginx && docker compose up nginx -d
      # nginx安装lua组件
      docker exec nginx sh -c "luarocks install lua-resty-t1k --force-lock"
      # nginx引入t1k配置
      add_t1k
      # 重启nginx
      restart_nginx
      leichi_waf_on
      break_end
        ;;

      20)
      clear
      webname="PHP动态站点"
      send_stats "安装$webname"
      ldnmp_install_status
      add_yuming
      #install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/index_php.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      remove_ssl

      cd /home/web/html
      mkdir $yuming
      cd $yuming

      clear
      echo -e "[${huang}1/6${bai}] 上传PHP源码"
      echo "-------------"
      echo "目前只允许上传zip格式的源码包，请将源码包放到/home/web/html/${yuming}目录下"
      read -p "也可以输入下载链接，远程下载源码包，直接回车将跳过远程下载： " url_download

      if [ -n "$url_download" ]; then
          wget "$url_download"
      fi

      unzip $(ls -t *.zip | head -n 1)
      rm -f $(ls -t *.zip | head -n 1)
      
      clear
      echo -e "[${huang}2/6${bai}] index.php所在路径"
      echo "-------------"
      find "$(realpath .)" -name "index.php" -print

      read -p "请输入index.php的路径，类似（/home/web/html/$yuming/wordpress/）： " index_lujing

      sed -i "s#root /var/www/html/$yuming/#root $index_lujing#g" /home/web/conf.d/$yuming.conf
      sed -i "s#/home/web/#/var/www/#g" /home/web/conf.d/$yuming.conf
      
      
      clear
      echo -e "[${huang}3/6${bai}] 请选择PHP版本"
      echo "-------------"
      read -p "1. php最新版 | 2. php7.4 : " pho_v
      case "$pho_v" in
        1)
          sed -i "s#php:9000#php:9000#g" /home/web/conf.d/$yuming.conf
          PHP_Version="php"
          ;;
        2)
          sed -i "s#php:9000#php74:9000#g" /home/web/conf.d/$yuming.conf
          PHP_Version="php74"
          ;;
        *)
          echo "无效的选择，请重新输入。"
          ;;
      esac


      clear
      echo -e "[${huang}4/6${bai}] 安装指定扩展"
      echo "-------------"
      echo "已经安装的扩展"
      docker exec php php -m

      read -p "$(echo -e "输入需要安装的扩展名称，如 ${huang}SourceGuardian imap ftp${bai} 等等。直接回车将跳过安装 ： ")" php_extensions
      if [ -n "$php_extensions" ]; then
          docker exec $PHP_Version install-php-extensions $php_extensions
      fi


      clear
      echo -e "[${huang}5/6${bai}] 编辑站点配置"
      echo "-------------"
      echo "按任意键继续，可以详细设置站点配置，如伪静态等内容"
      read -n 1 -s -r -p ""
      install nano
      nano /home/web/conf.d/$yuming.conf


      clear
      echo -e "[${huang}6/6${bai}] 数据库管理"
      echo "-------------"
      read -p "1. 我搭建新站        2. 我搭建老站有数据库备份： " use_db
      case $use_db in
          1)
              echo
              ;;
          2)
              echo "数据库备份必须是.gz结尾的压缩包。请放到/home/目录下，支持宝塔/1panel备份数据导入。"
              read -p "也可以输入下载链接，远程下载备份数据，直接回车将跳过远程下载： " url_download_db

              cd /home/
              if [ -n "$url_download_db" ]; then
                  wget "$url_download_db"
              fi
              gunzip $(ls -t *.gz | head -n 1)
              latest_sql=$(ls -t *.sql | head -n 1)
              dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
              docker exec -i mysql mysql -u root -p"$dbrootpasswd" $dbname < "/home/$latest_sql"
              echo "数据库导入的表数据"
              docker exec -i mysql mysql -u root -p"$dbrootpasswd" -e "USE $dbname; SHOW TABLES;"
              rm -f *.sql
              echo "数据库导入完成"
              ;;
          *)
              echo
              ;;
      esac
      set_permissions
      restart_ldnmp

      ldnmp_web_on
      prefix="web$(shuf -i 10-99 -n 1)_"
      echo "数据库地址: mysql"
      echo "数据库名: $dbname"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "表前缀: $prefix"
      echo "管理员登录信息自行设置"
      nginx_status
        ;;


      21)
      send_stats "安装nginx环境"
      root_use
      check_port
      install_dependency
      install_docker
      #install_certbot

      cd /home && mkdir -p web/html web/mysql web/certs web/conf.d web/redis web/log/nginx && touch web/docker-compose.yml

      wget -O /home/web/nginx.conf https://raw.githubusercontent.com/linuxbt/nginx/main/nginx10.conf
      wget -O /home/web/conf.d/default.conf https://raw.githubusercontent.com/linuxbt/nginx/main/default10.conf
      default_server_ssl
      docker rm -f nginx >/dev/null 2>&1
      docker rmi nginx nginx:alpine-fat >/dev/null 2>&1
      docker run -d --name nginx --restart unless-stopped -p 80:80 -p 443:443 -p 443:443/udp -v /home/web/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf -v /home/web/conf.d:/etc/nginx/conf.d -v /home/web/certs:/opt/openresty/nginx/conf/certs -v /home/web/html:/var/www/html -v /home/web/log/nginx:/var/log/openresty openresty/openresty:alpine-fat
          
      clear
      nginx_version=$(docker exec nginx nginx -v 2>&1)
      nginx_version=$(echo "$nginx_version" | grep -oP '(?:openresty|nginx)/\K[\d.]+')
      echo "nginx已安装完成"
      echo -e "当前版本: ${huang}v$nginx_version${bai}"
      echo ""
        ;;

      22)
      clear
      webname="站点重定向"
      send_stats "安装$webname"
      nginx_install_status
      ip_address
      add_yuming
      read -p "请输入跳转域名: " reverseproxy

      #install_ssltls

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/rewrite.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      sed -i "s/baidu.com/$reverseproxy/g" /home/web/conf.d/$yuming.conf

      docker restart nginx

      nginx_web_on
      nginx_status

        ;;

      23)
      clear
      webname="反向代理-IP+端口"
      send_stats "安装$webname"
      nginx_install_status
      ip_address
      add_yuming
      read -p "请输入你的反代IP: " reverseproxy
      read -p "请输入你的反代端口: " port

      #install_ssltls

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/reverse-proxy.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      sed -i "s/0.0.0.0/$reverseproxy/g" /home/web/conf.d/$yuming.conf
      sed -i "s/0000/$port/g" /home/web/conf.d/$yuming.conf
      set_permissions
      docker restart nginx

      nginx_web_on
      nginx_status
        ;;

      24)
      clear
      webname="反向代理-域名"
      send_stats "安装$webname"
      nginx_install_status
      ip_address
      add_yuming
      echo -e "域名格式: ${huang}http://www.google.com${bai}"
      read -p "请输入你的反代域名: " fandai_yuming

      #install_ssltls

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/reverse-proxy-domain.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      sed -i "s|fandaicom|$fandai_yuming|g" /home/web/conf.d/$yuming.conf
      set_permissions
      docker restart nginx

      nginx_web_on
      nginx_status
        ;;


      25)
      clear
      webname="静态站点"
      send_stats "安装$webname"
      nginx_install_status
      add_yuming
      #install_ssltls

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/linuxbt/nginx/main/html.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

      cd /home/web/html
      mkdir $yuming
      cd $yuming


      clear
      echo -e "[${huang}1/2${bai}] 上传静态源码"
      echo "-------------"
      echo "目前只允许上传zip格式的源码包，请将源码包放到/home/web/html/${yuming}目录下"
      read -p "也可以输入下载链接，远程下载源码包，直接回车将跳过远程下载： " url_download

      if [ -n "$url_download" ]; then
          wget "$url_download"
      fi

      unzip $(ls -t *.zip | head -n 1)
      rm -f $(ls -t *.zip | head -n 1)

      clear
      echo -e "[${huang}2/2${bai}] index.html所在路径"
      echo "-------------"
      find "$(realpath .)" -name "index.html" -print

      read -p "请输入index.html的路径，类似（/home/web/html/$yuming/index/）： " index_lujing

      sed -i "s#root /var/www/html/$yuming/#root $index_lujing#g" /home/web/conf.d/$yuming.conf
      sed -i "s#/home/web/#/var/www/#g" /home/web/conf.d/$yuming.conf

      #docker exec nginx chmod -R 777 /var/www/html
      set_permissions
      docker restart nginx

      nginx_web_on
      nginx_status
        ;;


      26)
      clear
      webname="Bitwarden"
      send_stats "安装$webname"
      nginx_install_status
      add_yuming
      install_ssltls

      docker run -d \
        --name bitwarden \
        --restart always \
        -p 3280:80 \
        -v /home/web/html/$yuming/bitwarden/data:/data \
        vaultwarden/server
      duankou=3280
      reverse_proxy
      

      nginx_web_on
      nginx_status
        ;;

      27)
      clear
      webname="halo"
      send_stats "安装$webname"
      nginx_install_status
      add_yuming
      #install_ssltls

      docker run -d --name halo --restart always -p 8010:8090 -v /home/web/html/$yuming/.halo2:/root/.halo2 halohub/halo:2
      duankou=8010
      reverse_proxy
      remove_ssl
      

      nginx_web_on
      nginx_status
        ;;



    31)
    root_use
    while true; do
        clear
        send_stats "LDNMP站点管理"
        echo "LDNMP环境"
        echo "------------------------"
        ldnmp_v

        # ls -t /home/web/conf.d | sed 's/\.[^.]*$//'
        echo "站点信息                      证书到期时间"
        echo "------------------------"
        for cert_file in /home/web/certs/*_cert.pem; do
          domain=$(basename "$cert_file" | sed 's/_cert.pem//')
          if [ -n "$domain" ]; then
            expire_date=$(openssl x509 -noout -enddate -in "$cert_file" | awk -F'=' '{print $2}')
            formatted_date=$(date -d "$expire_date" '+%Y-%m-%d')
            printf "%-30s%s\n" "$domain" "$formatted_date"
          fi
        done

        echo "------------------------"
        echo ""
        echo "数据库信息"
        echo "------------------------"
        dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
        docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SHOW DATABASES;" 2> /dev/null | grep -Ev "Database|information_schema|mysql|performance_schema|sys"

        echo "------------------------"
        echo ""
        echo "站点目录"
        echo "------------------------"
        echo -e "数据 ${hui}/home/web/html${bai}     证书 ${hui}/home/web/certs${bai}     配置 ${hui}/home/web/conf.d${bai}"
        echo "------------------------"
        echo ""
        echo "操作"
        echo "------------------------"
        echo "1. 申请/更新域名证书                2. 更换绑定域名"
        echo "3. 清理站点缓存                    4. 查看站点分析报告"
        echo "5. 编辑全局配置                    6. 编辑站点配置"
        echo "------------------------"
        echo "7. 删除指定站点                    8. 删除指定数据库"
        echo "------------------------"
        echo "0. 返回上一级选单"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice
        case $sub_choice in
            1)
                send_stats "申请域名证书"
                read -p "请输入你的域名: " yuming
                install_ssltls

                ;;

            2)
                read -p "请输入旧域名: " oddyuming
                read -p "请输入新域名: " yuming
                #install_ssltls
                mv /home/web/conf.d/$oddyuming.conf /home/web/conf.d/$yuming.conf
                sed -i "s/$oddyuming/$yuming/g" /home/web/conf.d/$yuming.conf
                mv /home/web/html/$oddyuming /home/web/html/$yuming

                rm /home/web/certs/${oddyuming}_key.pem
                rm /home/web/certs/${oddyuming}_cert.pem

                docker restart nginx


                ;;


            3)
                send_stats "清理站点缓存"
                # docker exec -it nginx rm -rf /var/cache/nginx
                docker restart nginx
                docker exec php php -r 'opcache_reset();'
                docker restart php
                docker exec php74 php -r 'opcache_reset();'
                docker restart php74
                docker restart redis
                docker exec redis redis-cli FLUSHALL
                docker exec -it redis redis-cli CONFIG SET maxmemory 512mb
                docker exec -it redis redis-cli CONFIG SET maxmemory-policy allkeys-lru

                ;;
            4)
                send_stats "查看站点数据"
                install goaccess
                goaccess --log-format=COMBINED /home/web/log/nginx/access.log

                ;;

            5)
                send_stats "编辑全局配置"
                install vim
                vim /home/web/nginx.conf
                docker restart nginx
                ;;

            6)
                send_stats "编辑站点配置"
                read -p "编辑站点配置，请输入你要编辑的域名: " yuming
                install vim
                vim /home/web/conf.d/$yuming.conf
                docker restart nginx
                ;;

            7)
                send_stats "删除站点数据目录"
                read -p "删除站点数据目录，请输入你的域名: " yuming
                rm -r /home/web/html/$yuming
                rm /home/web/conf.d/$yuming.conf
                rm /home/web/certs/${yuming}_key.pem
                rm /home/web/certs/${yuming}_cert.pem
                docker restart nginx
                ;;
            8)
                send_stats "删除站点数据库"
                read -p "删除站点数据库，请输入数据库名: " shujuku
                dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
                docker exec mysql mysql -u root -p"$dbrootpasswd" -e "DROP DATABASE $shujuku;" 2> /dev/null
                ;;
            0)
                break  # 跳出循环，退出菜单
                ;;
            *)
                break  # 跳出循环，退出菜单
                ;;
        esac
    done

      ;;


    32)
      clear
      send_stats "LDNMP环境备份"
      cd /home/ && tar czvf web_$(date +"%Y%m%d%H%M%S").tar.gz web

      while true; do
        clear
        read -p "要传送文件到远程服务器吗？(Y/N): " choice
        case "$choice" in
          [Yy])
            read -p "请输入远端服务器IP:  " remote_ip
            if [ -z "$remote_ip" ]; then
              echo "错误: 请输入远端服务器IP。"
              continue
            fi
            latest_tar=$(ls -t /home/*.tar.gz | head -1)
            if [ -n "$latest_tar" ]; then
              ssh-keygen -f "/root/.ssh/known_hosts" -R "$remote_ip"
              sleep 2  # 添加等待时间
              scp -o StrictHostKeyChecking=no "$latest_tar" "root@$remote_ip:/home/"
              echo "文件已传送至远程服务器home目录。"
            else
              echo "未找到要传送的文件。"
            fi
            break
            ;;
          [Nn])
            break
            ;;
          *)
            echo "无效的选择，请输入 Y 或 N。"
            ;;
        esac
      done
      ;;

    33)
      clear
      send_stats "定时远程备份"
      read -p "输入远程服务器IP: " useip
      read -p "输入远程服务器密码: " usepasswd

      cd ~
      wget -O ${useip}_beifen.sh https://raw.githubusercontent.com/linuxbt/sh/main/beifen.sh > /dev/null 2>&1
      chmod +x ${useip}_beifen.sh

      sed -i "s/0.0.0.0/$useip/g" ${useip}_beifen.sh
      sed -i "s/123456/$usepasswd/g" ${useip}_beifen.sh

      echo "------------------------"
      echo "1. 每周备份                 2. 每天备份"
      read -p "请输入你的选择: " dingshi

      case $dingshi in
          1)
              check_crontab_installed
              read -p "选择每周备份的星期几 (0-6，0代表星期日): " weekday
              (crontab -l ; echo "0 0 * * $weekday ./${useip}_beifen.sh") | crontab - > /dev/null 2>&1
              ;;
          2)
              check_crontab_installed
              read -p "选择每天备份的时间（小时，0-23）: " hour
              (crontab -l ; echo "0 $hour * * * ./${useip}_beifen.sh") | crontab - > /dev/null 2>&1
              ;;
          *)
              break  # 跳出
              ;;
      esac

      install sshpass

      ;;

    34)
      root_use
      send_stats "LDNMP环境还原"
      echo "请确认home目录中已经放置网站备份的gz压缩包，按任意键继续……"
      read -n 1 -s -r -p ""
      echo "开始解压……"
      cd /home/ && ls -t /home/*.tar.gz | head -1 | xargs -I {} tar -xzf {}
      check_port
      install_dependency
      install_docker
      #install_certbot

      install_ldnmp

      ;;

    35)
        send_stats "LDNMP环境防御"
        if docker inspect fail2ban &>/dev/null ; then
          while true; do
              clear
              echo "服务器防御程序已启动"
              echo "------------------------"
              echo "1. 开启SSH防暴力破解              2. 关闭SSH防暴力破解"
              echo "3. 开启网站保护                   4. 关闭网站保护"
              echo "------------------------"
              echo "5. 查看SSH拦截记录                6. 查看网站拦截记录"
              echo "7. 查看防御规则列表               8. 查看日志实时监控"
              echo "------------------------"
              echo "11. 配置拦截参数"
              echo "------------------------"
              echo "21. cloudflare模式                22. 高负载开启5秒盾"
              echo "------------------------"
              echo "9. 卸载防御程序"
              echo "------------------------"
              echo "0. 退出"
              echo "------------------------"
              read -p "请输入你的选择: " sub_choice
              case $sub_choice in
                  1)
                      sed -i 's/false/true/g' /path/to/fail2ban/config/fail2ban/jail.d/alpine-ssh.conf
                      sed -i 's/false/true/g' /path/to/fail2ban/config/fail2ban/jail.d/linux-ssh.conf
                      sed -i 's/false/true/g' /path/to/fail2ban/config/fail2ban/jail.d/centos-ssh.conf
                      f2b_status
                      ;;
                  2)
                      sed -i 's/true/false/g' /path/to/fail2ban/config/fail2ban/jail.d/alpine-ssh.conf
                      sed -i 's/true/false/g' /path/to/fail2ban/config/fail2ban/jail.d/linux-ssh.conf
                      sed -i 's/true/false/g' /path/to/fail2ban/config/fail2ban/jail.d/centos-ssh.conf
                      f2b_status
                      ;;
                  3)
                      sed -i 's/false/true/g' /path/to/fail2ban/config/fail2ban/jail.d/nginx-docker-cc.conf
                      f2b_status
                      ;;
                  4)
                      sed -i 's/true/false/g' /path/to/fail2ban/config/fail2ban/jail.d/nginx-docker-cc.conf
                      f2b_status
                      ;;
                  5)
                      echo "------------------------"
                      f2b_sshd
                      echo "------------------------"
                      ;;
                  6)

                      echo "------------------------"
                      xxx=fail2ban-nginx-cc
                      f2b_status_xxx
                      echo "------------------------"
                      xxx=docker-nginx-bad-request
                      f2b_status_xxx
                      echo "------------------------"
                      xxx=docker-nginx-botsearch
                      f2b_status_xxx
                      echo "------------------------"
                      xxx=docker-nginx-http-auth
                      f2b_status_xxx
                      echo "------------------------"
                      xxx=docker-nginx-limit-req
                      f2b_status_xxx
                      echo "------------------------"
                      xxx=docker-php-url-fopen
                      f2b_status_xxx
                      echo "------------------------"

                      ;;

                  7)
                      docker exec -it fail2ban fail2ban-client status
                      ;;
                  8)
                      tail -f /path/to/fail2ban/config/log/fail2ban/fail2ban.log

                      ;;
                  9)
                      docker rm -f fail2ban
                      rm -rf /path/to/fail2ban
                      crontab -l | grep -v "CF-Under-Attack.sh" | crontab - 2>/dev/null
                      echo "Fail2Ban防御程序已卸载"
                      break
                      ;;

                  11)
                      install vim
                      vim /path/to/fail2ban/config/fail2ban/jail.d/nginx-docker-cc.conf
                      f2b_status

                      break
                      ;;
                  21)
                      send_stats "cloudflare模式"
                      echo "到cf后台右上角我的个人资料，选择左侧API令牌，获取Global API Key"
                      echo "https://dash.cloudflare.com/login"
                      read -p "输入CF的账号: " cfuser
                      read -p "输入CF的Global API Key: " cftoken

                      wget -O /home/web/conf.d/default.conf https://raw.githubusercontent.com/linuxbt/nginx/main/default11.conf
                      docker restart nginx

                      cd /path/to/fail2ban/config/fail2ban/jail.d/
                      curl -sS -O https://raw.githubusercontent.com/linuxbt/config/main/fail2ban/nginx-docker-cc.conf

                      cd /path/to/fail2ban/config/fail2ban/action.d
                      curl -sS -O https://raw.githubusercontent.com/linuxbt/config/main/fail2ban/cloudflare-docker.conf

                      sed -i "s/linuxbt@outlook.com/$cfuser/g" /path/to/fail2ban/config/fail2ban/action.d/cloudflare-docker.conf
                      sed -i "s/APIKEY00000/$cftoken/g" /path/to/fail2ban/config/fail2ban/action.d/cloudflare-docker.conf
                      f2b_status

                      echo "已配置cloudflare模式，可在cf后台，站点-安全性-事件中查看拦截记录"
                      ;;

                  22)
                      send_stats "高负载开启5秒盾"
                      echo -e "${huang}网站每5分钟自动检测，当达检测到高负载会自动开盾，低负载也会自动关闭5秒盾。${bai}"
                      echo "--------------"
                      echo "获取CF参数: "
                      echo -e "到cf后台右上角我的个人资料，选择左侧API令牌，获取${huang}Global API Key${bai}"
                      echo -e "到cf后台域名概要页面右下方获取${huang}区域ID${bai}"
                      echo "https://dash.cloudflare.com/login"
                      echo "--------------"
                      read -p "输入CF的账号: " cfuser
                      read -p "输入CF的Global API Key: " cftoken
                      read -p "输入CF中域名的区域ID: " cfzonID

                      cd ~
                      install jq bc
                      check_crontab_installed
                      curl -sS -O https://raw.githubusercontent.com/linuxbt/sh/main/CF-Under-Attack.sh
                      chmod +x CF-Under-Attack.sh
                      sed -i "s/AAAA/$cfuser/g" ~/CF-Under-Attack.sh
                      sed -i "s/BBBB/$cftoken/g" ~/CF-Under-Attack.sh
                      sed -i "s/CCCC/$cfzonID/g" ~/CF-Under-Attack.sh

                      cron_job="*/5 * * * * ~/CF-Under-Attack.sh"

                      existing_cron=$(crontab -l 2>/dev/null | grep -F "$cron_job")

                      if [ -z "$existing_cron" ]; then
                          (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
                          echo "高负载自动开盾脚本已添加"
                      else
                          echo "自动开盾脚本已存在，无需添加"
                      fi

                      ;;
                  0)
                      break
                      ;;
                  *)
                      echo "无效的选择，请重新输入。"
                      ;;
              esac
              break_end

          done

      elif [ -x "$(command -v fail2ban-client)" ] ; then
          clear
          echo "卸载旧版fail2ban"
          read -p "确定继续吗？(Y/N): " choice
          case "$choice" in
            [Yy])
              remove fail2ban
              rm -rf /etc/fail2ban
              echo "Fail2Ban防御程序已卸载"
              ;;
            [Nn])
              echo "已取消"
              ;;
            *)
              echo "无效的选择，请输入 Y 或 N。"
              ;;
          esac

      else
          clear
          install_docker
	  nginx_install_status

          #docker rm -f nginx
          #wget -O /home/web/nginx.conf https://raw.githubusercontent.com/linuxbt/nginx/main/nginx10.conf
          #wget -O /home/web/conf.d/default.conf https://raw.githubusercontent.com/linuxbt/nginx/main/default10.conf
          #default_server_ssl
          #docker run -d --name nginx --restart always -p 80:80 -p 443:443 -p 443:443/udp -v /home/web/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf -v /home/web/conf.d:/etc/nginx/conf.d -v /home/web/certs:/opt/openresty/nginx/conf/certs -v /home/web/html:/var/www/html -v /home/web/log/nginx:/var/log/openresty openresty/openresty:alpine-fat
          ##docker exec -it nginx chmod -R 777 /var/www/html

          f2b_install_sshd

          cd /path/to/fail2ban/config/fail2ban/filter.d
          curl -sS -O https://raw.githubusercontent.com/linuxbt/sh/main/fail2ban-nginx-cc.conf
          cd /path/to/fail2ban/config/fail2ban/jail.d/
          curl -sS -O https://raw.githubusercontent.com/linuxbt/config/main/fail2ban/nginx-docker-cc.conf
          sed -i "/cloudflare/d" /path/to/fail2ban/config/fail2ban/jail.d/nginx-docker-cc.conf

          cd ~
          f2b_status

          echo "防御程序已开启"
      fi

        ;;

    36)
          while true; do
              clear
              send_stats "优化LDNMP环境"
              echo "优化LDNMP环境"
              echo "------------------------"
              echo "1. 标准模式              2. 高性能模式 (推荐2H2G以上)"
              echo "------------------------"
              echo "0. 退出"
              echo "------------------------"
              read -p "请输入你的选择: " sub_choice
              case $sub_choice in
                  1)
                  send_stats "站点标准模式"
                  # nginx调优
                  sed -i 's/worker_connections.*/worker_connections 1024;/' /home/web/nginx.conf

                  # php调优
                  wget -O /home/optimized_php.ini https://raw.githubusercontent.com/linuxbt/sh/main/optimized_php.ini
                  docker cp /home/optimized_php.ini php:/usr/local/etc/php/conf.d/optimized_php.ini
                  docker cp /home/optimized_php.ini php74:/usr/local/etc/php/conf.d/optimized_php.ini
                  rm -rf /home/optimized_php.ini

                  # php调优
                  wget -O /home/www.conf https://raw.githubusercontent.com/linuxbt/sh/main/www-1.conf
                  docker cp /home/www.conf php:/usr/local/etc/php-fpm.d/www.conf
                  docker cp /home/www.conf php74:/usr/local/etc/php-fpm.d/www.conf
                  rm -rf /home/www.conf

                  # mysql调优
                  wget -O /home/custom_mysql_config.cnf https://raw.githubusercontent.com/linuxbt/sh/main/custom_mysql_config-1.cnf
                  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
                  rm -rf /home/custom_mysql_config.cnf

                  docker exec -it redis redis-cli CONFIG SET maxmemory 512mb
                  docker exec -it redis redis-cli CONFIG SET maxmemory-policy allkeys-lru

                  docker restart nginx
                  docker restart php
                  docker restart php74
                  docker restart mysql

                  echo "LDNMP环境已设置成 标准模式"

                      ;;
                  2)
                  send_stats "站点高性能模式"
                  # nginx调优
                  sed -i 's/worker_connections.*/worker_connections 10240;/' /home/web/nginx.conf

                  # php调优
                  wget -O /home/www.conf https://raw.githubusercontent.com/linuxbt/sh/main/www.conf
                  docker cp /home/www.conf php:/usr/local/etc/php-fpm.d/www.conf
                  docker cp /home/www.conf php74:/usr/local/etc/php-fpm.d/www.conf
                  rm -rf /home/www.conf

                  # mysql调优
                  wget -O /home/custom_mysql_config.cnf https://raw.githubusercontent.com/linuxbt/sh/main/custom_mysql_config.cnf
                  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
                  rm -rf /home/custom_mysql_config.cnf

                  docker exec -it redis redis-cli CONFIG SET maxmemory 1024mb
                  docker exec -it redis redis-cli CONFIG SET maxmemory-policy allkeys-lru

                  docker restart nginx
                  docker restart php
                  docker restart php74
                  docker restart mysql

                  echo "LDNMP环境已设置成 高性能模式"

                      ;;
                  0)
                      break
                      ;;
                  *)
                      echo "无效的选择，请重新输入。"
                      ;;
              esac
              break_end

          done
        ;;


    37)
      root_use
      send_stats "更新LDNMP环境"

        read -p "$(echo -e "${huang}注意：${bai}长时间不更新环境的用户，请慎重更新LDNMP环境，会有数据库更新失败的风险。确定更新LDNMP环境吗？(Y/N): ")" choice
        case "$choice" in
          [Yy])
            docker rm -f nginx php php74 mysql redis
            docker rmi nginx nginx:alpine php:fpm php:fpm-alpine php:7.4.33-fpm php:7.4-fpm-alpine mysql redis redis:alpine

            check_port
            install_dependency
            install_docker
            #install_certbot
            install_ldnmp

            ;;
          [Nn])
            ;;
          *)
            echo "无效的选择，请输入 Y 或 N。"
            ;;
        esac
      ;;

    38)
        root_use
        send_stats "卸载LDNMP环境"
        read -p "$(echo -e "${hong}强烈建议：${bai}先备份全部网站数据，再卸载LDNMP环境。确定删除所有网站数据吗？(Y/N): ")" choice
        case "$choice" in
          [Yy])
            docker rm -f nginx php php74 mysql redis
            docker rmi nginx nginx:alpine php:fpm php:fpm-alpine php:7.4.33-fpm php:7.4-fpm-alpine mysql redis redis:alpine
            rm -rf /home/web

            ;;
          [Nn])

            ;;
          *)
            echo "无效的选择，请输入 Y 或 N。"
            ;;
        esac
        ;;

    0)
        linuxbt
      ;;

    *)
        echo "无效的输入!"
    esac
    break_end

  done

}



linux_panel() {

    while true; do
      clear
      # send_stats "面板工具"
      echo "▶ 面板工具"
	echo -e "${bai}------------------------${bai}"
	echo -e "${lan}1. 宝塔面板官方版${bai}                       ${kjlan}2. aaPanel宝塔国际版${bai}"
	echo -e "${huang}3. 1Panel新一代管理面板${bai}                 ${kjlan}4. NginxProxyManager可视化面板${bai}"
	echo -e "${lan}5. AList多存储文件列表程序${bai}              ${huang}6. Ubuntu远程桌面网页版${bai}"
	echo -e "${kjlan}7. 哪吒探针VPS监控面板${bai}                  ${huang}8. QB离线BT磁力下载面板${bai}"
	echo -e "${lan}9. Poste.io邮件服务器程序${bai}               ${kjlan}10. RocketChat多人在线聊天系统${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${kjlan}11. 禅道项目管理软件${bai}                    ${huang}12. 青龙面板定时任务管理平台${bai}"
	echo -e "${lan}13. Cloudreve网盘${bai}                       ${kjlan}14. 简单图床图片管理程序${bai}"
	echo -e "${huang}15. emby多媒体管理系统${bai}                  ${lan}16. Speedtest测速面板${bai}"
	echo -e "${huang}17. AdGuardHome去广告软件${bai}               ${kjlan}18. onlyoffice在线办公OFFICE${bai}"
	echo -e "${lan}19. 雷池WAF防火墙面板${bai}                   ${huang}20. portainer容器管理面板${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${huang}21. VScode网页版${bai}                        ${lan}22. UptimeKuma监控工具${bai}"
	echo -e "${kjlan}23. Memos网页备忘录${bai}                     ${huang}24. Webtop远程桌面网页版${bai}"
	echo -e "${lan}25. Nextcloud网盘${bai}                       ${kjlan}26. QD-Today定时任务管理框架${bai}"
	echo -e "${huang}27. Dockge容器堆栈管理面板${bai}              ${lan}28. LibreSpeed测速工具${bai}"
	echo -e "${kjlan}29. searxng聚合搜索站${bai}                   ${huang}30. PhotoPrism私有相册系统${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${huang}31. StirlingPDF工具大全${bai}                 ${kjlan}32. drawio免费的在线图表软件${bai}"
	echo -e "${lan}33. Sun-Panel导航面板${bai}                   ${kjlan}34. Pingvin-Share文件分享平台${bai}"
	echo -e "${huang}35. 极简朋友圈${bai}                          ${lan}36. LobeChatAI聊天聚合网站${bai}"
	echo -e "${kjlan}37. MyIP工具箱${bai}                          ${huang}38. 小雅alist全家桶${bai}"
	echo -e "${huang}39. Bililive直播录制工具${bai}                ${bai}40. docker版Windows 2022${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${kjlan}51. PVE开小鸡面板${bai}"
	echo -e "${bai}------------------------${bai}"
	echo -e "${lan}0. 返回主菜单${bai}"
	echo -e "${bai}------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in
          1)

            lujing="[ -d "/www/server/panel" ]"
            panelname="宝塔面板"

            gongneng1="bt"
            gongneng1_1=""
            gongneng2="curl -o bt-uninstall.sh http://download.bt.cn/install/bt-uninstall.sh > /dev/null 2>&1 && chmod +x bt-uninstall.sh && ./bt-uninstall.sh"
            gongneng2_1="chmod +x bt-uninstall.sh"
            gongneng2_2="./bt-uninstall.sh"

            panelurl="https://www.bt.cn/new/index.html"


            centos_mingling="wget -O install.sh https://download.bt.cn/install/install_6.0.sh"
            centos_mingling2="sh install.sh ed8484bec"

            ubuntu_mingling="wget -O install.sh https://download.bt.cn/install/install-ubuntu_6.0.sh"
            ubuntu_mingling2="bash install.sh ed8484bec"

            install_panel



              ;;
          2)

            lujing="[ -d "/www/server/panel" ]"
            panelname="aapanel"

            gongneng1="bt"
            gongneng1_1=""
            gongneng2="curl -o bt-uninstall.sh http://download.bt.cn/install/bt-uninstall.sh > /dev/null 2>&1 && chmod +x bt-uninstall.sh && ./bt-uninstall.sh"
            gongneng2_1="chmod +x bt-uninstall.sh"
            gongneng2_2="./bt-uninstall.sh"

            panelurl="https://www.aapanel.com/new/index.html"

            centos_mingling="wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh"
            centos_mingling2="bash install.sh aapanel"

            ubuntu_mingling="wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh"
            ubuntu_mingling2="bash install.sh aapanel"

            install_panel

              ;;
          3)

            lujing="command -v 1pctl &> /dev/null"
            panelname="1Panel"

            gongneng1="1pctl user-info"
            gongneng1_1="1pctl update password"
            gongneng2="1pctl uninstall"
            gongneng2_1=""
            gongneng2_2=""

            panelurl="https://1panel.cn/"


            centos_mingling="curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh"
            centos_mingling2="sh quick_start.sh"

            ubuntu_mingling="curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh"
            ubuntu_mingling2="bash quick_start.sh"

            install_panel

              ;;
          4)

            docker_name="npm"
            docker_img="jc21/nginx-proxy-manager:latest"
            docker_port=81
            docker_rum="docker run -d \
                          --name=$docker_name \
                          -p 80:80 \
                          -p 81:$docker_port \
                          -p 443:443 \
                          -v /home/docker/npm/data:/data \
                          -v /home/docker/npm/letsencrypt:/etc/letsencrypt \
                          --restart=always \
                          $docker_img"
            docker_describe="如果您已经安装了其他面板工具或者LDNMP建站环境，建议先卸载，再安装npm！"
            docker_url="官网介绍: https://nginxproxymanager.com/"
            docker_use="echo \"初始用户名: admin@example.com\""
            docker_passwd="echo \"初始密码: changeme\""

            docker_app

              ;;

          5)

            docker_name="alist"
            docker_img="xhofe/alist:latest"
            docker_port=5244
            docker_rum="docker run -d \
                                --restart=always \
                                -v /home/docker/alist:/opt/alist/data \
                                -p 5244:5244 \
                                -e PUID=0 \
                                -e PGID=0 \
                                -e UMASK=022 \
                                --name="alist" \
                                xhofe/alist:latest"
            docker_describe="一个支持多种存储，支持网页浏览和 WebDAV 的文件列表程序，由 gin 和 Solidjs 驱动"
            docker_url="官网介绍: https://alist.nn.ci/zh/"
            docker_use="docker exec -it alist ./alist admin random"
            docker_passwd=""

            docker_app

              ;;

          6)

            docker_name="webtop-ubuntu"
            docker_img="lscr.io/linuxserver/webtop:ubuntu-kde"
            docker_port=3006
            docker_rum="docker run -d \
                          --name=webtop-ubuntu \
                          --security-opt seccomp=unconfined \
                          -e PUID=1000 \
                          -e PGID=1000 \
                          -e TZ=Etc/UTC \
                          -e SUBFOLDER=/ \
                          -e TITLE=Webtop \
                          -p 3006:3000 \
                          -v /home/docker/webtop/data:/config \
                          -v /var/run/docker.sock:/var/run/docker.sock \
                          --shm-size="1gb" \
                          --restart unless-stopped \
                          lscr.io/linuxserver/webtop:ubuntu-kde"

            docker_describe="webtop基于Ubuntu的容器，包含官方支持的完整桌面环境，可通过任何现代 Web 浏览器访问"
            docker_url="官网介绍: https://docs.linuxserver.io/images/docker-webtop/"
            docker_use=""
            docker_passwd=""
            docker_app


              ;;
          7)
            clear
            send_stats "搭建哪吒"
            curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh  -o nezha.sh && chmod +x nezha.sh
            ./nezha.sh
              ;;

          8)

            docker_name="qbittorrent"
            docker_img="lscr.io/linuxserver/qbittorrent:latest"
            docker_port=8081
            docker_rum="docker run -d \
                                  --name=qbittorrent \
                                  -e PUID=1000 \
                                  -e PGID=1000 \
                                  -e TZ=Etc/UTC \
                                  -e WEBUI_PORT=8081 \
                                  -p 8081:8081 \
                                  -p 6881:6881 \
                                  -p 6881:6881/udp \
                                  -v /home/docker/qbittorrent/config:/config \
                                  -v /home/docker/qbittorrent/downloads:/downloads \
                                  --restart unless-stopped \
                                  lscr.io/linuxserver/qbittorrent:latest"
            docker_describe="qbittorrent离线BT磁力下载服务"
            docker_url="官网介绍: https://hub.docker.com/r/linuxserver/qbittorrent"
            docker_use="sleep 3"
            docker_passwd="docker logs qbittorrent"

            docker_app

              ;;

          9)
            send_stats "搭建邮局"
            if docker inspect mailserver &>/dev/null; then

                    clear
                    echo "poste.io已安装，访问地址: "
                    yuming=$(cat /home/docker/mail.txt)
                    echo "https://$yuming"
                    echo ""

                    echo "应用操作"
                    echo "------------------------"
                    echo "1. 更新应用             2. 卸载应用"
                    echo "------------------------"
                    echo "0. 返回上一级选单"
                    echo "------------------------"
                    read -p "请输入你的选择: " sub_choice

                    case $sub_choice in
                        1)
                            clear
                            docker rm -f mailserver
                            docker rmi -f analogic/poste.io

                            yuming=$(cat /home/docker/mail.txt)
                            docker run \
                                --net=host \
                                -e TZ=Europe/Prague \
                                -v /home/docker/mail:/data \
                                --name "mailserver" \
                                -h "$yuming" \
                                --restart=always \
                                -d analogic/poste.io

                            clear
                            echo "poste.io已经安装完成"
                            echo "------------------------"
                            echo "您可以使用以下地址访问poste.io:"
                            echo "https://$yuming"
                            echo ""
                            ;;
                        2)
                            clear
                            docker rm -f mailserver
                            docker rmi -f analogic/poste.io
                            rm /home/docker/mail.txt
                            rm -rf /home/docker/mail
                            echo "应用已卸载"
                            ;;
                        0)
                            break  # 跳出循环，退出菜单
                            ;;
                        *)
                            break  # 跳出循环，退出菜单
                            ;;
                    esac
            else
                clear
                install telnet

                clear
                echo ""
                echo "端口检测"
                port=25
                timeout=3

                if echo "quit" | timeout $timeout telnet smtp.qq.com $port | grep 'Connected'; then
                  echo -e "${lv}端口 $port 当前可用${bai}"
                else
                  echo -e "${hong}端口 $port 当前不可用${bai}"
                fi
                echo "------------------------"
                echo ""


                echo "安装提示"
                echo "poste.io一个邮件服务器，确保80和443端口没被占用，确保25端口开放"
                echo "官网介绍: https://hub.docker.com/r/analogic/poste.io"
                echo ""

                # 提示用户确认安装
                read -p "确定安装poste.io吗？(Y/N): " choice
                case "$choice" in
                    [Yy])
                    clear

                    read -p "请设置邮箱域名 例如 mail.yuming.com : " yuming
                    mkdir -p /home/docker      # 递归创建目录
                    echo "$yuming" > /home/docker/mail.txt  # 写入文件
                    echo "------------------------"
                    ip_address
                    echo "先解析这些DNS记录"
                    echo "A           mail            $ipv4_address"
                    echo "CNAME       imap            $yuming"
                    echo "CNAME       pop             $yuming"
                    echo "CNAME       smtp            $yuming"
                    echo "MX          @               $yuming"
                    echo "TXT         @               v=spf1 mx ~all"
                    echo "TXT         ?               ?"
                    echo ""
                    echo "------------------------"
                    echo "按任意键继续..."
                    read -n 1 -s -r -p ""

                    install_docker

                    docker run \
                        --net=host \
                        -e TZ=Europe/Prague \
                        -v /home/docker/mail:/data \
                        --name "mailserver" \
                        -h "$yuming" \
                        --restart=always \
                        -d analogic/poste.io

                    clear
                    echo "poste.io已经安装完成"
                    echo "------------------------"
                    echo "您可以使用以下地址访问poste.io:"
                    echo "https://$yuming"
                    echo ""

                        ;;
                    [Nn])
                        ;;
                    *)
                        ;;
                esac
            fi
              ;;

          10)
            send_stats "搭建聊天"
            has_ipv4_has_ipv6

            if docker inspect rocketchat &>/dev/null; then

                    clear
                    echo "rocket.chat已安装，访问地址: "
                    if $has_ipv4; then
                        echo "http:$ipv4_address:3897"
                    fi
                    if $has_ipv6; then
                        echo "http:[$ipv6_address]:3897"
                    fi
                    echo ""

                    echo "应用操作"
                    echo "------------------------"
                    echo "1. 更新应用             2. 卸载应用"
                    echo "------------------------"
                    echo "0. 返回上一级选单"
                    echo "------------------------"
                    read -p "请输入你的选择: " sub_choice

                    case $sub_choice in
                        1)
                            clear
                            docker rm -f rocketchat
                            docker rmi -f rocket.chat:6.3


                            docker run --name rocketchat --restart=always -p 3897:3000 --link db --env ROOT_URL=http://localhost --env MONGO_OPLOG_URL=mongodb://db:27017/rs5 -d rocket.chat

                            clear
                            ip_address
                            echo "rocket.chat已经安装完成"
                            echo "------------------------"
                            echo "多等一会，您可以使用以下地址访问rocket.chat:"
                            if $has_ipv4; then
                                echo "http:$ipv4_address:3897"
                            fi
                            if $has_ipv6; then
                                echo "http:[$ipv6_address]:3897"
                            fi
                            echo ""
                            ;;
                        2)
                            clear
                            docker rm -f rocketchat
                            docker rmi -f rocket.chat
                            docker rmi -f rocket.chat:6.3
                            docker rm -f db
                            docker rmi -f mongo:latest
                            # docker rmi -f mongo:6
                            rm -rf /home/docker/mongo
                            echo "应用已卸载"
                            ;;
                        0)
                            break  # 跳出循环，退出菜单
                            ;;
                        *)
                            break  # 跳出循环，退出菜单
                            ;;
                    esac
            else
                clear
                echo "安装提示"
                echo "rocket.chat国外知名开源多人聊天系统"
                echo "官网介绍: https://www.rocket.chat"
                echo ""

                # 提示用户确认安装
                read -p "确定安装rocket.chat吗？(Y/N): " choice
                case "$choice" in
                    [Yy])
                    clear
                    install_docker
                    docker run --name db -d --restart=always \
                        -v /home/docker/mongo/dump:/dump \
                        mongo:latest --replSet rs5 --oplogSize 256
                    sleep 1
                    docker exec -it db mongosh --eval "printjson(rs.initiate())"
                    sleep 5
                    docker run --name rocketchat --restart=always -p 3897:3000 --link db --env ROOT_URL=http://localhost --env MONGO_OPLOG_URL=mongodb://db:27017/rs5 -d rocket.chat

                    clear

                    ip_address
                    echo "rocket.chat已经安装完成"
                    echo "------------------------"
                    echo "多等一会，您可以使用以下地址访问rocket.chat:"
                    if $has_ipv4; then
                        echo "http:$ipv4_address:3897"
                    fi
                    if $has_ipv6; then
                        echo "http:[$ipv6_address]:3897"
                    fi
                    echo ""

                        ;;
                    [Nn])
                        ;;
                    *)
                        ;;
                esac
            fi
              ;;



          11)
            docker_name="zentao-server"
            docker_img="idoop/zentao:latest"
            docker_port=82
            docker_rum="docker run -d -p 82:80 -p 3308:3306 \
                              -e ADMINER_USER="root" -e ADMINER_PASSWD="password" \
                              -e BIND_ADDRESS="false" \
                              -v /home/docker/zentao-server/:/opt/zbox/ \
                              --add-host smtp.exmail.qq.com:163.177.90.125 \
                              --name zentao-server \
                              --restart=always \
                              idoop/zentao:latest"
            docker_describe="禅道是通用的项目管理软件"
            docker_url="官网介绍: https://www.zentao.net/"
            docker_use="echo \"初始用户名: admin\""
            docker_passwd="echo \"初始密码: 123456\""
            docker_app

              ;;

          12)
            docker_name="qinglong"
            docker_img="whyour/qinglong:latest"
            docker_port=5700
            docker_rum="docker run -d \
                      -v /home/docker/qinglong/data:/ql/data \
                      -p 5700:5700 \
                      --name qinglong \
                      --hostname qinglong \
                      --restart unless-stopped \
                      whyour/qinglong:latest"
            docker_describe="青龙面板是一个定时任务管理平台"
            docker_url="官网介绍: https://github.com/whyour/qinglong"
            docker_use=""
            docker_passwd=""
            docker_app

              ;;
          13)
            send_stats "搭建网盘"
            has_ipv4_has_ipv6

            if docker inspect cloudreve &>/dev/null; then

                    clear
                    echo "cloudreve已安装，访问地址: "

                    if $has_ipv4; then
                        echo "http:$ipv4_address:5212"
                    fi
                    if $has_ipv6; then
                        echo "http:[$ipv6_address]:5212"
                    fi

                    echo ""

                    echo "应用操作"
                    echo "------------------------"
                    echo "1. 更新应用             2. 卸载应用"
                    echo "------------------------"
                    echo "0. 返回上一级选单"
                    echo "------------------------"
                    read -p "请输入你的选择: " sub_choice

                    case $sub_choice in
                        1)
                            clear
                            docker rm -f cloudreve
                            docker rmi -f cloudreve/cloudreve:latest
                            docker rm -f aria2
                            docker rmi -f p3terx/aria2-pro

                            cd /home/ && mkdir -p docker/cloud && cd docker/cloud && mkdir temp_data && mkdir -vp cloudreve/{uploads,avatar} && touch cloudreve/conf.ini && touch cloudreve/cloudreve.db && mkdir -p aria2/config && mkdir -p data/aria2 && chmod -R 777 data/aria2
                            curl -o /home/docker/cloud/docker-compose.yml https://raw.githubusercontent.com/linuxbt/docker/main/cloudreve-docker-compose.yml
                            cd /home/docker/cloud/ && docker compose up -d


                            clear
                            echo "cloudreve已经安装完成"
                            echo "------------------------"
                            echo "您可以使用以下地址访问cloudreve:"

                            if $has_ipv4; then
                                echo "http:$ipv4_address:5212"
                            fi
                            if $has_ipv6; then
                                echo "http:[$ipv6_address]:5212"
                            fi

                            sleep 3
                            docker logs cloudreve
                            echo ""
                            ;;
                        2)
                            clear
                            docker rm -f cloudreve
                            docker rmi -f cloudreve/cloudreve:latest
                            docker rm -f aria2
                            docker rmi -f p3terx/aria2-pro
                            rm -rf /home/docker/cloud
                            echo "应用已卸载"
                            ;;
                        0)
                            break  # 跳出循环，退出菜单
                            ;;
                        *)
                            break  # 跳出循环，退出菜单
                            ;;
                    esac
            else
                clear
                echo "安装提示"
                echo "cloudreve是一个支持多家云存储的网盘系统"
                echo "官网介绍: https://cloudreve.org/"
                echo ""

                # 提示用户确认安装
                read -p "确定安装cloudreve吗？(Y/N): " choice
                case "$choice" in
                    [Yy])
                    clear
                    install_docker
                    cd /home/ && mkdir -p docker/cloud && cd docker/cloud && mkdir temp_data && mkdir -vp cloudreve/{uploads,avatar} && touch cloudreve/conf.ini && touch cloudreve/cloudreve.db && mkdir -p aria2/config && mkdir -p data/aria2 && chmod -R 777 data/aria2
                    curl -o /home/docker/cloud/docker-compose.yml https://raw.githubusercontent.com/linuxbt/docker/main/cloudreve-docker-compose.yml
                    cd /home/docker/cloud/ && docker compose up -d


                    clear
                    echo "cloudreve已经安装完成"
                    echo "------------------------"
                    echo "您可以使用以下地址访问cloudreve:"
                    if $has_ipv4; then
                        echo "http:$ipv4_address:5212"
                    fi
                    if $has_ipv6; then
                        echo "http:[$ipv6_address]:5212"
                    fi
                    sleep 3
                    docker logs cloudreve
                    echo ""

                        ;;
                    [Nn])
                        ;;
                    *)
                        ;;
                esac
            fi

              ;;

          14)
            docker_name="easyimage"
            docker_img="ddsderek/easyimage:latest"
            docker_port=85
            docker_rum="docker run -d \
                      --name easyimage \
                      -p 85:80 \
                      -e TZ=Asia/Shanghai \
                      -e PUID=1000 \
                      -e PGID=1000 \
                      -v /home/docker/easyimage/config:/app/web/config \
                      -v /home/docker/easyimage/i:/app/web/i \
                      --restart unless-stopped \
                      ddsderek/easyimage:latest"
            docker_describe="简单图床是一个简单的图床程序"
            docker_url="官网介绍: https://github.com/icret/EasyImages2.0"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          15)
            docker_name="emby"
            docker_img="linuxserver/emby:latest"
            docker_port=8096
            docker_rum="docker run -d --name=emby --restart=always \
                        -v /homeo/docker/emby/config:/config \
                        -v /homeo/docker/emby/share1:/mnt/share1 \
                        -v /homeo/docker/emby/share2:/mnt/share2 \
                        -v /mnt/notify:/mnt/notify \
                        -p 8096:8096 -p 8920:8920 \
                        -e UID=1000 -e GID=100 -e GIDLIST=100 \
                        linuxserver/emby:latest"
            docker_describe="emby是一个主从式架构的媒体服务器软件，可以用来整理服务器上的视频和音频，并将音频和视频流式传输到客户端设备"
            docker_url="官网介绍: https://emby.media/"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          16)
            docker_name="looking-glass"
            docker_img="wikihostinc/looking-glass-server"
            docker_port=89
            docker_rum="docker run -d --name looking-glass --restart always -p 89:80 wikihostinc/looking-glass-server"
            docker_describe="Speedtest测速面板是一个VPS网速测试工具，多项测试功能，还可以实时监控VPS进出站流量"
            docker_url="官网介绍: https://github.com/wikihost-opensource/als"
            docker_use=""
            docker_passwd=""
            docker_app

              ;;
          17)

            docker_name="adguardhome"
            docker_img="adguard/adguardhome"
            docker_port=3000
            docker_rum="docker run -d \
                            --name adguardhome \
                            -v /home/docker/adguardhome/work:/opt/adguardhome/work \
                            -v /home/docker/adguardhome/conf:/opt/adguardhome/conf \
                            -p 53:53/tcp \
                            -p 53:53/udp \
                            -p 3000:3000/tcp \
                            --restart always \
                            adguard/adguardhome"
            docker_describe="AdGuardHome是一款全网广告拦截与反跟踪软件，未来将不止是一个DNS服务器。"
            docker_url="官网介绍: https://hub.docker.com/r/adguard/adguardhome"
            docker_use=""
            docker_passwd=""
            docker_app

              ;;


          18)

            docker_name="onlyoffice"
            docker_img="onlyoffice/documentserver"
            docker_port=8082
            docker_rum="docker run -d -p 8082:80 \
                        --restart=always \
                        --name onlyoffice \
                        -v /home/docker/onlyoffice/DocumentServer/logs:/var/log/onlyoffice  \
                        -v /home/docker/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data  \
                         onlyoffice/documentserver"
            docker_describe="onlyoffice是一款开源的在线office工具，太强大了！"
            docker_url="官网介绍: https://www.onlyoffice.com/"
            docker_use=""
            docker_passwd=""
            docker_app

              ;;

          19)
            send_stats "搭建雷池"
            if docker inspect safeline-tengine &>/dev/null; then

                    clear
                    echo "雷池已安装，访问地址: "
                    ip_address
                    echo "http:$ipv4_address:9443"
                    echo ""

                    echo "应用操作"
                    echo "------------------------"
                    echo "1. 更新应用             2. 卸载应用"
                    echo "------------------------"
                    echo "0. 返回上一级选单"
                    echo "------------------------"
                    read -p "请输入你的选择: " sub_choice

                    case $sub_choice in
                        1)
                            clear
                            echo "暂不支持"
                            echo ""
                            ;;
                        2)

                            clear
                            echo "cd命令到安装目录下执行: docker compose down"
                            echo ""
                            ;;
                        0)
                            break  # 跳出循环，退出菜单
                            ;;
                        *)
                            break  # 跳出循环，退出菜单
                            ;;
                    esac
            else
                clear
                echo "安装提示"
                echo "雷池是长亭科技开发的WAF站点防火墙程序面板，可以反代站点进行自动化防御"
                echo "80和443端口不能被占用，无法与宝塔，1panel，npm，ldnmp建站共存"
                echo "官网介绍: https://github.com/chaitin/safeline"
                echo ""

                # 提示用户确认安装
                read -p "确定安装吗？(Y/N): " choice
                case "$choice" in
                    [Yy])
                    clear
                    install_docker
                    bash -c "$(curl -fsSLk https://waf-ce.chaitin.cn/release/latest/setup.sh)"

                    clear
                    echo "雷池WAF面板已经安装完成"
                    echo "------------------------"
                    echo "您可以使用以下地址访问:"
                    ip_address
                    echo "http:$ipv4_address:9443"
                    echo ""

                        ;;
                    [Nn])
                        ;;
                    *)
                        ;;
                esac
            fi

              ;;

          20)
            docker_name="portainer"
            docker_img="portainer/portainer"
            docker_port=9050
            docker_rum="docker run -d \
                    --name portainer \
                    -p 9050:9000 \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -v /home/docker/portainer:/data \
                    --restart always \
                    portainer/portainer"
            docker_describe="portainer是一个轻量级的docker容器管理面板"
            docker_url="官网介绍: https://www.portainer.io/"
            docker_use=""
            docker_passwd=""
            docker_app

              ;;

          21)
            docker_name="vscode-web"
            docker_img="codercom/code-server"
            docker_port=8180
            docker_rum="docker run -d -p 8180:8080 -v /home/docker/vscode-web:/home/coder/.local/share/code-server --name vscode-web --restart always codercom/code-server"
            docker_describe="VScode是一款强大的在线代码编写工具"
            docker_url="官网介绍: https://github.com/coder/code-server"
            docker_use="sleep 3"
            docker_passwd="docker exec vscode-web cat /home/coder/.config/code-server/config.yaml"
            docker_app
              ;;
          22)
            docker_name="uptime-kuma"
            docker_img="louislam/uptime-kuma:latest"
            docker_port=3003
            docker_rum="docker run -d \
                            --name=uptime-kuma \
                            -p 3003:3001 \
                            -v /home/docker/uptime-kuma/uptime-kuma-data:/app/data \
                            --restart=always \
                            louislam/uptime-kuma:latest"
            docker_describe="Uptime Kuma 易于使用的自托管监控工具"
            docker_url="官网介绍: https://github.com/louislam/uptime-kuma"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          23)
            docker_name="memos"
            docker_img="ghcr.io/usememos/memos:latest"
            docker_port=5230
            docker_rum="docker run -d --name memos -p 5230:5230 -v /home/docker/memos:/var/opt/memos --restart always ghcr.io/usememos/memos:latest"
            docker_describe="Memos是一款轻量级、自托管的备忘录中心"
            docker_url="官网介绍: https://github.com/usememos/memos"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          24)
            docker_name="webtop"
            docker_img="lscr.io/linuxserver/webtop:latest"
            docker_port=3083
            docker_rum="docker run -d \
                          --name=webtop \
                          --security-opt seccomp=unconfined \
                          -e PUID=1000 \
                          -e PGID=1000 \
                          -e TZ=Etc/UTC \
                          -e SUBFOLDER=/ \
                          -e TITLE=Webtop \
                          -e LC_ALL=zh_CN.UTF-8 \
                          -e DOCKER_MODS=linuxserver/mods:universal-package-install \
                          -e INSTALL_PACKAGES=font-noto-cjk \
                          -p 3083:3000 \
                          -v /home/docker/webtop/data:/config \
                          -v /var/run/docker.sock:/var/run/docker.sock \
                          --shm-size="1gb" \
                          --restart unless-stopped \
                          lscr.io/linuxserver/webtop:latest"

            docker_describe="webtop基于 Alpine、Ubuntu、Fedora 和 Arch 的容器，包含官方支持的完整桌面环境，可通过任何现代 Web 浏览器访问"
            docker_url="官网介绍: https://docs.linuxserver.io/images/docker-webtop/"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          25)
            docker_name="nextcloud"
            docker_img="nextcloud:latest"
            docker_port=8989
            rootpasswd=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)
            docker_rum="docker run -d --name nextcloud --restart=always -p 8989:80 -v /home/docker/nextcloud:/var/www/html -e NEXTCLOUD_ADMIN_USER=nextcloud -e NEXTCLOUD_ADMIN_PASSWORD=$rootpasswd nextcloud"
            docker_describe="Nextcloud拥有超过 400,000 个部署，是您可以下载的最受欢迎的本地内容协作平台"
            docker_url="官网介绍: https://nextcloud.com/"
            docker_use="echo \"账号: nextcloud  密码: $rootpasswd\""
            docker_passwd=""
            docker_app
              ;;

          26)
            docker_name="qd"
            docker_img="qdtoday/qd:latest"
            docker_port=8923
            docker_rum="docker run -d --name qd -p 8923:80 -v /home/docker/qd/config:/usr/src/app/config qdtoday/qd"
            docker_describe="QD-Today是一个HTTP请求定时任务自动执行框架"
            docker_url="官网介绍: https://qd-today.github.io/qd/zh_CN/"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;
          27)
            docker_name="dockge"
            docker_img="louislam/dockge:latest"
            docker_port=5003
            docker_rum="docker run -d --name dockge --restart unless-stopped -p 5003:5001 -v /var/run/docker.sock:/var/run/docker.sock -v /home/docker/dockge/data:/app/data -v  /home/docker/dockge/stacks:/home/docker/dockge/stacks -e DOCKGE_STACKS_DIR=/home/docker/dockge/stacks louislam/dockge"
            docker_describe="dockge是一个可视化的docker-compose容器管理面板"
            docker_url="官网介绍: https://github.com/louislam/dockge"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          28)
            docker_name="speedtest"
            docker_img="ghcr.io/librespeed/speedtest:latest"
            docker_port=6681
            docker_rum="docker run -d \
                            --name speedtest \
                            --restart always \
                            -e MODE=standalone \
                            -p 6681:80 \
                            ghcr.io/librespeed/speedtest:latest"
            docker_describe="librespeed是用Javascript实现的轻量级速度测试工具，即开即用"
            docker_url="官网介绍: https://github.com/librespeed/speedtest"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          29)
            docker_name="searxng"
            docker_img="alandoyle/searxng:latest"
            docker_port=8700
            docker_rum="docker run --name=searxng \
                            -d --init \
                            --restart=unless-stopped \
                            -v /home/docker/searxng/config:/etc/searxng \
                            -v /home/docker/searxng/templates:/usr/local/searxng/searx/templates/simple \
                            -v /home/docker/searxng/theme:/usr/local/searxng/searx/static/themes/simple \
                            -p 8700:8080/tcp \
                            alandoyle/searxng:latest"
            docker_describe="searxng是一个私有且隐私的搜索引擎站点"
            docker_url="官网介绍: https://hub.docker.com/r/alandoyle/searxng"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          30)
            docker_name="photoprism"
            docker_img="photoprism/photoprism:latest"
            docker_port=2342
            rootpasswd=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)
            docker_rum="docker run -d \
                            --name photoprism \
                            --restart always \
                            --security-opt seccomp=unconfined \
                            --security-opt apparmor=unconfined \
                            -p 2342:2342 \
                            -e PHOTOPRISM_UPLOAD_NSFW="true" \
                            -e PHOTOPRISM_ADMIN_PASSWORD="$rootpasswd" \
                            -v /home/docker/photoprism/storage:/photoprism/storage \
                            -v /home/docker/photoprism/Pictures:/photoprism/originals \
                            photoprism/photoprism"
            docker_describe="photoprism非常强大的私有相册系统"
            docker_url="官网介绍: https://www.photoprism.app/"
            docker_use="echo \"账号: admin  密码: $rootpasswd\""
            docker_passwd=""
            docker_app
              ;;


          31)
            docker_name="s-pdf"
            docker_img="frooodle/s-pdf:latest"
            docker_port=8020
            docker_rum="docker run -d \
                            --name s-pdf \
                            --restart=always \
                             -p 8020:8080 \
                             -v /home/docker/s-pdf/trainingData:/usr/share/tesseract-ocr/5/tessdata \
                             -v /home/docker/s-pdf/extraConfigs:/configs \
                             -v /home/docker/s-pdf/logs:/logs \
                             -e DOCKER_ENABLE_SECURITY=false \
                             frooodle/s-pdf:latest"
            docker_describe="这是一个强大的本地托管基于 Web 的 PDF 操作工具，使用 docker，允许您对 PDF 文件执行各种操作，例如拆分合并、转换、重新组织、添加图像、旋转、压缩等。"
            docker_url="官网介绍: https://github.com/Stirling-Tools/Stirling-PDF"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          32)
            docker_name="drawio"
            docker_img="jgraph/drawio"
            docker_port=7080
            docker_rum="docker run -d --restart=always --name drawio -p 7080:8080 -v /home/docker/drawio:/var/lib/drawio jgraph/drawio"
            docker_describe="这是一个强大图表绘制软件。思维导图，拓扑图，流程图，都能画"
            docker_url="官网介绍: https://www.drawio.com/"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          33)
            docker_name="sun-panel"
            docker_img="hslr/sun-panel"
            docker_port=3009
            docker_rum="docker run -d --restart=always -p 3009:3002 \
                            -v /home/docker/sun-panel/conf:/app/conf \
                            -v /home/docker/sun-panel/uploads:/app/uploads \
                            -v /home/docker/sun-panel/database:/app/database \
                            --name sun-panel \
                            hslr/sun-panel"
            docker_describe="Sun-Panel服务器、NAS导航面板、Homepage、浏览器首页"
            docker_url="官网介绍: https://doc.sun-panel.top/zh_cn/"
            docker_use="echo \"账号: admin@sun.cc  密码: 12345678\""
            docker_passwd=""
            docker_app
              ;;

          34)
            docker_name="pingvin-share"
            docker_img="stonith404/pingvin-share"
            docker_port=3060
            docker_rum="docker run -d \
                            --name pingvin-share \
                            --restart always \
                            -p 3060:3000 \
                            -v /home/docker/pingvin-share/data:/opt/app/backend/data \
                            stonith404/pingvin-share"
            docker_describe="Pingvin Share 是一个可自建的文件分享平台，是 WeTransfer 的一个替代品"
            docker_url="官网介绍: https://github.com/stonith404/pingvin-share"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;


          35)
            docker_name="moments"
            docker_img="kingwrcy/moments:latest"
            docker_port=8035
            docker_rum="docker run -d --restart unless-stopped \
                            -p 8035:3000 \
                            -v /home/docker/moments/data:/app/data \
                            -v /etc/localtime:/etc/localtime:ro \
                            -v /etc/timezone:/etc/timezone:ro \
                            --name moments \
                            kingwrcy/moments:latest"
            docker_describe="极简朋友圈，高仿微信朋友圈，记录你的美好生活"
            docker_url="官网介绍: https://github.com/kingwrcy/moments?tab=readme-ov-file"
            docker_use="echo \"账号: admin  密码: a123456\""
            docker_passwd=""
            docker_app
              ;;



          36)
            docker_name="lobe-chat"
            docker_img="lobehub/lobe-chat:latest"
            docker_port=8036
            docker_rum="docker run -d -p 8036:3210 \
                            --name lobe-chat \
                            --restart=always \
                            lobehub/lobe-chat"
            docker_describe="LobeChat聚合市面上主流的AI大模型，ChatGPT/Claude/Gemini/Groq/Ollama"
            docker_url="官网介绍: https://github.com/lobehub/lobe-chat"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          37)
            docker_name="myip"
            docker_img="ghcr.io/jason5ng32/myip:latest"
            docker_port=8037
            docker_rum="docker run -d -p 8037:18966 --name myip --restart always ghcr.io/jason5ng32/myip:latest"
            docker_describe="是一个多功能IP工具箱，可以查看自己IP信息及连通性，用网页面板呈现"
            docker_url="官网介绍: https://github.com/jason5ng32/MyIP/blob/main/README_ZH.md"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          38)
            send_stats "小雅全家桶"
            install_docker
            bash -c "$(curl --insecure -fsSL https://ddsrem.com/xiaoya_install.sh)"
              ;;

          39)

            if [ ! -d /home/docker/bililive-go/ ]; then
                mkdir -p /home/docker/bililive-go/ > /dev/null 2>&1
                wget -O /home/docker/bililive-go/config.yml https://raw.githubusercontent.com/hr3lxphr6j/bililive-go/master/config.yml > /dev/null 2>&1
            fi

            docker_name="bililive-go"
            docker_img="chigusa/bililive-go"
            docker_port=8039
            docker_rum="docker run --restart=always --name bililive-go -v /home/docker/bililive-go/config.yml:/etc/bililive-go/config.yml -v /home/docker/bililive-go/Videos:/srv/bililive -p 8039:8080 -d chigusa/bililive-go"
            docker_describe="Bililive-go是一个支持多种直播平台的直播录制工具"
            docker_url="官网介绍: https://github.com/hr3lxphr6j/bililive-go"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          40)

            docker_name="windows"
            docker_img="dockurr/windows"
            docker_port=8039
            docker_rum="docker run -d \
                            --name windows \
                            --cap-add=NET_ADMIN \
			    --env VERSION="2022" \
			    --env LANGUAGE="Chinese" \
			    --device /dev/kvm \
                            -p 8039:8006 \
                            -p 3389:3389/tcp \
                            -p 3389:3389/udp \
                            --restart unless-stopped \
                            dockurr/windows"
            docker_describe="一款虚拟化远程Windows Server 2022 要求4核心4G内存及以上"
            docker_url="官网介绍: https://github.com/dockur/windows"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          51)
            clear
            send_stats "PVE开小鸡"
            curl -L https://raw.githubusercontent.com/oneclickvirt/pve/main/scripts/install_pve.sh -o install_pve.sh && chmod +x install_pve.sh && bash install_pve.sh
              ;;
          0)
              linuxbt
              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end

    done
}


linux_work() {

    while true; do
      clear
      send_stats "我的工作区"
	echo -e "${kjlan}▶ 我的工作区${bai}"
	echo -e "${kjlan}系统将为你提供可以后台常驻运行的工作区，你可以用来执行长时间的任务${bai}"
	echo -e "${kjlan}即使你断开SSH，工作区中的任务也不会中断，后台常驻任务。${bai}"
	echo -e "${huang}注意：${bai}进入工作区后使用Ctrl+b再单独按d，退出工作区！"
	echo -e "${kjlan}------------------------${bai}"
	echo -e "1. 1号工作区"
	echo -e "2. 2号工作区"
	echo -e "3. 3号工作区"
	echo -e "4. 4号工作区"
	echo -e "5. 5号工作区"
	echo -e "6. 6号工作区"
	echo -e "7. 7号工作区"
	echo -e "8. 8号工作区"
	echo -e "9. 9号工作区"
	echo -e "10. 10号工作区"
	echo -e "${kjlan}------------------------${bai}"
	echo -e "${kjlan}99. 工作区管理${bai}"
	echo -e "${kjlan}------------------------${bai}"
	echo -e "0. 返回主菜单"
	echo -e "${kjlan}------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in

          1)
              clear
              install tmux
              SESSION_NAME="work1"
              send_stats "启动工作区$SESSION_NAME"
              tmux_run

              ;;
          2)
              clear
              install tmux
              SESSION_NAME="work2"
              send_stats "启动工作区$SESSION_NAME"
              tmux_run
              ;;
          3)
              clear
              install tmux
              SESSION_NAME="work3"
              send_stats "启动工作区$SESSION_NAME"
              tmux_run
              ;;
          4)
              clear
              install tmux
              SESSION_NAME="work4"
              send_stats "启动工作区$SESSION_NAME"
              tmux_run
              ;;
          5)
              clear
              install tmux
              SESSION_NAME="work5"
              send_stats "启动工作区$SESSION_NAME"
              tmux_run
              ;;
          6)
              clear
              install tmux
              SESSION_NAME="work6"
              send_stats "启动工作区$SESSION_NAME"
              tmux_run
              ;;
          7)
              clear
              install tmux
              SESSION_NAME="work7"
              send_stats "启动工作区$SESSION_NAME"
              tmux_run
              ;;
          8)
              clear
              install tmux
              SESSION_NAME="work8"
              send_stats "启动工作区$SESSION_NAME"
              tmux_run
              ;;
          9)
              clear
              install tmux
              SESSION_NAME="work9"
              send_stats "启动工作区$SESSION_NAME"
              tmux_run
              ;;
          10)
              clear
              install tmux
              SESSION_NAME="work10"
              send_stats "启动工作区$SESSION_NAME"
              tmux_run
              ;;

          99)
            while true; do
              clear
              send_stats "工作区管理"
              echo "当前已存在的工作区列表"
              echo "------------------------"
              tmux list-sessions
              echo "------------------------"
              echo "1. 创建/进入工作区"
              echo "2. 注入命令到后台工作区"
              echo "3. 删除指定工作区"
              echo "------------------------"
              echo "0. 返回上一级"
              echo "------------------------"
              read -p "请输入你的选择: " gongzuoqu_del
              case "$gongzuoqu_del" in
                1)
                  read -p "请输入你创建或进入的工作区名称，如1001 kj001 work1: " SESSION_NAME
                  tmux_run
                  ;;

                2)
                  read -p "请输入你要后台执行的命令，如:curl -fsSL https://get.docker.com | sh: " tmuxd
                  tmux_run_d
                  ;;

                3)
                  read -p "请输入要删除的工作区名称: " gongzuoqu_name
                  tmux kill-window -t $gongzuoqu_name
                  ;;
                0)
                  break
                  ;;
                *)
                  echo "无效的选择，请输入 Y 或 N。"
                  ;;
              esac
            done

              ;;
          0)
              linuxbt
              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end

    done


}




linux_Settings() {

    while true; do
      clear
      # send_stats "系统工具"
	echo -e "${lan}▶ 系统工具${bai}"
	echo "------------------------"
	echo -e "${lv}1. 设置脚本启动快捷键                  ${lan}2. 修改登录密码${bai}"
	echo -e "${lv}3. ROOT密码登录模式                    ${lan}4. 安装Python指定版本${bai}"
	echo -e "${lv}5. 开放所有端口                        ${lan}6. 修改SSH连接端口${bai}"
	echo -e "${lv}7. 优化DNS地址                         ${lan}8. 一键重装系统${bai}"
	echo -e "${lv}9. 禁用ROOT账户创建新账户              ${lan}10. 切换优先ipv4/ipv6${bai}"
	echo "------------------------"
	echo -e "${huang}11. 查看端口占用状态                   ${hong}12. 修改虚拟内存大小${bai}"
	echo -e "${huang}13. 用户管理                           ${hong}14. 用户/密码生成器${bai}"
	echo -e "${huang}15. 系统时区调整                       ${hong}16. 设置BBR3加速${bai}"
	echo -e "${huang}17. 防火墙高级管理器                   ${hong}18. 修改主机名${bai}"
	echo -e "${huang}19. 切换系统更新源                     ${hong}20. 定时任务管理${bai}"
	echo "------------------------"
	echo -e "${kjlan}21. 本机host解析                       ${hui}22. fail2banSSH防御程序${bai}"
	echo -e "${kjlan}23. 限流自动关机                       ${hui}24. ROOT私钥登录模式${bai}"
	echo -e "${kjlan}25. TG-bot系统监控预警                 ${hui}26. 修复OpenSSH高危漏洞（岫源）${bai}"
	echo -e "${kjlan}27. 红帽系Linux内核升级                ${hui}28. Linux系统内核参数优化${bai}"
	echo -e "${kjlan}29. 开源病毒扫描工具                   ${hui}30. 河马webshell扫描${bai}"
	echo "------------------------"
	echo -e "${lan}31. 留言板                             ${hong}66. 一条龙系统调优${bai}"
	echo "------------------------"
	echo -e "${lan}99. 重启服务器"
	echo "------------------------"
	echo -e "${lv}101. 卸载K脚本${bai}"
	echo "------------------------"
	echo -e "${huang}0. 返回主菜单${bai}"
	echo "------------------------"
	read -p "请输入你的选择: " sub_choice

      case $sub_choice in
          1)
              clear
              read -p "请输入你的快捷按键: " kuaijiejian
              echo "alias $kuaijiejian='~/k.sh'" >> ~/.bashrc
              source ~/.bashrc
              echo "快捷键已设置"
              send_stats "脚本快捷键已设置"
              ;;

          2)
              clear
              send_stats "设置你的登录密码"
              echo "设置你的登录密码"
              passwd
              ;;
          3)
              root_use
              send_stats "root密码模式"
              add_sshpasswd
              ;;

          4)
            root_use
            send_stats "py版本管理"
            VERSION=$(python3 -V 2>&1 | awk '{print $2}')
            echo -e "当前python版本号: ${huang}$VERSION${bai}"
            echo "------------"
            echo "推荐版本:  3.12    3.11    3.10    3.9    3.8    2.7"
            echo "查询更多版本: https://www.python.org/downloads/"
            echo "------------"
            read -p "输入你要安装的python版本号: " py_new_v

            if ! grep -q 'export PYENV_ROOT="\$HOME/.pyenv"' ~/.bashrc; then
                if command -v yum &>/dev/null; then
                    yum update -y && yum install git -y
                    yum groupinstall "Development Tools" -y
                    yum install openssl-devel bzip2-devel libffi-devel ncurses-devel zlib-devel readline-devel sqlite-devel xz-devel findutils -y

                    curl -O https://www.openssl.org/source/openssl-1.1.1u.tar.gz
                    tar -xzf openssl-1.1.1u.tar.gz
                    cd openssl-1.1.1u
                    ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib
                    make
                    make install
                    echo "/usr/local/openssl/lib" > /etc/ld.so.conf.d/openssl-1.1.1u.conf
                    ldconfig -v
                    cd ..

                    export LDFLAGS="-L/usr/local/openssl/lib"
                    export CPPFLAGS="-I/usr/local/openssl/include"
                    export PKG_CONFIG_PATH="/usr/local/openssl/lib/pkgconfig"

                elif command -v apt &>/dev/null; then
                    apt update -y && apt install git -y
                    apt install build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev libgdbm-dev libnss3-dev libedit-dev -y
                elif command -v apk &>/dev/null; then
                    apk update && apk add git
                    apk add --no-cache bash gcc musl-dev libffi-dev openssl-dev bzip2-dev zlib-dev readline-dev sqlite-dev libc6-compat linux-headers make xz-dev build-base  ncurses-dev
                else
                    echo "未知的包管理器!"
                    return 1
                fi

                curl https://pyenv.run | bash
                cat << EOF >> ~/.bashrc

export PYENV_ROOT="\$HOME/.pyenv"
if [[ -d "\$PYENV_ROOT/bin" ]]; then
  export PATH="\$PYENV_ROOT/bin:\$PATH"
fi
eval "\$(pyenv init --path)"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"

EOF

            fi

            sleep 1
            source ~/.bashrc
            sleep 1
            pyenv install $py_new_v
            pyenv global $py_new_v

            rm -rf /tmp/python-build.*
            rm -rf $(pyenv root)/cache/*

            VERSION=$(python -V 2>&1 | awk '{print $2}')
            echo -e "当前python版本号: ${huang}$VERSION${bai}"

              ;;

          5)
              root_use
              send_stats "开放端口"
              iptables_open
              remove iptables-persistent ufw firewalld iptables-services > /dev/null 2>&1
              echo "端口已全部开放"

              ;;
          6)
              root_use
              send_stats "修改SSH端口"
              # 去掉 #Port 的注释
              sed -i 's/#Port/Port/' /etc/ssh/sshd_config

              # 读取当前的 SSH 端口号
              current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

              # 打印当前的 SSH 端口号
              echo "当前的 SSH 端口号是: $current_port"

              echo "------------------------"

              # 提示用户输入新的 SSH 端口号
              read -p "请输入新的 SSH 端口号: " new_port

              new_ssh_port

              send_stats "SSH端口已修改"

              ;;


          7)
            root_use
            send_stats "优化DNS"

            while true; do
                clear
                echo "优化DNS地址"
                echo "------------------------"
                echo "当前DNS地址"
                cat /etc/resolv.conf
                echo "------------------------"
                echo ""
                echo "1. 国外DNS优化: "
                echo " v4: 1.1.1.1 8.8.8.8"
                echo " v6: 2606:4700:4700::1111 2001:4860:4860::8888"
                echo "2. 国内DNS优化: "
                echo " v4: 223.5.5.5 183.60.83.19"
                echo " v6: 2400:3200::1 2400:da00::6666"
                echo "------------------------"
                echo "0. 返回上一级"
                echo "------------------------"
                read -p "请输入你的选择: " Limiting
                case "$Limiting" in
                  1)
                    dns1_ipv4="1.1.1.1"
                    dns2_ipv4="8.8.8.8"
                    dns1_ipv6="2606:4700:4700::1111"
                    dns2_ipv6="2001:4860:4860::8888"
                    set_dns
                    send_stats "国外DNS优化"
                    ;;
                  2)
                    dns1_ipv4="223.5.5.5"
                    dns2_ipv4="183.60.83.19"
                    dns1_ipv6="2400:3200::1"
                    dns2_ipv6="2400:da00::6666"
                    set_dns
                    send_stats "国内DNS优化"
                    ;;
                  *)
                    break
                    ;;
                esac
            done
              ;;


          8)

            dd_xitong
              ;;
          9)
            root_use
            send_stats "新用户禁用root"
            # 提示用户输入新用户名
            read -p "请输入新用户名: " new_username

            # 创建新用户并设置密码
            useradd -m -s /bin/bash "$new_username"
            passwd "$new_username"

            # 赋予新用户sudo权限
            echo "$new_username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers

            # 禁用ROOT用户登录
            passwd -l root

            echo "操作已完成。"
            ;;


          10)
            root_use
            send_stats "设置v4/v6优先级"
            ipv6_disabled=$(sysctl -n net.ipv6.conf.all.disable_ipv6)

            echo ""
            if [ "$ipv6_disabled" -eq 1 ]; then
                echo "当前网络优先级设置: IPv4 优先"
            else
                echo "当前网络优先级设置: IPv6 优先"
            fi
            echo "------------------------"

            echo ""
            echo "切换的网络优先级"
            echo "------------------------"
            echo "1. IPv4 优先          2. IPv6 优先"
            echo "------------------------"
            read -p "选择优先的网络: " choice

            case $choice in
                1)
                    sysctl -w net.ipv6.conf.all.disable_ipv6=1 > /dev/null 2>&1
                    echo "已切换为 IPv4 优先"
                    send_stats "已切换为 IPv4 优先"
                    ;;
                2)
                    sysctl -w net.ipv6.conf.all.disable_ipv6=0 > /dev/null 2>&1
                    echo "已切换为 IPv6 优先"
                    send_stats "已切换为 IPv6 优先"
                    ;;
                *)
                    echo "无效的选择"
                    ;;

            esac
            ;;

          11)
            clear
            ss -tulnape
            ;;

          12)
            root_use
            send_stats "设置虚拟内存"
            while true; do
                clear
                echo "设置虚拟内存"
                swap_used=$(free -m | awk 'NR==3{print $3}')
                swap_total=$(free -m | awk 'NR==3{print $2}')
                swap_info=$(free -m | awk 'NR==3{used=$3; total=$2; if (total == 0) {percentage=0} else {percentage=used*100/total}; printf "%dMB/%dMB (%d%%)", used, total, percentage}')

                echo -e "当前虚拟内存: ${huang}$swap_info${bai}"
                echo "------------------------"
                echo "1. 分配1024MB         2. 分配2048MB         3. 自定义大小         0. 退出"
                echo "------------------------"
                read -p "请输入你的选择: " choice

                case "$choice" in
                  1)
                    send_stats "已设置1G虚拟内存"
                    new_swap=1024
                    add_swap

                    ;;
                  2)
                    send_stats "已设置2G虚拟内存"
                    new_swap=2048
                    add_swap

                    ;;
                  3)
                    read -p "请输入虚拟内存大小MB: " new_swap
                    add_swap
                    send_stats "已设置自定义虚拟内存"
                    ;;

                  *)
                    break
                    ;;
                esac
            done
            ;;


          13)
              while true; do
                root_use
                send_stats "用户管理"
                # 显示所有用户、用户权限、用户组和是否在sudoers中
                echo "用户列表"
                echo "----------------------------------------------------------------------------"
                printf "%-24s %-34s %-20s %-10s\n" "用户名" "用户权限" "用户组" "sudo权限"
                while IFS=: read -r username _ userid groupid _ _ homedir shell; do
                    groups=$(groups "$username" | cut -d : -f 2)
                    sudo_status=$(sudo -n -lU "$username" 2>/dev/null | grep -q '(ALL : ALL)' && echo "Yes" || echo "No")
                    printf "%-20s %-30s %-20s %-10s\n" "$username" "$homedir" "$groups" "$sudo_status"
                done < /etc/passwd


                  echo ""
                  echo "账户操作"
                  echo "------------------------"
                  echo "1. 创建普通账户             2. 创建高级账户"
                  echo "------------------------"
                  echo "3. 赋予最高权限             4. 取消最高权限"
                  echo "------------------------"
                  echo "5. 删除账号"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                       # 提示用户输入新用户名
                       read -p "请输入新用户名: " new_username

                       # 创建新用户并设置密码
                       useradd -m -s /bin/bash "$new_username"
                       passwd "$new_username"

                       echo "操作已完成。"
                          ;;

                      2)
                       # 提示用户输入新用户名
                       read -p "请输入新用户名: " new_username

                       # 创建新用户并设置密码
                       useradd -m -s /bin/bash "$new_username"
                       passwd "$new_username"

                       # 赋予新用户sudo权限
                       echo "$new_username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers

                       echo "操作已完成。"

                          ;;
                      3)
                       read -p "请输入用户名: " username
                       # 赋予新用户sudo权限
                       echo "$username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
                          ;;
                      4)
                       read -p "请输入用户名: " username
                       # 从sudoers文件中移除用户的sudo权限
                       sed -i "/^$username\sALL=(ALL:ALL)\sALL/d" /etc/sudoers

                          ;;
                      5)
                       read -p "请输入要删除的用户名: " username
                       # 删除用户及其主目录
                       userdel -r "$username"
                          ;;

                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done
              ;;

          14)
            clear
            send_stats "用户信息生成器"
            echo "随机用户名"
            echo "------------------------"
            for i in {1..5}; do
                username="user$(< /dev/urandom tr -dc _a-z0-9 | head -c6)"
                echo "随机用户名 $i: $username"
            done

            echo ""
            echo "随机姓名"
            echo "------------------------"
            first_names=("John" "Jane" "Michael" "Emily" "David" "Sophia" "William" "Olivia" "James" "Emma" "Ava" "Liam" "Mia" "Noah" "Isabella")
            last_names=("Smith" "Johnson" "Brown" "Davis" "Wilson" "Miller" "Jones" "Garcia" "Martinez" "Williams" "Lee" "Gonzalez" "Rodriguez" "Hernandez")

            # 生成5个随机用户姓名
            for i in {1..5}; do
                first_name_index=$((RANDOM % ${#first_names[@]}))
                last_name_index=$((RANDOM % ${#last_names[@]}))
                user_name="${first_names[$first_name_index]} ${last_names[$last_name_index]}"
                echo "随机用户姓名 $i: $user_name"
            done

            echo ""
            echo "随机UUID"
            echo "------------------------"
            for i in {1..5}; do
                uuid=$(cat /proc/sys/kernel/random/uuid)
                echo "随机UUID $i: $uuid"
            done

            echo ""
            echo "16位随机密码"
            echo "------------------------"
            for i in {1..5}; do
                password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)
                echo "随机密码 $i: $password"
            done

            echo ""
            echo "32位随机密码"
            echo "------------------------"
            for i in {1..5}; do
                password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)
                echo "随机密码 $i: $password"
            done
            echo ""

              ;;

          15)
            root_use
            send_stats "换时区"
            while true; do
                clear
                echo "系统时间信息"

                # 获取当前系统时区
                timezone=$(current_timezone)

                # 获取当前系统时间
                current_time=$(date +"%Y-%m-%d %H:%M:%S")

                # 显示时区和时间
                echo "当前系统时区：$timezone"
                echo "当前系统时间：$current_time"

                echo ""
                echo "时区切换"
                echo "亚洲------------------------"
                echo "1. 中国上海时间              2. 中国香港时间"
                echo "3. 日本东京时间              4. 韩国首尔时间"
                echo "5. 新加坡时间                6. 印度加尔各答时间"
                echo "7. 阿联酋迪拜时间            8. 澳大利亚悉尼时间"
                echo "欧洲------------------------"
                echo "11. 英国伦敦时间             12. 法国巴黎时间"
                echo "13. 德国柏林时间             14. 俄罗斯莫斯科时间"
                echo "15. 荷兰尤特赖赫特时间       16. 西班牙马德里时间"
                echo "美洲------------------------"
                echo "21. 美国西部时间             22. 美国东部时间"
                echo "23. 加拿大时间               24. 墨西哥时间"
                echo "25. 巴西时间                 26. 阿根廷时间"
                echo "------------------------"
                echo "0. 返回上一级选单"
                echo "------------------------"
                read -p "请输入你的选择: " sub_choice


                case $sub_choice in
                    1) set_timedate Asia/Shanghai ;;
                    2) set_timedate Asia/Hong_Kong ;;
                    3) set_timedate Asia/Tokyo ;;
                    4) set_timedate Asia/Seoul ;;
                    5) set_timedate Asia/Singapore ;;
                    6) set_timedate Asia/Kolkata ;;
                    7) set_timedate Asia/Dubai ;;
                    8) set_timedate Australia/Sydney ;;
                    11) set_timedate Europe/London ;;
                    12) set_timedate Europe/Paris ;;
                    13) set_timedate Europe/Berlin ;;
                    14) set_timedate Europe/Moscow ;;
                    15) set_timedate Europe/Amsterdam ;;
                    16) set_timedate Europe/Madrid ;;
                    21) set_timedate America/Los_Angeles ;;
                    22) set_timedate America/New_York ;;
                    23) set_timedate America/Vancouver ;;
                    24) set_timedate America/Mexico_City ;;
                    25) set_timedate America/Sao_Paulo ;;
                    26) set_timedate America/Argentina/Buenos_Aires ;;
                    0) break ;; # 跳出循环，退出菜单
                    *) break ;; # 跳出循环，退出菜单
                esac
            done
              ;;

          16)

            bbrv3
              ;;

          17)
          root_use
          send_stats "高级防火墙管理"
          if dpkg -l | grep -q iptables-persistent; then
            while true; do
                  echo "防火墙已安装"
                  send_stats "高级防火墙已安装"
                  echo "------------------------"
                  iptables -L INPUT

                  echo ""
                  echo "防火墙管理"
                  echo "------------------------"
                  echo "1. 开放指定端口              2. 关闭指定端口"
                  echo "3. 开放所有端口              4. 关闭所有端口"
                  echo "------------------------"
                  echo "5. IP白名单                  6. IP黑名单"
                  echo "7. 清除指定IP"
                  echo "------------------------"
                  echo "9. 卸载防火墙"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                      read -p "请输入开放的端口号: " o_port
                      sed -i "/COMMIT/i -A INPUT -p tcp --dport $o_port -j ACCEPT" /etc/iptables/rules.v4
                      sed -i "/COMMIT/i -A INPUT -p udp --dport $o_port -j ACCEPT" /etc/iptables/rules.v4
                      iptables-restore < /etc/iptables/rules.v4

                          ;;
                      2)
                      read -p "请输入关闭的端口号: " c_port
                      sed -i "/--dport $c_port/d" /etc/iptables/rules.v4
                      iptables-restore < /etc/iptables/rules.v4
                        ;;

                      3)
                      current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

                      cat > /etc/iptables/rules.v4 << EOF
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A FORWARD -i lo -j ACCEPT
-A INPUT -p tcp --dport $current_port -j ACCEPT
COMMIT
EOF
                      iptables-restore < /etc/iptables/rules.v4

                          ;;
                      4)
                      current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

                      cat > /etc/iptables/rules.v4 << EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A FORWARD -i lo -j ACCEPT
-A INPUT -p tcp --dport $current_port -j ACCEPT
COMMIT
EOF
                      iptables-restore < /etc/iptables/rules.v4

                          ;;

                      5)
                      read -p "请输入放行的IP: " o_ip
                      sed -i "/COMMIT/i -A INPUT -s $o_ip -j ACCEPT" /etc/iptables/rules.v4
                      iptables-restore < /etc/iptables/rules.v4

                          ;;

                      6)
                      read -p "请输入封锁的IP: " c_ip
                      sed -i "/COMMIT/i -A INPUT -s $c_ip -j DROP" /etc/iptables/rules.v4
                      iptables-restore < /etc/iptables/rules.v4
                          ;;

                      7)
                     read -p "请输入清除的IP: " d_ip
                     sed -i "/-A INPUT -s $d_ip/d" /etc/iptables/rules.v4
                     iptables-restore < /etc/iptables/rules.v4
                          ;;

                      9)
                      remove iptables-persistent
                      rm /etc/iptables/rules.v4
                      break
                          ;;

                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;

                  esac
            done
        else

          clear
          echo "将为你安装防火墙，该防火墙仅支持Debian/Ubuntu"
          echo "------------------------------------------------"
          read -p "确定继续吗？(Y/N): " choice

          case "$choice" in
            [Yy])
            if [ -r /etc/os-release ]; then
                . /etc/os-release
                if [ "$ID" != "debian" ] && [ "$ID" != "ubuntu" ]; then
                    echo "当前环境不支持，仅支持Debian和Ubuntu系统"
                    break
                fi
            else
                echo "无法确定操作系统类型"
                break
            fi

          clear
          iptables_open
          remove iptables-persistent ufw
          rm /etc/iptables/rules.v4

          apt update -y && apt install -y iptables-persistent

          current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

          cat > /etc/iptables/rules.v4 << EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A FORWARD -i lo -j ACCEPT
-A INPUT -p tcp --dport $current_port -j ACCEPT
COMMIT
EOF

          iptables-restore < /etc/iptables/rules.v4
          systemctl enable netfilter-persistent
          echo "防火墙安装完成"


              ;;
            [Nn])
              echo "已取消"
              ;;
            *)
              echo "无效的选择，请输入 Y 或 N。"
              ;;
          esac
        fi
              ;;

          18)
          root_use
          send_stats "修改主机名"
          current_hostname=$(hostname)
          echo "当前主机名: $current_hostname"
          read -p "是否要更改主机名？(y/n): " answer
          if [[ "${answer,,}" == "y" ]]; then
              # 获取新的主机名
              read -p "请输入新的主机名: " new_hostname
              if [ -n "$new_hostname" ]; then
                  if [ -f /etc/alpine-release ]; then
                      # Alpine
                      echo "$new_hostname" > /etc/hostname
                      hostname "$new_hostname"
                  else
                      # 其他系统，如 Debian, Ubuntu, CentOS 等
                      hostnamectl set-hostname "$new_hostname"
                      sed -i "s/$current_hostname/$new_hostname/g" /etc/hostname
                      systemctl restart systemd-hostnamed
                  fi
                  echo "主机名已更改为: $new_hostname"
                  send_stats "主机名已更改"
              else
                  echo "无效的主机名。未更改主机名。"
                  exit 1
              fi
          else
              echo "未更改主机名。"
          fi
              ;;

          19)
          root_use
          send_stats "换系统更新源"
          # 获取系统信息
          source /etc/os-release

          # 定义 Ubuntu 更新源
          aliyun_ubuntu_source="http://mirrors.aliyun.com/ubuntu/"
          official_ubuntu_source="http://archive.ubuntu.com/ubuntu/"
          initial_ubuntu_source=""

          # 定义 Debian 更新源
          aliyun_debian_source="http://mirrors.aliyun.com/debian/"
          official_debian_source="http://deb.debian.org/debian/"
          initial_debian_source=""

          # 定义 CentOS 更新源
          aliyun_centos_source="http://mirrors.aliyun.com/centos/"
          official_centos_source="http://mirror.centos.org/centos/"
          initial_centos_source=""

          # 获取当前更新源并设置初始源
          case "$ID" in
              ubuntu)
                  initial_ubuntu_source=$(grep -E '^deb ' /etc/apt/sources.list | head -n 1 | awk '{print $2}')
                  ;;
              debian)
                  initial_debian_source=$(grep -E '^deb ' /etc/apt/sources.list | head -n 1 | awk '{print $2}')
                  ;;
              centos|rhel|almalinux|rocky|fedora)
                  initial_centos_source=$(awk -F= '/^baseurl=/ {print $2}' /etc/yum.repos.d/CentOS-Base.repo | head -n 1 | tr -d ' ')
                  ;;
              *)
                  echo "未知系统，无法执行切换源脚本"
                  exit 1
                  ;;
          esac

          # 备份当前源
          backup_sources() {
              case "$ID" in
                  ubuntu)
                      cp /etc/apt/sources.list /etc/apt/sources.list.bak
                      ;;
                  debian)
                      cp /etc/apt/sources.list /etc/apt/sources.list.bak
                      ;;
                  centos|rhel|almalinux|rocky|fedora)
                      if [ ! -f /etc/yum.repos.d/CentOS-Base.repo.bak ]; then
                          cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
                      else
                          echo "备份已存在，无需重复备份"
                      fi
                      ;;
                  *)
                      echo "未知系统，无法执行备份操作"
                      exit 1
                      ;;
              esac
              echo "已备份当前更新源为 /etc/apt/sources.list.bak 或 /etc/yum.repos.d/CentOS-Base.repo.bak"
          }

          # 还原初始更新源
          restore_initial_source() {
              case "$ID" in
                  ubuntu)
                      cp /etc/apt/sources.list.bak /etc/apt/sources.list
                      ;;
                  debian)
                      cp /etc/apt/sources.list.bak /etc/apt/sources.list
                      ;;
                  centos|rhel|almalinux|rocky|fedora)
                      cp /etc/yum.repos.d/CentOS-Base.repo.bak /etc/yum.repos.d/CentOS-Base.repo
                      ;;
                  *)
                      echo "未知系统，无法执行还原操作"
                      exit 1
                      ;;
              esac
              echo "已还原初始更新源"
          }

          # 函数：切换更新源
          switch_source() {
              case "$ID" in
                  ubuntu)
                      sed -i 's|'"$initial_ubuntu_source"'|'"$1"'|g' /etc/apt/sources.list
                      ;;
                  debian)
                      sed -i 's|'"$initial_debian_source"'|'"$1"'|g' /etc/apt/sources.list
                      ;;
                  centos|rhel|almalinux|rocky|fedora)
                      sed -i "s|^baseurl=.*$|baseurl=$1|g" /etc/yum.repos.d/CentOS-Base.repo
                      ;;
                  *)
                      echo "未知系统，无法执行切换操作"
                      exit 1
                      ;;
              esac
          }

          # 主菜单
          while true; do
              case "$ID" in
                  ubuntu)
                      echo "Ubuntu 更新源切换脚本"
                      echo "------------------------"
                      ;;
                  debian)
                      echo "Debian 更新源切换脚本"
                      echo "------------------------"
                      ;;
                  centos|rhel|almalinux|rocky|fedora)
                      echo "CentOS 更新源切换脚本"
                      echo "------------------------"
                      ;;
                  *)
                      echo "未知系统，无法执行脚本"
                      exit 1
                      ;;
              esac

              echo "1. 切换到阿里云源"
              echo "2. 切换到官方源"
              echo "------------------------"
              echo "3. 备份当前更新源"
              echo "4. 还原初始更新源"
              echo "------------------------"
              echo "0. 返回上一级"
              echo "------------------------"
              read -p "请选择操作: " choice

              case $choice in
                  1)
                      backup_sources
                      case "$ID" in
                          ubuntu)
                              switch_source $aliyun_ubuntu_source
                              ;;
                          debian)
                              switch_source $aliyun_debian_source
                              ;;
                          centos|rhel|almalinux|rocky|fedora)
                              switch_source $aliyun_centos_source
                              ;;
                          *)
                              echo "未知系统，无法执行切换操作"
                              exit 1
                              ;;
                      esac
                      echo "已切换到阿里云源"
                      ;;
                  2)
                      backup_sources
                      case "$ID" in
                          ubuntu)
                              switch_source $official_ubuntu_source
                              ;;
                          debian)
                              switch_source $official_debian_source
                              ;;
                          centos|rhel|almalinux|rocky|fedora)
                              switch_source $official_centos_source
                              ;;
                          *)
                              echo "未知系统，无法执行切换操作"
                              exit 1
                              ;;
                      esac
                      echo "已切换到官方源"
                      ;;
                  3)
                      backup_sources
                      case "$ID" in
                          ubuntu)
                              switch_source $initial_ubuntu_source
                              ;;
                          debian)
                              switch_source $initial_debian_source
                              ;;
                          centos|rhel|almalinux|rocky|fedora)
                              switch_source $initial_centos_source
                              ;;
                          *)
                              echo "未知系统，无法执行切换操作"
                              exit 1
                              ;;
                      esac
                      echo "已切换到初始更新源"
                      ;;
                  4)
                      restore_initial_source
                      ;;
                  0)
                      break
                      ;;
                  *)
                      echo "无效的选择，请重新输入"
                      ;;
              esac
              break_end

          done

              ;;

          20)
          send_stats "定时任务管理"
              while true; do
                  clear
                  check_crontab_installed
                  clear
                  echo "定时任务列表"
                  crontab -l
                  echo ""
                  echo "操作"
                  echo "------------------------"
                  echo "1. 添加定时任务              2. 删除定时任务              3. 编辑定时任务"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                          read -p "请输入新任务的执行命令: " newquest
                          echo "------------------------"
                          echo "1. 每月任务                 2. 每周任务"
                          echo "3. 每天任务                 4. 每小时任务"
                          echo "------------------------"
                          read -p "请输入你的选择: " dingshi

                          case $dingshi in
                              1)
                                  read -p "选择每月的几号执行任务？ (1-30): " day
                                  (crontab -l ; echo "0 0 $day * * $newquest") | crontab - > /dev/null 2>&1
                                  ;;
                              2)
                                  read -p "选择周几执行任务？ (0-6，0代表星期日): " weekday
                                  (crontab -l ; echo "0 0 * * $weekday $newquest") | crontab - > /dev/null 2>&1
                                  ;;
                              3)
                                  read -p "选择每天几点执行任务？（小时，0-23）: " hour
                                  (crontab -l ; echo "0 $hour * * * $newquest") | crontab - > /dev/null 2>&1
                                  ;;
                              4)
                                  read -p "输入每小时的第几分钟执行任务？（分钟，0-60）: " minute
                                  (crontab -l ; echo "$minute * * * * $newquest") | crontab - > /dev/null 2>&1
                                  ;;
                              *)
                                  break  # 跳出
                                  ;;
                          esac
                          ;;
                      2)
                          read -p "请输入需要删除任务的关键字: " kquest
                          crontab -l | grep -v "$kquest" | crontab -
                          ;;
                      3)
                          crontab -e
                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done

              ;;

          21)
              root_use
              send_stats "本地host解析"
              while true; do
                  clear
                  echo "本机host解析列表"
                  echo "如果你在这里添加解析匹配，将不再使用动态解析了"
                  cat /etc/hosts
                  echo ""
                  echo "操作"
                  echo "------------------------"
                  echo "1. 添加新的解析              2. 删除解析地址"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " host_dns

                  case $host_dns in
                      1)
                          read -p "请输入新的解析记录 格式: 110.25.5.33 linuxbt.pro : " addhost
                          echo "$addhost" >> /etc/hosts
                          send_stats "本地host解析新增"

                          ;;
                      2)
                          read -p "请输入需要删除的解析内容关键字: " delhost
                          sed -i "/$delhost/d" /etc/hosts
                          send_stats "本地host解析删除"
                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done
              ;;

          22)
            root_use
            send_stats "ssh防御"
            if docker inspect fail2ban &>/dev/null ; then
                while true; do
                    clear
                    echo "SSH防御程序已启动"
                    echo "------------------------"
                    echo "1. 查看SSH拦截记录"
                    echo "2. 日志实时监控"
                    echo "------------------------"
                    echo "9. 卸载防御程序"
                    echo "------------------------"
                    echo "0. 退出"
                    echo "------------------------"
                    read -p "请输入你的选择: " sub_choice
                    case $sub_choice in

                        1)
                            echo "------------------------"
                            f2b_sshd
                            echo "------------------------"
                            ;;
                        2)
                            tail -f /path/to/fail2ban/config/log/fail2ban/fail2ban.log
                            break
                            ;;
                        9)
                            docker rm -f fail2ban
                            rm -rf /path/to/fail2ban
                            echo "Fail2Ban防御程序已卸载"

                            break
                            ;;
                        0)
                            break
                            ;;
                        *)
                            echo "无效的选择，请重新输入。"
                            ;;
                    esac
                    break_end

                done

            elif [ -x "$(command -v fail2ban-client)" ] ; then
                clear
                echo "卸载旧版fail2ban"
                read -p "确定继续吗？(Y/N): " choice
                case "$choice" in
                  [Yy])
                    remove fail2ban
                    rm -rf /etc/fail2ban
                    echo "Fail2Ban防御程序已卸载"
                    ;;
                  [Nn])
                    echo "已取消"
                    ;;
                  *)
                    echo "无效的选择，请输入 Y 或 N。"
                    ;;
                esac

            else

              clear
              echo "fail2ban是一个SSH防止暴力破解工具"
              echo "官网介绍: https://github.com/fail2ban/fail2ban"
              echo "------------------------------------------------"
              echo "工作原理：研判非法IP恶意高频访问SSH端口，自动进行IP封锁"
              echo "------------------------------------------------"
              read -p "确定继续吗？(Y/N): " choice

              case "$choice" in
                [Yy])
                  clear
                  install_docker
                  f2b_install_sshd

                  cd ~
                  f2b_status
                  echo "Fail2Ban防御程序已开启"
                  send_stats "Fail2Ban防御程序已开启"

                  ;;
                [Nn])
                  echo "已取消"
                  ;;
                *)
                  echo "无效的选择，请输入 Y 或 N。"
                  ;;
              esac
            fi
              ;;


          23)
            root_use
            send_stats "限流关机功能"
            echo "当前流量使用情况，重启服务器流量计算会清零！"
            output_status
            echo "$output"

            # 检查是否存在 Limiting_Shut_down.sh 文件
            if [ -f ~/Limiting_Shut_down.sh ]; then
                # 获取 threshold_gb 的值
                rx_threshold_gb=$(grep -oP 'rx_threshold_gb=\K\d+' ~/Limiting_Shut_down.sh)
                tx_threshold_gb=$(grep -oP 'tx_threshold_gb=\K\d+' ~/Limiting_Shut_down.sh)
                echo -e "当前设置的进站限流阈值为 ${hang}${rx_threshold_gb}${bai}GB"
                echo -e "当前设置的出站限流阈值为 ${hang}${tx_threshold_gb}${bai}GB"
            else
                echo -e "${hui}前未启用限流关机功能${bai}"
            fi

            echo
            echo "------------------------------------------------"
            echo "系统每分钟会检测实际流量是否到达阈值，到达后会自动关闭服务器！每月1日重置流量重启服务器。"
            read -p "1. 开启限流关机功能    2. 停用限流关机功能    0. 退出  : " Limiting

            case "$Limiting" in
              1)
                # 输入新的虚拟内存大小
                echo "如果实际服务器就100G流量，可设置阈值为95G，提前关机，以免出现流量误差或溢出."
                read -p "请输入进站流量阈值（单位为GB）: " rx_threshold_gb
                read -p "请输入出站流量阈值（单位为GB）: " tx_threshold_gb
                cd ~
                curl -Ss -o ~/Limiting_Shut_down.sh https://raw.githubusercontent.com/linuxbt/sh/main/Limiting_Shut_down1.sh
                chmod +x ~/Limiting_Shut_down.sh
                sed -i "s/110/$rx_threshold_gb/g" ~/Limiting_Shut_down.sh
                sed -i "s/120/$tx_threshold_gb/g" ~/Limiting_Shut_down.sh
                check_crontab_installed
                crontab -l | grep -v '~/Limiting_Shut_down.sh' | crontab -
                (crontab -l ; echo "* * * * * ~/Limiting_Shut_down.sh") | crontab - > /dev/null 2>&1
                crontab -l | grep -v 'reboot' | crontab -
                (crontab -l ; echo "0 1 1 * * reboot") | crontab - > /dev/null 2>&1
                echo "限流关机已设置"
                send_stats "限流关机已设置"
                ;;
              0)
                echo "已取消"
                ;;
              2)
                check_crontab_installed
                crontab -l | grep -v '~/Limiting_Shut_down.sh' | crontab -
                crontab -l | grep -v 'reboot' | crontab -
                rm ~/Limiting_Shut_down.sh
                echo "已关闭限流关机功能"
                ;;
              *)
                echo "无效的选择，请输入 Y 或 N。"
                ;;
            esac

              ;;


          24)
              root_use
              send_stats "私钥登录"
              echo "ROOT私钥登录模式"
              echo "------------------------------------------------"
              echo "将会生成密钥对，更安全的方式SSH登录"
              read -p "确定继续吗？(Y/N): " choice

              case "$choice" in
                [Yy])
                  clear
                  send_stats "私钥登录使用"
                  add_sshkey
                  ;;
                [Nn])
                  echo "已取消"
                  ;;
                *)
                  echo "无效的选择，请输入 Y 或 N。"
                  ;;
              esac

              ;;

          25)
              root_use
              send_stats "电报预警"
              echo "TG-bot监控预警功能"
              echo "------------------------------------------------"
              echo "您需要配置tg机器人API和接收预警的用户ID，即可实现本机CPU，内存，硬盘，流量，SSH登录的实时监控预警"
              echo "到达阈值后会向用户发预警消息"
              echo -e "${hui}-关于流量，重启服务器将重新计算-${bai}"
              read -p "确定继续吗？(Y/N): " choice

              case "$choice" in
                [Yy])
                  send_stats "电报预警启用"
                  cd ~
                  install nano tmux bc jq > /dev/null 2>&1
                  check_crontab_installed
                  if [ -f ~/TG-check-notify.sh ]; then
                      chmod +x ~/TG-check-notify.sh
                      nano ~/TG-check-notify.sh
                  else
                      curl -sS -O https://raw.githubusercontent.com/linuxbt/sh/main/TG-check-notify.sh
                      chmod +x ~/TG-check-notify.sh
                      nano ~/TG-check-notify.sh
                  fi
                  tmux kill-session -t TG-check-notify > /dev/null 2>&1
                  tmux new -d -s TG-check-notify "~/TG-check-notify.sh"
                  crontab -l | grep -v '~/TG-check-notify.sh' | crontab - > /dev/null 2>&1
                  (crontab -l ; echo "@reboot tmux new -d -s TG-check-notify '~/TG-check-notify.sh'") | crontab - > /dev/null 2>&1

                  curl -sS -O https://raw.githubusercontent.com/linuxbt/sh/main/TG-SSH-check-notify.sh > /dev/null 2>&1
                  sed -i "3i$(grep '^TELEGRAM_BOT_TOKEN=' ~/TG-check-notify.sh)" TG-SSH-check-notify.sh > /dev/null 2>&1
                  sed -i "4i$(grep '^CHAT_ID=' ~/TG-check-notify.sh)" TG-SSH-check-notify.sh
                  chmod +x ~/TG-SSH-check-notify.sh

                  # 添加到 ~/.profile 文件中
                  if ! grep -q 'bash ~/TG-SSH-check-notify.sh' ~/.profile > /dev/null 2>&1; then
                      echo 'bash ~/TG-SSH-check-notify.sh' >> ~/.profile
                      if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
                         echo 'source ~/.profile' >> ~/.bashrc
                      fi
                  fi

                  source ~/.profile

                  clear
                  echo "TG-bot预警系统已启动"
                  echo -e "${hui}你还可以将root目录中的TG-check-notify.sh预警文件放到其他机器上直接使用！${bai}"
                  ;;
                [Nn])
                  echo "已取消"
                  ;;
                *)
                  echo "无效的选择，请输入 Y 或 N。"
                  ;;
              esac

              ;;

          26)
              root_use
              send_stats "修复SSH高危漏洞"
              cd ~
              curl -sS -O https://raw.githubusercontent.com/linuxbt/sh/main/upgrade_openssh9.8p1.sh
              chmod +x ~/upgrade_openssh9.8p1.sh
              ~/upgrade_openssh9.8p1.sh
              rm -f ~/upgrade_openssh9.8p1.sh
              ;;

          27)
              elrepo
              ;;


          28)
            root_use
            while true; do
              clear
              send_stats "Linux内核调优管理"
              echo -e "Linux系统内核参数优化 ${huang}测试版${bai}"
              echo "------------------------------------------------"
              echo "提供多种系统参数调优模式，用户可以根据自身使用场景进行选择切换。"
              echo -e "${huang}提示: ${bai}生产环境请谨慎使用！"
              echo "--------------------"
              echo "1. 高性能优化模式：     最大化系统性能，优化文件描述符、虚拟内存、网络设置、缓存管理和CPU设置。"
              echo "2. 均衡优化模式：       在性能与资源消耗之间取得平衡，适合日常使用。"
              echo "3. 网站优化模式：       针对网站服务器进行优化，提高并发连接处理能力、响应速度和整体性能。"
              echo "4. 直播优化模式：       针对直播推流的特殊需求进行优化，减少延迟，提高传输性能。"
              echo "5. 游戏服优化模式：     针对游戏服务器进行优化，提高并发处理能力和响应速度。"
              echo "6. 还原默认设置：       将系统设置还原为默认配置。"
              echo "--------------------"
              echo "0. 返回上一级"
              echo "--------------------"
              read -p "请输入你的选择: " sub_choice
              case $sub_choice in
                  1)
                      cd ~
                      clear
                      tiaoyou_moshi="高性能优化模式"
                      optimize_high_performance
                      send_stats "高性能模式优化"
                      break_end
                      ;;
                  2)
                      cd ~
                      clear
                      optimize_balanced
                      send_stats "均衡模式优化"
                      break_end
                      ;;
                  3)
                      cd ~
                      clear
                      optimize_web_server
                      send_stats "网站优化模式"
                      break_end
                      ;;
                  4)
                      cd ~
                      clear
                      tiaoyou_moshi="直播优化模式"
                      optimize_high_performance
                      send_stats "直播推流优化"
                      break_end
                      ;;
                  5)
                      cd ~
                      clear
                      tiaoyou_moshi="游戏服优化模式"
                      optimize_high_performance
                      send_stats "游戏服优化"
                      break_end
                      ;;
                  6)
                      cd ~
                      clear
                      restore_defaults
                      send_stats "还原默认设置"
                      break_end
                      ;;
                  0)
                      break
                      ;;
                  *)
                      echo "无效的选择，请重新输入。"
                      ;;
              esac
            done
              ;;


          29)
              clamav
              ;;

          30)
              hmscan
              ;;

          31)
            clear
            send_stats "留言板"
            install sshpass

            remote_ip="66.42.61.110"
            remote_user="liaotian123"
            remote_file="/home/liaotian123/liaotian.txt"
            password="linuxbtYYDS"  # 替换为您的密码

            clear
            echo "linuxbt留言板"
            echo "------------------------"
            # 显示已有的留言内容
            sshpass -p "${password}" ssh -o StrictHostKeyChecking=no "${remote_user}@${remote_ip}" "cat '${remote_file}'"
            echo ""
            echo "------------------------"

            # 判断是否要留言
            read -p "是否要留言？(y/n): " leave_message

            if [ "$leave_message" == "y" ] || [ "$leave_message" == "Y" ]; then
                # 输入新的留言内容
                read -p "输入你的昵称: " nicheng
                read -p "输入你的聊天内容: " neirong

                # 添加新留言到远程文件
                sshpass -p "${password}" ssh -o StrictHostKeyChecking=no "${remote_user}@${remote_ip}" "echo -e '${nicheng}: ${neirong}' >> '${remote_file}'"
                echo "已添加留言: "
                echo "${nicheng}: ${neirong}"
                echo ""
            else
                echo "您选择了不留言。"
            fi

            echo "留言板操作完成。"

              ;;

          66)

              root_use
              send_stats "一条龙调优"
              echo "一条龙系统调优"
              echo "------------------------------------------------"
              echo "将对以下内容进行操作与优化"
              echo "1. 更新系统到最新"
              echo "2. 清理系统垃圾文件"
              echo -e "3. 设置虚拟内存${huang}1G${bai}"
              echo -e "4. 设置SSH端口号为${huang}5522${bai}"
              echo -e "5. 开放所有端口"
              echo -e "6. 开启${huang}BBR${bai}加速"
              echo -e "7. 设置时区到${huang}上海${bai}"
              echo -e "8. 自动优化DNS地址${huang}海外: 1.1.1.1 8.8.8.8  国内: 223.5.5.5 ${bai}"
              echo -e "9. 安装常用工具${huang}docker wget sudo tar unzip socat btop nano vim${bai}"
              echo -e "10. Linux系统内核参数优化切换到${huang}均衡优化模式${bai}"
              echo "------------------------------------------------"
              read -p "确定一键保养吗？(Y/N): " choice

              case "$choice" in
                [Yy])
                  clear
                  send_stats "一条龙调优启动"
                  echo "------------------------------------------------"
                  linux_update
                  echo -e "[${lv}OK${bai}] 1/10. 更新系统到最新"

                  echo "------------------------------------------------"
                  linux_clean
                  echo -e "[${lv}OK${bai}] 2/10. 清理系统垃圾文件"

                  echo "------------------------------------------------"
                  new_swap=1024
                  add_swap
                  echo -e "[${lv}OK${bai}] 3/10. 设置虚拟内存${huang}1G${bai}"

                  echo "------------------------------------------------"
                  new_port=5522
                  new_ssh_port
                  echo -e "[${lv}OK${bai}] 4/10. 设置SSH端口号为${huang}5522${bai}"
                  echo "------------------------------------------------"
                  echo -e "[${lv}OK${bai}] 5/10. 开放所有端口"

                  echo "------------------------------------------------"
                  bbr_on
                  echo -e "[${lv}OK${bai}] 6/10. 开启${huang}BBR${bai}加速"

                  echo "------------------------------------------------"
                  set_timedate Asia/Shanghai
                  echo -e "[${lv}OK${bai}] 7/10. 设置时区到${huang}上海${bai}"

                  echo "------------------------------------------------"
                  country=$(curl -s ipinfo.io/country)
                  if [ "$country" = "CN" ]; then
                      dns1_ipv4="223.5.5.5"
                      dns2_ipv4="183.60.83.19"
                      dns1_ipv6="2400:3200::1"
                      dns2_ipv6="2400:da00::6666"
                  else
                      dns1_ipv4="1.1.1.1"
                      dns2_ipv4="8.8.8.8"
                      dns1_ipv6="2606:4700:4700::1111"
                      dns2_ipv6="2001:4860:4860::8888"
                  fi

                  set_dns
                  echo -e "[${lv}OK${bai}] 8/10. 自动优化DNS地址${huang}${bai}"

                  echo "------------------------------------------------"
                  install_add_docker
                  install wget sudo tar unzip socat btop nano vim
                  echo -e "[${lv}OK${bai}] 9/10. 安装常用工具${huang}docker wget sudo tar unzip socat btop${bai}"
                  echo "------------------------------------------------"

                  echo "------------------------------------------------"
                  optimize_balanced
                  echo -e "[${lv}OK${bai}] 10/10. Linux系统内核参数优化"
                  echo -e "${lv}一条龙系统调优已完成${bai}"

                  ;;
                [Nn])
                  echo "已取消"
                  ;;
                *)
                  echo "无效的选择，请输入 Y 或 N。"
                  ;;
              esac

              ;;

          99)
              clear
              send_stats "重启系统"
              server_reboot
              ;;
          100)

            root_use
            while true; do
              clear
              yinsiyuanquan1
              echo "隐私与安全"
              echo "脚本将收集用户使用功能的数据，优化脚本体验，制作更多好玩好用的功能"
              echo "将收集脚本版本号，使用的时间，系统版本，CPU架构，机器所属国家和使用的功能的名称，"
              echo "------------------------------------------------"
              echo -e "当前状态: $status_message"
              echo "--------------------"
              echo "1. 开启采集"
              echo "2. 关闭采集"
              echo "--------------------"
              echo "0. 返回上一级"
              echo "--------------------"
              read -p "请输入你的选择: " sub_choice
              case $sub_choice in
                  1)
                      cd ~
                      sed -i 's/^ENABLE_STATS="false"/ENABLE_STATS="true"/' /usr/local/bin/k
                      sed -i 's/^ENABLE_STATS="false"/ENABLE_STATS="true"/' ~/k.sh
                      echo "已开启采集"
                      send_stats "隐私与安全已开启采集"
                      ;;
                  2)
                      cd ~
                      sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' /usr/local/bin/k
                      sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' ~/k.sh
                      echo "已关闭采集"
                      send_stats "隐私与安全已关闭采集"
                      ;;
                  0)
                      break
                      ;;
                  *)
                      echo "无效的选择，请重新输入。"
                      ;;
              esac
            done
              ;;

          101)
              clear
              send_stats "卸载K脚本"
              echo "卸载K脚本"
              echo "------------------------------------------------"
              echo "将彻底卸K脚本，不影响你其他功能"
              read -p "确定继续吗？(Y/N): " choice

              case "$choice" in
                [Yy])
                  clear
                  rm -f /usr/local/bin/k
                  rm ~/k.sh
                  echo "脚本已卸载，再见！"
                  break_end
                  clear
                  exit
                  ;;
                [Nn])
                  echo "已取消"
                  ;;
                *)
                  echo "无效的选择，请输入 Y 或 N。"
                  ;;
              esac
              ;;

          0)
              linuxbt

              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end

    done



}


linux_cluster() {

    clear
    send_stats "集群控制"
    while true; do
      clear
      echo -e "${kjlan}▶ VPS集群控制${bai}"
      echo -e "${kjlan}你可以远程操控多台VPS一起执行任务（仅支持Ubuntu/Debian）${bai}"
      echo -e "${kjlan}------------------------${bai}"
      echo -e "${huang}1. 安装集群环境${bai}"
      echo -e "${kjlan}------------------------${bai}"
      echo -e "${lv}2. 集群控制中心${bai}"
      echo -e "${kjlan}------------------------${bai}"
      echo -e "${lan}7. 备份集群环境${bai}"
      echo -e "${lan}8. 还原集群环境${bai}"
      echo -e "${lan}9. 卸载集群环境${bai}"
      echo -e "${kjlan}------------------------${bai}"
      echo -e "${bai}0. 返回主菜单${bai}"
      echo -e "${kjlan}------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in
          1)
            clear
            send_stats "安装集群环境"
            install python3 python3-paramiko speedtest-cli lrzsz
            mkdir cluster && cd cluster
            touch servers.py

            cat > ./servers.py << EOF
servers = [

]
EOF

              ;;
          2)

              while true; do
                  clear
                  send_stats "集群控制中心"
                  echo "集群服务器列表"
                  cat ~/cluster/servers.py

                  echo ""
                  echo "操作"
                  echo "------------------------"
                  echo "1. 添加服务器                2. 删除服务器             3. 编辑服务器"
                  echo "------------------------"
                  echo "11. 安装K脚本         12. 更新系统              13. 清理系统"
                  echo "14. 安装docker               15. 安装BBR3              16. 设置1G虚拟内存"
                  echo "17. 设置时区到上海           18. 开放所有端口"
                  echo "------------------------"
                  echo "51. 自定义指令"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                          send_stats "添加集群服务器"
                          read -p "服务器名称: " server_name
                          read -p "服务器IP: " server_ip
                          read -p "服务器端口（22）: " server_port
                          server_port=${server_port:-22}
                          read -p "服务器用户名（root）: " server_username
                          server_username=${server_username:-root}
                          read -p "服务器用户密码: " server_password

                          sed -i "/servers = \[/a\    {\"name\": \"$server_name\", \"hostname\": \"$server_ip\", \"port\": $server_port, \"username\": \"$server_username\", \"password\": \"$server_password\", \"remote_path\": \"/home/\"}," ~/cluster/servers.py

                          ;;
                      2)
                          send_stats "删除集群服务器"
                          read -p "请输入需要删除的关键字: " rmserver
                          sed -i "/$rmserver/d" ~/cluster/servers.py
                          ;;
                      3)
                          send_stats "编辑集群服务器"
                          install nano
                          nano ~/cluster/servers.py
                          ;;
                      11)
                          py_task=install_linuxbt.py
                          cluster_python3
                          ;;
                      12)
                          py_task=update.py
                          cluster_python3
                          ;;
                      13)
                          py_task=clean.py
                          cluster_python3
                          ;;
                      14)
                          py_task=install_docker.py
                          cluster_python3
                          ;;
                      15)
                          py_task=install_bbr3.py
                          cluster_python3
                          ;;
                      16)
                          py_task=swap1024.py
                          cluster_python3
                          ;;
                      17)
                          py_task=time_shanghai.py
                          cluster_python3
                          ;;
                      18)
                          py_task=firewall_close.py
                          cluster_python3
                          ;;
                      51)
                          send_stats "自定义执行命令"
                          read -p "请输入批量执行的命令: " mingling
                          py_task=custom_tasks.py
                          cd ~/cluster/
                          curl -sS -O https://raw.githubusercontent.com/linuxbt/python-for-vps/main/cluster/$py_task
                          sed -i "s#Customtasks#$mingling#g" ~/cluster/$py_task
                          python3 ~/cluster/$py_task
                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done

              ;;
          7)
            clear
            send_stats "备份集群"
            echo "将下载服务器列表数据，按任意键下载！"
            read -n 1 -s -r -p ""
            sz -y ~/cluster/servers.py

              ;;

          8)
            clear
            send_stats "还原集群"
            echo "请上传您的servers.py，按任意键开始上传！"
            read -n 1 -s -r -p ""
            cd ~/cluster/
            rz -y
              ;;

          9)

            clear
            send_stats "卸载集群"
            read -p "请先备份环境，确定要卸载集群控制环境吗？(Y/N): " choice
            case "$choice" in
              [Yy])
                remove python3-paramiko speedtest-cli lrzsz
                rm -rf ~/cluster/
                ;;
              [Nn])
                echo "已取消"
                ;;
              *)
                echo "无效的选择，请输入 Y 或 N。"
                ;;
            esac

              ;;

          0)
              linuxbt
              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end

    done



}



linuxbt_update() {

    send_stats "脚本更新"
    cd ~
    clear
    echo "更新日志"
    echo "------------------------"
    echo "全部日志: https://raw.githubusercontent.com/linuxbt/sh/main/k_sh_log.txt"
    echo "------------------------"

    curl -s https://raw.githubusercontent.com/linuxbt/sh/main/k_sh_log.txt | tail -n 35
    sh_v_new=$(curl -s https://raw.githubusercontent.com/linuxbt/sh/main/k.sh | grep -o 'sh_v="[0-9.]*"' | cut -d '"' -f 2)

    if [ "$sh_v" = "$sh_v_new" ]; then
        echo -e "${lv}你已经是最新版本！${huang}v$sh_v${bai}"
    else
        echo "发现新版本！"
        echo -e "当前版本 v$sh_v        最新版本 ${huang}v$sh_v_new${bai}"
        echo "------------------------"
        read -p "确定更新脚本吗？(Y/N): " choice
        case "$choice" in
            [Yy])
                clear
                country=$(curl -s ipinfo.io/country)
                if [ "$country" = "CN" ]; then
                    curl -sS -O https://raw.githubusercontent.com/linuxbt/sh/main/k.sh && chmod +x k.sh
                else
                    curl -sS -O https://raw.githubusercontent.com/linuxbt/sh/main/k.sh && chmod +x k.sh
                fi
                CheckFirstRun_true
                yinsiyuanquan2
                cp ./k.sh /usr/local/bin/k > /dev/null 2>&1
                echo -e "${lv}脚本已更新到最新版本！${huang}v$sh_v_new${bai}"
                break_end
                linuxbt
                ;;
            [Nn])
                echo "已取消"
                ;;
            *)
                ;;
        esac
    fi


}



linuxbt_sh() {
while true; do
clear

echo -e "${kjlan}_  _ ____  _ _ _    _ ____ _  _ "
echo "  _  __                        _       _   "
echo " | |/ /                       (_)     | |  "
echo " | ' /    ___    ___   _ __    _   __ | |_ "
echo " |  <    / __|  / __| | '__|  | | / _\| __|"
echo " | . \   \__ \ | (__  | |     | || (_ | |_ "
echo " |_|\_\  |___/  \___| |_|     |_| \___|\__|"
echo "                                           "
echo -e "${kjlan}K脚本工具箱 v$sh_v 只为更简单的Linux的使用！"
echo -e "适配Ubuntu/Debian/CentOS/Alpine/Kali/Arch/RedHat/Fedora/Alma/Rocky系统"
echo -e "-输入${huang}k${kjlan}可快速启动此脚本-${bai}"
echo -e "${kjlan}------------------------${bai}"
echo -e "${lv}1. 系统信息查询${bai}"
echo -e "${lv}2. 系统更新${bai}"
echo -e "${lv}3. 系统清理${bai}"
echo -e "${huang}4. 常用工具 ▶${bai}"
echo -e "${huang}5. BBR管理 ▶${bai}"
echo -e "${huang}6. Docker管理 ▶${bai}"
echo -e "${huang}7. WARP管理 ▶${bai}"
echo -e "${huang}8. 测试脚本 ▶${bai}"
echo -e "${huang}9. 甲骨文脚本 ▶${bai}"
echo -e "${huang}10. LDNMP建站 ▶${bai}"
echo -e "${huang}11. 面板工具 ▶${bai}"
echo -e "${huang}12. 我的工作区 ▶${bai}"
echo -e "${huang}13. 系统工具 ▶${bai}"
echo -e "${huang}14. VPS集群控制 ▶${bai}"
echo -e "${huang}15. Linux远程桌面 ▶${bai}"
#echo -e "${huang}16. 科学上网工具 ▶${bai}"
echo -e "${kjlan}17. 组网神器 ▶${bai}"
echo -e "${kjlan}18. 文件同步备份 ▶${bai}"
echo -e "${kjlan}19. 助记词安全管理工具 ▶${bai}"
echo -e "${huang}99. 快捷命令菜单 ▶${bai}"
echo -e "${kjlan}------------------------${bai}"
echo -e "${bai}00. 脚本更新${bai}"
echo -e "${kjlan}------------------------${bai}"
echo -e "${bai}0. 退出脚本${bai}"
echo -e "${kjlan}------------------------${bai}"
read -p "请输入你的选择: " choice

case $choice in
  1)
    linux_ps
    ;;

  2)
    clear
    send_stats "系统更新"
    linux_update
    ;;

  3)
    clear
    send_stats "系统清理"
    linux_clean
    ;;

  4)

    linux_tools
    ;;

  5)
    linux_bbr
    ;;

  6)
    linux_docker
    ;;


  7)
    clear
    send_stats "warp管理"
    install wget
    wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh [option] [lisence/url/token]
    ;;

  8)
    linux_test
    ;;

  9)
    linux_Oracle
    ;;


  10)
    linux_ldnmp
      ;;

  11)
    linux_panel
    ;;

  12)
    linux_work
    ;;

  13)
    linux_Settings
    ;;

  14)
    linux_cluster
    ;;

  15)
    linux_remote
    ;;

  16)
    linux_vpn
    ;;

  17)
    linux_tunnel
    ;;

  18)
    linux_backup
    ;;

  19)
    bip39_manage
    ;;

  99)
    kjj_menu
    ;;

  00)
    linuxbt_update
    ;;

  0)
    clear
    exit
    ;;

  *)
    echo "无效的输入!"
    ;;
esac
    break_end
done

}





# 添加快捷键菜单部分
kjj_url="https://raw.githubusercontent.com/linuxbt/sh/main/kjj_config.json"
kjj_file="/tmp/kjj_config.json"

check_jq() {
    command -v jq >/dev/null 2>&1 || {
        if [ -f /etc/redhat-release ]; then
            install jq
        elif [ -f /etc/debian_version ]; then
            install jq
        elif [ -f /etc/arch-release ]; then
            install jq
        elif [ -f /etc/fedora-release ]; then
            install jq
        elif [ -f /etc/alpine-release ]; then
            install jq
        else
            echo "不支持的Linux发行版,请手动安装jq"
            exit 1
        fi
    }
}

# 下载配置文件
download_kjj_config() {
    if [ ! -f "$kjj_file" ]; then
        curl -s -o "$kjj_file" "$kjj_url"
        if [ $? -ne 0 ]; then
            echo "无法下载配置文件，使用本地配置"
            kjj_file="./kjj_config.json"
        fi
    fi
}


# 函数：执行命令
exec_kjj_command() {
    local cmd="$1"
    shift
    eval "$cmd \"\$@\""
}


# 函数：显示快捷键菜单
show_kjj_menu() {
    local menu=$1

    jq -r 'to_entries[] | "\(.key). \(.value.name)"' <<< "$menu"
}


# 函数：快捷键交互式菜单
kjj_menu() {
    check_jq
    download_kjj_config
    local kjj_file="/tmp/kjj_config.json"
    local path=()

    while true; do
        clear
        echo "当前位置: /${path[*]}"
        echo "选择一个选项 (输入数字选择, '0' 返回上一级, '00' 返回一级菜单页, 'q' 退出):"

        # 构建 jq_filter 以获取当前菜单
        local jq_filter=".menu"
        for p in "${path[@]}"; do
            jq_filter+=".\"$p\".submenu"
        done

        # 显示当前菜单
        local menu
        menu=$(jq "$jq_filter" "$kjj_file")
        if [[ $? -ne 0 ]]; then
            echo "读取菜单失败，请检查 JSON 文件。"
            exit 1
        fi
        show_kjj_menu "$menu"

        read -p "> " choice

        if [[ "$choice" == "q" ]]; then
            exit 0
        elif [[ "$choice" == "0" ]]; then
            if [[ ${#path[@]} -gt 0 ]]; then
                unset path[${#path[@]}-1]  # 移除当前菜单
            fi
        elif [[ "$choice" == "00" ]]; then
            path=()  # 清空路径数组，返回到一级菜单
        else
            # 构建 jq_filter 以获取选定的项
            local selected
            selected=$(jq -r "$jq_filter.\"$choice\"" "$kjj_file")
            if [[ -n "$selected" && "$selected" != "null" ]]; then
                if jq -e '.submenu' <<< "$selected" > /dev/null; then
                    path+=("$choice")
                else
                    local cmd
                    cmd=$(jq -r '.cmd' <<< "$selected")
                    if [[ "$cmd" == "null" || -z "$cmd" ]]; then
                        echo "无效命令或命令为空，请重试"
                    else
                        eval "$cmd"
                        if [[ $? -ne 0 ]]; then
                            echo "Error: Command failed with exit status $?"
                        fi
                    fi
                    read -p "按回车键继续..."
                fi
            else
                echo "无效选项，请重试"
                read -p "按回车键继续..."
            fi
        fi
    done
}





kjj_help() {
    echo "无效参数"
    echo "-------------------"
    echo "以下是命令参考用例："
    echo "启动原有脚本        ./k.sh"
    echo "安装软件包          ./k.sh install nano wget | ./k.sh add nano wget | ./k.sh 安装 nano wget"
    echo "卸载软件包          ./k.sh remove nano wget | ./k.sh del nano wget | ./k.sh uninstall nano wget | ./k.sh 卸载 nano wget"
    echo "更新系统            ./k.sh update | ./k.sh 更新"
    echo "清理系统垃圾        ./k.sh clean | ./k.sh 清理"
    echo "重装系统            ./k.sh dd | ./k.sh 重装"
    echo "BBR v3控制面板      ./k.sh bbr3 | ./k.sh bbrv3"
    echo "软件启动            ./k.sh start sshd | ./k.sh 启动 sshd"
    echo "软件停止            ./k.sh stop sshd | ./k.sh 停止 sshd"
    echo "软件重启            ./k.sh restart sshd | ./k.sh 重启 sshd"
    echo "软件状态查看        ./k.sh status sshd | ./k.sh 状态 sshd"
    echo "软件开机启动        ./k.sh enable docker | ./k.sh autostart docker | ./k.sh 开机启动 docker"
    echo "域名证书申请        ./k.sh ssl"
    echo "域名证书到期查询    ./k.sh sslps"
    echo "防火墙相关命令      ./k.sh fwl | ./k.sh fwr | ./k.sh fws | ./k.sh fwre | ./k.sh tj80"
}


if [ "$#" -eq 0 ]; then
    # 如果没有参数，运行原有的 linuxbt_sh 函数
    linuxbt_sh
elif [ "$1" = "k" ]; then
    if [ "$#" -eq 1 ]; then
        # 如果只输入了 k，运行原有的 kjj_menu 函数
        kjj_menu
    fi
else
    case "$1" in
        install|add|安装)
            shift 1
            send_stats "安装软件"
            install "$@"
            ;;
        remove|del|uninstall|卸载)
            shift 1
            send_stats "卸载软件"
            remove "$@"
            ;;
        update|更新)
            send_stats "系统更新"
            linux_update
            ;;
        clean|清理)
            send_stats "系统清理"
            linux_clean
            ;;
        dd|重装)
            send_stats "重装系统"
            dd_xitong
            ;;
        bbr3|bbrv3)
            send_stats "BBR v3"
            bbrv3
            ;;
        status|状态)
            shift 1
            send_stats "软件状态查看"
            status "$@"
            ;;
        start|启动)
            shift 1
            send_stats "软件启动"
            start "$@"
            ;;
        stop|停止)
            shift 1
            send_stats "软件暂停"
            stop "$@"
            ;;
        restart|重启)
            shift 1
            send_stats "软件重启"
            restart "$@"
            ;;
        enable|autostart|开机启动)
            shift 1
            send_stats "软件开机自启"
            enable "$@"
            ;;
        ssl)
            send_stats "快捷证书申请"
            add_ssl
            ;;
        sslps)
            send_stats "查看证书到期情况"
            ssl_ps
            ;;
        *)
            cmd=$(jq -r ".commands.\"$1\"" "$kjj_file")
            if [ "$cmd" != "null" ]; then
                exec_kjj_command "$cmd" "${@:2}"
            else
                kjj_help
            fi    
        ;;
    esac
fi





