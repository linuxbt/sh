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
