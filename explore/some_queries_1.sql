/*SELECT desi, dir, tsdep, min(dist) AS mindist, avg(dist) AS avgdist, max(dist) AS maxdist, count(geom) AS nlinks
FROM consec_dist
GROUP BY desi, dir, tsdep
ORDER BY desi, dir, tsdep;
*/
--select * from points where desi = '1' and dir = 1 and tsdep = '2019-06-05 15:06:00+00';
/*select time_bucket('15 minutes', tst) as tb, count(desi)
from points
group by 1
order by 1;
*/
--select * from consec_dist limit 100;
--select distinct desi from points order by desi;
with deps as (select distinct desi, dir, tsdep from points)
select desi, dir, count(tsdep) from deps group by desi, dir order by 3 desc; 

WITH inm AS 
(SELECT
  shape_id,
  max(shape_dist_traveled) AS total_dist_traveled,
  ST_Transform(
    ST_MakeLine(
      ST_SetSRID(
        ST_MakePoint(shape_pt_lon, shape_pt_lat),
        4326
        ) ORDER BY shape_pt_sequence
      ),
    3067
  ) AS geom
FROM gtfs.shapes
GROUP BY shape_id)
SELECT *, ST_Length(geom)/1000 AS len_km, 1 - total_dist_traveled / (ST_Length(geom)/1000) AS reldiff
FROM inm
LIMIT 100;

select * from gtfs.trips
inner join gtfs.shape_lines
using (shape_id)
limit 100;