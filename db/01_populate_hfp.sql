/*
Populate HFP data tables.
Delete possible existing raw data, 
and the imported raw data at the end.
*/

\connect hfpdb;

BEGIN;

TRUNCATE hfp_staging.points;

\copy hfp_staging.points FROM ../rawdata/tidy/hsl_tram_geo4_tidy_2019-06-03.csv CSV HEADER;
\copy hfp_staging.points FROM ../rawdata/tidy/hsl_tram_geo4_tidy_2019-06-04.csv CSV HEADER;
\copy hfp_staging.points FROM ../rawdata/tidy/hsl_tram_geo4_tidy_2019-06-05.csv CSV HEADER;
\copy hfp_staging.points FROM ../rawdata/tidy/hsl_tram_geo4_tidy_2019-06-06.csv CSV HEADER;
\copy hfp_staging.points FROM ../rawdata/tidy/hsl_tram_geo4_tidy_2019-06-07.csv CSV HEADER;
\copy hfp_staging.points FROM ../rawdata/tidy/hsl_tram_geo4_tidy_2019-06-08.csv CSV HEADER;
\copy hfp_staging.points FROM ../rawdata/tidy/hsl_tram_geo4_tidy_2019-06-09.csv CSV HEADER;

INSERT INTO hfp.points
SELECT
  desi,
  dir,
  -- Start day and time in Finnish local time in the raw data
  (oday + start) AT TIME ZONE 'Europe/Helsinki' AS tsdep,
  tst,
  veh,
  spd,
  hdg,
  acc,
  dl,
  odo,
  drst,
  -- We transform the points right away to Finnish TM35 system (3067)
  -- to enable easier distance calculations etc.
  -- Original coordinates are in WGS84 (4326).
  ST_Transform(
    ST_SetSRID(
      ST_MakePoint(long, lat),
      4326),
    3067) AS geom
FROM hfp_staging.points
ON CONFLICT DO NOTHING;

TRUNCATE hfp_staging.points;

COMMIT;