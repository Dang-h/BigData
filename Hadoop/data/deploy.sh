#!/bin/sh

yum="/etc/yum.repos.d/CentOS-Base.repo"
xshell="/etc/ssh/sshd_config"
hostname="/etc/sysconfig/network"
ipconf="/etc/sysconfig/network-scripts/ifcfg-eth0"
hosts="/etc/hosts"
yum="/etc/yum.repos.d/CentOS-Base.repo"
eth="/etc/udev/rules.d/70-persistent-net.rules"
selinux="/etc/sysconfig/selinux"
profile="/etc/profile"

vimcon="
set mouse=nic
set number
set  ruler
set cursorline
set nocompatible
set showmode
set t_Co=256
set autoindent

set ts=4
set noexpandtab
%retab!

set expandtab
set softtabstop=2
set paste
set incsearch
set showmatch
set clipboard=unnamed
"

host="
192.168.1.101 hadooop101
192.168.1.102 hadooop102
192.168.1.103 hadooop103
192.168.1.104 hadooop104
192.168.1.105 hadooop105
192.168.1.106 hadooop106
"

ip="
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
path="
#JAVA_HOME
export JAVA_HOME=/opt/module/jdk1.8.0_144
export PATH=\$PATH:\$JAVA_HOME/bin

#HADOOP_HOME
export HADOOP_HOME=/opt/module/hadoop-2.7.2
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
"

yumfile6="
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-$releasever - Base
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#released updates
[updates]
name=CentOS-$releasever - Updates
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/centosplus/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/contrib/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=contrib
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
"

yumfile7="
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-$releasever - Base
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#released updates
[updates]
name=CentOS-$releasever - Updates
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/centosplus/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
"


read -p "是否新虚拟机[yes/no]" ys
echo "=============================="
if [ "${ys}" == "yes" ] || [ "${ys}" == "y" ]
then 
	echo "#########yum源###########"
	nl $yum
	read -p "是否需要更新yum源[yes/no]" ys
	if [ "${ys}" == "yes" ] || [ "${ys}" == "y" ]
	then
		yum install -y wget
		read -p "请选择系统:
				1 centOS6
				2 centOS7
				系统是[1/2]：" ch
		case $ch in 
			"1") 
				cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
				echo "$yumfile6" > $yum
				yum clean all
				yum makecache
				;;
			"2")
				yum install -y wget
				cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
				echo "$yumfile7" > $yum
				yum clean all
				yum makecache
				;;
		esac
		echo "+++++++++完成+++++++++"
		nl $yum
		echo ""
	fi


	echo "#########vim配置#########"
	nl ./vimrc
	read -p "是否添加vim配置[yes/no]" ys
	if [ "${ys}" == "yes" ] || [ "${ys}" == "y" ]
	then 
		echo "$vimcon" > .vimrc
		source .vimrc
		echo "+++++++++完成+++++++++"
		nl .vimrc
		echo ""
	fi

	echo "########优化Xshell连接速度###"
	nl $xshell | grep UseDNS
	read -p "是否优化[yes/no]" ys
	if [ "${ys}" == "yes" ] || [ "${ys}" == "y" ]
	then 
		sed -i "s/^#UseDNS.*$/UseDNS no/g" $xshell
		echo "+++++++++完成+++++++++"
		nl $xshell | grep UseDNS
		echo ""
	fi


	echo "########防火墙##############"
	chkconfig iptables --list
	read -p "是否修改[yes/no]:" ys1
	if [ "${ys1}" == "yes" ] || [ "${ys1}" == "y" ] 
	then
	   
        service iptables stop
        chkconfig iptables off
        echo "+++++++++完成+++++++++"
        chkconfig iptables --list
		echo ""
	fi

	echo "########hosts##############"
	nl $hosts
	read -p "是否修改[yes/no]:" ys1
	if [ "${ys1}" == "yes" ] || [ "${ys1}" == "y" ] 
	then
		echo "$host" > $hosts
		echo "+++++++++完成+++++++++"
		nl $hosts
		echo ""
	fi

	echo "########Java&Hadoop路径##############"
	nl $profile | grep JAVA_HOME
	nl $profile | grep HADOOP_HOME
	read -p "是否修改[yes/no]:" ys1
	if [ "${ys1}" == "yes" ] || [ "${ys1}" == "y" ] 
	then
		echo "$path" >> $profile
		source $profile
		echo "+++++++++完成+++++++++"
		nl $profile | grep _HOME
		echo ""
	fi

	echo "=============安装zsh============"
	read -p "是否安装[yes/no]" ys
	if [ "${ys}" == "yes" ] || [ "${ys}" == "y" ]
	then
		yum install -y git
		yum install -y zsh
		chsh -s /bin/zsh
		echo "zshDone"
	fi

	echo "=============安装oh-my-zsh============"
	read -p "是否安装[yes/no]" ys
	if [ "${ys}" == "yes" ] || [ "${ys}" == "y" ]
	then
		sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
	fi
	read -p "是否安装插件[yes/no]" ys
	if [ "${ys}" == "yes" ] || [ "${ys}" == "y" ]
	then
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	fi
fi


echo "==============用户名、IP、网卡脚本修改==============" 
read -p "是否需要修改[yes/no]" ys
if [ "${ys}" == "yes" ] || [ "${ys}" == "y" ]
then

	echo "==================用户名=================="
	nl $hostname
	read -p "是否修改[yes/no]:" ys1
	if [ "${ys1}" == "yes" ] || [ "${ys1}" == "y" ] 
	then
	    read -p "输入要修改的用户名: " NAME
	    sed -i "s/^HOSTNAME.*$/HOSTNAME=$NAME/g" $hostname
	    echo "+++++++++完成+++++++++"
	    cat $hostname
	fi
	echo "====================IP==================="
	nl $ipconf
	read -p "是否修改[yes/no]:" ys2
	if [ "${ys2}" == "yes" ] || [ "${ys2}" == "y" ] 
	then
	    echo "$ip" > $ipconf
	    read -p "输入需要更改的IP: " IP
	    sed -i "s/^IPADDR.*$/IPADDR=$IP/g" $ipconf
	    echo "+++++++++完成+++++++++"
	    nl $ipconf
	fi

	echo "====================网卡脚本==================="
	read -p "是否修改[yes/no]:" ys4
	if [ "${ys4}" == "yes" ] || [  "${ys4}" == "y" ]
	then
    	nl $eth
    	sed -i "/eth0/d" $eth
    	sed -i "s/eth1/eth0/" $eth
    	 echo "+++++++++完成+++++++++"
    	nl $eth
	fi

	echo "!!!!!!!需要重新启动!!!!!!!"
	read -p "是否重启[yes/no]: " ys5
	if [ "${ys5}" == "yes" ] || [  "${ys5}" == "y" ]
	then
	    reboot
	fi
fi