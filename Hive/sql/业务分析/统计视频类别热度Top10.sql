-- 2. 统计视频类别热度Top10
SELECT categories,
       count(*) hot,
       sum(views) hot2
FROM video lateral VIEW explode(category) tbl AS categories
GROUP BY
    categories
ORDER BY hot2
DESC
    limit 10;