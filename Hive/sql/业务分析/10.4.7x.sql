-- 7 统计上传视频最多的用户Top10以及他们上传的观看次数在前20的视频

-- 前20的视频哪些是由前10用户上传的

-- 上传视频前10的用户 t1
SELECT uploader,
       videos
FROM users
ORDER BY videos DESC
LIMIT 10;

-- 观看次数在前20的视频 t2
SELECT videoid,
       uploader,
       views
FROM video
ORDER BY views DESC
LIMIT 20;

-- t2 left join t1 看看前20的视频哪些由前10上传
SELECT t2.videoid,
       t1.uploader
FROM t2
         LEFT JOIN
     t1
     ON
         t1.uploader = t2.uploader;