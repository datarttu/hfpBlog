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

\copy gtfs_staging.calendar_dates FROM ../rawdata/gtfs/calendar_dates.txt CSV HEADER;
\copy gtfs_staging.calendar FROM ../rawdata/gtfs/calendar.txt CSV HEADER;
\copy gtfs.routes FROM ../rawdata/gtfs/routes.txt CSV HEADER;
\copy gtfs_staging.shapes FROM ../rawdata/gtfs/shapes.txt CSV HEADER;
\copy gtfs_staging.stops FROM ../rawdata/gtfs/stops.txt CSV HEADER;
\copy gtfs.trips FROM ../rawdata/gtfs/trips.txt CSV HEADER;
\copy gtfs.stop_times FROM ../rawdata/gtfs/stop_times.txt CSV HEADER;

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