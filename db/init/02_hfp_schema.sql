\connect hfpdb;

CREATE TABLE hfp_staging.points (
  route   text,
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
  route   text          NOT NULL,
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
  PRIMARY KEY (route, dir, tsdep, tst)
);

-- 2D point geom column using ETRS-TM35;
-- this function takes care of constraints and indexes
-- as opposed to stating `geom   geometry, ...` above.
SELECT AddGeometryColumn ('hfp', 'points', 'geom', 3067, 'POINT', 2);

-- Partition the large points table using Timescale hypertable
SELECT create_hypertable('hfp.points', 'tst', chunk_time_interval => interval '1 day');