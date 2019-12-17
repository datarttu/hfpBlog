/*
Create HFP-GTFS-network database, extensions and empty schemata.
"_staging" schemata are created for raw data that is eventually deleted,
once transformed to the actual tables.
Assuming "postgres" superuser.
*/
CREATE DATABASE hfpdb;
\connect hfpdb;

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS timescaledb;

CREATE SCHEMA IF NOT EXISTS hfp_staging;
CREATE SCHEMA IF NOT EXISTS hfp;
CREATE SCHEMA IF NOT EXISTS gtfs_staging;
CREATE SCHEMA IF NOT EXISTS gtfs;