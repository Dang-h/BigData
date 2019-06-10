-- 8 统计每个类别视频观看数Top10

-- 从分类别中间表查起，查每个类别观看数排名 t1
SELECT videoid,
       views,
       categories,
       rank() OVER (PARTITION BY categories ORDER BY views DESC) r
FROM video_category;


-- 找每个类别的前10
SELECT categories,
       videoid,
       views
FROM t1
WHERE r <= 10;