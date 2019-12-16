\connect hfpdb;
BEGIN;
TRUNCATE gtfs.calendar_dates;
TRUNCATE gtfs.calendar;
TRUNCATE gtfs.routes CASCADE;
TRUNCATE gtfs.shapes;
TRUNCATE gtfs.shape_lines;
TRUNCATE gtfs.stops CASCADE;
TRUNCATE gtfs.stop_points;
TRUNCATE gtfs.trips CASCADE;
TRUNCATE gtfs.stop_times;
\copy gtfs.calendar_dates FROM ../rawdata/hsl-gtfs_20190531-20190714/calendar_dates.txt CSV HEADER;
\copy gtfs.calendar FROM ../rawdata/hsl-gtfs_20190531-20190714/calendar.txt CSV HEADER;
\copy gtfs.routes FROM ../rawdata/hsl-gtfs_20190531-20190714/routes.txt CSV HEADER;
\copy gtfs.shapes FROM ../rawdata/hsl-gtfs_20190531-20190714/shapes.txt CSV HEADER;
\copy gtfs.stops FROM ../rawdata/hsl-gtfs_20190531-20190714/stops.txt CSV HEADER;
\copy gtfs.trips FROM ../rawdata/hsl-gtfs_20190531-20190714/trips.txt CSV HEADER;
--\copy gtfs.stop_times FROM ../rawdata/hsl-gtfs_20190531-20190714/stop_times.txt CSV HEADER;

-- Transform row-wise shape points into linestring table
INSERT INTO gtfs.shape_lines
SELECT
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
GROUP BY shape_id;

-- Transform stops with float coordinates into point geom table
INSERT INTO gtfs.stop_points
SELECT stop_id, stop_code, stop_name, stop_desc, zone_id, stop_url,
  location_type, parent_station, wheelchair_boarding, platform_code, vehicle_type,
  ST_Transform(
    ST_SetSRID(
      ST_MakePoint(stop_lon, stop_lat), 
      4326), 
    3067
  ) AS geom
FROM gtfs.stops;

COMMIT;