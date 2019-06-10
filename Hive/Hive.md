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

用户表

| item     | Model  |  Price |
| -------- | ------ | -----: |
| uploader | 上传者用户名 | string |
| videos   | 上传视频数  |    int |
| friends  | 朋友数量   |    int |

- ETL原始数据
   - [数据处理]([https://github.com/Dang-h/movieETL](https://github.com/Dang-h/movieETL))
   - 数据准备
     - 打jar包上传服务器
     - 执行ETL
           ` hadoop jar movieETL ETLDriver /user/hive/warehouse/movie/data /user/hive/warehouse/movie/data/output`
- 完成需求
   - 建表
   - 关联数据
   - 业务分析
