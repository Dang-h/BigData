-- 3. 统计出视频观看数最高的20个视频的所属类别以及类别包含Top20视频的个数

-- 查出观看数最高的20个视频 t1
SELECT videoid,
       category,
       views
FROM video
ORDER BY views DESC
LIMIT 20;

-- 炸开视频类别 t2
SELECT videoid,
       categories
FROM (SELECT videoid,
             category,
             views
      FROM video
      ORDER BY views DESC
      LIMIT 20) t1
    LATERAL VIEW explode(category) tbl AS categories;

-- 重新按照视频类别统计
SELECT categories,
       count(*) hot
FROM (SELECT videoid,
             categories
      FROM (SELECT videoid,
                   category,
                   views
            FROM video
            ORDER BY views DESC
            LIMIT 20) t1
          LATERAL VIEW explode(category) tbl AS categories) t2
GROUP BY categories;