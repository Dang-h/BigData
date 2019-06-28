# 集群搭建

<!-- TOC -->

- [集群搭建](#集群搭建)
    - [系统准备（针对Vmware）](#系统准备针对vmware)
    - [安装Linux（CentOs6.8）](#安装linuxcentos68)
    - [环境布置](#环境布置)
    - [软件准备](#软件准备)
    - [Hadoop 集群搭建](#hadoop-集群搭建)
        - [虚拟机准备](#虚拟机准备)

<!-- /TOC -->
---

## 系统准备（针对Vmware）

- 自定义安装
- 稍后安装操作系统

- 处理器（2核4线程）核数：2；每个处理器内核数：2
- 内存：3G
- 网络类型：NAT
- I/O控制器：LSI Logic
- 磁盘类型：SCSI
- 磁盘：创建新虚拟磁盘
- 磁盘大小：40G（存储为单个文件）

## 安装Linux（CentOs6.8）

- 创建自定义布局

- 标准分区

  /boot 200M

  swap 2G

  ![1561552597540](G:\Git_Repository\BigData\Hadoop\assets\1561552597540.png)

  /	剩下

  ![1561552628903](G:\Git_Repository\BigData\Hadoop\assets\1561552628903.png)

- 选择最小安装：Minimal

  ![1561552712936](G:\Git_Repository\BigData\Hadoop\assets\1561552712936.png)

## 环境布置

- 检查是否联网：`ifconfig`查看inet是否获取到IP

- 通过[部署脚本](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/deploy.sh)完成基本配置

  - 更新yum源
  
    > 1. 用的是[清华镜像源](https://mirror.tuna.tsinghua.edu.cn/help/centos/)
    >
    > 2. 备份CentOS-Base.repo
    >
    >       cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
    >
    > 3. 修改CentOS-Base.repo
    >
    >       拷贝对应系统版本到CentOS-Base.repo
  
  - 配置vim
  
  - 优化xshell连接
  
  - 关闭防火墙
  
  - 更改hosts
  
  - 配置JAVA_HOME和HADOOP_HOME
  
  - 安装zsh和oh-my-zsh
  
- 通过[虚拟机配置脚本](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/modify.sh)完成网络配置

  - 修改hostname
  - 修改IP
  - 修改网卡脚本

- 创建一般用户hadoop并赋予sudo权限

  ```
  useradd hadoop
  passwd hadoop
  vim /etc/sudoers
  	在root ALL=(ALL) ALL 一行后添加
  	hadoop ALL=(ALL) NOPASSWD:ALL
  ```

- 在/opt目录下创建module和software文件夹，并给hadoop赋予所有权

  ```
  mkdir /opt/module /opt/software
  chown hadoop:hadoop /opt/module /opt/software
  ```
  
- 重启，通过[xshell](https://www.lanzous.com/i1t4rne)登录hadoop用户

- 安装[JDK](https://www.oracle.com/technetwork/java/javase/downloads/java-archive-javase8-2177648.html):

  解压jdk-8u144-linux-x64.tar.gz到目录/opt/module/

  ​	`tar -zxvf jdk-8u144-linux-x64.tar.gz -C /opt/module/`

## 软件准备

1. [JDK](https://www.oracle.com/technetwork/java/javase/downloads/java-archive-javase8-2177648.html) ：jdk-8u144-linux-x64
2. [Hadoop](https://hadoop.apache.org/release/2.7.2.html)：hadoop-2.7.2
3. [Zookeeper](https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz)：zookeeper-3.4.14

## 脚本准备

1. [部署脚本](deploy)：deploy
2. [克隆虚拟机配置脚本](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/modify.sh):modify
3. [集群分发脚本](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/xsync.sh):xsync
4. [集群进程查看脚本](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/jpsall):jpsall
5. [zookeeper群起脚本]()：zkstartall
6. [zookeeper状态查询脚本]()：zkstatus
7. [zookeeper群关脚本]()：zkstopall

## Hadoop 集群搭建

### 虚拟机准备

1. 克隆两台虚拟机，通过[脚本](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/modify.sh)更改hostname、IP、网卡脚本

2. 准备集群[分发脚本](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/xsync.sh)

   ```
   chmod +x xsyc	# 添加执行权限
   sudo cp xsync /bin	#让脚本全局可用
   sudo cp xsync /usr/local/bin
   ```

3. 准备集群[进程查看脚本](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/jpsall)

4. 配置ssh免密登录

   ```bash
   # hadoop @ hadoop101 in ~ [19:02:34] C:255
   $ ssh-keygen -t rsa (敲三次回车)
   # 发送密码到本机
   # hadoop @ hadoop101 in ~ [19:03:18] 
   $ ssh-copy-id hadoop101 （yes/输入一次密码）
   
   # 分别ssh登陆一下所有虚拟机
   ssh hadoop102
   exit
   ssh hadoop103
   exit
   
   # 把/home/hadoop/.ssh 文件夹发送到集群所有服务器
   # hadoop @ hadoop101 in ~ [19:16:54] C:1
   $ xsync /home/hadoop/.ssh/
   ```

### 集群规划

|      | hadoop101           | hadoop102                     | hadoop103                    |
| :--: | :------------------ | :---------------------------- | :--------------------------- |
| HDFS | NameNode   DataNode | DataNode                      | SecondaryNameNode   DataNode |
| YARN | NodeManager         | ResourceManager   NodeManager | NodeManager                  |

1. 修改集群配置文件（[官方配置文档](https://hadoop.apache.org/docs/r2.7.2/hadoop-project-dist/hadoop-common/ClusterSetup.html)）

```xml
# 进入目录/opt/module/hadoop-2.7.2/etc/hadoop
1. 修改配置文件（添加以下内容）
	1） core-site.xml
		<!-- 指定HDFS中NameNode的地址 -->
		<property>
			<name>fs.defaultFS</name>
      		<value>hdfs://hadoop101:9000</value>
		</property>

		<!-- 指定Hadoop运行时产生文件的存储目录 -->
		<property>
			<name>hadoop.tmp.dir</name>
			<value>/opt/module/hadoop-2.7.2/data/tmp</value>
		</property>
	2） hadoop-env.sh
		export JAVA_HOME=/opt/module/jdk1.8.0_144
	3） hdfs-site.xml
		<!-- 指定副本数 -->
		<property>
			<name>dfs.replication</name>
			<value>3</value>
		</property>

		<!-- 指定Hadoop辅助名称节点主机配置 -->
		<property>
      		<name>dfs.namenode.secondary.http-address</name>
      		<value>hadoop103:50090</value>
		</property>
	4） yarn-env.sh
		export JAVA_HOME=/opt/module/jdk1.8.0_144
	5） yarn-site.xml
		<!-- Reducer获取数据的方式 -->
		<property>
			<name>yarn.nodemanager.aux-services</name>
			<value>mapreduce_shuffle</value>
		</property>

		<!-- 指定YARN的ResourceManager的地址 -->
		<property>
			<name>yarn.resourcemanager.hostname</name>
			<value>hadoop102</value>
		</property>
	6） mapred-env.sh
		export JAVA_HOME=/opt/module/jdk1.8.0_144
	7） cp mapred-site.xml.template mapred-site.xml && vim mapred-site.xml
		<!-- 指定MR运行在Yarn上 -->
		<property>
			<name>mapreduce.framework.name</name>
			<value>yarn</value>
		</property>
	8） 配置slaves
		hadoop101
		hadoop102
		hadoop103

2. 分发配置文件
	# hadoop @ hadoop101 in /opt/module/hadoop-2.7.2/etc [19:42:03] 
	$ xsync hadoop
```

### 集群操作

1. 启动集群

   ```
   1. 第一次启动，格式化NameNode
   	hdfs namenode -format
   	成功提示：
   	INFO common.Storage: Storage directory /opt/module/hadoop-2.7.2/data/tmp/dfs/name has been successfully formatted.
   2. 启动HDFS(在hadoop101)
   	satrt-dfs.sh
   	成功提示：
   	# hadoop @ hadoop101 in /opt/module/hadoop-2.7.2 [19:59:09] 
   	$ jpsall
   	======================= hadoop101 =============================
   	3619 NameNode
   	3742 DataNode
   	======================= hadoop102 =============================
   	2175 DataNode
   	======================= hadoop103 =============================
   	1888 SecondaryNameNode
   	1821 DataNode
   3. 启动YARN（在hadoop102）
   	start-yarn.sh
   	成功提示：
   	# hadoop @ hadoop101 in /opt/module/hadoop-2.7.2 [19:59:15] 
   	$ jpsall
   	======================= hadoop101 =============================
   	3619 NameNode
   	4042 NodeManager
   	3742 DataNode
   	======================= hadoop102 =============================
   	2323 ResourceManager
   	2421 NodeManager
   	2175 DataNode
   	======================= hadoop103 =============================
   	1888 SecondaryNameNode
   	2019 NodeManager
   	1821 DataNode
   ```

2. 停止集群

   ```
   1. 停止HDFS
   	stop-dfs.sh
   2. 停止YARN
   	stop-yarn.sh
   ```

3. Web端查看集群

   ```
   1. NameNode
   	http://hadoop101:50070
   2. YARN
   	http://hadoop102:8088
   3. Secondary NameNode
   	http://hadoop103:50090/status.html
   ```

4. 集群时间同步

   ```bash
   1. 切换到root用户
   	su
   2.	ntp和ntpdate安装
   	yum install -y ntp
   3. 配置集群时间服务器（hadoop101）
   	1）手动联网校时 
   		a 查看ntpd服务
   			service ntpd status
   		b 关闭ntpd服务
   			service ntpd stop
   		c 同步时间
   			ntpdate ntp1.aliyun.com
   	2) 修改ntp配置文件
   		sudo vim /etc/ntp.conf
   		a 授权192.168.1.0-192.168.1.255网段上的所有机器可以从这台机器上查询和同步时间
   			restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap
   		b 集群是在一个封闭的局域网内，可以屏蔽掉默认的server:(屏蔽掉以后,集群内部时间一致)
   		c 将hadoop101的本地时钟作为时间供给源，即便它失去网络连接，它也可以继续为网络提供服务;
   			server 127.127.1.0
   			fudge 127.127.1.0 stratum 10
   	3） 硬件时间与系统时间同步
   		vim /etc/sysconfig/ntpd
   		增加内容如下
   		SYNC_HWCLOCK=yes
   	4） 重启ntpd服务
   		service ntpd start
   	5） 设置ntpd服务开机启动
   		chkconfig ntpd on
   4. salve时间配置
   	1） 设置时间服务器hadoop101同步频率 10min/次
   		crontab -e
   		输入内容：
   			# 与时间服务器hadoop104同步频率 10min/次
   			*/10 * * * * /sbin/ntpdate hadoop101
   			# (30min/次) 将系统时间同步给硬件
   			*/30 * * * * /sbin/hwclock -w
   	2） 刷新crontab服务
   		service crond restart
   ```

## Zookeeper

 1. 集群规划

    在101、102、103上部署Zookeeper

2. 安装

    安装包准备：[zookeeper-3.4.14](https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz)

    ```bash
    1. 解压zookeeper-3.4.14到目录/opt/module
    	tar -zxvf zookeeper-3.4.14.tar.gz -C /opt/module/
    2. 同步/opt/module/zookeeper-3.4.14目录内容到hadoop102、hadoop103
    	xsync zookeeper-3.4.10/
    ```

3. 配置服务器编号myid

    ```
    1. 在/opt/module/zookeeper-3.4.14/这个目录下创建zkData
    	mkdir zkData 
    2. 在/opt/module/zookeeper-3.4.14/这个目录下创建myid文件
    	vim myid
    	输入内容：
    	101
    3. 分发zkData到hadoop102、hadoop103.并更改myid为各自的id
    ```

4. 配置zoo.cfg
	
	```
	1. 重命名/opt/module/zookeeper-3.4.10/conf这个目录下的zoo_sample.cfg为zoo.cfg
		cp zoo_sample.cfg zoo.cfg
	2. 配置zoo.cfg
		vim zoo.cfg
		输入内容：
		dataDir=/opt/module/zookeeper-3.4.10/zkData
		#######################cluster##########################
	    server.101=hadoop101:2888:3888
	    server.102=hadoop102:2888:3888
	    server.103=hadoop103:2888:3888
	3. 分发配置文件
		xsync zoo.cfg
	```
	
5. 集群操作
	
	1. 启动
	
	   每台机器逐步启动
	
	   `/opt/module/zookeeper-3.4.14/bin/zkServer.sh start`
	
	   **[群起脚本](zkstartall)**
	
	2. 查看状态
	
	   每台机器逐台查询
	
	   `/opt/module/zookeeper-3.4.14/bin/zkServer.sh status`
	
	   **[群查脚本](zkstatus)**
	
	3. 关闭👉[脚本](zkstopall)
	
	4. 客户端命令行操作
	
	   | 命令基本语法      | 功能描述                                               | 示例                 |
	   | ----------------- | ------------------------------------------------------ | -------------------- |
	   | help              | 显示所有操作命令                                       |                      |
	   | ls path   [watch] | 使用 ls 命令来查看当前znode中所包含的内容              | ls /                 |
	   | ls2 path [watch]  | 查看当前节点数据并能看到更新次数等数据                 | ls2 /                |
	   | create            | 普通创建   -s  含有序列   -e  临时（重启或者超时消失） | create -e /dir "tmp" |
	   | get path [watch]  | 获得节点的值                                           | get /dir tmp         |
	   | set               | 设置节点的具体值                                       | set /dir "modify"    |
	   | stat              | 查看节点状态                                           | stat /dir            |
	   | delete            | 删除节点                                               | delete /dir/dir1     |
	   | rmr               | 递归删除节点                                           | rmr /dit             |
	
	## Sqoop
	
	1. [下载](https://mirrors.tuna.tsinghua.edu.cn/apache/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz)并解压到指定目录
	
	   `$ tar -zxvf sqoop-1.4.7.bin__hadoop-2.0.4-alpha.tar.gz -C /opt/module/`
	
	2. 修改配置文件
	
	   ```
	   1. 重命名配置文件
	   	$ cp sqoop-env-template.sh sqoop-env.sh
	   2. 修改配置文件
	   	vim sqoop-env.sh
	   	export HADOOP_COMMON_HOME=/opt/module/hadoop-2.7.2
	       export HADOOP_MAPRED_HOME=/opt/module/hadoop-2.7.2
	       export HIVE_HOME=/opt/module/hive
	       export ZOOKEEPER_HOME=/opt/module/zookeeper-3.4.10
	       export ZOOCFGDIR=/opt/module/zookeeper-3.4.10/conf
	       export HBASE_HOME=/opt/module/hbase
	   ```
	
	3. 拷贝[JDBC驱动](https://dev.mysql.com/downloads/file/?id=480090)
	
	   `$ cp mysql-connector-java-5.1.47-bin.jar /opt/module/sqoop-1.4.6.bin__hadoop-2.0.4-alpha/lib/`
	
	4. 验证Sqoop
	
	   `bin/sqoop help`
	
	   > 出现一些Warning警告（警告信息已省略），并伴随着帮助命令的输出：
	   >
	   > Available commands:
	   >
	   >   codegen            Generate code to interact with database records
	   >
	   >   create-hive-table     Import a table definition into Hive
	   >
	   >   eval               Evaluate a SQL statement and display the results
	   >
	   >   export             Export an HDFS directory to a database table
	   >
	   >   help               List available commands
	   >
	   >   import             Import a table from a database to HDFS
	   >
	   >   import-all-tables     Import tables from a database to HDFS
	   >
	   >   import-mainframe    Import datasets from a mainframe server to HDFS
	   >
	   >   job                Work with saved jobs
	   >
	   >   list-databases        List available databases on a server
	   >
	   >   list-tables           List available tables in a database
	   >
	   >   merge              Merge results of incremental imports
	   >
	   >   metastore           Run a standalone Sqoop metastore
	   >
	   >   version            Display version information
	
	5. 测试Sqoop连接数据库
	
	   `$ bin/sqoop list-databases --connect jdbc:mysql://hadoop101:3306/ --username root --password mysql`
	
	   > 出现如下输出：
	   >
	   > information_schema
	   >
	   > metastore
	   >
	   > mysql
	   >
	   > oozie
	   >
	   > performance_schema
	
	## Oozie
	
	1. 部署Hadoop（CDH版本）
	   1. 修改Hadoop配置文件
	   2. 启动Hadoop集群
	2. 部署Oozie
	   1. 

