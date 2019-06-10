CREATE
# external 建立外部表，drop表的时候不会删除HDFS上的元数据
EXTERNAL TABLE video_ori
(
    videoId STRING,
    uploader STRING,
    age      INT,
    category array< STRING >,
    length   INT,
    views    INT,
    rate     FLOAT,
    ratings  INT,
    comments INT,
    relatedId array< STRING >
) ROW FORMAT delimited
FIELDS TERMINATED BY "\t"
collection items TERMINATED BY "&"
# stored as指定存储文件的类型（SEQUENCEFILE（二进制序列文件）、TEXTFILE（文本）、RCFILE（列式存储格式文件））
STORED AS textfile
# location指定加载数据的路径
LOCATION '/user/hive/warehouse/movie/data/movie';


CREATE
EXTERNAL TABLE user_ori
(
    uploader STRING,
    videos  INT,
    friends INT
) ROW FORMAT delimited
FIELDS TERMINATED BY "\t"
STORED AS textfile
LOCATION '/user/hive/warehouse/movie/data/user';

# 内部表
# 通过
# INSERT INTO video
# SELECT *
# FROM vedo_ori;
# 将外部表的数据导入进颞部表从而保护数据，insert into候得SQL语句可以做简单的数据清洗
CREATE TABLE video
(
    videoId STRING,
    uploader STRING,
    age      int,
    category array< STRING >,
    length   int,e
    views    int,
    rate     float,
    ratings  int,
    comments int,
    relatedId array< STRING >
) ROW FORMAT delimited FIELDS TERMINATED BY "\t"
collection items TERMINATED BY "&"
STORED AS orc;


CREATE TABLE users
(
    uploader STRING,
    videos  int,
    friends int
) ROW FORMAT delimited
FIELDS TERMINATED BY "\t"
STORED AS orc;

