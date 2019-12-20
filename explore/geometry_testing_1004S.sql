/*
Testing geometry stuff with exceptional route "1004S" (16 departures).
*/

-- Select points and some attributes
-- TODO

-- Create linestrings for each trip
-- TODO

-- Create shortest lines between points and respective trip linestrings
WITH ls AS (
SELECT route, dir, tsdep, ST_MakeLine(geom ORDER BY tst) AS geom
FROM hfp.points
WHERE route LIKE '1004S%'
GROUP BY route, dir, tsdep
)
SELECT pt.route, pt.dir, pt.tsdep, pt.tst,
ST_ShortestLine(pt.geom, ls.geom) AS geom
FROM hfp.points AS pt
INNER JOIN ls 
ON pt.route = ls.route AND pt.dir = ls.dir AND pt.tsdep = ls.tsdep