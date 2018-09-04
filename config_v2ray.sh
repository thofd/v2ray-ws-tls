#!/bin/bash

systemctl stop firewalld
systemctl disable firewalld

#安装v2
bash <(curl -L -s https://install.direct/go.sh)

#生成随机整数，用来生成端口
rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
    echo $(($num%$max+$min))  
}
yum install -y wget
#获取本机外网ip
serverip=$(curl icanhazip.com)

#进入v2配置文件目录
cd /etc/v2ray/

#删除原有v2配置文件
rm -f config.json

#下载kcp+tcp配置文件，kcp（srtp混淆），tcp（http混淆）
wget https://raw.githubusercontent.com/yobabyshark/prov-ws/master/config.json

#生成并替换uuid，kcp、tcp各一个
kcpuuid=$(cat /proc/sys/kernel/random/uuid)
sed -i "s/aaaa/$kcpuuid/;" config.json
newpath=$(cat /dev/urandom | head -1 | md5sum | head -c 8)
sed -i "s/mypath/$newpath/;" config.json

#生成并修改端口
port=$(rand 10000 30000)
sed -i "s/11234/$port/" config.json

#重启prov
systemctl restart v2ray.service

#输出配置到文件
cat > /etc/v2ray/myconfig.json<<-EOF
{
===========KCP配置=============
地址：${serverip}
端口：${port}
uuid：${kcpuuid}
额外id：64
加密方式：aes-128-gcm
传输协议：ws
别名：myws
路径：${newpath}
底层传输：tls
}
EOF


#输出配置信息
clear
echo
echo "安装已经完成，开启了kcp和tcp两种模式，客户端可任意选择对应的配置"
echo 
echo "===========KCP配置============="
echo "地址：${serverip}"
echo "端口：${port}"
echo "uuid：${kcpuuid}"
echo "额外id：64"
echo "加密方式：aes-128-gcm"
echo "传输协议：ws"
echo "别名：myws"
echo "路径：${newpath}"
echo "底层传输：tls"
echo 



