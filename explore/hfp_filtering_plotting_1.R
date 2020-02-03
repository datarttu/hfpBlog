#' Plot a trip of 1014 in space-time,
#' find out if redundant raw points can be dropped.
library(RPostgreSQL)
library(tidyverse)
library(lubridate)

con <- dbConnect(drv = dbDriver('PostgreSQL'),
                 host = 'localhost',
                 port = 5434,
                 dbname = 'test_1014',
                 user = 'postgres',
                 password = 'postgres')

query <- "
WITH pts AS (
SELECT tst, event, drst, ST_Transform(geom, 3067) AS geom
FROM rawpts 
WHERE start = '14:05:00'::time
ORDER BY tst
),
pts_dist AS (
SELECT tst, event, drst,
coalesce(ST_Distance(geom, LAG(geom) OVER (ORDER BY tst)), 0) AS dist_from_prev
FROM pts
)
SELECT tst, event, drst,
sum(dist_from_prev) OVER (ORDER BY tst) AS cumul_dist
FROM pts_dist
;"
df <- dbGetQuery(conn = con, statement = query) %>%
  as_tibble()
head(df)

p <- ggplot(df) +
  theme_minimal() +
  geom_point(aes(x = tst, y = cumul_dist),
             alpha = 0.3)
p +
  lims(x = c(ymd_hms('2020-01-21 12:10:00'), ymd_hms('2020-01-21 12:15:00')),
       y = c(2000, 2750))
p +
  lims(x = c(ymd_hms('2020-01-21 12:30:00'), ymd_hms('2020-01-21 12:45:00')),
       y = c(6000, 10000))
