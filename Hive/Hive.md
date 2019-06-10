# Hive

* * *

## Hive练习之影音Top N

- ## 需求

  - 统计视频观看数Top10
  - 统计视频类别热度Top10
  - 统计视频观看数Top20所属类别
  - 统计视频观看数Top50所关联视频的所属类别Rank
  - 统计每个类别中的视频热度Top10
  - 统计每个类别中视频流量Top10
  - 统计上传视频最多的用户Top10以及他们上传的视频
  - 统计每个类别视频观看数Top10

- Do it！😮

  - 数据结构
    视频表

| 字段          | 类型     |     备注 |           详细描述 |
| ----------- | ------ | -----: | -------------: |
| video id    | String | 视频唯一id |         11位字符串 |
| uploader    | String |  视频上传者 | 上传视频的用户名String |
| age         | Int    |   视频年龄 |     视频在平台上的整数天 |
| category    | Array  |   视频类别 |    上传视频指定的视频分类 |
| length      | Int    |   视频长度 |    整形数字标识的视频长度 |
| views       | Int    |   观看次数 |       视频被浏览的次数 |
| rate        | Double |   视频评分 |           满分5分 |
| Ratings     | Int    |     流量 |     视频的流量，整型数字 |
| conments    | Int    |    评论数 |     一个视频的整数评论数 |
| related ids | Array  | 相关视频id |  相关视频的id，最多20个 |

​			用户表

| 字段     | 说明         |   类型 |
| -------- | ------------ | -----: |
| uploader | 上传者用户名 | string |
| videos   | 上传视频数   |    int |
| friends  | 朋友数量     |    int |

- ETL原始数据
   - [数据处理]([https://github.com/Dang-h/movieETL](https://github.com/Dang-h/movieETL))
   - 数据准备
     - 打jar包上传服务器
     - 执行ETL
           ` hadoop jar movieETL ETLDriver /user/hive/warehouse/movie/data /user/hive/warehouse/movie/data/output`
- 完成需求
   - 建表
   
   - 关联数据
   
     ```sql
      # 将外部表数据导入到内部表video中
      INSERT INTO video
      SELECT *
      FROM vedo_ori;
      
      # 到数据到users表
      INSERT INTO users
      SELECT *
      FROM user_ori;
     ```
   
   - 业务分析
   
     - 统计视频观看数Top10
   
       `使用order by按照views字段做一个全局排序即可，同时我们设置只显示前10条`
   
     - 统计视频类别热度Top10
   
       ```
       1) 即统计每个类别有多少个视频，显示出包含视频最多的前10个类别。
       2) 我们需要按照类别group by聚合，然后count组内的videoId个数即可。
       3) 因为当前表结构为：一个视频对应一个或多个类别。所以如果要group by类别，需要先将类别进行列转行(展开)，然后再进行count即可。
       4) 最后按照热度排序，显示前10条。
       ```
   
     - 统计视频观看数Top20所属类别
   
       ```
       1) 先找到观看数最高的20个视频所属条目的所有信息，降序排列
       2) 把这20条信息中的category分裂出来(行转列)
       3) 最后查询视频分类名称和该分类下有多少个Top20的视频
       ```
   
     - 统计视频观看数Top50所关联视频的所属类别Rank
   
       ```
       1)	查询出观看数最多的前50个视频的所有信息(当然包含了每个视频对应的关联视频)，记为临时表t1
       2)	将找到的50条视频信息的相关视频relatedId列转行，记为临时表t2
       3)	将相关视频的id和gulivideo_orc表进行inner join操作
       4) 按照视频类别进行分组，统计每组视频个数，然后排行
       ```
   
     - 统计每个类别中的视频热度Top10
   
       ```
       1) 要想统计Music类别中的视频热度Top10，需要先找到Music类别，那么就需要将category展开，所以可以创建一张表用于存放categoryId展开的数据。
       2) 向category展开的表中插入数据。
       3) 统计对应类别（Music）中的视频热度。
       ```
   
     - 统计每个类别中视频流量Top10
   
       ```
       1) 创建视频类别展开表（categoryId列转行后的表）
       2) 按照ratings排序即可
       ```
   
     - 统计上传视频最多的用户Top10以及他们上传的视频
   
       ```
       1) 先找到上传视频最多的10个用户的用户信息
       2) 通过uploader字段与gulivideo_orc表进行join，得到的信息按照views观看次数进行排序即可。
       ```
   
     - 统计每个类别视频观看数Top10
   
       ```
       1) 先得到categoryId展开的表数据
       2) 子查询按照categoryId进行分区，然后分区内排序，并生成递增数字，该递增数字这一列起名为rank列
       3) 通过子查询产生的临时表，查询rank值小于等于10的数据行即可。
       ```
   
       
