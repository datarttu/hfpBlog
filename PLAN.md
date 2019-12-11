# HFP data exploration: *plan*

## 1. HFP data and its quality

- Features and structure of HFP v1 (vehicle positions)
  - *Sample rows of raw data*
  - Here we focus on geometry, time and speed; door statuses etc. later
- What is a route, direction and a trip; points = observations
  - *Demo svg drawing*
- Creating a database, inserting raw data and transforming it
- How to distinguish between trips
  - *Sample rows by desi, dir and tsdep*
  - *A few trip lines on a map*
- Geometry quality
  - Distances between consecutive points within a trip
  - Total trajectory length vs. number of points of a trip
  - Euclidean distance of first and last point vs. total trajectory length;
  classify distributions by route
  - Do we find reasonable limits for quality, i.e., clear outliers?
- Spatiotemporal quality
  - Speed value distribution from all points: outliers?
  - Speed value vs. distance / timedelta of consecutive points within a trip
  - Can we again detect erroneous points systematically?
- A universal analysis or error detection method available?
  - Possible metrics
  - Now that we examined one day data in detal,
  go through all the data of a month automatically

## 2. HFP versus GTFS

- Short intro of GTFS
- How to match HFP and GTFS trips
- How many trips found in GTFS are missing in HFP?
Are there any the other way around?
- How well do HFP points follow GTFS geometries?
  - Comment: GTFS geoms are not perfectly aligned with the network
  - Distance between HFP point and nearest point on corresponding line: distribution
    - Do we find clear outliers, and are they correlated?
    I.e., can we detect exceptional routes from spatiotemporal data?
- Stop events
  - Door status attribute: number of points with true, false and null
  - Are true values always close to a stop?
  Are they bunched well or are there spatial outliers?
  - Where are the null values located in space and time?

## 3. Snapping GTFS and HFP data to a network

General idea: making HFP data into a generalized, comparable format while minimizing the amount of data required for analyses.
E.g., remove excess points when the vehicle is stopped.
