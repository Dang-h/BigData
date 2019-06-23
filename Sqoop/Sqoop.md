# Sqoop

​		一款开源的工具，主要用于在Hadoop(Hive)与传统的数据库(mysql、postgresql...)间进行数据的传递，可以将一个关系型数据库（例如 ： MySQL ,Oracle ,Postgres等）中的数据导进到Hadoop的HDFS中，也可以将HDFS的数据导进到关系型数据库中。

## [安装配置](anzhuang)

## [官方文档](https://sqoop.apache.org/docs/1.4.6/index.html)

## 简单使用案例

### 导入数据

1. RDBMS到HDFS

   ```
   1. 在MySQL中建表
   	$ mysql -uroot -p000000
       mysql> create database company;
       mysql> create table company.staff(id int(4) primary key not null auto_increment, name varchar(255), sex varchar(255));
       mysql> insert into company.staff(name, sex) values('Thomas', 'Male');
       mysql> insert into company.staff(name, sex) values('Catalina', 'FeMale');
       mysql> insert into company.staff(name, sex) values('Thomas', 'Male');
       mysql> insert into company.staff(name, sex) values('Catalina', 'FeMale');    		mysql> insert into company.staff(name, sex) values('Thomas', 'Male');
       mysql> insert into company.staff(name, sex) values('Catalina', 'FeMale');
   2. 导入数据
   	（1） 全部导入
           sqoop import \
           --connect jdbc:mysql://hadoop102:3306/company \
           --username root \
           --password 000000 \
           --table staff \
           --target-dir /user/company \
           --delete-target-dir \
           --num-mappers 1 \
           --fields-terminated-by "\t"
   	（2） 查询导入
   		sqoop import \
           --connect jdbc:mysql://hadoop101:3306/company \
           --username root \
           --password mysql \
           --target-dir /user/company \
           --delete-target-dir \
           --num-mappers 2 \
           --fields-terminated-by "\t" \
           --query 'select name,sex from staff where id <=10 and $CONDITIONS;'
   
   
   ```

2. RDBMS到Hive

3. RDBMS到Hbase

### 导出数据

1. Hive/HBase到RDBMS

