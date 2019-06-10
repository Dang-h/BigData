-- 1. 统计视频观看数Top10
SELECT videoid,
       views
FROM video
ORDER BY views DESC
LIMIT 10;