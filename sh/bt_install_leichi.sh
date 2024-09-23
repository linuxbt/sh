#!/bin/bash
# 安装docker和docker-compse
wget -qO- get.docker.com | bash
systemctl start docker
systemctl enable docker

# 安装雷池waf社区版
bash -c "$(curl -fsSLk https://waf-ce.chaitin.cn/release/latest/setup.sh)"

# 安装t1k相关支持组件
install_luarocks_and_t1k() {
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu 系列
        echo "正在 Debian/Ubuntu 上安装..."
        sudo apt-get update
        sudo apt-get install -y luarocks
    elif command -v yum >/dev/null 2>&1; then
        # Red Hat/CentOS 系列
        echo "正在 Red Hat/CentOS 上安装..."
        sudo yum install -y epel-release
        sudo yum install -y luarocks
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora
        echo "正在 Fedora 上安装..."
        sudo dnf install -y epel-release
        sudo dnf install -y luarocks
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        echo "正在 Arch Linux 上安装..."
        sudo pacman -S --noconfirm luarocks
    elif command -v apk >/dev/null 2>&1; then
        # Alpine Linux
        echo "正在 Alpine Linux 上安装..."
        sudo apk add luarocks
    else
        echo "未知的发行版,请手动安装 luarocks 和 lua-resty-t1k."
        exit 1
    fi

    # 使用 luarocks 安装 lua-resty-t1k
    echo "正在安装 lua-resty-t1k..."
    sudo luarocks install lua-resty-t1k
}

install_luarocks_and_t1k

# 设置t1k配置文件
FILE_PATH="/www/server/nginx/conf/nginx.conf"
CHECK_STRING='lua_package_path'
if ! grep -q "$CHECK_STRING" "$FILE_PATH"; then
    sed -i "/include[[:space:]]\+mime.types;/i \    lua_package_path '/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;;';\n    lua_package_cpath '/usr/lib64/lua/5.1/?.so;;';\n    include t1k.conf;" "$FILE_PATH"
fi
# 添加t1k.conf文件
cat >/www/server/nginx/conf/t1k.conf<<"EOF"
access_by_lua_block {
    local t1k = require "resty.t1k"

    local t = {
        mode = "block", -- block or monitor or off, default off
        host = "unix:/data/safeline/resources/detector/snserver.sock",
        port = 8000,
        connect_timeout = 1000,
        send_timeout = 1000,
        read_timeout = 1000,
        req_body_size = 1024,
        keepalive_size = 256,
        keepalive_timeout = 60000,
        remote_addr = "http_x_forwarded_for: 1",
    }

    local ok, err, _ = t1k.do_access(t, true)
    if not ok then
        ngx.log(ngx.ERR, err)
    end
}

header_filter_by_lua_block {
    local t1k = require "resty.t1k"
    t1k.do_header_filter()
}
EOF
# 重启nginx-openresty
/etc/init.d/nginx reload


# 输出雷池waf面板登陆信息
ip_address() {
ipv4_address=$(curl -s ipv4.ip.sb)
ipv6_address=$(curl -s --max-time 1 ipv6.ip.sb)
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

leichi_waf_on
