# HBase

<!-- TOC -->

- [HBase](#hbase)
    - [概述](#概述)
        - [HBase逻辑结构](#hbase逻辑结构)
        - [物理存储结构](#物理存储结构)
        - [HBase基本架构](#hbase基本架构)
    - [HBase Shell操作](#hbase-shell操作)
        - [基本操作](#基本操作)
        - [DDL（Data Definition Language）](#ddldata-definition-language)
        - [DML（Data Manipulation Language）](#dmldata-manipulation-language)
    - [HBase API](#hbase-api)
    - [NoSQL](#nosql)

<!-- /TOC -->
---
## 概述

[HBase官网文档](http://hbase.apache.org/book.html#arch.overview)

​	Hadoop生态系统组件，它是一个**分布式数据库**，旨在将结构化数据存储在可能有数十亿行和数百万列的表中。HBase是可拓展的、分布式的和[NoSQL](#NoSQL)数据库，构建在HDFS之上。提供对HDFS中的读写数据的实时访问。

### HBase逻辑结构

![逻辑结构](https://github.com/Dang-h/BigData/blob/master/Hbase/assets/%E9%80%BB%E8%BE%91%E7%BB%93%E6%9E%84.png)

**简单说明**：

	1. Row key：（行键）类似于关系型数据库中的主键。HBase查询时候只能以RowKey作为查询条件。按照字符顺序排序。
 	2. Region：切开后的每一个分区。易分区就容易扩展，读写性能也随之提高。达到阈值会自动分区。
 	3. Columun：列不需要指定，只需要**指定列族**，不需要指定类型，全都是字节数组。
 	4. store：一个region下的一个列族的存储。
 	5. column family：（列族）几个列组成一个列族。相同列族的数据会存在一起，存在同一个文件上。

### 物理存储结构

![物理存储结构](https://github.com/Dang-h/BigData/blob/master/Hbase/assets/%E7%89%A9%E7%90%86%E5%AD%98%E5%82%A8%E7%BB%93%E6%9E%84.png)

**简单说明**

	1. 一个单元格对应下面一行数据，以类似于K-V的形式来存储；key是一个多维的key。
 	2. TimeStamp：时间戳，用于标识数据的不同版本（version），每条数据写入时，系统会自动为其加上该字段，其值为写入HBase的时间。
 	3. Cell：（单元格），由{rowkey, column Family：column Qualifier, time Stamp} 唯一确定。cell中的数据没有类型，全部是字节码形式存储。一个K-V代表一个单元格。
 	4. HBase利用磁盘的顺序写，速度奇快，删除并不会将数据从磁盘上抹去，而是一直追加，修改数据类型，在查找时不返回数据。
 	5. Type：对于删除，类型为deleteColumn

### HBase基本架构

![基本架构](https://github.com/Dang-h/BigData/blob/master/Hbase/assets/%E5%9F%BA%E6%9C%AC%E6%9E%B6%E6%9E%84.png)

- Region Server：Region的管理者。对数据的进行一些读写操作。客户端可以在访问数据时直接与HBase Region Server通信。部署的时候，部署在DataNode节点上
- Master：Region Server的管理者。处理区域分配以及DDL(创建、删除表)操作。监控Region Server状态，负载均衡和故障转移。
- Zookeeper：HBase通过Zookeeper来做Master的高可用、RegionServer的监控、元数据的入口以及集群配置的维护工作
- HDFS：为HBase提供最终的底层数据存储服务，同时为HBase提供高可用支持。

## HBase Shell操作

### 基本操作

- status：
  显式HBase状态，比如服务器的数量
-  version： 
  HBase的版本
- table_help： 
  This command provides help for table-reference commands.
- whoami：
  显式用户

### DDL（Data Definition Language）

- create：
    This command creates a table.

  ```
  create 'student','info'
  ```

- list：
  It lists all the tables in HBase.

  ```
  hbase(main):002:0>list
  TABLE
  student
  1 row(s) in 0.0010 seconds
  
  =>["student"]
  ```

- disable：
  This command disables a table.Deleting before `disable`

  ```
  hbase(main):002:0> disable 'student'
  0 row(s) in 2.8600 seconds
  ```

- is_disabled：
   It verifies whether a table is disabled.

  ```
  hbase(main):004:0> is_disabled 'student'
  true                                                                                            
  0 row(s) in 0.0270 seconds
  ```

- enable：
  This command enables a table.

- is_enabled：
  However, it verifies whether a table is enabled or not.

- describe：It shows the description of a table.
  ```
  hbase(main):005:0> desc 'student'
  Table student is ENABLED                                                                        
  student                                                                                         
  COLUMN FAMILIES DESCRIPTION                                                                     
  {NAME => 'info', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS
   => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VERSION
  S => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}                 
  1 row(s) in 0.0790 seconds
  ```

- alter：
  This command alters a table.

  ```
  hbase(main):015:0> alter 'student',{NAME=>'info',VERSIONS=>3}
  Updating all regions with the new schema...
  0/1 regions updated.
  1/1 regions updated.
  Done.
  0 row(s) in 3.4280 seconds
  ```

- exists：
  This one verifies whether a table exists or not.

- drop：
  This command drops a table from HBase.

- drop_all：
  Whereas,  this command drops the tables matching the ‘regex’ given in the command. 

- Java Admin API：
  Previously, to achieve DDL functionalities through programming, when the above commands were not there, Java provides an Admin API. Basically, HBaseAdmin and HTableDescriptor are the two important classes in this package which offers DDL functionalities, under org.apache.hadoop.hbase.client package.

### DML（Data Manipulation Language）

- put：
  In a particular table, this command puts a cell value at a specified column in a specified row.

  ```
  hbase(main):007:0> put 'student','1001','info:sex','male'
  ```

- get：
  We use Get command to fetch the contents of the row or a cell.

  ```
  hbase(main):009:0> get 'student','1001'
  COLUMN                    CELL                                                         info:age                 timestamp=1560754041176, value=18              
  info:name                timestamp=1560759027316, value=Nicho      
  info:sex                 timestamp=1560777015553, value=male                                   
  1 row(s) in 0.2640 seconds
  hbase(main):011:0>  get 'student','1001','info:name'
  COLUMN                    CELL                                                         info:name                timestamp=1560759027316, value=Nicho                             
  1 row(s) in 0.0270 seconds
  ```

- delete：
  In order to **delete a cell value** in a table, we use Delete command.

- deleteall：
  However, to **delete all the cells** in a given row, we use Deleteall command.

- scan：
  This command scans and returns the table data

  ```
  hbase(main):012:0> scan 'student'
  ROW                       COLUMN+CELL                                                 1001                     column=info:age, timestamp=1560754041176, value=18           1001                     column=info:name, timestamp=1560759027316, value=Nicho       1001                     column=info:sex, timestamp=1560777015553, value=male         1002                     column=info:age, timestamp=1560754158505, value=19           1002                     column=info:name, timestamp=1560754145965, value=Jerry       1002                     column=info:sex, timestamp=1560754171147, value=female                
  2 row(s) in 0.1590 seconds
  hbase(main):013:0> scan 'student',{STARTROW => '1001', STOPROW  => '1001'}
  ROW                       COLUMN+CELL                                                 1001                     column=info:age, timestamp=1560754041176, value=18           1001                     column=info:name, timestamp=1560759027316, value=Nicho       1001                     column=info:sex, timestamp=1560777015553, value=male                  
  1 row(s) in 0.1000 seconds
  # 删除一行后查看原数据
  hbase(main):018:0> scan 'student', {RAW => TRUE, VERSION => 10}
  ROW                       COLUMN+CELL                                                 1001                     column=info:age, timestamp=1560754041176, value=18           1001                     column=info:name, timestamp=1560759027316, value=Nicho       1001                     column=info:sex, timestamp=1560777015553, value=male         1002                     column=info:age, timestamp=1560754158505, value=19           1002                     column=info:name, timestamp=1560754145965, value=Jerry       1002                     column=info:sex, timestamp=1560777683188, type=DeleteColumn 1002                     column=info:sex, timestamp=1560754171147, value=female                
  2 row(s) in 0.0610 seconds
  ```

- count：
  To count and return the number of rows in a table, we use Count command.

  ```
  hbase(main):014:0> count 'student'
  2 row(s) in 0.0730 seconds
  
  => 2
  ```

- truncate：
  Truncate command, disables, drops, and recreates a specified table.

-  Java client API：
  Under org.apache.hadoop.hbase.client package, Java provides a client API to achieve DML functionalities, CRUD (Create Retrieve Update Delete) operations and more through programming, previously, when the above commands were not there.
  So, this was all about HBase Shell Commands. Hope you like our explanation

## HBase API

​	导入依赖

```xml
<dependency>
    <groupId>org.apache.hbase</groupId>
    <artifactId>hbase-server</artifactId>
    <version>1.3.1</version>
</dependency>

<dependency>
    <groupId>org.apache.hbase</groupId>
    <artifactId>hbase-client</artifactId>
    <version>1.3.1</version>
</dependency>
```

- 一通乱敲👉[得到代码](https://github.com/Dang-h/HBase_API_Demo)

## NoSQL

​	NoSQL(Not-Only-SQL)指的是非关系型的数据库，NoSQL不使用SQL作为查询语言。其数据存储可以不需要固定的表格模式，避免使用SQL的[JOIN](https://zh.wikipedia.org/wiki/连接_(SQL))操作，一般有[水平可扩展性](https://zh.wikipedia.org/w/index.php?title=水平可扩展性&action=edit&redlink=1)，分布式计算，架构灵活等特征。
