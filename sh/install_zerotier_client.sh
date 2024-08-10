#!/bin/bash
# zerotier
#1、在线安装zerotier
curl -s https://install.zerotier.com/ | sudo bash
#2、添加开机自启
systemctl enable zerotier-one.service
systemctl start zerotier-one.service
#3、启动zerotier-one.service
systemctl start zerotier-one.service
#4、加入网络
read -p "请输入您的zerotier网络id，如果没有请自行到my.zerotier.com去创建: " zerotier_network_id
zerotier-cli join $zerotier_network_id
# 输出用户信息
echo "安装完成"
echo "----------------------以下是您的candy网络相关配置信息--------------------------------"
echo "组网IP: ip a 自行查询下"
echo "--------------组网配置后，可以使用ping命令或其他nc命令测试网络延迟-------------"
