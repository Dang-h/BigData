# Hadoop



## Hadoop生态系统

[Hadoop Ecosystem参考](https://data-flair.training/blogs/hadoop-ecosystem/)

![HadoopEcosystem](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/HadoopEcosystem.png)

**精简一下**

![HadoopEcosystem2](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/HadoopEcosystem2.png)

**部分技术名词解释** 

- HDFS：(Hadoop Distributed File System)数据存储
- YARN：(Yet Another Resource Manager)Hadoop资源管理
- MapReduce：分布式运算编程框架
- Hive:数据仓库项目，它提供数据查询和分析
- Zookeeper：协调Hadoop生态系统中的各个服务；节省了同步、配置维护、分组和命名所需的时间
- Flume：一个帮助将结构化和半结构化数据导入HDFS的服务。
- Kafka：一种高吞吐量的分布式发布订阅消息系统
- Spark：当前最流行的开源大数据内存计算框架。可以基于Hadoop上存储的大数据进行计算。
- Sqoop：一个从外部资源导入数据到兼容的Hadoop生态系统组件，如HDFS、Hive、HBase等。
- Oozie：一个用于管理Hadoop作业的工作流调度程序系统。它支持Hadoop作业用于Map-Reduce、Pig、Hive和Sqoop。
- Hbase：一个构建在HDFS之上的NoSQL数据库

------

  ## Hadoop概述

  ### 	是什么
> ​	***“Hadoop is a technology to store massive datasets on a cluster of cheap machines in a distributed manner”***——*Doug Cutting and Mike Cafarella*

  ### 	什么用

- 存储大量的数据
- 处理不同格式的数据
- 高速生成数据

## [Hadoop入门几个题](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/%E5%87%A0%E4%B8%AA%E9%A2%98.md)

- 简单描述如何安装配置Apache的一个开源Hadoop

- Hadoop中需要哪些配置文件，作用是什么

- 正常工作额Hadoop集群中要分别启动哪些进程，它们的作用是什么

- 简述Hadoop的几个默认端口及其含义

-----

## [HDFS入门几个题](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/%E5%87%A0%E4%B8%AA%E9%A2%98.md)

- HDFS读写流程

- SecondaryNameNode工作机制

- NameNode和SecondaryNameNode区别与联系

- 服役新数据节点和退役旧数据节点步骤

  ### 是什么

  - HDFS
  - NameNode
  - DataNode
- 
  
  ### 什么用
  
  

------


## [MapReduce入门几个题](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/%E5%87%A0%E4%B8%AA%E9%A2%98.md)

- 谈谈Hadop序列化和反序列化以及自定义bean对象实现序列化

- FileInputFormat切片机制

- 自定义InputFormat流程

- 如何决定一个job的map和reduce数量

- MapTask的个数由什么决定

- MapTask工作机制

- ReduceTask工作机制

- 简述MapReduce有几种排序，执行几次，发生在什么阶段

- 简述Mapreduce中的shuffle阶段工作流程，如何优化shuffle阶段

- 简述MapReduce中combiner作用，一般使用场景，哪些情况不需要使用，以及和Reduce的区别

- 简述MapReduce工作原理，

- 如果没有定义partitioner，数据在被送到Reduce之前如何被分区

- MapReduce的TopN

- Hadoop任务能输出到多个目录中吗？如果可以怎么做？

- 简述Hadoop实现join的集中方法，每种方法的实现方法

- 简述Hadoop实现二级排序

- 简述Hadoop中RecordReader作用

  ### 是什么

  ### 什么用

------

## [YARN入门几个题](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/%E5%87%A0%E4%B8%AA%E9%A2%98.md)

- Hadoop1.X和Hadoop2.X架构的异同

- 为什么会产生YARN，它解决什么问题，优势是什么

- MapReduce作业提交全过程

- HDFS数据压缩算法

- Hadoop的调度器总结

- MapReduce推测执行算法及原理

  ### 是什么

  ### 什么用

  

----
## [Hadoop优化几个题](https://github.com/Dang-h/BigData/blob/master/Hadoop/data/%E5%87%A0%E4%B8%AA%E9%A2%98.md)
- MapReduce跑的慢的原因
- MapReduce优化方法
- HDFS小文件的优化方法
- MapReduce解决数据均衡的几个方法，如何确定分区号
- Hadoop中job和Task的区别

