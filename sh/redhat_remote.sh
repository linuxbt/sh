#!/bin/bash

# 更新系统
yum update -y

# 安装桌面环境和依赖包
yum groupinstall -y "Server with GUI"
yum install -y xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-utils

# 安装 xrdp
yum install -y epel-release
yum install -y xrdp

# 启动和启用 xrdp 服务
systemctl enable xrdp
systemctl start xrdp

# 允许远程连接的端口
firewall-cmd --permanent --zone=public --add-port=58390/tcp
firewall-cmd --reload

# 创建远程桌面用户名和密码
USERNAME="linuxbt"
PASSWORD="abcd1234"

# 创建新用户并设置密码
useradd "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd

# 将用户添加到 wheel 组（如果需要管理员权限）
usermod -aG wheel "$USERNAME"

# 安装中文语言包
yum install -y langpacks-zh_CN

# 安装 Firefox 和输入法
yum install -y firefox
yum install -y ibus ibus-libpinyin

# 配置输入法环境变量
echo 'export GTK_IM_MODULE=ibus' >> /etc/profile
echo 'export XMODIFIERS="@im=ibus"' >> /etc/profile
echo 'export QT_IM_MODULE=ibus' >> /etc/profile

# 修改 xrdp 配置文件中的远程连接端口
sed -i 's/^port=3389/port=58390/' /etc/xrdp/xrdp.ini

# 重启 xrdp 服务
systemctl restart xrdp

echo "--------------------------"
echo "请使用您的ip:58390进行连接"

echo "用户名为: linuxbt"
echo "密码为: abcd1234"

echo "注意：登录后请自行修改密码！！！"
echo "如遇到登录后闪退重启即可解决"
echo "--------------------------"
