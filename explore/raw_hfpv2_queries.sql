-- Using raw HFP v2 storage db
SELECT event_type, (stop is null) AS stop_null, count(tst) 
FROM bus 
WHERE event_type::text IN ('ARR', 'DEP', 'ARS', 'PDE', 'PAS', 'WAIT', 'DOO', 'DOC')
GROUP BY 1, 2
ORDER BY 1, 2;