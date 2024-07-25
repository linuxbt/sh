#!/bin/bash
apt update -y && apt upgrade -y
#安装桌面环境和依赖包
DEBIAN_FRONTEND=noninteractive apt-get -y install xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils
#安装xrdp
apt -y install xrdp
systemctl enable xrdp
adduser xrdp ssl-cert
#放行指定IP，允许远程登陆
ufw allow from 104.28.0.0/16 to any port 58390
ufw reload
ufw status numbered

# 创建远程桌面用户名和密码
USERNAME="linuxbt"
PASSWORD="abcd1234"
# 创建新用户并设置密码
useradd -m -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
# 将用户添加到 sudo 组（如果需要管理员权限）
usermod -aG sudo "$USERNAME"

# 安装中文语言包
apt -y install locales xfonts-intl-chinese fonts-wqy-microhei
# 设置默认语言环境为 zh_CN.UTF-8
echo "locales locales/default_environment_locale select zh_CN.UTF-8" |  debconf-set-selections
# 启用 zh_CN.UTF-8 语言环境并生成
sed -i 's/^# \(zh_CN.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
# 重新配置 locales 并生成启用的语言环境
dpkg-reconfigure -f noninteractive locales
# 设置系统默认语言环境为 zh_CN.UTF-8
update-locale LANG=zh_CN.UTF-8
# 确认 /etc/default/locale 文件内容
cat /etc/default/locale
# 安装firefox 和firefox中文包  和中文输入法
apt -y install firefox-esr firefox-esr-l10n-zh-cn
# 安装中文输入法
apt -y install fcitx fcitx-googlepinyin
# 修改 xrdp 配置文件中的远程连接端口
sed -i 's/^port=3389/port=58390/' /etc/xrdp/xrdp.ini
systemctl restart xrdp
echo "请使用ip:58390进行连接，用户名为：linuxbt  密码为abcd1234，如有遇到登陆后闪退重启即可解决"





