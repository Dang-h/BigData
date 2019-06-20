#!/bin/sh

file1="/etc/sysconfig/network"
file2="/etc/sysconfig/network-scripts/ifcfg-eth0"
file4="/etc/udev/rules.d/70-persistent-net.rules"

 content="
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
IPADDR=127.0.0.1
PREFIX=24
GATEWAY=192.168.1.2
DNS1=192.168.1.2
NAME=eth0
"

echo "================用户名==================="
nl $file1
read -p "是否修改[yes/no]:" ys1
if [ "${ys1}" == "yes" ] || [ "${ys1}" == "y" ] 
then
    echo "================修改用户名==================="
    read -p "输入要修改的用户名: " NAME
    sed -i "s/^HOSTNAME.*$/HOSTNAME=$NAME/g" $file1
    echo "================修改完成==================="
    cat $file1
fi

echo ""

echo "================IP==================="
nl $file2
read -p "是否修改[yes/no]:" ys2
if [ "${ys2}" == "yes" ] || [ "${ys2}" == "y" ] 
then
    echo "$content" > $file2
    echo "================修改IP地址==================="   
    read -p "输入需要更改的IP: " IP 
    sed -i "s/^IPADDR.*$/IPADDR=$IP/g" $file2   
    echo "================修改完成==================="
    cat $file2
fi

echo ""

echo "================修改网卡脚本==================="
    nl $file4
    read -p "是否修改[yes/no]:" ys2
    if [ "${ys2}" == "yes" ] || [ "${ys2}" == "y" ] 
    then
        sed -i "/eth0/d" $file4
        sed -i "s/eth1/eth0/" $file4
        echo "================修改完成==================="
        cat $file4
    fi

echo "!!!!!!!需要重新启动!!!!!!!"
read -p "是否重启[yes/no]: " ys5
if [ "${ys5}" == "yes" ] || [  "${ys5}" == "y" ]
then
    reboot
fi
