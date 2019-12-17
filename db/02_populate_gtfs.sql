/*
Populate GTFS data tables.
Delete possible existing raw data.
TODO: also delete raw data that is not needed anymore at the end.
*/

\connect hfpdb;

BEGIN;

TRUNCATE gtfs_staging.calendar_dates CASCADE;
TRUNCATE gtfs_staging.calendar CASCADE;
TRUNCATE gtfs.routes CASCADE;
TRUNCATE gtfs_staging.shapes CASCADE;
TRUNCATE gtfs.shape_lines CASCADE;
TRUNCATE gtfs_staging.stops CASCADE;
TRUNCATE gtfs.stops CASCADE;
TRUNCATE gtfs.trips CASCADE;
TRUNCATE gtfs.stop_times CASCADE;

\copy gtfs_staging.calendar_dates FROM ../rawdata/hsl-gtfs_20190531-20190714/calendar_dates.txt CSV HEADER;
\copy gtfs_staging.calendar FROM ../rawdata/hsl-gtfs_20190531-20190714/calendar.txt CSV HEADER;
\copy gtfs.routes FROM ../rawdata/hsl-gtfs_20190531-20190714/routes.txt CSV HEADER;
\copy gtfs_staging.shapes FROM ../rawdata/hsl-gtfs_20190531-20190714/shapes.txt CSV HEADER;
\copy gtfs_staging.stops FROM ../rawdata/hsl-gtfs_20190531-20190714/stops.txt CSV HEADER;
\copy gtfs.trips FROM ../rawdata/hsl-gtfs_20190531-20190714/trips.txt CSV HEADER;
-- stop_times ignored as of 2019-12-17 since it is huge and not needed yet
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
FROM gtfs_staging.shapes
GROUP BY shape_id;

-- Transform stops with float coordinates into point geom table
INSERT INTO gtfs.stops
SELECT stop_id, stop_code, stop_name, stop_desc, zone_id, stop_url,
  location_type, parent_station, wheelchair_boarding, platform_code, vehicle_type,
  ST_Transform(
    ST_SetSRID(
      ST_MakePoint(stop_lon, stop_lat), 
      4326), 
    3067
  ) AS geom
FROM gtfs_staging.stops;

COMMIT;