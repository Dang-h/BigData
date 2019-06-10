-- 统计每个类别中视频流量Top10，以Music为例

-- 由于和之前业务有相同的中间表，抽离成一张临时表
CREATE TABLE video_category
    STORED AS orc AS
SELECT videoId,
       uploader,
       categories,
       age,
       length,
       views,
       rate,
       ratings,
       comments,
       relatedId
FROM video lateral VIEW
    explode(category) tbl AS categories;

-- 直接查询Music类流量前10
SELECT videoid,
       ratings
FROM video_category
WHERE categories = "Music"
ORDER BY ratings DESC
LIMIT 10;
