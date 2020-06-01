# [Kafka](http://kafka.apache.org/)

<!-- TOC -->

- [Kafka](#kafka)
    - [概述](#概述)
        - [什么是Kafka](#什么是kafka)
        - [特点](#特点)
        - [Kafka架构](#kafka架构)
    - [Kafka工作流程](#kafka工作流程)
        - [Kafka生产者](#kafka生产者)
            - [分区原因](#分区原因)
            - [分区策略](#分区策略)
    - [Kafka消费者](#kafka消费者)
    - [Kafka集群部署](#kafka集群部署)
    - [Kafka API](#kafka-api)
        - [Producer API](#producer-api)
            - [消息发送流程](#消息发送流程)
            - [异步发送API](#异步发送api)
            - [同步发送API](#同步发送api)
        - [Customer API](#customer-api)
            - [自动提交offset](#自动提交offset)
            - [手动提交offset](#手动提交offset)
            - [自定义存储offset](#自定义存储offset)
        - [自定义Intercepter](#自定义intercepter)
    - [Kafka对接Flume](#kafka对接flume)

<!-- /TOC -->
---
## 概述

### 什么是Kafka

分布式的基于发布/订阅模式的**消息队列**，应用于大数据**实时**处理领域，多用于数据的实时传输。

> 消息队列：是一种进程间通信或同一进程的不同线程间的通信方式
>
> 应用场景：两系统间通信，两个线程之间的通信等（应用耦合、异步处理、流量削锋）
>
> 两种模式：
>
> ​	点对点（一对一）：消费者主动拉去数据，消息消费完删除
>
> ​	发布/订阅（一对多）：客户端主动推送数据，消息会持久化保存到本地，保存一段时间

### 特点

- 同时为发布和订阅提供高吞吐量。
- 可进行持久化操作。将消息持久化到磁盘，因此可用于批量消费，例如ETL，以及实时应用程序。通过将数据持久化到硬盘以及replication防止数据丢失。
- 分布式系统，易于向外扩展。所有的producer、broker和consumer都会有多个，均为分布式的。无需停机即可扩展机器。
- 消息被处理的状态是在consumer端维护，而不是由server端维护。当失败时能自动平衡。
- 支持online和offline的场景。

### Kafka架构

- 基础架构

  ![基础架构](assets/%E5%9F%BA%E7%A1%80%E6%9E%B6%E6%9E%84.png)


  ![多个Partition](assets/%E5%A4%9A%E4%B8%AApartition.png)

  > ​	**为了提高可用性，为每个partition增加若干个副本**，类似NameNode HA

  ![高可用](assets/%E9%AB%98%E5%8F%AF%E7%94%A8.png)

  

- 简介

  Producer：消息生产者，向Kafka broker发送消息的客户端

  Consumer：消息消费者，向Kafka Broker 拉取消息

  Consumer Group：消费者组，**一个partition只能被一个组中的一个customer消费**；逻辑上的一个订阅者

  Broker：一台Kafka服务器就是一个Broker，可容纳多个Topic

  Topic：一个队列，类似于Flume中的Channel；消息保存时根据topic进行分类

  Partition：可以解为一个大的Topic；一个Topic可以分为多个partition，每个partition是一个有序队列

  Replica：副本，为了在某个节点故障时数据不丢失，继续维持Kafka工作

  Leader：每个分区多个副本中的主

  Follower：每个分区多个副本中的从，实时从leader中同步数据，保持和leader数据的同步。leader发生故障时，某个follower会成为新的follower


## Kafka工作流程

![Kafka工作流程](assets/Kafka%E5%B7%A5%E4%BD%9C%E6%B5%81%E7%A8%8B.png)

```
1. Kafka中消息是以topic进行分类，生产者生产消息，消费者消费消息，都是面向topic。
2. topic是逻辑上的概念，而partition是物理上的概念，每个partition对应于一个log文件，
    该log文件中存储的就是producer生产的数据。Producer生产的数据会被追加到该log文件末端，
    且每条数据都有自己的offset(类似于书签🔖)。消费者组中的每个消费者，都会实时记录自己
    消费到了哪个offset(默认50个分区)，以便出错恢复时，从上次的位置继续消费。

```

------

### Kafka生产者

#### 分区原因

- 方便在集群中拓展
- 可以提高并发

#### 分区策略
> 将Producer发送的数据封装成一个ProducerRecord对象
- 直接指明partition的值
- 没指明partition值，有key；将key的hash值与topic的partition数值取余
- 没有partition的值，没有 key的值；第一次调用时随机生成一个整数（后面每次调用在这个整数上自增），将这个值与 topic 可用的 partition 总数取余得到 partition 值，也就是常说的 `round-robin` 算法。
## Kafka消费者

## Kafka集群部署

**[👉快速部署](<http://kafka.apache.org/quickstart>)**

[下载Kafka](https://kafka.apache.org/downloads)-kafka_2.11-0.11.0.0.tgz

> ​	2.11时Scala的版本号，0.11.0.0时Kafka版本号

解压到指定目录，创建`log`文件夹用于运行日志存放，修改配置文件`server.properties`

```
#broker 的全局唯一编号，不能重复
broker.id=0
#可删除 topic
delete.topic.enable=true
#处理网络请求的线程数量
num.network.threads=3
#用来处理磁盘 IO 的线程数
num.io.threads=8
#发送socket的缓冲区大小
socket.send.buffer.bytes=102400
#接收socket的缓冲区大小
socket.receive.buffer.bytes=102400
#请求socket的缓冲区大小
socket.request.max.bytes=104857600
#kafka 运行日志存放的路径
log.dirs=/opt/module/kafka/logs
#topic 在当前 broker 上的分区个数
num.partitions=1
#用来恢复和清理 data 下数据的线程数量
num.recovery.threads.per.data.dir=1
#segment 文件保留的最长时间，超时将被删除（单位：小时）
log.retention.hours=168
#配置连接 Zookeeper 集群地址
zookeeper.connect=hadoop102:2181,hadoop103:2181,hadoop104:2181
```

分发安装完的目录到集群及其，并修改`server.properties`中的`broker.id` (不能重复)

## Kafka API

> ​	导入依赖：
>
> ````xml
> <dependency>
> 	<groupId>org.apache.kafka</groupId>
> 	<artifactId>kafka-clients</artifactId>
> 	<version>0.11.0.0</version>
> </dependency>
> ````

### Producer API

#### 消息发送流程

1. 异步发送，涉及三个线程——main线程和send线程和RecordAccumulator

2. main线程将消息发给RecordAccumulator，Sender从RecordAccumulator不断拉取数据发送到Kafka的Broker

   ![消息发送流程](assets/%E6%B6%88%E6%81%AF%E5%8F%91%E9%80%81%E6%B5%81%E7%A8%8B.png)

#### 异步发送API

#### 同步发送API

### Customer API

#### 自动提交offset

#### 手动提交offset

#### 自定义存储offset

### 自定义Intercepter

## Kafka对接Flume



