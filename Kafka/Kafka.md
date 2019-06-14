# Kafka

**[Kafka官网](<http://kafka.apache.org/>)**

---
<!-- TOC -->

- [Kafka](#kafka)
    - [概述](#概述)
        - [什么是Kafka](#什么是kafka)
        - [特点](#特点)
        - [Kafka架构](#kafka架构)
    - [Kafka工作流程](#kafka工作流程)
        - [Kafka生产者](#kafka生产者)
            - [分区原因](#分区原因)
            - [分区原则](#分区原则)
    - [Kafka消费者](#kafka消费者)
    - [Kafka集群部署](#kafka集群部署)
    - [Kafka API](#kafka-api)

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

  ![基础架构](G:\Git_Repository\BigData\Kafka\assets\1560510625458.png)


  ![多个Partition](G:\Git_Repository\BigData\Kafka\assets\1560510977052.png)

  > ​	**为了提高可用性，为每个partition增加若干个副本**，类似NameNode HA

  ![高可用](G:\Git_Repository\BigData\Kafka\assets\1560511457469.png)

  

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

![Kafka工作流程](G:\Git_Repository\BigData\Kafka\assets\1560516904687.png)

```
1. Kafka中消息是以topic进行分类，生产者生产消息，消费者消费消息，都是面向topic。
2. topic是逻辑上的概念，而partition是物理上的概念，每个partition对应于一个log文件，该log文件中存储的	就是producer生产的数据。Producer生产的数据会被追加到该log文件末端，且每条数据都有自己的offset(类似于	 书签🔖)。消费者组中的每个消费者，都会实时记录自己消费到了哪个offset(默认50个分区)，以便出错恢复时，从   上次的位置继续消费。
```

------

### Kafka生产者

#### 分区原因

- 方便在集群中拓展
- 可以提高并发

#### 分区原则

- 指明partition情况下，直接指明值
- 没指明partition值但有key，将key的hash值与topic的partition数值取余

## Kafka消费者



## Kafka集群部署

**[👉快速部署](<http://kafka.apache.org/quickstart>)**

## Kafka API

