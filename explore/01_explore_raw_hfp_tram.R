library(data.table)
library(readr)
library(dplyr)
library(glue)
library(ggplot2)
library(leaflet)
library(sf)

getwd()
set.seed(123)

system.time({
  dtab <- fread('rawdata/tidy/hsl_tram_geo4_tidy_2019-06-03.csv')
})

system.time({
  dtib <- read_csv('rawdata/tidy/hsl_tram_geo4_tidy_2019-06-03.csv')
})

# data.table is a bit faster but it's also doable with readr.

system.time({
  dsf <- st_as_sf(dtib, coords = c('long', 'lat'), crs = 4326)
})

# Defining individual trips:
# dsf <- dsf %>%
#   mutate(trip = glue('{desi}_{dir}_{oday}_{start}'))

# Summary statistics by route
trips_per_route_dir <- dsf %>%
  st_drop_geometry() %>%
  group_by(desi, dir, oday, start) %>%
  tally()
head(trips_per_route_dir)

ggplot(trips_per_route_dir) +
  geom_bar(aes(x = desi, y = ..count..))

ggplot(trips_per_route_dir) +
  geom_boxplot(aes(x = desi, y = n))

trip_lines <- dsf %>%
  group_by(desi, dir, oday, start) %>%
  arrange(tst) %>%
  summarise(do_union = FALSE) %>%
  ungroup() %>%
  st_cast('LINESTRING')

trl_sample <- trip_lines %>% 
  ungroup() %>%
  filter(desi == '9') %>%
  slice(1)

leaflet(trl_sample) %>%
  addTiles() %>%
  addPolylines()

# ggplot(trip_lines %>% sample_n(100)) +
ggplot(trip_lines) +
  geom_sf(aes(color = alpha('red', 0.2))) +
  scale_color_discrete(guide = FALSE) +
  coord_sf() +
  theme_void()
