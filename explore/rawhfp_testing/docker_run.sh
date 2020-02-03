#!/usr/bin/env bash
docker run -d --name rawhfp-test \
-p 127.0.0.1:5434:5432 -e POSTGRES_PASSWORD=postgres \
-v /home/keripukki/dataa/hfp/hfpblog_2019-12/rawhfp_vol:/data:ro \
timescale/timescaledb-postgis:latest-pg11
