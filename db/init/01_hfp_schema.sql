CREATE DATABASE hfpdb;
\connect hfpdb;

CREATE EXTENSION postgis;

CREATE SCHEMA hfp;

CREATE TABLE hfp.staging (
  desi    text,
  dir     smallint,
  veh     smallint,
  tst     timestamptz,
  spd     real,
  hdg     smallint,
  lat     real,
  long    real,
  acc     real,
  dl      integer,
  odo     integer,
  drst    boolean,
  oday    date,
  start   interval
);

CREATE TABLE hfp.points (
  desi    text          NOT NULL,
  dir     smallint      NOT NULL,
  tsdep   timestamptz   NOT NULL,
  tst     timestamptz   NOT NULL,
  veh     smallint,
  spd     real,
  hdg     smallint,
  acc     real,
  dl      integer,
  odo     integer,
  drst    boolean,
  geom    geometry      NOT NULL,
  PRIMARY KEY (desi, dir, tsdep, tst)
);
