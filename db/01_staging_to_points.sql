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
FROM hfp.staging
ON CONFLICT DO NOTHING;
