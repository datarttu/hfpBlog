/*
2020-01-23
Get necessary data from raw HFPv2 database tables for bus and tram,
for stop events clustering & analysis.
As of 23.1., there is just some hours of data in the db.
*/
\copy (
  SELECT 'bus' AS mode, event_type, oper, veh, tst, lat, long, route, dir, stop
  FROM bus
  WHERE stop IS NOT NULL
  UNION
  SELECT 'tram' AS mode, event_type, oper, veh, tst, lat, long, route, dir, stop
  FROM bus
  WHERE stop IS NOT NULL
)
TO 'hfp_stopevents_2020-01-23.csv' CSV HEADER;
