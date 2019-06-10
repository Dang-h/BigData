-- 5 统计每个类别中的视频热度Top10，以Music为例

-- 炸开类别表 t1
SELECT videoid,
       views,
       categories
FROM video lateral VIEW
    explode(category) tbl AS categories;

-- 查出Music类观看数最高的10个视频
SELECT videoid,
       views
FROM t1
WHERE t1.categories = "Music"
ORDER BY views DESC
LIMIT 10;