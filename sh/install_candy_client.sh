#!/bin/bash
# 检查是否安装Docker
if ! command -v docker &> /dev/null; then
    echo "Docker未安装，正在安装..."
    bash <(curl -sSL https://get.docker.com) || bash <(curl -sSL https://raw.githubusercontent.com/linuxbt/sh/main/sh/install_docker.sh)
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "Docker已安装"
fi

mkdir -p /var/lib/candy  && docker run --detach --restart=always --privileged=true --net=host --volume /var/lib/candy:/var/lib/candy docker.io/lanthora/candy:latest
systemctl enable --now candy

candy_ip=ip a
# 输出用户信息
echo "安装完成"
echo "----------------------以下是您的candy网络相关配置信息--------------------------------"
echo "组网IP: ip a 自行查询下"
echo "--------------组网配置后，可以使用ping命令或其他nc命令测试网络延迟-------------"
