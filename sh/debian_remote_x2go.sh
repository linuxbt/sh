#!/bin/bash

set -e

apt update -y && apt upgrade -y

# ===============================
# 安装桌面环境（XFCE）
# ===============================
DEBIAN_FRONTEND=noninteractive apt-get -y install \
  xfce4 xfce4-goodies \
  xorg dbus-x11 x11-xserver-utils

# ===============================
# 安装 X2Go Server
# ===============================
apt -y install x2goserver x2goserver-xsession

# ===============================
# 防火墙：放行 SSH（X2Go 使用）
# ===============================
# ufw allow from 104.28.0.0/16 to any port 22
# ufw reload
# ufw status numbered

# ===============================
# 创建远程桌面用户
# ===============================
USERNAME="linuxbt"
PASSWORD="abcd1234"

useradd -m -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
usermod -aG sudo "$USERNAME"

# ===============================
# 中文语言支持
# ===============================
apt -y install locales xfonts-intl-chinese fonts-wqy-microhei

echo "locales locales/default_environment_locale select zh_CN.UTF-8" | debconf-set-selections
sed -i 's/^# \(zh_CN.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
dpkg-reconfigure -f noninteractive locales
update-locale LANG=zh_CN.UTF-8

cat /etc/default/locale

# ===============================
# Firefox + 中文
# ===============================
apt -y install firefox-esr firefox-esr-l10n-zh-cn

# ===============================
# 中文输入法（X2Go 下推荐 fcitx）
# ===============================
apt -y install fcitx fcitx-googlepinyin

# ===============================
# 为 X2Go 指定默认会话为 XFCE
# ===============================
cat > /home/$USERNAME/.xsession <<EOF
xfce4-session
EOF

chown $USERNAME:$USERNAME /home/$USERNAME/.xsession
chmod +x /home/$USERNAME/.xsession

# ===============================
# 完成提示
# ===============================
echo "--------------------------"
echo "✅ X2Go 服务已安装完成"
echo ""
echo "📌 连接方式："
echo "服务器 IP + SSH 端口（22）"
echo ""
echo "📌 X2Go Client 设置："
echo "会话类型：XFCE"
echo ""
echo "用户名： linuxbt"
echo "密码： abcd1234"
echo ""
echo "⚠️ 登录后请立即修改密码"
echo "--------------------------"
