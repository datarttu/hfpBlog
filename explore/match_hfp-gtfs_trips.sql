/*
GTFS trips table does NOT store
1) initial dep time of the entire trip
2) operating day of the trip
as HFP does.
Can we model the trips, i.e., departures,
the same way as we do with HFP?
*/

-- Distinct departures from HFP look like this.
-- These are the first points of each departure,
-- assuming the data is already sorted by tst.
SELECT distinct on (route, dir, tsdep) route, dir, tsdep, tst, ST_AsText(geom) AS geomtext
FROM hfp.points 
LIMIT 10;

-- Unique tram route identifiers in GTFS:
SELECT DISTINCT route_id 
FROM gtfs.routes 
WHERE route_type = 0
ORDER BY route_id;

-- Do the HFP route ids match GTFS routes?
SELECT DISTINCT g.route_id AS gtfs_route, h.route AS hfp_route
FROM hfp.points AS h
	FULL JOIN (
		SELECT DISTINCT route_id 
		FROM gtfs.routes 
		WHERE route_type = 0) AS g
	ON h.route = g.route_id
ORDER BY 1, 2;
-- HFP seems to have a number of different route id variants,
-- but the base part up to 5 characters looks similar to GTFS.
-- Let's look into this by picking a day and a route.
-- (Run this in QGIS for viz.)
SELECT route, dir, tsdep, tst, hdg, geom 
FROM hfp.points 
WHERE tst::date = '2019-07-01' 
	AND route LIKE '1010%'
ORDER BY random()
LIMIT 10000;

-- Looks like the last digit variants are used for
-- different "stub" routes, i.e., the tram is coming from
-- or going to a depot.
-- Using only the first 5 characters from the HFP route id
-- seems to solve the matching issue:
WITH h_trimmed AS (
	SELECT DISTINCT rtrim(left(route, 5)) AS route_trimmed
	FROM hfp.points)
SELECT DISTINCT 
	g.route_id AS gtfs_route, 
	h.route_trimmed AS hfp_route
FROM h_trimmed AS h
	FULL JOIN (
		SELECT DISTINCT route_id 
		FROM gtfs.routes 
		WHERE route_type = 0) AS g
	ON h.route_trimmed = g.route_id
ORDER BY 1, 2;
-- Except for route "4S" in this case.
-- I think it was a temporary route:
WITH deps AS (
	SELECT DISTINCT route, dir, tsdep 
	FROM hfp.points
	WHERE route LIKE '1004%')
SELECT rtrim(left(route, 5)) AS route_trimmed,
	min(tsdep::date) AS mindate,
	max(tsdep::date) AS maxdate,
	count(route) AS n
FROM deps
GROUP BY 1
ORDER BY 1;
-- Yes, 4S only had 16 departures and on one day only.

-- Let's now see if we can match individual HFP and GTFS departures,
-- i.e., trips.
-- We're going to need the distinct HFP departures
-- quite much so let us assign them to a temporary table;
-- a view would mean running the same query again every time.
CREATE TEMPORARY TABLE hfp_deps AS (
	SELECT DISTINCT rtrim(left(route, 5)) AS route, dir, tsdep 
	FROM hfp.points);
SELECT * FROM hfp_deps LIMIT 15;

-- For each route and direction, there is a separate row
-- for each day AND clock time in the HFP departures.
-- Since these are real trips where all the reality-related
-- attributes vary, we cannot aggregate multiple trips/departures
-- into "general" trips valid for a period of time, as in GTFS.
-- Therefore, we have to make GTFS trips into individual departures
-- and then we can try to match them with HFP departures.
-- We tried out the "calendar transformation" earlier,
-- and this should be made part of the staging from raw GTFS
-- to actual GTFS / "plan" schema.
-- But now we do not use the "array_agg" but let the table
-- be "long" along individual dates instead.
CREATE TEMPORARY TABLE gtfs_cal AS (
WITH 
dows AS (
	SELECT service_id, 0 AS dow, start_date, end_date
	FROM gtfs_staging.calendar WHERE sunday IS TRUE
	UNION
	SELECT service_id, 1 AS dow, start_date, end_date
	FROM gtfs_staging.calendar WHERE monday IS TRUE
	UNION
	SELECT service_id, 2 AS dow, start_date, end_date
	FROM gtfs_staging.calendar WHERE tuesday IS TRUE
	UNION
	SELECT service_id, 3 AS dow, start_date, end_date
	FROM gtfs_staging.calendar WHERE wednesday IS TRUE
	UNION
	SELECT service_id, 4 AS dow, start_date, end_date
	FROM gtfs_staging.calendar WHERE thursday IS TRUE
	UNION
	SELECT service_id, 5 AS dow, start_date, end_date
	FROM gtfs_staging.calendar WHERE friday IS TRUE
	UNION
	SELECT service_id, 6 AS dow, start_date, end_date
	FROM gtfs_staging.calendar WHERE saturday IS TRUE),
alldates AS (
	SELECT generate_series::date AS date, extract(DOW FROM generate_series) AS dow
	FROM generate_series('2019-01-01'::timestamp, now()::timestamp, '1 day'::interval)),
validdates AS (
	SELECT dows.service_id, alldates.date, alldates.dow
	FROM alldates
		INNER JOIN dows
		ON alldates.date <@ daterange(dows.start_date, dows.end_date + 1)
		AND alldates.dow = dows.dow
	UNION
	SELECT service_id, date, extract(DOW FROM date) AS dow 
	FROM gtfs_staging.calendar_dates
	WHERE exception_type = 1
	EXCEPT
	SELECT service_id, date, extract(DOW FROM date) AS dow 
	FROM gtfs_staging.calendar_dates
	WHERE exception_type = 2
	ORDER BY date)
SELECT service_id, date
FROM validdates
ORDER BY service_id);
SELECT * FROM gtfs_cal LIMIT 15;

-- Individual departures in GTFS are stored by table "trips",
-- which we have to make into "trips for each date" by using the above calendar.
-- Let's at this point use the "route" table to help filtering out
-- everything except tram trips.
-- But the "trip" table does not contain the initial departure time of the trip;
-- we have to get it from the "stop_times" table,
-- where it logically should be the first stop time of each trip,
-- that is, with stop_sequence = 1.
CREATE TEMP TABLE gtfs_ind_deps AS (
WITH 
tramroutes AS (
	SELECT DISTINCT route_id FROM gtfs.routes WHERE route_type = 0),
first_stops AS (
	SELECT trip_id, departure_time FROM gtfs.stop_times WHERE stop_sequence = 1)
SELECT route_id, gtfs.trips.service_id, gtfs.trips.trip_id, direction_id, departure_time, date
FROM gtfs.trips
	LEFT JOIN gtfs_cal ON gtfs.trips.service_id = gtfs_cal.service_id
	LEFT JOIN gtfs.stop_times ON gtfs.trips.trip_id = gtfs.stop_times.trip_id
WHERE route_id IN (SELECT route_id FROM tramroutes)
	);
-- TODO: Limit calendar to HFP date range