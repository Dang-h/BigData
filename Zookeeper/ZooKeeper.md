# Zookeeper

<!-- TOC -->

- [Zookeeper](#zookeeper)
    - [几个题](#几个题)
    - [是什么](#是什么)
        - [概述](#概述)
        - [数据模型](#数据模型)
            - [Znode组成](#znode组成)
            - [节点类型](#节点类型)
            - [Stat结构](#stat结构)
    - [能做什么](#能做什么)
        - [统一命名服务](#统一命名服务)
        - [统一配置管理](#统一配置管理)
        - [统一集群管理](#统一集群管理)
        - [服务器动态上下线](#服务器动态上下线)
        - [软负载均衡](#软负载均衡)
    - [一些原理](#一些原理)
        - [监听器原理](#监听器原理)
            - [怎么监听](#怎么监听)
        - [选举机制](#选举机制)
            - [Znode节点状态](#znode节点状态)
            - [选举机制](#选举机制-1)

<!-- /TOC -->
---

[Zookeeper官网](https://zookeeper.apache.org/)

## 几个题

- 简述Zookeeper选举机制

- 简述Zookeeper监听原理

- Zookeeper常用命令

-----

## 是什么

### 概述

​	Zookeeper是一个针对大型应用提供高可用的数据管理、应用程序协调服务的分布式服务框架，基于对Paxos算法的实现，使该框架保证了分布式环境中数据的强一致性，提供的功能包括：配置维护、统一命名服务、状态同步服务、集群管理等

> ​	ZooKeeper: Because Coordinating Distributed Systems is a Zoo

### 数据模型

![数据模型](https://github.com/Dang-h/BigData/blob/master/Zookeeper/assets/%E6%95%B0%E6%8D%AE%E6%A8%A1%E5%9E%8B.png)

​	Zookeeper数据模型结构类似于Unix的文件系统，呈树型状，路径必须是绝对路径；每个节点称为Znode，一个节点默认能够存储1MB数据；

#### Znode组成

​	Znode兼具**文件**和**目录**两种特点，既像文件一样维护着数据、元信息、ACL(Access Control List访问控制列表)、时间戳等数据结构，邮箱目录一样可以作为路径的唯一标识。

​	Znode由三部分组成：

1. stat：状态信息，描述该Znode的版本、权限等信息
2. data：与该Znode关联的数据
3. children：该node下的子节点

#### 节点类型

1. 临时节点(Ephemeral Node)：声明周期依赖于创建它的会话。会话结束，临时节点被自动删除；**临时节点不允许拥有子节点**。
2. 永久节点(Persistent Node)：生命周期不依赖于会话，只有在客户端显式地执行删除才能被删除；

#### Stat结构

- cZxid：这是导致创建znode更改的事务ID。

- mZxid：这是最后修改znode更改的事务ID。

- pZxid：这是用于添加或删除子节点的znode更改的事务ID。

- ctime：表示从1970-01-01T00:00:00Z开始以毫秒为单位的znode创建时间。

- mtime：表示从1970-01-01T00:00:00Z开始以毫秒为单位的znode最近修改时间。

- dataVersion：表示对该znode的数据所做的更改次数。

- cversion：这表示对此znode的子节点进行的更改次数。

- aclVersion：表示对此znode的ACL进行更改的次数。

- ephemeralOwner：如果znode是ephemeral类型节点，则这是znode所有者的 session ID。 如果znode不是ephemeral节点，则该字段设置为零。

- dataLength：这是znode数据字段的长度。

- numChildren：这表示znode的子节点的数量。

## 能做什么

### 统一命名服务

![统一命名服务](https://github.com/Dang-h/BigData/blob/master/Zookeeper/assets/%E7%BB%9F%E4%B8%80%E5%91%BD%E5%90%8D%E6%9C%8D%E5%8A%A1.png)

### 统一配置管理

![统一配置管理](https://github.com/Dang-h/BigData/blob/master/Zookeeper/assets/%E7%BB%9F%E4%B8%80%E9%85%8D%E7%BD%AE%E7%AE%A1%E7%90%86.png)

### 统一集群管理

![统一集群管理](https://github.com/Dang-h/BigData/blob/master/Zookeeper/assets/%E7%BB%9F%E4%B8%80%E9%9B%86%E7%BE%A4%E7%AE%A1%E7%90%86.png)

### 服务器动态上下线

![服务器动态上下线](https://github.com/Dang-h/BigData/blob/master/Zookeeper/assets/%E6%9C%8D%E5%8A%A1%E5%99%A8%E5%8A%A8%E6%80%81%E4%B8%8A%E4%B8%8B%E7%BA%BF.png)

### 软负载均衡

![软负载均衡](https://github.com/Dang-h/BigData/blob/master/Zookeeper/assets/%E8%BD%AF%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1.png)

## 一些原理

### 监听器原理

![监听器原理](https://github.com/Dang-h/BigData/blob/master/Zookeeper/assets/%E7%9B%91%E5%90%AC%E5%99%A8%E5%8E%9F%E7%90%86.png)

#### 怎么监听

1. 客户端命令行操作

   ls path：使用ls命令来查看当前znode中所包含的内容

   ls2 path：查看当前节点数据并能看到更新次数等数据

   get path：查看节点的值

2. 调用Zookeeper的API

### 选举机制

​	采用**半数选举机制**，集群中半数以上的机器存活，集群可用。所以Zookeeper一般适合安装在**奇数台**服务器。

#### Znode节点状态

- Looking：寻找Leader状态，处于该状态需要进入选举流程
- Leading：领导者状态，该节点为Leader
- Following：跟随着状态，表示Leader已经被选举出来，当前节点状态为Follower
- Observer：观察者状态，该节点角色为Observer

#### 选举机制

![选举机制](https://github.com/Dang-h/BigData/blob/master/Zookeeper/assets/%E9%80%89%E4%B8%BE%E6%9C%BA%E5%88%B6.png)

1. **每个Server发出一次投票** ，初始，ZK1和ZK2都会将自己作为Leader进行投票，每次投票会包含有被推举服务器的**myid**和**zxid** ，使用（myid，zxid）表示；此时假设ZK1的投票为（1，0），ZK2为（2，0），然后将各自的投票信息发送给集群中其他机器

2. **接受来自各个服务器的投票**， 集群中每个服务器接收到投票后，首先会判断该投票的有效性（是否是本轮投票、是否来自Looking状态的服务器）

3. **处理投票**。将别人的投票和自己的投票进行对比，

   - 检查zxid。zxid较大的作为Leader
   - zxid相同，检查myid，myid大的作为Leader

   对于ZK1而言，它的投票时（1，0）；接收ZK2的投票为（2，0）；比较zxid，均为0；在比较myid，ZK2当选Leader，ZK1更新自己投票信息为（2，0），并将信息发送给其他机器

4. **统计投票**。每次投票后，服务器统计投票信息，判断是否已有**过半**机器接受了相同的投票信息。对于ZK1和ZK2，都统计出集群（3太服务器）中已有两台机器接受了（2，0）的投票信息，此时认定ZK2为整个集群的Leader

5. **改变服务器状态**。确定了集群Leader，每个服务器更新自己的状态，Flower更新为Flowing，Leader更新为Leading。ZK3启动时，发现已经Leader，不再选举，直接将状态从Looking改为Following





