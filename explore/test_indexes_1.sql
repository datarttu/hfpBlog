\timing 1
\o indexes.out
BEGIN;

SELECT time_bucket('3 hours', tst) AS tb, count(tst) AS n
FROM hfp.points
GROUP BY 1
ORDER BY 1;

CREATE INDEX pts_tst_brin ON hfp.points USING BRIN(tst);

SELECT time_bucket('3 hours', tst) AS tb, count(tst) AS n
FROM hfp.points
GROUP BY 1
ORDER BY 1;

ROLLBACK;
\o