# Oozie

​	训象人，提供Hadoop MapReduce、Pig Jobs的任务调度协调。用于定时调度任务。

## 模块

1. Workfolw

   顺序执行流程节点，支持fork（分支多个节点），join（合并多个节点为一个）

   ### 常用节点

   1. 控制流节点（control Folow Nodes）

      定义在工作流开始或者结束的位置，比如start,end,kill等。以及提供工作流的执行路径机制，如decision，fork，join等

   2. 动作节点（Action Nodes）

      负责执行具体动作的节点，比如：拷贝文件，执行某个Shell脚本等等

2. Coordinator

   定时触发Workflow

3. Bundle

   绑定多个Coordinator

## 案例([Oozie4.0.0官方文档](https://oozie.apache.org/docs/4.0.0/index.html))

1. 调度shell脚本

   ```
   1. 创建工作目录并创建文件job.properties和workflow.xml
   	# hadoop @ hadoop101 in /opt/module/oozie-4.0.0-cdh5.3.6 [14:29:01] 
   	$ mkdir -p  oozie-apps/shell && touch oozie-apps/shell/job.propertis oozie-apps/shell/workflow.xml
   	
   2. 编辑job.properties和workflow.xml
   	vim job.properties
   	#HDFS地址
   	nameNode=hdfs://hadoop102:8020
   	#ResourceManager地址
       jobTracker=hadoop103:8032
       #队列名称
       queueName=default
       examplesRoot=oozie-apps
       oozie.wf.application.path=${nameNode}/user/${user.name}/${examplesRoot}/shell
   	vim workflow.xml
   	<workflow-app xmlns="uri:oozie:workflow:0.4" name="shell-wf">
       <start to="p1-shell-node"/>
       <action name="p1-shell-node">
           <shell xmlns="uri:oozie:shell-action:0.2">
               <job-tracker>${jobTracker}</job-tracker>
               <name-node>${nameNode}</name-node>
               <configuration>
                   <property>
                       <name>mapred.job.queue.name</name>
                       <value>${queueName}</value>
                   </property>
               </configuration>
               <exec>mkdir</exec>
               <argument>/opt/module/d1</argument>
               <capture-output/>
           </shell>
           <ok to="p2-shell-node"/>
           <error to="fail"/>
       </action>
   
       <action name="p2-shell-node">
           <shell xmlns="uri:oozie:shell-action:0.2">
               <job-tracker>${jobTracker}</job-tracker>
               <name-node>${nameNode}</name-node>
               <configuration>
                   <property>
                       <name>mapred.job.queue.name</name>
                       <value>${queueName}</value>
                   </property>
               </configuration>
               <exec>mkdir</exec>
               <argument>/opt/module/d2</argument>
               <capture-output/>
           </shell>
           <ok to="end"/>
           <error to="fail"/>
       </action>
       <kill name="fail">
           <message>Shell action failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
       </kill>
       <end name="end"/>
   </workflow-app>
   
   3. 上传任务配置
   	$ bin/hadoop fs -put oozie-apps/shells /user/atguigu/oozie-apps
   4. 执行任务
   	$ bin/oozie job -oozie http://hadoop101:11000/oozie -config oozie-apps/shell2/job.properties -run
   5. 杀死某个任务
   	$ bin/oozie job -oozie http://hadoop102:11000/oozie -kill 0000004-170425105153692-oozie-z-W
   6. 查看任务结果
   	http://hadoop101:11000/oozie
   ```

   