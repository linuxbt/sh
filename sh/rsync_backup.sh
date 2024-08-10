#!/bin/bash
# 安装rsync，适应各大发行版
if command -v dnf &> /dev/null; then
    dnf -y install rsync
elif command -v apt &> /dev/null; then
    apt-get -y install rsync
elif command -v yum &> /dev/null; then
    yum -y install rsync
elif command -v pacman &> /dev/null; then
    pacman -Sy --noconfirm rsync
elif command -v apk &> /dev/null; then
    apk add --no-cache rsync
elif command -v zypper &> /dev/null; then
    zypper install -y rsync
else
    echo "未检测到受支持的包管理器，无法自动安装rsync，请手动安装。"
    exit 1
fi

# 获取用户输入
read -p "请输入rsync密码: " pwd
read -p "请输入rsync端口 (默认873): " port
port=${port:-873}
read -p "请输入需要同步的路径（多个路径用空格隔开,末尾不用带斜杆/）: " -a paths
read -p "请输入允许访问的IP或IP段（多个用空格隔开，默认放行所有IP）: " -a allowed_ips

# 获取公网IP
public_ip=$(curl -s https://ip.gs)

# 判断防火墙管理工具类型
if command -v firewall-cmd &> /dev/null; then
    firewall_tool="firewalld"
elif command -v ufw &> /dev/null; then
    firewall_tool="ufw"
else
    echo "未检测到受支持的防火墙管理工具（firewalld或ufw）!"
fi

# 配置防火墙规则
if [[ "$firewall_tool" == "firewalld" ]]; then
    firewall-cmd --zone=public --add-port=$port/tcp --permanent
    for ip in "${allowed_ips[@]}"; do
        firewall-cmd --zone=public --add-source=$ip --permanent
    done
    firewall-cmd --reload
elif [[ "$firewall_tool" == "ufw" ]]; then
    ufw allow $port/tcp
    for ip in "${allowed_ips[@]}"; do
        ufw allow from $ip to any port $port
    done
    ufw reload
fi

# 备份rsync配置文件
cp /etc/rsyncd.conf /etc/rsyncd.conf.bak

# 修改rsync配置文件
hosts_allow=${allowed_ips[@]:-*}
if [ -z "$hosts_allow" ]; then
    hosts_allow="*"
fi

cat >/etc/rsyncd.conf<<EOF
uid = root
use chroot = no
dont compress = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2 *.mp4 *.avi *.swf *.rar
hosts allow = $hosts_allow
max connections = 200
gid = root
timeout = 600
lock file = /var/run/rsync.lock
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
port = $port
EOF

# 根据用户输入的路径生成对应的配置
for i in "${!paths[@]}"; do
    cat >>/etc/rsyncd.conf<<EOF
[web$(($i+1))]
        path = ${paths[$i]}/
        comment =
        read only = true
        ignore errors
        auth users = web
        secrets file = /etc/rsyncd.secrets
EOF
done

# 启动rsync服务
rsync --daemon

# 添加rsync用户密码到secrets文件
echo "web:$pwd" > /etc/rsyncd.secrets

# 设置密码文件权限
chmod 600 /etc/rsyncd.secrets

# 输出配置完成信息，并给出客户端同步命令示例
echo "服务端rsync配置完成，端口号: $port"
echo "客户端同步命令格式："
for i in "${!paths[@]}"; do
    if [ "$port" -ne 873 ]; then
        echo "rsync -avzP --port=$port web@$public_ip::web$(($i+1)) /local/to/path/ --password-file=/path/to/web.pwd"
    else
        echo "rsync -avzP web@$public_ip::web$(($i+1)) /local/to/path/ --password-file=/path/to/web.pwd"
    fi
done
echo "客户端若使用密码文件传输则需配置文件为600权限 chmod 600 /path/to/web.pwd"
echo "若是不用密码文件，可以把--password-file=/path/to/web.pwd去掉"
