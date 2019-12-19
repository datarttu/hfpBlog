-- Are arr and dep times always the same?
-- Does it depend on timepoint field?
select * from gtfs.stop_times where arrival_time <> departure_time limit 100;
select timepoint, (arrival_time <> departure_time) as diff_arr_dep, count(trip_id) 
from gtfs.stop_times
group by 1, 2;

-- So it seems that many timepoint stops have different arr and dep times.
-- There are some with timepoint = false, though:
select distinct on (stop_id) * from gtfs.stop_times 
where timepoint is false and arrival_time <> departure_time;
-- Seems to be one stop only.

-- We assume that the arr-dep times are defined not more accurately than full minutes.
-- Check if this holds:
select count(trip_id) from gtfs.stop_times
where extract(second from arrival_time) <> 0
or extract(second from departure_time) <> 0;
-- Yes, all the seconds parts are 0.

-- Are there errors where arr time is later than dep time?
select count(trip_id) from gtfs.stop_times
where arrival_time > departure_time;
-- No.