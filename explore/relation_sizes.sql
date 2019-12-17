select 
	table_schema, 
	table_name, 
	pg_size_pretty(pg_relation_size('"'||table_schema||'"."'||table_name||'"'))
from information_schema.tables
where table_schema !~* 'timescale|information|pg'
order by 3 desc;