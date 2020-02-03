CREATE DATABASE hfp;
\c hfp;
CREATE EXTENSION postgis;
CREATE EXTENSION timescaledb;

CREATE TYPE mode AS ENUM('bus', 'tram', 'train', 'metro', 'ferry');
CREATE TYPE event_type AS ENUM(
  'VP', 'DUE', 'ARR', 'DEP', 'ARS', 'PDE', 'PAS', 'WAIT', 'DOO', 'DOC',
  'TLR', 'TLA', 'DA', 'DOUT', 'BA', 'BOUT', 'VJA', 'VJOUT'
);

CREATE TABLE hfp_staging (
  mode        mode,
  event_type  event_type,
  oper        smallint,
  veh         integer,
  tst         timestamptz,
  lat         real,
  long        real,
  route       text,
  dir         smallint,
  stop        integer
);

CREATE TABLE hfp_stop_events (
  mode        text,
  event_type  text,
  oper        smallint,
  veh         integer,
  tst         timestamptz,
  route       text,
  dir         smallint,
  stop        integer,
  PRIMARY KEY (tst, event_type, oper, veh)
);
SELECT AddGeometryColumn ('public', 'hfp_stop_events', 'geom', 3067, 'POINT', 2);
SELECT create_hypertable('hfp_stop_events', 'tst', chunk_time_interval => interval '1 hour');
CREATE INDEX hfp_stop_events_geom_idx
  ON hfp_stop_events
  USING GIST (geom);
