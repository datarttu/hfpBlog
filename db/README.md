# Database image and container

## Build and run

```
docker build -t hfpdb .
docker run --rm -d -e POSTGRES_PASSWORD=postgres -p 7001:5432 hfpdb
psql -p 7001 -U postgres -h localhost -d hfpdb
```

Scripts in `init/` are copied and run when the image is built,
so you should find e.g. the `hfp` schema in the database already.

## Ingest data

```
postgres=# \copy hfp.staging from ../rawdata/tidy/hsl_tram_geo4_tidy_2019-06-05.csv csv header;
```