# [Spark](https://spark.apache.org/)

## 部署

- [下载](https://archive.apache.org/dist/spark/)Spark安装包

- 部署Spark集群

  - 基于Standalone模式

    1. 解压安装包到指定目录

    2. 修改配置文件

       ```bash
       1. 修改slaves
       先删除“localhost”，然后添加主机名称或者IP地址
       # hadoop @ hadoop100 in /opt/module/spark-2.4.4/conf [10:29:31] 
       $ cat slaves 
       hadoop100
       hadoop101
       hadoop102
       
       2. 修改配置文件`spark-default-conf`，添加：
       # 配置Spark历史服务器
        spark.eventLog.enabled           true
        spark.eventLog.dir               hdfs://hadoop100:9000/spark_directory
        
       3. 在HDFS上创建对应spark-logs目录
        hdfs dfs -mkdir /spark_directory
       
       4. 修改spark-env.sh,添加master的`地址`和`端口`和Spark历史服务相关配置
       SPARK_MASTER_HOST=hadoop100
       SPARK_MASTER_POST=7077
       
       export SPARK_HISTORY_OPTS="-Dspark.history.ui.port=18080 -Dspark.history.retainedApplications=30 -Dspark.history.fs.logDirectory=hdfs://hadoop100:9000/spark_directory"
        其中：
        -Dspark.history.retainedApplications：内存中允许存放的日志个数
        -Dspark.history.fs.logDirectory：指定日志信息存放的目录
       ```

    3. 分发配置文件到集群

    4. 启动并查看Spark历史服务

       ```bash
       1. 在Master节点上进入spark安装目录执行
       sbin/start-all.sh
       
       2. 启动历史服务
       sbin/start-history-server.sh
       
       3. 访问历史服务页面
       http://hadoop100:18080
       ```

    - 基于Standalone模式部署高可用Master

    1. 节点分配

       | 主机      | 服务           |
       | --------- | -------------- |
       | hadoop100 | master、worker |
       | hadoop101 | master、worker |
       | hadoop102 | worker         |

    2. 停止Spark历史服务、Master和Worker

    3. 修改配置文件

       1. 确保[Zookeeper安装](Zookeeper/Zookeeper.md)且正常运行

       2. 修改`spark-env.sh`，注释掉之前配置的`SPARK_MASTER_HOST`,添加内容
     
          `export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER -Dspark.deploy.zookeeper=hadoop100:2181,hadoop101:2181,hadoop102:2181 -Dspark.deploy.zookeeper.dir=/saprk"`
       
       3. 分发配置文件
       
  
  - 基于YARN模式
  
    1. 修改Hadoop配置`yarn-site.xml`，添加内容：
  
       ```xml
       <!-- 关掉虚拟内存检查 -->
       <property>
         <name>yarn.nodemanager.vmem-check-enabled</name>
         <value>false</value>
       </property>
       
       <property>
       	<name>yarn.nodemanager.pmem-check-enabled</name>
       	<value>false</value>
       </property>
       
       ```
  
    2. 分发Hadoop配置文件
  
    3. 修改Spark配置文件`spark-env.sh`，添加
  
       ```bash
       HADOOP_CONF_DIR=/opt/module/hadoop-2.7.2/etc/hadoop
       YARN_CONF_DIR=/opt/module/hadoop-2.7.2/etc/hadoop
       ```
  
    4. 分发配置文件