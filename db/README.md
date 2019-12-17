# Database image and container

## Build and run

```
docker build -t hfpdb .
docker run --rm -d -e POSTGRES_PASSWORD=postgres -p 7001:5432 hfpdb
psql -p 7001 -U postgres -h localhost -d hfpdb
```

Scripts in `init/` are copied and run when the image is built,
so you should find e.g. the `hfp` schema in the database already.

You can check what tables you have, excluding the TimescaleDB and internal tables (inside a `psql` session):

```
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema !~* 'timescale|information|pg'
ORDER BY table_schema, table_name;
```

## Ingest data

Check if the `_populate` scripts are using correct raw data paths, and run them in a `psql` session (assuming you're in the `db/` directory):

```
\i 01_populate_hfp.sql
\i 02_populate_gtfs.sql
```

