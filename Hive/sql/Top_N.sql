CREATE
-- external 建立外部表，drop表的时候不会删除HDFS上的元数据
    EXTERNAL TABLE video_ori
(
    videoId   STRING COMMENT '视频唯一id',
    uploader  STRING COMMENT '视频上传者',
    age       INT COMMENT '视频上传天数',
    category  array<STRING> COMMENT '视频类别',
    length    INT COMMENT '视频长度',
    `views`   INT COMMENT '观看次数',
    rate      FLOAT COMMENT '视频评分',
    ratings   INT COMMENT '流量',
    comments  INT COMMENT '评论数',
    relatedId array<STRING> COMMENT '相关视频id'
) ROW FORMAT DELIMITED
    FIELDS TERMINATED BY "\t"
    COLLECTION ITEMS TERMINATED BY "&"
-- stored as指定存储文件的类型（SEQUENCEFILE（二进制序列文件）、TEXTFILE（文本）、RCFILE（列式存储格式文件））
    STORED AS TEXTFILE
-- location指定存储位置
    LOCATION '/user/hive/warehouse/movie/data/movie';


CREATE
    EXTERNAL TABLE user_ori
(
    uploader STRING,
    videos   INT,
    friends  INT
) ROW FORMAT DELIMITED
    FIELDS TERMINATED BY "\t"
    STORED AS TEXTFILE
    LOCATION '/user/hive/warehouse/movie/data/user';

-- 内部表
-- 通过
-- INSERT INTO video
-- SELECT *
-- FROM vedo_ori;
-- 将外部表的数据导入进颞部表从而保护数据，insert into候得SQL语句可以做简单的数据清洗
CREATE TABLE video
(
    videoId   STRING COMMENT '视频唯一id',
    uploader  STRING COMMENT '视频上传者',
    age       INT COMMENT '视频上传天数',
    category  array<STRING> COMMENT '视频类别',
    length    INT COMMENT '视频长度',
    `views`   INT COMMENT '观看次数',
    rate      FLOAT COMMENT '视频评分',
    ratings   INT COMMENT '流量',
    comments  INT COMMENT '评论数',
    relatedId array<STRING> COMMENT '相关视频id'
) ROW FORMAT DELIMITED FIELDS TERMINATED BY "\t"
    COLLECTION ITEMS TERMINATED BY "&"
    STORED AS ORC;


CREATE TABLE users
(
    uploader STRING COMMENT '上传者',
    videos   int COMMENT '上传视频数',
    friends  int COMMENT '粉丝'
) ROW FORMAT DELIMITED
    FIELDS TERMINATED BY "\t"
    STORED AS ORC;

-- 加载数据
LOAD DATA INPATH "/movie/video_etl" INTO TABLE video_ori;
LOAD DATA INPATH "/movie/user" INTO TABLE user_ori;

-- 关联数据
-- 将外部表数据导入到内部表video中
INSERT INTO video
SELECT *
FROM video_ori;

-- 到数据到users表
INSERT INTO users
SELECT *
FROM user_ori;

// 需求
-- 统计视频观看数Top10
-- 统计视频类别热度Top10
-- 统计视频观看数Top20所属类别
-- 统计视频观看数Top50所关联视频的所属类别排序
-- 统计每个类别中的视频热度Top10,以music为例
-- 统计每个类别中视频流量Top10，以Music为例
-- 统计上传视频最多的用户Top10以及他们上传的观看次数在前20的视频
-- 统计每个类别视频观看数Top10

-- 统计视频观看数Top10
SELECT videoId, uploader, `views`
FROM video
ORDER BY `views` DESC
LIMIT 10;
/*
+--------------+------------------+-----------+--+
|   videoid    |     uploader     |   views   |
+--------------+------------------+-----------+--+
| dMH0bHeiRNg  | judsonlaipply    | 42513417  |
| 0XxI-hvPRRA  | smosh            | 20282464  |
| 1dmVU08zVpA  | NBC              | 16087899  |
| RB-wUgnyGv0  | ChrisInScotland  | 15712924  |
| QjA5faZF1A8  | guitar90         | 15256922  |
| -_CSo1gOd48  | tasha            | 13199833  |
| 49IDp76kjPw  | TexMachina       | 11970018  |
| tYnn51C3X_w  | CowSayingMoo     | 11823701  |
| pv5zWaTEVkI  | OkGo             | 11672017  |
| D2kJZOfq7zk  | mrWoot           | 11184051  |
+--------------+------------------+-----------+--+
*/

-- 统计视频类别热度Top10
/*
 1 把类别炸开
 2 电影按类别归类，
 3 统计该类别下电影播放次数之和，按播放次数的和降序排列截取前10
 */
-- lateral view explode() 使用：lateral view与explode等udtf就是天生好搭档，
-- explode将复杂结构一行拆成多行，然后再用lateral view做各种聚合。

// 1 把类别炸开
SELECT categories, videoId, `views`
FROM video LATERAL VIEW explode(category) tb_tmp AS categories
LIMIT 10;
/*
+----------------+--------------+--------+--+
|   categories   |   videoid    | views  |
+----------------+--------------+--------+--+
| Gadgets        | 52K6NEXxjrg  | 2450   |
| Games          | 52K6NEXxjrg  | 2450   |
| Gadgets        | qraNEktJfVI  | 2750   |
| Games          | qraNEktJfVI  | 2750   |
| Entertainment  | vDUElhHlQD8  | 755    |
| Comedy         | 265TFhvWZ4o  | 78496  |
| Comedy         | 6Xv4FHZHnMk  | 3565   |
| Comedy         | fbup5jY6m0M  | 18451  |
| Entertainment  | D5empOBL48s  | 2023   |
| Comedy         | 4mk_z6ERp9c  | 1403   |
+----------------+--------------+--------+--+
*/
// 2 电影按类别归类
SELECT categories
FROM video LATERAL VIEW explode(category) tb_tmp AS categories
GROUP BY categories
LIMIT 10;
/*
+----------------+--+
|   categories   |
+----------------+--+
| Places         |
| DIY            |
| Animals        |
| Entertainment  |
| Film           |
| Animation      |
| People         |
| Autos          |
| News           |
| Gadgets        |
+----------------+--+
*/
// 1 统计该类别下电影播放次数之和，按播放次数的和降序排列截取前10
SELECT categories, count(*) hot, sum(`views`) hot2
FROM video LATERAL VIEW explode(category) tb_tmp AS categories
GROUP BY categories
ORDER BY hot2 DESC
LIMIT 10;
/*
+----------------+---------+-------------+--+
|   categories   |   hot   |    hot2     |
+----------------+---------+-------------+--+
| Music          | 179049  | 2426199511  |
| Entertainment  | 127674  | 1644510629  |
| Comedy         | 87818   | 1603337065  |
| Film           | 73293   | 659449540   |
| Animation      | 73293   | 659449540   |
| Sports         | 67329   | 647412772   |
| Gadgets        | 59817   | 505658305   |
| Games          | 59817   | 505658305   |
| Blogs          | 48890   | 425607955   |
| People         | 48890   | 425607955   |
+----------------+---------+-------------+--+
*/

-- 统计视频观看数Top20所属类别
/*
 1 筛选出观看数前20的视频
 2 炸开视频列别
 3 按照类别分类
 */
// 1 筛选出观看数前20的视频
SELECT videoId, `views`, category
FROM video
ORDER BY `views` DESC
LIMIT 20;
/*
+--------------+-----------+---------------------+--+
|   videoid    |   views   |      category       |
+--------------+-----------+---------------------+--+
| dMH0bHeiRNg  | 42513417  | ["Comedy"]          |
| 0XxI-hvPRRA  | 20282464  | ["Comedy"]          |
| 1dmVU08zVpA  | 16087899  | ["Entertainment"]   |
| RB-wUgnyGv0  | 15712924  | ["Entertainment"]   |
| QjA5faZF1A8  | 15256922  | ["Music"]           |
| -_CSo1gOd48  | 13199833  | ["People","Blogs"]  |
| 49IDp76kjPw  | 11970018  | ["Comedy"]          |
| tYnn51C3X_w  | 11823701  | ["Music"]           |
| pv5zWaTEVkI  | 11672017  | ["Music"]           |
| D2kJZOfq7zk  | 11184051  | ["People","Blogs"]  |
| vr3x_RRJdd4  | 10786529  | ["Entertainment"]   |
| lsO6D1rwrKc  | 10334975  | ["Entertainment"]   |
| 5P6UU6m3cqk  | 10107491  | ["Comedy"]          |
| 8bbTtPL1jRs  | 9579911   | ["Music"]           |
| _BuRwH59oAo  | 9566609   | ["Comedy"]          |
| aRNzWyD7C9o  | 8825788   | ["UNA"]             |
| UMf40daefsI  | 7533070   | ["Music"]           |
| ixsZy2425eY  | 7456875   | ["Entertainment"]   |
| MNxwAU_xAMk  | 7066676   | ["Comedy"]          |
| RUCZJVJ_M8o  | 6952767   | ["Entertainment"]   |
+--------------+-----------+---------------------+--+
*/
// 2 炸开视频类别 t1
SELECT videoId, categories, `views`
FROM (
         SELECT videoId, `views`, category
         FROM video
         ORDER BY `views` DESC
         LIMIT 20
     ) t1 LATERAL VIEW explode(category) t_tmp AS categories;
/*
+--------------+----------------+-----------+--+
|   videoid    |   categories   |   views   |
+--------------+----------------+-----------+--+
| dMH0bHeiRNg  | Comedy         | 42513417  |
| 0XxI-hvPRRA  | Comedy         | 20282464  |
| 1dmVU08zVpA  | Entertainment  | 16087899  |
| RB-wUgnyGv0  | Entertainment  | 15712924  |
| QjA5faZF1A8  | Music          | 15256922  |
| -_CSo1gOd48  | People         | 13199833  |
| -_CSo1gOd48  | Blogs          | 13199833  |
| 49IDp76kjPw  | Comedy         | 11970018  |
| tYnn51C3X_w  | Music          | 11823701  |
| pv5zWaTEVkI  | Music          | 11672017  |
| D2kJZOfq7zk  | People         | 11184051  |
| D2kJZOfq7zk  | Blogs          | 11184051  |
| vr3x_RRJdd4  | Entertainment  | 10786529  |
| lsO6D1rwrKc  | Entertainment  | 10334975  |
| 5P6UU6m3cqk  | Comedy         | 10107491  |
| 8bbTtPL1jRs  | Music          | 9579911   |
| _BuRwH59oAo  | Comedy         | 9566609   |
| aRNzWyD7C9o  | UNA            | 8825788   |
| UMf40daefsI  | Music          | 7533070   |
| ixsZy2425eY  | Entertainment  | 7456875   |
| MNxwAU_xAMk  | Comedy         | 7066676   |
| RUCZJVJ_M8o  | Entertainment  | 6952767   |
+--------------+----------------+-----------+--+
*/
// 3 按类别分组
SELECT t2.categories ctgy, sum(t2.`views`) sum_views, count(*) count_views
FROM (
         SELECT videoId, categories, `views`
         FROM (
                  SELECT videoId, `views`, category
                  FROM video
                  ORDER BY `views` DESC
                  LIMIT 20
              ) t1 LATERAL VIEW explode(category) t_tmp AS categories) t2
GROUP BY t2.categories
ORDER BY sum_views DESC;
/*
+----------------+------------+--------------+--+
|      ctgy      | sum_views  | count_views  |
+----------------+------------+--------------+--+
| Comedy         | 101506675  | 6            |
| Entertainment  | 67331969   | 6            |
| Music          | 55865621   | 5            |
| Blogs          | 24383884   | 2            |
| People         | 24383884   | 2            |
| UNA            | 8825788    | 1            |
+----------------+------------+--------------+--+
*/

-- 统计视频观看数Top50所关联视频的所属类别排序
/*
 1 筛选出观看数前50的视频的关联视频,t1
 2 炸开相关视频Id,t2
 3 根据相关视频Id找出对应视频(join原表)，t3
 4 炸开视频类别，根据电影数排序,t4
 5 根据视频Id统计视频数量并排序
 */

// 1 筛选出观看数前50视频的相关视频 t1
SELECT relatedId
FROM video
ORDER BY `views`
LIMIT 50;
/*
+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--+
|                                                                                                                                        relatedid                                                                                                                                          |
+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--+
|["DpqQC8UKKgQ","eu7S8xo9_pQ","r3F2tuxO58I","BB4MAZcBJCY","Ja_YW4LIhRo","luXOksO25iA","4sPN9rrOUlY","L9dE-cB-060","F5vbMN-714A","TginMOfD9bQ","plA7Nb_4f_w","oVnsduKvf-4","Ats8_ROfv1k","gCfndIR39uo","xn26NxorqTA","IVL-AuEgAdU","zQg5qNLxyIU","mV8Ac2iKmVg","cIwX37uOE2M","TLodY4RyKZ8"]  |
|["xL-rXB24fdY","z0Nn_cPmo2M","cuQSumJZr2w","l7lYdn2BB30","esL35X5dD_0","qbeA7KuGDVs","XKHp2Dj-DJA","baYqpIIteug","dtQiSEJqAkk","NQjHeh_quBY","ASuI34exHlE","tO8Vw_DiEJ0","cljiqD1ivhw","OHo23ZiF9jI","ER_hqeDOBGQ","rhzUuTiAkDw","SxMpGlvuFHU","I-gwH3B5CNk","w95J6UN47jI","3yT6-JGaIb8"]  |
|["n7ou39-CfEU","7z_ml03VItA","i3i10ckBePI","8EWFiDwftbU","0rmDwr6BQHc","2oAfe3THX0M","WEc5kzk0zfY","vaoBiXZSFGw","SxP7FV8cQCM","K07C6pg8-us","0s-VAXueHo4","V_Lwc6l_szg","owygOTm7vJo","gIxBcweuo0Y","Uzn6gtBrLa0","5FURU2SOHDQ","x44l5LxPgGg","7uy52JmSokc","cYAGLBSK8cI","anM6gT7q4qk"]  |
|["l5JmsLfNcW0","VGCjPu4Dnqk","Tu8JJNNdzkU","IdNdxIvCG6A","kyj9m3npalo","efJol0WJ3BY","tiSTa0pJ9KE","OfweB2q0LSY","vOdAXIU1ALU","f2GwWNvNsH4","Z9BmHAv_Q2E","bQQBx2Pug-w","yKZZjpoatEU","UUdQE5J9YFY","AZ4Sl51BOZA","TU_Yc38Yuto","EbXEcgZUAfs","7v0R_3bxPeM","KggGEooBlao","lVueR241LC4"]  |
|["nypYVhnGbcQ","bZ1JVxvAXpg","hZUU2-UBaGk","YLoj42QczWs","SaLaotssH0w","PUlcrBaYpwI","3oiiyTR8Hvo","i-pf42LhPR8","UHgQHPSY60A","n6x7jyFAf7E","c6VAs8uZjlU","z9RIi29RNnY","oTaQOrvCZqk","8AInR7EZ-zo","JW9CgqTyMhY","7nQYsvriIe4","tjIK2xop4L0","Xy8zUxU8CpI","OpGmlBpoRWE","o7fU1G0hrHk"]  |
|["M0dCceKoz10","32mbCxs4N08","3b8G8delDlk","y4by2doxa-w","f55QflfoFlc","bZ3n0gOv9Is","DbJdMkaz-Bo","f1v7jZQ4sys","5OzB5Fmo-Zc","RNAwNhlcYN4","qrTxpRUHWds","xadenEsB0_Q","dhKa85bi6zk","Rbl3QLM2dsU","Soh_2RYa9OA","GtTdMTMajm8","M7bZGjDteag","-ChbGUqesw0","FocS7wuXBjQ","nbnD7sVCBOE"]  |
|["S5DYNyRLB-k","HTbPO8WvK7s","m59LV5KFb94","spB4xW3VUwI","v-UUlVaR9Gc","i7jkwNC6BTI","SOPFuiLnsMg","a3k-JY6XINc","j52zMwxMx0s","eTLv7Cvvfmo","l-FaVVtjItg","cvHeVdlZQPs","25OjtaIe43Y","vi8nQRLkSwI","xV2tFdYBFgY","9tm1KzgFoPk","W5mtaQm5lSI","nsNlmiLJGIw","AMG_fwH3IL0","_OS_Xk-9ClI"]  |
|["W2cQv7F2YwQ","R5b6thW4L38","uAy7qrHvQik","eXsQbXsjgHE","DuXSM60VzgI","U34kH8XhH_Q","ts68hokS0Z0","bMEBdzzrFUk","JhxPmpYzxJM","qnPVt8IF3aE","UnVuD1AM0yA","Jt24eYPFmh4","IMGu4maX0k4","BYF3BpbFI9c","v520U3vS2iI","T1BHuQ5RbLU","WjhgP2-mS-s","4gxXcGaN5KA","j83AF_-DM7A","LjKUDOYUtPk"]  |
*/
// 2 炸开相关视频Id, t2
SELECT explode(relatedId) videoId
FROM (
         SELECT relatedId, `views`
         FROM video
         ORDER BY `views`
         LIMIT 50
     ) t1;
/*
+--------------+--+
|   videoid    |
+--------------+--+
| DpqQC8UKKgQ  |
| eu7S8xo9_pQ  |
| r3F2tuxO58I  |
| BB4MAZcBJCY  |
| Ja_YW4LIhRo  |
| luXOksO25iA  |
| 4sPN9rrOUlY  |
| L9dE-cB-060  |
| F5vbMN-714A  |
*/
// 3 根据相关视频Id找出对应视频(join原表)，t3
SELECT category, `views`
FROM (
         SELECT explode(relatedId) videoId
         FROM (
                  SELECT relatedId, `views`
                  FROM video
                  ORDER BY `views`
                  LIMIT 50
              ) t1
     ) t2
         JOIN video
              ON video.videoId = t2.videoId;
/*
+-----------------------+-----------+--+
|       category        |   views   |
+-----------------------+-----------+--+
| ["Comedy"]            | 351805    |
| ["Music"]             | 47545     |
| ["Gadgets","Games"]   | 5487      |
| ["Sports"]            | 30682     |
| ["Entertainment"]     | 4681      |
| ["Howto","DIY"]       | 2791      |
| ["Music"]             | 51467     |
| ["Gadgets","Games"]   | 10459     |
| ["Music"]             | 43014     |
| ["Music"]             | 111       |
| ["Comedy"]            | 3236      |
*/
// 4 炸开视频类别，筛选出相关视频Id，t4
SELECT videoId, categories
FROM (
         SELECT category, videoId
         FROM (
                  SELECT explode(relatedId) videosId
                  FROM (
                           SELECT relatedId, `views`
                           FROM video
                           ORDER BY `views`
                           LIMIT 50
                       ) t1
              ) t2
                  JOIN video
                       ON video.videoId = t2.videosId
     ) t3 LATERAL VIEW explode(t3.category) t_tmp AS categories;
/*
+--------------+----------------+--+
|   videoid    |   categories   |
+--------------+----------------+--+
| ASuI34exHlE  | Music          |
| 8Cz_HEh6L3k  | Music          |
890 rows selected
*/
// 根据视频Id统计视频数量并排序
SELECT categories, count(videoId) coun_videos
FROM (SELECT videoId, categories
      FROM (
               SELECT category, videoId
               FROM (
                        SELECT explode(relatedId) videosId
                        FROM (
                                 SELECT relatedId, `views`
                                 FROM video
                                 ORDER BY `views`
                                 LIMIT 50
                             ) t1
                    ) t2
                        JOIN video
                             ON video.videoId = t2.videosId
           ) t3 LATERAL VIEW explode(t3.category) t_tmp AS categories
     ) t4
GROUP BY categories
ORDER BY coun_videos DESC;
/*
+----------------+--------------+--+
|   categories   | coun_videos  |
+----------------+--------------+--+
| Music          | 118          |
| People         | 108          |
| Blogs          | 108          |
| Entertainment  | 89           |
| Comedy         | 74           |
| Sports         | 56           |
| DIY            | 45           |
| Howto          | 45           |
| Animation      | 44           |
| Film           | 44           |
| News           | 34           |
| Games          | 34           |
| Politics       | 34           |
| Gadgets        | 34           |
| Animals        | 4            |
| Vehicles       | 4            |
| Pets           | 4            |
| Autos          | 4            |
| UNA            | 3            |
| Travel         | 2            |
| Places         | 2            |
+----------------+--------------+--+
21 rows selected (57.299 seconds)
*/

-- 统计每个类别中的视频热度Top10，以music为例
/*
 1 炸开类别，筛选出Music类别的视频,t1
 2 从筛选出的视频中筛选出播放量Top10
 */
// 1 炸开类别，筛选出Music类别视频,t1
SELECT categoties, `views`
FROM video LATERAL VIEW explode(category) t_tmp AS categoties
WHERE categoties = 'Music';
/*
+-------------+-----------+--+
| categoties  |   views   |
+-------------+-----------+--+
| Music       | 62148     |
| Music       | 233573    |
| Music       | 8141      |
179,049 rows selected (10.452 seconds)
*/
// 2 从筛选出的视频中筛选出播放量Top10
SELECT categoties, `views`
FROM (
         SELECT categoties, `views`
         FROM video LATERAL VIEW explode(category) t_tmp AS categoties
         WHERE categoties = 'Music'
     ) t1
ORDER BY `views` DESC
LIMIT 10;
/*
+-------------+-----------+--+
| categoties  |   views   |
+-------------+-----------+--+
| Music       | 15256922  |
| Music       | 11823701  |
| Music       | 11672017  |
| Music       | 9579911   |
| Music       | 7533070   |
| Music       | 6946033   |
| Music       | 6935578   |
| Music       | 6193057   |
| Music       | 5581171   |
| Music       | 5142238   |
+-------------+-----------+--+
10 rows selected (40.26 seconds)
*/

-- 由于业务中使用到相同的表，抽离创建一张新表以便使用
CREATE TABLE video_category
    STORED AS ORC AS
SELECT videoId,
       uploader,
       categories,
       age,
       length,
       `views`,
       rate,
       ratings,
       comments,
       relatedId
FROM video LATERAL VIEW explode(category) tbl AS categories;

-- 统计每个类别中视频流量Top10,以Music为例
/*
 从video_category表中查出流量top10的视频
 */
SELECT categories, ratings
FROM video_category
ORDER BY ratings DESC
LIMIT 10;
/*
+----------------+----------+--+
|   categories   | ratings  |
+----------------+----------+--+
| Music          | 120506   |
| Comedy         | 87520    |
| Comedy         | 80710    |
| UNA            | 70972    |
| Comedy         | 62265    |
| Entertainment  | 59008    |
| Entertainment  | 46472    |
| Film           | 42417    |
| Animation      | 42417    |
| Music          | 42386    |
+----------------+----------+--+
*/

-- 统计上传视频最多的用户Top10以及他们上传的观看次数在前20的视频
/*
 1 筛选出上传视频数Top10的用户, t1
 2 根据用户筛选出视频, t2
 3 筛选出观看次数Top20
 */
// 1 筛选出上传视频数Top10的用户, t1
SELECT uploader, videos
FROM users
ORDER BY videos DESC
LIMIT 10;
/*
+---------------------+---------+--+
|      uploader       | videos  |
+---------------------+---------+--+
| expertvillage       | 86228   |
| TourFactory         | 49078   |
| myHotelVideo        | 33506   |
| AlexanderRodchenko  | 24315   |
| VHTStudios          | 20230   |
| ephemeral8          | 19498   |
| HSN                 | 15371   |
| rattanakorn         | 12637   |
| Ruchaneewan         | 10059   |
| futifu              | 9668    |
+---------------------+---------+--+
*/
// 2 根据上传者join原表筛选出上传过的视频；按照上传者分组，组内按照播放量降序排列
SELECT v.videoid,
       v.views,
       t1.uploader,
       rank() OVER (PARTITION BY t1.uploader ORDER BY v.views DESC) r
FROM (
         SELECT uploader, videos
         FROM users
         ORDER BY videos DESC
         LIMIT 10
     ) t1
         JOIN
     video v
     ON t1.uploader = v.uploader;
/*
+--------------+----------+----------------+-----+--+
|  v.videoid   | v.views  |  t1.uploader   |  r  |
+--------------+----------+----------------+-----+--+
| -IxHBW0YpZw  | 39059    | expertvillage  | 1   |
| BU-fT5XI_8I  | 29975    | expertvillage  | 2   |
| ADOcaBYbMl0  | 26270    | expertvillage  | 3   |
105 rows selected (45.86 seconds)
*/

// 3 筛选出观看次数的Top20
SELECT uploader, videoId, `views`
FROM (
         SELECT v.videoid,
                v.views,
                t1.uploader,
                rank() OVER (PARTITION BY t1.uploader ORDER BY v.views DESC) r
         FROM (
                  SELECT uploader, videos
                  FROM users
                  ORDER BY videos DESC
                  LIMIT 10
              ) t1
                  JOIN
              video v
              ON t1.uploader = v.uploader
     ) t2
WHERE r <= 20;
/*
+----------------+--------------+--------+--+
|    uploader    |   videoid    | views  |
+----------------+--------------+--------+--+
| expertvillage  | -IxHBW0YpZw  | 39059  |
| expertvillage  | BU-fT5XI_8I  | 29975  |
| expertvillage  | ADOcaBYbMl0  | 26270  |
| expertvillage  | yAqsULIDJFE  | 25511  |
| expertvillage  | vcm-t0TJXNg  | 25366  |
| expertvillage  | 0KYGFawp14c  | 24659  |

| expertvillage  | IyQoDgaLM7U  | 10597  |
| expertvillage  | tbZibBnusLQ  | 10402  |
| expertvillage  | _GnCHodc7mk  | 9422   |
| expertvillage  | hvEYlSlRitU  | 7123   |
| Ruchaneewan    | 5_T5Inddsuo  | 3132   |
| Ruchaneewan    | wje4lUtbYNU  | 1086   |
| Ruchaneewan    | i8rLbOUhAlM  | 549    |
| Ruchaneewan    | OwnEtde9_Co  | 453    |
| Ruchaneewan    | 5Zf0lbAdJP0  | 441    |
| Ruchaneewan    | wenI5MrYT20  | 426    |
| Ruchaneewan    | Iq4e3SopjxQ  | 420    |

+----------------+--------------+--------+--+
40 rows selected (44.398 seconds)
*/

-- 统计每个类别视频观看数Top10
/*
 根据类别开窗接排序截取前10
 */

SELECT videoId, categories, `views`
FROM (
         SELECT videoId, categories, `views`, dense_rank() OVER (PARTITION BY categories ORDER BY `views` DESC ) r
         FROM video_category
     ) t
WHERE r <= 10;
/*
+--------------+----------------+-----------+--+
|   videoid    |   categories   |   views   |
+--------------+----------------+-----------+--+
| dMH0bHeiRNg  | Comedy         | 42513417  |

| aRNzWyD7C9o  | UNA            | 8825788   |

| RjrEQaG5jPM  | Autos          | 2803140   |

| -_CSo1gOd48  | Blogs          | 13199833  |

| eVFF98kNg8Q  | Blogs          | 1813803   |

| hut3VRL5XRE  | DIY            | 2684989   |

| bNF_P281Uu4  | Travel         | 5231539   |

| sdUUx5FdySs  | Animation      | 5840839   |

| QjA5faZF1A8  | Music          | 15256922  |

| pFlcqWQVVuU  | Gadgets        | 3651600   |

| bNF_P281Uu4  | Places         | 5231539   |

| Ugrlzm7fySE  | Sports         | 2867888   |

| RjrEQaG5jPM  | Vehicles       | 2803140   |

| 2GWPOPSXGYI  | Animals        | 3660009   |
|
| sdUUx5FdySs  | Film           | 5840839   |

| -_CSo1gOd48  | People         | 13199833  |

| hr23tpWX8lM  | Politics       | 4706030   |

| pFlcqWQVVuU  | Games          | 3651600   |

| hut3VRL5XRE  | Howto          | 2684989   |

| 2GWPOPSXGYI  | Pets           | 3660009   |

| 1dmVU08zVpA  | Entertainment  | 16087899  |

| hr23tpWX8lM  | News           | 4706030   |

+--------------+----------------+-----------+--+
210 rows selected (63.837 seconds)
*/