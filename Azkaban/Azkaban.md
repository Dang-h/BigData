# [Azkaban](https://azkaban.readthedocs.io/en/latest/)


- [概述](#概述)
- [Azkaban基础架构](#azkaban基础架构)
- [使用](#使用)

---
## 概述

​	一个**批量工作流任务调度器**；用于在一个工作流内以一个特定的顺序运行一组工作和流程，它的配置是通过简单的key:value对的方式，通过配置中的dependencies 来设置依赖关系。Azkaban使用job配置文件建立任务之间的依赖关系，并提供一个易于使用的web用户界面维护和跟踪工作流。

## Azkaban基础架构

![Azkaban基础架构](G:\Git_Repository\BigData\Azkaban\assets\1561424810037.png)

1. AzkabanWebServer：AzkabanWebServer是整个Azkaban工作流系统的主要管理者，它用户登录认证、负责project管理、定时执行工作流、跟踪工作流执行进度等一系列任务。
2. AzkabanExecutorServer：负责具体的工作流的提交、执行，它们通过mysql数据库来协调任务的执行。
3. 关系型数据库（MySQL）：存储大部分执行流状态，AzkabanWebServer和AzkabanExecutorServer都需要访问数据库。

## 使用

 1. 启动executor服务和web服务

    ```
    # hadoop @ hadoop101 in /opt/module/Azkaban/executor [18:34:31] 
    $ bin/azkaban-executor-start.sh 
    
    # hadoop @ hadoop101 in /opt/module/Azkaban/server [18:35:23] 
    $ bin/azkaban-web-start.sh 
    ```

	2.  浏览器登录https://hadoop101:8443，输入账号密码admin

     ![登录Azkaban](G:\Git_Repository\BigData\Azkaban\assets\1561545503039.png)

     ![登录成功](G:\Git_Repository\BigData\Azkaban\assets\1561545620376.png)

	3. ### [案例](https://azkaban.readthedocs.io/en/latest/useAzkaban.html#createprojects)

       #### 1. 单一job

       1) 创建first.job配置文件

       ```
       # first job
       type = command
       command = echo 'This is my first job'
       ```

       2) 打包first.job为first.zip

       > 目前，Azkaban上传的工作流文件只支持xxx.zip文件。zip应包含xxx.job运行作业所需的文件和任何文件（文件名后缀必须以.job结尾，否则无法识别）。作业名称在项目中必须是唯一的。

       3) 上传项目

       ![上传项目](G:\Git_Repository\BigData\Azkaban\assets\1561547001234.png)

       4) 执行job

       ![执行job](G:\Git_Repository\BigData\Azkaban\assets\1561547680171.png)

       5) 执行成功

       ![成功](G:\Git_Repository\BigData\Azkaban\assets\1561547741852.png)

       #### 2. 邮件通知配置

       1) 修改配置文件

       ```
       修改配置文件azkaban.properties
       # hadoop @ hadoop101 in ~ [19:20:19] 
       $ vim /opt/module/Azkaban/server/conf/azkaban.properties
       
       # mail settings
       mail.sender=XXXXXXXXXX@163.com
       mail.host=smtp.163.com
       mail.user=XXXXXXXXXX@163.com
       mail.password=zhimakaimen
       ```
    
       2) 网页进行配置
    
       ![邮件通知](G:\Git_Repository\BigData\Azkaban\assets\1561548357234.png)
    
       