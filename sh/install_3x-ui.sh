#!/bin/bash
# 定义字体颜色
huang='\033[33m'
bai='\033[0m'
lv='\033[0;32m'
lan='\033[0;34m'
hong='\033[31m'
kjlan='\033[96m'
hui='\e[37m'

send_stats() {
    echo -e
}

#定义ip和端口相关输出
warning() {
    echo -e "\033[33m[3x-ui] $*\033[0m"
}

command_exists() {
	command -v "$1" 2>&1
}

local_ips() {
    if [ -z `command_exists ip` ]; then
        ip_cmd="ip addr show"
    else
        ip_cmd="ifconfig -a"
    fi

    echo $($ip_cmd | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | awk '{print $2}')
}

show_ip() {
    #输出服务器ip和端口
    ips=`local_ips`
    for ip in $ips; do
    warning https://$ip:2053/
    done
}

# 检测依赖环境
check_docker() {
if ! command -v docker &> /dev/null; then
    echo "Docker未安装，正在安装..."
    bash <(curl -sSL https://get.docker.com) || bash <(curl -sSL https://raw.githubusercontent.com/linuxbt/sh/main/sh/install_docker.sh)
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "Docker已安装"
fi
}

# 输出用户信息
show_info() {
    echo "安装完成"
    echo "----------------------以下是您的3x-ui面板默认配置信息--------------------------------"
    show_ip
    echo "默认账号: admin"
    echo "默认密码: admin"
    echo "--------------端口，用户名密码，都是默认生成的，登录后请及时修改-------------"
}
# 安装3x-ui
install_3x-ui() {
    check_docker
    docker run -itd \
	-e XRAY_VMESS_AEAD_FORCED=false \
	-v $PWD/db/:/etc/x-ui/ \
	-v $PWD/cert/:/root/cert/ \
	--network=host \
	--restart=unless-stopped \
	--name 3x-ui \
	ghcr.io/mhsanaei/3x-ui:latest
}



# 定义3x-ui面板函数
x-ui_menu() {
    while true; do
      clear
      send_stats "运行3x-ui"
      echo -e "▶ ${kjlan}3x-ui科学上网多协议面板工具"
      echo "K脚本为你提供：各种linux科学上网一键脚本"
      echo -e "${huang}告别繁琐: 一键安装。"
      echo "------------------------"
      echo "1. 安装3x-ui 官方docker版"
      echo "2. 卸载3x-ui"
      echo "3. 重启3x-ui  "
      echo "4. 查看安装信息  "
      echo "5. 查看官方文档  "
      echo "------------------------"
      echo "6. 3x-ui 官方脚本（英文提示，需手动设置参数）"
      echo "0. 返回主菜单"
      echo -e "------------------------${bai}"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in

          1)
              clear
              send_stats "安装 3x-ui "
              install_3x-ui
              show_info
              sleep 15
              ;;

          2)
              clear
              send_stats "卸载 3x-ui "
              docker rm -f 3x-ui
              echo "3x-ui已卸载"
              sleep 5
              ;;

          3)
              clear
              send_stats "重启3x-ui "
              docker restart 3x-ui
              echo "3x-ui已重启"
              sleep 5
              ;;

          4)
              clear
              show_info
	      sleep 15
              ;;

          5)
              clear
              send_stats "x-ui 官方文档"
              echo "3x-ui官方文档：https://github.com/MHSanaei/3x-ui/blob/main/README.zh.md"
              sleep 10
              ;;


          6)
              clear
              send_stats "3x-ui官方bash版 "
              bash <(curl -sSL https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
              ;;


          0)
              break
              ;;

          *)
              echo "无效的输入!"
              sleep 3
              ;;
      esac

      read -p "按 Enter 返回菜单"  # 等待用户按 Enter 继续
    done
}


# 运行3x-ui调用
x-ui_menu
