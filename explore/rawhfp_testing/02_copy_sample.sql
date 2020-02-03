\set ON_ERROR_STOP TRUE \c hfp;

BEGIN;

COPY hfp_staging
FROM PROGRAM 'gzip -cd /data/hfp_stopevents_2020-01-23.csv.gz' CSV HEADER;


INSERT INTO hfp_stop_events
SELECT mode,
       event_type,
       oper,
       veh,
       tst,
       route,
       dir,
       stop, -- We transform the points right away to Finnish TM35 system (3067)
 -- to enable easier distance calculations etc.
 -- Original coordinates are in WGS84 (4326).
 ST_Transform(ST_SetSRID(ST_MakePoint(long, lat), 4326), 3067) AS geom
FROM hfp_staging ON CONFLICT DO NOTHING;

TRUNCATE TABLE hfp_staging;


COMMIT;
