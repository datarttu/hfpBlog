#' Comparing tram stops between OSM and GTFS.

library(tidyverse)
library(httr)
library(sf)

g_stops <- read_csv(file = 'rawdata/gtfs/stops.txt') %>%
  # Tram stop short codes 1) start with 0 2) have 2. digit other than 0
  filter(str_detect(stop_code, '^0[1-9][0-9]{2}$')) %>%
  st_as_sf(coords = c('stop_lon', 'stop_lat'), crs = 4326) %>%
  st_transform(crs = 3067)
saveRDS(g_stops, file = 'rawdata/r_obj/gtfs_stuff_g_stops.rds')

ggplot(g_stops) +
  geom_sf(alpha = 0.2) +
  theme_minimal()

#' Query:
#' 
#' ```
#' [out:csv(::id, ::lat, ::lon, "ref")];
#' node["railway"="tram_stop"](60.140091,24.858358,60.216751,25.002554);
#' out geom;
#' ```

op_url <- 'https://overpass.kumi.systems/api/interpreter?data=%5Bout%3Acsv%28%3A%3Aid%2C%3A%3Alat%2C%3A%3Alon%2C%22ref%22%29%5D%3Bnode%5B%22railway%22%3D%22tram%5Fstop%22%5D%2860%2E140091%2C24%2E858358%2C60%2E216751%2C25%2E002554%29%3Bout%20geom%3B%0A'
op_res <- GET(op_url)
o_stops <- op_res %>% 
  content(as = 'text', encoding = 'UTF-8') %>%
  read_tsv() %>%                               # Tab sep by default
  rename_all(~ str_replace(., '@', '')) %>%    # Colnames start with '@', eliminate
  # Some short codes start with 'H', eliminate
  mutate(ref = str_match(ref, '^0[1-9][0-9]{2}$')) %>%
  st_as_sf(coords = c('lon', 'lat'), crs = 4326) %>%
  st_transform(crs = 3067)
saveRDS(o_stops, file = 'rawdata/r_obj/gtfs_stuff_o_stops.rds')

ggplot(o_stops) +
  geom_sf(aes(color = is.na(ref)),
          alpha = 0.2) +
  theme_minimal()

f <- st_nearest_feature(g_stops, o_stops)
