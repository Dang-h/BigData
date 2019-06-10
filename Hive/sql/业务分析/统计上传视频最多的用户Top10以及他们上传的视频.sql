-- 7 统计上传视频最多的用户Top10以及他们上传的观看次数在前20的视频

-- 查询上传视频最多的10个人 t1
SELECT uploader,
       videos
FROM users
ORDER BY videos DESC
LIMIT 10;

-- 和Video 表join， 查出这些人上传了那些视频 t2
SELECT v.videoid,
       v.views,
       t1.uploader,
       rank() OVER (PARTITION BY t1.uploader ORDER BY v.views DESC) r
FROM t1
         JOIN
     video v
     ON t1.uploader = v.uploader;

-- 查出每个人观看数在前20的视频
SELECT videoid,
       views,
       uploader
FROM t2
WHERE r <= 20;