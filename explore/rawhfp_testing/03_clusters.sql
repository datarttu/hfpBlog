/*
Clustering of stop events by stop id.
*/


CREATE TABLE cluster_sample_multipts AS (
  WITH sample AS (
    SELECT * FROM hfp_stop_events ORDER BY random() LIMIT 100000
  )
  SELECT stop, ST_Union(geom) AS geom
  FROM sample
  GROUP BY stop
);
CREATE INDEX ON cluster_sample_multipts USING GIST (geom);

/*
For QGIS:
*/
-- Layer 0: point collections
SELECT stop, geom
FROM cluster_sample_multipts;

-- Layer 1: centroid points per stop
SELECT stop, ST_Centroid(geom) AS geom
FROM cluster_sample_multipts;

-- Layer 2: convex hulls and areas per stop
SELECT stop, ST_Area(ST_ConvexHull(geom)) AS area, ST_ConvexHull(geom)
FROM cluster_sample_multipts
ORDER BY 2 DESC;
