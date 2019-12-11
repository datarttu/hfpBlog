-- Calculate distances between consecutive points per trip.
CREATE VIEW consec_dist AS (
  WITH consec_pts AS
  (SELECT
    desi, dir, tsdep, tst AS tsfrom,
    lead(tst, 1) OVER (PARTITION BY desi, dir, tsdep ORDER BY tst) AS tsto,
    geom AS ptfrom,
    lead(geom, 1) OVER (PARTITION BY desi, dir, tsdep ORDER BY tst) AS ptto
  FROM hfp.points)
  SELECT
    desi, dir, tsdep,
    tsfrom, tsto, (tsto - tsfrom) AS tsdelta,
    ST_Distance(ptfrom, ptto) AS dist,
    ST_MakeLine(ptfrom, ptto) AS geom
  FROM consec_pts
  WHERE tsto IS NOT NULL AND ptto IS NOT NULL
);

/*
SELECT desi, dir, tsdep, min(dist) AS mindist, avg(dist) AS avgdist, max(dist) AS maxdist, count(geom) AS nlinks
FROM consec_dist
GROUP BY desi, dir, tsdep
ORDER BY desi, dir, tsdep;
*/
