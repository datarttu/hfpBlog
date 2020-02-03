#' Comparing tram stops between OSM and GTFS.

library(tidyverse)
library(httr)
library(sf)
library(nngeo)
library(leaflet)

rdspath_g_stops <- 'rawdata/r_obj/gtfs_stuff_g_stops.rds'
if (file.exists(rdspath_g_stops)) {
  g_stops <- readRDS(rdspath_g_stops)
} else {
  g_stops <- read_csv(file = 'rawdata/gtfs/stops.txt') %>%
    # Tram stop short codes 1) start with 0 2) have 2. digit other than 0
    filter(str_detect(stop_code, '^0[1-9][0-9]{2}$')) %>%
    st_as_sf(coords = c('stop_lon', 'stop_lat'), crs = 4326) %>%
    st_transform(crs = 3067)
  saveRDS(g_stops, file = rdspath_g_stops)
}

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

rdspath_o_stops <- 'rawdata/r_obj/gtfs_stuff_o_stops.rds'
if (file.exists(rdspath_o_stops)) {
  o_stops <- readRDS(rdspath_o_stops)
} else {
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
  saveRDS(o_stops, file = rdspath_o_stops)
}
  
ggplot(o_stops) +
  geom_sf(aes(color = is.na(ref)),
          alpha = 0.2) +
  theme_minimal()

cbind(gtfs = nrow(g_stops), osm = nrow(o_stops))

#' GTFS has a few more stops than OSM.
#' Let us see which ones are missing in either dataset.
g_stops$stop_code %>% setdiff(o_stops$ref)
o_stops$ref %>% setdiff(g_stops$stop_code)

#' For every GTFS stop, find the nearest feature from OSM stops.
#' Find the pairwise distances.
pairs_gpt <- st_join(g_stops %>% select(stop_code), o_stops, 
                     join = st_nn, k = 1, progress = FALSE) %>%
  mutate(codes_match = case_when(stop_code == ref ~ 'codes match',
                                 stop_code != ref ~ 'no match',
                                 is.na(ref) ~ 'ref is NA'))
pairs_opt <- pairs_gpt %>%
  st_drop_geometry() %>%
  filter(!is.na(ref)) %>%
  inner_join(o_stops %>% select(ref), by = 'ref') %>%
  st_as_sf()
nn <- st_nn(g_stops, o_stops, k = 1)
pairlines <- st_connect(g_stops, o_stops, ids = nn, progress = FALSE) %>%
  st_as_sf() %>%
  mutate(len = st_length(.))

m <- leaflet() %>%
  # addProviderTiles(providers$CartoDB.Positron)
  addProviderTiles(providers$OpenStreetMap.BlackAndWhite)

m %>%
  addPolylines(data = pairlines %>%
                 st_transform(crs = 4326),
               popup = ~sprintf('%.1f m', as.numeric(len))) %>%
  addCircleMarkers(data = o_stops %>% 
                     st_transform(crs = 4326),
                   radius = 5, color = 'red', stroke = FALSE, fillOpacity = 0.8,
                   popup = ~sprintf('OSM %s', ref)) %>%
  addCircleMarkers(data = pairs_gpt %>% 
                     st_transform(crs = 4326),
                   radius = 5, color = 'green', stroke = FALSE, fillOpacity = 0.8,
                   popup = ~sprintf('OSM %s<br>GTFS %s', ref, stop_code))

m %>%
  addCircleMarkers(data = o_stops %>% filter(is.na(ref)) %>% st_transform(crs = 4326),
                   radius = 5, color = 'blue', stroke = FALSE, fillOpacity = 0.5) %>%
  addCircleMarkers(data = pairs_gpt %>% st_transform(crs = 4326),
                   radius = 5, color = 'green', stroke = FALSE, fillOpacity = 0.5,
                   popup = ~sprintf('OSM %s<br>GTFS %s', ref, stop_code))

g_stops %>%
  filter(lengths(st_is_within_distance(., o_stops, dist = 100) > 0))


# nn <- st_nn(g_stops, o_stops, k = 1)
pairlines <- st_connect(g_stops, o_stops, ids = nn, progress = FALSE) %>%
  st_as_sf() %>%
  mutate(len = st_length(.))
ggplot(pairlines, aes(x = as.numeric(len))) +
  geom_histogram(binwidth = 10, boundary = 0) +
  theme_minimal()

#' Show distance lines for `> 30 m`.
(p1 <- ggplot(pairlines %>% filter(as.numeric(len) > 30)) +
  geom_sf() +
  theme_minimal()
)
