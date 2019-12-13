# Build and run

```
docker build -t hfpdb .
docker run --rm -d -e POSTGRES_PASSWORD=postgres -p 7001:5432 hfpdb
```