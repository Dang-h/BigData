# Flume

## 几个题

- Fume有哪些组件，分别有什么用
- 如何实现Flume数据传输的监控
- Flume事务机制
- 

---
## Flume简介
[Flume官方地址](http://flume.apache.org/)

[Flume文档地址](http://flume.apache.org/FlumeUserGuide.html)

* ## Flume定义
     分布式的海量**日志采集、聚合和传输**的系统。基于流式架构，灵活简单。
     

![Flume作用](https://github.com/Dang-h/BigData/blob/master/Flume/data/Flume%E4%BD%9C%E7%94%A8.png)

* ## Flume基础架构
  

![Flume基础组成架构](https://github.com/Dang-h/BigData/blob/master/Flume/data/Flume%E5%9F%BA%E7%A1%80%E7%BB%84%E6%88%90%E6%9E%B6%E6%9E%84.png)

### FLume架构中的组件

* Agent
  * 一个JVM进程，以事件形式将数据从源头送至目的地；
  * 由`Source`、`Channel`、`Sink`组成
* ==**Source**==
  * 数据的来源
  * 负责接收数据到`Agent`组件。
  * 用于处理各种类型、各种格式的日志数据
* ==**Sink**==
  * 数据的去向
  * 不断咨询`Channel`中的事件且批量移除它们，并将这些事件批量写入到内存或者索引系统、或者发送到下一个`Flume Agent`。
  * `Sink`组件目的地包括`HDFS`、`Logger`、`HBase`等
* ==**Channel**==
  * 位于`Source`和`Sink`之间的缓冲区
  * 线程安全，可同时处理几个`Source`的写入操作和几个`Sink`的读取操作
  * `File Channel`将所有事件写到磁盘，因此关闭程序或宕机书籍不会丢失
* Event
  * Flume数据传输基本单元，以Event形式将数据从源头送至目的地
  * 由`Header`和`Body`两部分组成；`Header`存放一些属性，为**K-V** 结构；`Body`存放数据，为**字节数组**。

## Flume安装

- 进入`flume/conf`修改配置文件`flume-env.sh.template`为`flume-env.sh`；在里面添加`JAVA_HOME`

  

## FLume事务

![Flume事务流程](https://github.com/Dang-h/BigData/blob/master/Flume/data/Flume%E4%BA%8B%E5%8A%A1%E6%B5%81%E7%A8%8B.png)

### Put事务

​	从Source到Channel；

- doPut：将数据写入临时缓冲区**putList**

- doCommit：检查channel内存队列是否足够合并

- doRollback：channel内存队列空间不足，回滚数据；内存充足提交Source到Channel；

### Take事务

​	从Channel拉取数据提交到Sink

- doTake：将数据取到临时缓冲区takeList，并将数据发送到HDFS

- doCommit：如果数据发送成功，则清除临时缓冲区

- doRollback：数据发送过程中如果出现异常，rollback将临时缓冲区的数据归还给channel内存队列。

  

## Flume Agent内部原理

![FlumeAgent内部原理](https://github.com/Dang-h/BigData/blob/master/Flume/data/Agent%E5%86%85%E9%83%A8%E5%8E%9F%E7%90%86.png)

- 重要组件：

  **1**）**ChannelSelector**

  **`ChannelSelector`**的作用就是选出Event将要被发往哪个Channel。其共有两种类型，分别是**Replicating**（复制）和**Multiplexing**（多路复用）。

  ReplicatingSelector会将同一个Event发往所有的Channel，Multiplexing会根据相应的原则，将不同的Event发往不同的Channel。

  **2**）**SinkProcessor**

  **`SinkProcessor`**共有三种类型

  分别是`DefaultSinkProcessor`、`LoadBalancingSinkProcessor`和`FailoverSinkProcessor`

  - `DefaultSinkProcessor`对应的是单个的Sink

  - `LoadBalancingSinkProcessor`和`FailoverSinkProcessor`对应的是`Sink Group`
    - `LoadBalancingSinkProcessor`可以实现负载均衡的功能
    - `FailoverSinkProcessor`可以错误恢复的功能。

## Flume拓扑结构

###  简单串联

​		将多个flume顺序连接起来了，从最初的source开始到最终sink传送的目的存储系统。此模式不建议桥接过多的flume数量， flume数量过多不仅会影响传输速率，而且一旦传输过程中某个节点flume宕机，会影响整个传输系统。

![FLume简单串联](https://github.com/Dang-h/BigData/blob/master/Flume/data/%E7%AE%80%E5%8D%95%E4%B8%B2%E8%81%94.png)

### 复制和多路复用

​		Flume支持将事件流向一个或者多个目的地。这种模式可以将相同数据复制到多个channel中，或者将不同数据分发到不同的channel中，sink可以选择传送到不同的目的地。

![Flume复制和多路复用](https://github.com/Dang-h/BigData/blob/master/Flume/data/复制和多路复用.png)

### 负载均衡和故障转移

​		Flume支持使用将多个sink逻辑上分到一个sink组，sink组配合不同的SinkProcessor可以实现负载均衡和错误恢复的功能

![Flume负载均衡和故障转移](https://github.com/Dang-h/BigData/blob/master/Flume/data/%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%E5%92%8C%E6%95%B0%E6%8D%AE%E8%BD%AC%E7%A7%BB.png)

### 聚合

​		日常web应用通常分布在上百个服务器，大者甚至上千个、上万个服务器。产生的日志，处理起来也非常麻烦。用flume的这种组合方式能很好的解决这一问题，每台服务器部署一个flume采集日志，传送到一个集中收集日志的flume，再由此flume上传到hdfs、hive、hbase等，进行日志分析

![Flume聚合](https://github.com/Dang-h/BigData/blob/master/Flume/data/Flume%E8%81%9A%E5%90%88.png)

## Flume配置文件

[官方文档](<http://flume.apache.org/FlumeUserGuide.html>)

​		一个单节点Flume部署。该配置允许用户生成事件，然后将它们发送到控制台。

```
# 第一块：定义组件
# Name the components on this agent
a1.sources = r1			# 定义source
a1.sinks = k1			# 定义sink
a1.channels = c1		# 定义channel

	# a1:agent名称
	# r1:a1的输入源
	# k1:a1的输出目的地
	# c1:a1的缓冲区

# 第二块：定义Source
# Describe/configure the source
a1.sources.r1.type = netcat		# 定义source的类型，source来源
a1.sources.r1.bind = localhost	# 监听端口的主机名称
a1.sources.r1.port = 44444		# 监听的端口

# 第三块：定义sink
# Describe the sink
a1.sinks.k1.type = logger		# 输出到目的地为文件类型

# 第四块：定义channel
# Use a channel which buffers events in memory
a1.channels.c1.type = memory	# Channel存储类型，内存（memory）和磁盘（file）
a1.channels.c1.capacity = 1000	# 总容量为1000个event
a1.channels.c1.transactionCapacity = 100	

# 第五块：拼接
# Bind the source and sink to the channel
a1.sources.r1.channels = c1		# 将r1和c1连起来
a1.sinks.k1.channel = c1		# 将k1和c1连起来
```

 	实时监控Hive日志，并上传到HDFS中

```
# Name the components on this agent
a2.sources = r2
a2.sinks = k2
a2.channels = c2

# Describe/configure the source
# 定义source的类型
a2.sources.r2.type = exec
# source要执行的命令
a2.sources.r2.command = tail -F /opt/module/hive/logs/hive.log
# 指定执行脚本的shell
a2.sources.r2.shell = /bin/bash -c

# Describe the sink
a2.sinks.k2.type = hdfs
# 指定HDFS的路径
a2.sinks.k2.hdfs.path = hdfs://hadoop102:9000/flume/%Y%m%d/%H
# 上传文件的前缀
a2.sinks.k2.hdfs.filePrefix = logs-
# 是否按照时间滚动文件夹
a2.sinks.k2.hdfs.round = true
# 多少时间单位创建一个新的文件夹
a2.sinks.k2.hdfs.roundValue = 1
# 定义时间单位
a2.sinks.k2.hdfs.roundUnit = hour
# 是否使用本地时间戳
a2.sinks.k2.hdfs.useLocalTimeStamp = true
# 积攒多少个Event才flush到HDFS一次
a2.sinks.k2.hdfs.batchSize = 1000
# 设置文件类型，可支持压缩（DataScream为非压缩，CompressedStream为压缩）
a2.sinks.k2.hdfs.fileType = DataStream
# 多久生成一个新的文件
a2.sinks.k2.hdfs.rollInterval = 60
# 设置每个文件的滚动大小
a2.sinks.k2.hdfs.rollSize = 134217700
# 文件的滚动与Event数量无关
a2.sinks.k2.hdfs.rollCount = 0

# Use a channel which buffers events in memory
a2.channels.c2.type = memory
a2.channels.c2.capacity = 1000
a2.channels.c2.transactionCapacity = 100

# Bind the source and sink to the channel
# 数据传输顺序，拼接成一个拓扑结构
# r2 ——> c2 ——> k2
a2.sources.r2.channels = c2
a2.sinks.k2.channel = c2
```

​	使用Flume监听整个目录的文件，并上传至HDFS

```
# 第一块：定义组件
a3.sources = r3
a3.sinks = k3
a3.channels = c3

# 第二块：定义source
# source类型
a3.sources.r3.type = spooldir
# 监控目录
a3.sources.r3.spoolDir = /opt/module/flume/upload
# 上传完成候的后缀
a3.sources.r3.fileSuffix = .COMPLETED
# 是否有文件头
a3.sources.r3.fileHeader = true
#忽略所有以.tmp结尾的文件，不上传
a3.sources.r3.ignorePattern = ([^ ]*\.tmp)

# 第三块：定义sink
a3.sinks.k3.type = hdfs
a3.sinks.k3.hdfs.path = hdfs://hadoop102:9000/flume/upload/%Y%m%d/%H
# 上传文件的前缀
a3.sinks.k3.hdfs.filePrefix = upload-
# 是否按照时间滚动文件夹
a3.sinks.k3.hdfs.round = true
# 多少时间单位创建一个新的文件夹
a3.sinks.k3.hdfs.roundValue = 1
# 重新定义时间单位
a3.sinks.k3.hdfs.roundUnit = hour
# 是否使用本地时间戳
a3.sinks.k3.hdfs.useLocalTimeStamp = true
# 积攒多少个Event才flush到HDFS一次
a3.sinks.k3.hdfs.batchSize = 100
# 设置文件类型，可支持压缩
a3.sinks.k3.hdfs.fileType = DataStream
# 多久生成一个新的文件（单位：s）
a3.sinks.k3.hdfs.rollInterval = 60
# 设置每个文件的滚动大小大概是128M
a3.sinks.k3.hdfs.rollSize = 134217700
# 文件的滚动与Event数量无关
a3.sinks.k3.hdfs.rollCount = 0
# 副本数
a3.sinks.k3.hdfs.minBlockReplicas

# 第四块：定义channel
# Use a channel which buffers events in memory
a3.channels.c3.type = memory
a3.channels.c3.capacity = 1000
a3.channels.c3.transactionCapacity = 100

# 第五块：拼接
# r3 ——> c3 ——> k3
a3.sources.r3.channels = c3
a3.sinks.k3.channel = c3
```

​	单数据源多出口(**单个source多个channel、sink**)

![单数据源多出口](https://github.com/Dang-h/BigData/blob/master/Flume/data/%E5%8D%95%E6%95%B0%E6%8D%AE%E6%BA%90%E5%AF%B9%E5%87%BA%E5%8F%A3%E6%A1%88%E4%BE%8B.png)

>Avro:一种远程过程调用和数据序列化框架；使用JSON来定义数据类型和通讯协议，使用压缩二进制格式来序列化数据。它主要用于Hadoop，它可以为持久化数据提供一种序列化格式，并为Hadoop节点间及从客户端程序到Hadoop服务的通讯提供一种电报格式

3个配置文件

 1. flume-file-flume.conf

    配置1个接收日志文件的source和2个channel、2个sink，分别输送给flume-flume-hdfs和flume-flume-dir

    ```
    # Name the components on this agent
    a1.sources = r1
    a1.sinks = k1 k2
    a1.channels = c1 c2
    # 将数据流复制给所有channel
    a1.sources.r1.selector.type = replicating
    
    # Describe/configure the source
    a1.sources.r1.type = exec
    a1.sources.r1.command = tail -F /opt/module/hive/logs/hive.log
    a1.sources.r1.shell = /bin/bash -c
    
    # Describe the sink
    # 2个sink
    # sink端的avro是一个数据发送者
    a1.sinks.k1.type = avro
    a1.sinks.k1.hostname = hadoop102 
    a1.sinks.k1.port = 4141
    
    a1.sinks.k2.type = avro
    a1.sinks.k2.hostname = hadoop102
    a1.sinks.k2.port = 4142
    
    # Describe the channel
    # 2个channel
    a1.channels.c1.type = memory
    a1.channels.c1.capacity = 1000
    a1.channels.c1.transactionCapacity = 100
    
    a1.channels.c2.type = memory
    a1.channels.c2.capacity = 1000
    a1.channels.c2.transactionCapacity = 100
    
    # Bind the source and sink to the channel
    # 	c1 ——> k1
    #r1
    #	c2 ——> k2
    a1.sources.r1.channels = c1 c2
    a1.sinks.k1.channel = c1
    a1.sinks.k2.channel = c2
    ```

 2. flume-flume-hdfs.conf

    配置上级Flume输出的Source，输出是到HDFS的Sink

    ```
    # Name the components on this agent
    a2.sources = r1
    a2.sinks = k1
    a2.channels = c1
    
    # Describe/configure the source
    # source端的avro是一个数据接收服务
    # 上级的输出是这一级的输入
    a2.sources.r1.type = avro
    a2.sources.r1.bind = hadoop102
    a2.sources.r1.port = 4141
    
    # Describe the sink
    a2.sinks.k1.type = hdfs
    a2.sinks.k1.hdfs.path = hdfs://hadoop102:9000/flume2/%Y%m%d/%H
    a2.sinks.k1.hdfs.filePrefix = flume2-
    a2.sinks.k1.hdfs.round = true
    a2.sinks.k1.hdfs.roundValue = 1
    a2.sinks.k1.hdfs.roundUnit = hour
    a2.sinks.k1.hdfs.useLocalTimeStamp = true
    a2.sinks.k1.hdfs.batchSize = 100
    a2.sinks.k1.hdfs.fileType = DataStream
    a2.sinks.k1.hdfs.rollInterval = 600
    a2.sinks.k1.hdfs.rollSize = 134217700
    a2.sinks.k1.hdfs.rollCount = 0
    
    # Describe the channel
    a2.channels.c1.type = memory
    a2.channels.c1.capacity = 1000
    a2.channels.c1.transactionCapacity = 100
    
    # Bind the source and sink to the channel
    # r1 ——> c1 ——> k1
    a2.sources.r1.channels = c1
    a2.sinks.k1.channel = c1
    ```

 3. flume-flume-dir.conf

    配置上级Flume输出的Source，输出是到本地目录的Sink。
    
    ```
    # Name the components on this agent
    a3.sources = r1
    a3.sinks = k1
    a3.channels = c2
    
    # Describe/configure the source
    a3.sources.r1.type = avro
    a3.sources.r1.bind = hadoop102
    a3.sources.r1.port = 4142
    
    # Describe the sink
    # sink文件类型为file_roll,实时滚动生成文件
    a3.sinks.k1.type = file_roll
    # 目录需要提前创建
    a3.sinks.k1.sink.directory = /opt/module/data/flume3
    
    # Describe the channel
    a3.channels.c2.type = memory
    a3.channels.c2.capacity = 1000
    a3.channels.c2.transactionCapacity = 100
    
    # Bind the source and sink to the channel
    a3.sources.r1.channels = c2
    a3.sinks.k1.channel = c2
    ```
    
    [开发者官方文档](<http://flume.apache.org/releases/content/1.9.0/FlumeDeveloperGuide.html>)
    
    ### Interceptor自定义
    
    > ​	思路：定义一个类CustomerInterceptor并实现Interceptor接口，重写Interceptor方法。
    
    ### Source自定义
    
    ### Sink自定义
    
    
    
    
