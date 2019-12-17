-- omit agency

CREATE TABLE gtfs.calendar_dates (
  service_id     text         NOT NULL,
  date           date         NOT NULL,
  exception_type smallint     NOT NULL,
  PRIMARY KEY (service_id, date)
);

CREATE TABLE gtfs.calendar (
  service_id     text         PRIMARY KEY,
  monday         boolean      NOT NULL,
  tuesday        boolean      NOT NULL,
  wednesday      boolean      NOT NULL,
  thursday       boolean      NOT NULL,
  friday         boolean      NOT NULL,
  saturday       boolean      NOT NULL,
  sunday         boolean      NOT NULL,
  start_date     date         NOT NULL,
  end_date       date         NOT NULL
);

-- omit call_line_phone_numbers
-- omit fare_attributes
-- omit fare_rules
-- omit feed_info

CREATE TABLE gtfs.routes (
  route_id          text        PRIMARY KEY,
  agency_id         text,
  route_short_name  text,
  route_long_name   text,
  route_desc        text,
  route_type        smallint    NOT NULL,
  route_url         text
);

CREATE TABLE gtfs.shapes (
  shape_id            text          NOT NULL,
  shape_pt_lat        numeric(8, 6) NOT NULL,
  shape_pt_lon        numeric(8, 6) NOT NULL,
  shape_pt_sequence   integer       NOT NULL,
  shape_dist_traveled real,
  PRIMARY KEY (shape_id, shape_pt_sequence)
);

/*
Non-gtfs table for linestring representations
of the above shapes.
*/
CREATE TABLE gtfs.shape_lines (
  shape_id            text          PRIMARY KEY,
  total_dist_traveled real
);
SELECT AddGeometryColumn ('gtfs', 'shape_lines', 'geom', 3067, 'LINESTRING', 2);

CREATE TABLE gtfs.stops (
  stop_id             integer       PRIMARY KEY,
  stop_code           text,
  stop_name           text,
  stop_desc           text,
  stop_lat            numeric(8, 6) NOT NULL,
  stop_lon            numeric(8, 6) NOT NULL,
  zone_id             text,
  stop_url            text,
  location_type       smallint,
  parent_station      integer,
  wheelchair_boarding smallint,
  platform_code       text,
  vehicle_type        smallint -- NOTE: non-standard attribute by HSL
);

/*
Non-gtfs table for point geometry representations
of the above stops.
*/
CREATE TABLE gtfs.stop_points (
  stop_id             integer       PRIMARY KEY,
  stop_code           text,
  stop_name           text,
  stop_desc           text,
  zone_id             text,
  stop_url            text,
  location_type       smallint,
  parent_station      integer,
  wheelchair_boarding smallint,
  platform_code       text,
  vehicle_type        smallint -- NOTE: non-standard attribute by HSL
);
SELECT AddGeometryColumn ('gtfs', 'stop_points', 'geom', 3067, 'POINT', 2);

-- omit translations

CREATE TABLE gtfs.trips (
  route_id              text      REFERENCES gtfs.routes (route_id),
  service_id            text      NOT NULL,  -- refers to calendar. OR calendar_date.service_id!
  trip_id               text      PRIMARY KEY,
  trip_headsign         text,
  direction_id          smallint,
  shape_id              text,     -- References gtfs.shape_lines, 
                                  -- but cannot be enforced until that table is populated
  wheelchair_accesible  smallint  DEFAULT 0,
  bikes_allowed         smallint  DEFAULT 0,
  max_delay             smallint  -- NOTE: non-standard attribute by HSL
);

CREATE TABLE gtfs.stop_times (
  trip_id             text      REFERENCES gtfs.trips (trip_id),
  arrival_time        interval  NOT NULL,
  departure_time      interval  NOT NULL,
  stop_id             integer   REFERENCES gtfs.stops (stop_id),
  stop_sequence       smallint  NOT NULL,
  stop_headsign       text,
  pickup_type         smallint  DEFAULT 0,
  drop_off_type       smallint  DEFAULT 0,
  shape_dist_traveled real,
  timepoint           boolean  DEFAULT TRUE,
  PRIMARY KEY (trip_id, stop_sequence)
);