-- Using raw HFP v2 storage db
SELECT event_type, (stop is null) AS stop_null, count(tst)
FROM bus
WHERE event_type::text IN ('ARR', 'DEP', 'ARS', 'PDE', 'PAS', 'WAIT', 'DOO', 'DOC')
GROUP BY 1, 2
ORDER BY 1, 2;

SELECT event_type, (stop is null) AS stop_null, count(tst)
FROM tram
WHERE event_type::text IN ('ARR', 'DEP', 'ARS', 'PDE', 'PAS', 'WAIT', 'DOO', 'DOC')
GROUP BY 1, 2
ORDER BY 1, 2;

SELECT event_type, (stop is null) AS stop_null, count(tst)
FROM train
WHERE event_type::text IN ('ARR', 'DEP', 'ARS', 'PDE', 'PAS', 'WAIT', 'DOO', 'DOC')
GROUP BY 1, 2
ORDER BY 1, 2;
-- All events are strictly related to a stop except 'DOO' and 'DOC'.

SELECT event_type, (stop is null) AS stop_null, count(tst)
FROM metro
WHERE event_type::text IN ('ARR', 'DEP', 'ARS', 'PDE', 'PAS', 'WAIT', 'DOO', 'DOC')
GROUP BY 1, 2
ORDER BY 1, 2;
-- No data returned for metro...
SELECT event_type, count(tst)
FROM metro
GROUP BY event_type
ORDER BY event_type;
-- Metro only has VP events.
