-- 4. 统计视频观看数Top50所关联视频的所属类别排序

-- 查出视频Top50及其关联视频 t1
SELECT videoid,
       relatedid,
       views
FROM video
ORDER BY views DESC
LIMIT 50;

-- 炸开关联视频 t2
SELECT explode(relatedid) videoid
FROM t1;

-- 获取关联视频的类别，跟原表join t3
SELECT DISTINCT t2.videoid,
                v.category
FROM t2
         JOIN
     video v
     ON
         v.videoid = t2.videoid;

-- 给所属类别排序
SELECT categories,
       count(*) hot
FROM t3 lateral VIEW explode(category) tbl AS categories
GROUP BY categories
ORDER BY hot
DESC
    limit 100;