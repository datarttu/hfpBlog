WITH 
-- Pivot "wide" table with days of week in cols
-- into "long" table with rows for valid dows only
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
-- Make a full set of individual dates for a basis for the next join.
-- Start date is MANUALLY SET and must be before the GTFS minimum date!
alldates AS (
	SELECT generate_series::date AS date, extract(DOW FROM generate_series) AS dow
	FROM generate_series('2019-01-01'::timestamp, now()::timestamp, '1 day'::interval)),
validdates AS (
	-- Now service_id is repeated for every single date on which it is valid:
	SELECT dows.service_id, alldates.date, alldates.dow
	FROM alldates
		INNER JOIN dows
		ON alldates.date <@ daterange(dows.start_date, dows.end_date + 1)
		AND alldates.dow = dows.dow
	-- Add calendar_dates with ADDED service
	UNION
	SELECT service_id, date, extract(DOW FROM date) AS dow 
	FROM gtfs_staging.calendar_dates
	WHERE exception_type = 1
	-- Remove calendar_dates with REMOVED service
	EXCEPT
	SELECT service_id, date, extract(DOW FROM date) AS dow 
	FROM gtfs_staging.calendar_dates
	WHERE exception_type = 2
	ORDER BY date)
SELECT service_id, array_agg(date) AS dates
FROM validdates
GROUP BY service_id
ORDER BY service_id;