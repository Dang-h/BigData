# Hadoop集群搭建

### 虚拟机准备（针对Vmware）

- 自定义安装
- 稍后安装操作系统

- 处理器（2核4线程）处理器核数：2 每个处理器内核数：2
- 内存：3G
- 网络类型：NAT
- I/O控制器：LSI Logic
- 磁盘类型：SCSI
- 磁盘：创建新虚拟磁盘
- 磁盘大小：40G（存储为单个文件）

### 安装Linux（CentOs6.8）

- 创建自定义布局

- 标准分区

  /boot 200M

  /swap 2G

  /	剩下

- 选择最小安装：Minimal

### 环境布置

- 检查是否联网：`ifconfig`查看inet是否获取到IP

- [通过脚本完成基本配置](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/deploy.sh)

  - 更新yum源
  - 配置vim
  - 优化xshell连接
  - 关闭防火墙
  - 更改hosts
  - 配置JAVA_HOME和HADOOP_HOME
  - 安装zsh和oh-my-zsh
  - 修改hostname
  - 修改IP
  
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

## 软件准备

- [JDK](https://download.oracle.com/otn/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/server-jre-8u144-linux-x64.tar.gz) ：jdk-8u144-linux-x64

- [Hadoop](https://archive.apache.org/dist/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz)：hadoop-2.7.2

- 重启

- 以hadoop用户登录

- 解压jdk和Hadoop到/opt/module文件夹

  `tar -zxvf jdk -C /opt/module`

  `tar -zxvf hadoop -C /opt/module`

- 更新Hadoop和jdk环境变量

  `source /etc/profile`

- 测试
  
  jdk配置成功
  
  ![jdk配置成功](https://github.com/Dang-h/BigData/blob/master/Hadoop/assets/jdk%E9%85%8D%E7%BD%AE%E6%88%90%E5%8A%9F.png)
  
  hadoop配置成功
  
  ![hadoop配置成功](https://github.com/Dang-h/BigData/blob/master/Hadoop/assets/hadoop%E9%85%8D%E7%BD%AE%E6%88%90%E5%8A%9F.png)
