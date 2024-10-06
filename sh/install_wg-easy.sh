#!/bin/bash
# 更新包列表
# if [ -f /etc/redhat-release ]; then
#     sudo yum update -y
# elif [ -f /etc/debian_version ]; then
#     sudo apt update -y
# else
#     echo "不支持的Linux发行版"
#     exit 1
# fi

# 检查是否安装Docker
if ! command -v docker &> /dev/null; then
    echo "Docker未安装，正在安装..."
    bash <(curl -sSL https://get.docker.com) || bash <(curl -sSL https://raw.githubusercontent.com/linuxbt/sh/main/sh/install_docker.sh)
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "Docker已安装"
fi

# 检查是否安装Python3
if ! command -v python3 &> /dev/null; then
    echo "Python3未安装，正在安装..."
    if [[ -f /etc/debian_version ]]; then
        sudo apt install -y python3
    elif [[ -f /etc/redhat-release ]]; then
        sudo yum install -y python3
    elif [[ -f /etc/arch-release ]]; then
        sudo pacman -Sy python
    elif [[ -f /etc/fedora-release ]]; then
        sudo dnf install -y python3
    else
        echo "不支持的Linux发行版"
        exit 1
    fi
else
    echo "Python3已安装"
fi

# 检查是否成功安装Python3，否则使用备用脚本安装
if ! command -v python3 &> /dev/null ; then
    echo "Python3 未成功安装，使用备用脚本安装..."
    curl -O https://raw.githubusercontent.com/linuxbt/sh/main/sh/install_python.sh && chmod +x install_python.sh && ./install_python.sh
fi

# 检查并安装pip3
if ! command -v pip3 &> /dev/null; then
    echo "pip3 未安装，正在安装..."
    if [ -f /etc/redhat-release ]; then
        sudo yum install -y python3-pip
    elif [ -f /etc/debian_version ]; then
        sudo apt install -y python3-pip
    fi
else
    echo "pip3 已安装"
fi

# 检查并安装bcrypt模块
if ! python3 -c "import bcrypt" &> /dev/null; then
    echo "bcrypt 模块未安装，正在安装..."
    pip3 install bcrypt || apt -y install python3-bcrypt
else
    echo "bcrypt 模块已安装"
fi

ip_address() {
ipv4_address=$(curl -s ipv4.ip.sb)
ipv6_address=$(curl -s --max-time 1 ipv6.ip.sb)
}
ip_address
# 获取用户输入的端口
read -p "请输入宿主机的科学上网连接端口 (默认51820): " HOST_PORT_UDP
HOST_PORT_UDP=${HOST_PORT_UDP:-51820}

read -p "请输入宿主机的科学上网管理面板端口 (默认51821): " HOST_PORT_TCP
HOST_PORT_TCP=${HOST_PORT_TCP:-51821}

# 获取用户输入的WG_HOST和PASSWORD
read -p "请输入WG_HOST (服务器IP或域名,默认获取的主IP): " WG_HOST
WG_HOST=${WG_HOST:-$ipv4_address}
read -p "请输入PASSWORD: " PASSWORD

# 验证IP格式或域名
if ! [[ $WG_HOST =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ || $WG_HOST =~ ^[a-zA-Z0-9.-]+$ ]]; then
    echo "IP地址或域名格式不正确"
    exit 1
fi

# 验证密码长度
if [ ${#PASSWORD} -gt 32 ]; then
    echo "密码长度超过32位"
    exit 1
fi

# 生成加密盐值的Python脚本
PASSWORD_HASH=$(python3 <<EOF
import bcrypt
password = b"$PASSWORD"  # DO NOT REMOVE THE b
assert len(password) < 72, "Password must be less than 72 bytes due to bcrypt limitation"
hashed = bcrypt.hashpw(password, bcrypt.gensalt())
docker_interpolation = hashed.decode().replace("\$", "\$\$")
print(docker_interpolation)
EOF
)

echo "加密后的密码: $PASSWORD_HASH"

# 运行Docker容器
docker run -d \
    --name=wg-easy \
    -e WG_HOST="$WG_HOST" \
    -e PASSWORD="$PASSWORD_HASH" \
    -e PORT="$HOST_PORT_TCP" \
    -e WG_PORT="$HOST_PORT_UDP" \
    -v ~/.wg-easy:/etc/wireguard \
    -p "$HOST_PORT_UDP":51820/udp \
    -p "$HOST_PORT_TCP":51821/tcp \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
    --sysctl="net.ipv4.ip_forward=1" \
    --restart=unless-stopped \
    ghcr.io/wg-easy/wg-easy

echo "wg-easy 容器已启动"

# 检查并放行防火墙端口
if command -v firewall-cmd &> /dev/null; then
    echo "使用firewalld管理防火墙，正在放行端口..."
    sudo firewall-cmd --permanent --add-port="$HOST_PORT_UDP"/udp
    sudo firewall-cmd --permanent --add-port="$HOST_PORT_TCP"/tcp
    sudo firewall-cmd --reload
elif command -v ufw &> /dev/null; then
    echo "使用UFW管理防火墙，正在放行端口..."
    sudo ufw allow "$HOST_PORT_UDP"/udp
    sudo ufw allow "$HOST_PORT_TCP"/tcp
    sudo ufw reload
else
    echo "未找到防火墙管理工具，跳过防火墙配置"
fi

# 输出用户信息
echo "安装完成"
echo "----------------------以下是您的wireguard相关配置信息--------------------------------"
echo "服务器IP: $WG_HOST"
echo "面板端口号: $HOST_PORT_TCP"
echo "面板管理密码: $PASSWORD"
echo "--------------请将您的连接信息保存在安全的地方，不要随意透露他人-------------"
