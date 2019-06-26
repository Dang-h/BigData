# Kettle

## 概述

​	Kettle是一款开源的ETL工具。简化数据仓库的创建，更新和维护，使用Kettle可以构建一套开源的ETL解决方案。

## 基本架构

Kettle是一个组件化的集成系统，包括如下几个主要部分：

1. Spoon：图形化界面工具(GUI方式)，Spoon允许你通过图形界面来设计Job和Transformation，可以保存为文件或者保存在数据库中。也可以直接在Spoon图形化界面中运行Job和Transformation，
2. Pan：Transformation执行器(命令行方式)，Pan用于在终端执行Transformation，没有图形界面。
3. Kitchen：Job执行器(命令行方式)，Kitchen用于在终端执行Job，没有图形界面。
4. Carte：嵌入式Web服务，用于远程执行Job或Transformation，Kettle通过Carte建立集群。
5. Encr：Kettle用于字符串加密的命令行工具，如：对在Job或Transformation中定义的数据库连接参数进行加密。

## Q&A

1. Q：Hadoop File Output.0 - ERROR (version 7.1.0.0-12, build 1 from 2017-05-16 17.18.02 by buildguy) : Couldn't open file hdfs://hdfs@host250:8020/user/hive/warehouse/genotype.txt

   A：在 windows 上使用 kettle 连接 hadoop 写文件的时候，默认使用的是本机登录用户作为文件属主访问 HDFS 文件的，如果目标路径权限不允许，就会报错。

   在Spoon.bat中第119行（set OPT）末尾添加参数
   "-DHADOOP_USER_NAME=atguigu" "-Dfile.encoding=UTF-8"