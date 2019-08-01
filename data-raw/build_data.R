##################################################################################################
#
# Program name: build_data
# Description: This program builds the base US geographic datasets for the package.
# Inputs: Various geographic data from US government (e.g., census). See metadata file in
#         data_raw folder for sourcing locations.
# Ouputs: The following data.frames to the data folder:
#         1. state_df
#         2. adjacent_county_df
#         3. county_df
#         4. zip_df
#         5. border_coord_df
#         6.
#         7.
#
###################################################################################################

# ---- Preliminaries ------------------------------------------------------------------------------

library(tidyverse)
library(geosphere)

# ---- US states ----------------------------------------------------------------------------------

# Load data
state_df = readr::read_csv(
  file = "./data-raw/state_list.csv"
)

# Wrangle the data
state_df = state_df %>%
  dplyr::select(state, state_code) %>%
  dplyr::filter(
    !(state_code %in% c("GU", "PR", "VI"))
  )

# Save data
usethis::use_data(state_df, overwrite = TRUE)

# ---- Adjacent counties --------------------------------------------------------------------------

# Load data
adjacent_county_df = readr::read_tsv(
  file = "./data-raw/county_adjacency.txt",
  col_names = c("county", "fips_code", "neighbor", "neighbor_fips_code")
)
temp_df = readr::read_csv(
  file = "./data-raw/pop_center_csv.csv"
) %>%
  mutate(fips_code = statefp*1000 + county_num)

# Initial wrangling of data
adjacent_county_df = adjacent_county_df %>%
  # Fill NAs
  mutate(
    county = zoo::na.locf(county),
    fips_code = zoo::na.locf(fips_code)
  ) %>%
  # Correct one-off encoding cases in US (ignore PR)
  dplyr::mutate(
    county = ifelse(fips_code == '35013', "Dona Ana County, NM", county),
    neighbor = ifelse(neighbor_fips_code == '35013', "Dona Ana County, NM", neighbor)
  ) %>%
  # Create fips numeric - string distinctions
  dplyr::mutate(
    fips_string = fips_code,
    fips_code = as.numeric(fips_code),
    neighbor_fips_string = neighbor_fips_code,
    neighbor_fips_code = as.numeric(neighbor_fips_code)
  )

# Split state and county names and merge back onto file

  # County splits
  temp_county = as.data.frame(
    matrix(
      unlist(
        strsplit(adjacent_county_df$county, ",")
      ),
      ncol = 2,
      byrow = TRUE
    ),
    stringsAsFactors = FALSE
  ) %>%
    dplyr::rename(county_name = V1, county_state = V2) %>%
    dplyr::mutate(county_name = trimws(county_name), county_state = trimws(county_state))

  # Neighbor splits
  temp_neighbor = as.data.frame(
    matrix(
      unlist(
        strsplit(adjacent_county_df$neighbor, ",")
      ),
      ncol = 2,
      byrow = TRUE
    ),
    stringsAsFactors = FALSE
  ) %>%
    dplyr::rename(neighbor_name = V1, neighbor_state = V2) %>%
    dplyr::mutate(neighbor_name = trimws(neighbor_name), neighbor_state = trimws(neighbor_state))

  # Merge back onto main data
  adjacent_county_df = adjacent_county_df %>%
    dplyr::bind_cols(
      temp_county,
      temp_neighbor
    )

# Final wrangling of data
adjacent_county_df = adjacent_county_df %>%
  # Remove non-U.S. states
  dplyr::filter(
    !(county_state %in% c("AS", "GU", "MP", "PR", "VI", "MH", "FM", "PW"))
  ) %>%
  # Remove non-continental U.S. (Hawaiian island counties have no adjacent counties)
  dplyr::filter(
    !(county_state %in% c("AK", "HI"))
  ) %>%
  # Merge on county coordinates
  dplyr::left_join(
    y = temp_df %>%
      select(fips_code, population, lat, long),
    by = c("fips_code" = "fips_code")
  ) %>%
  # Merge on neighbor county coordinates
  dplyr::left_join(
    y = temp_df %>%
      select(fips_code, population, lat, long) %>%
      rename(
        neighbor_fips_code = fips_code,
        neighbor_population = population,
        neighbor_lat = lat,
        neighbor_long = long
      ),
    by = c("neighbor_fips_code" = "neighbor_fips_code")
  ) %>%
  # Reorder columns
  dplyr::select(
    county_name, county_state, fips_code, fips_string,
    population, lat, long,
    neighbor_name, neighbor_state, neighbor_fips_code, neighbor_fips_string,
    neighbor_population, neighbor_lat, neighbor_long
  ) %>%
  # Remove county matches to themselves
  dplyr::filter(
    fips_string != neighbor_fips_string
  )

# Save data
usethis::use_data(adjacent_county_df, overwrite = TRUE)

# Remove temporary files
rm(temp_county, temp_neighbor, temp_df)

# ---- Counties -----------------------------------------------------------------------------------

# Wrangle adjacent county data and merge on coordinates
county_df = adjacent_county_df %>%
  dplyr::distinct(
    county_name, county_state, fips_code, fips_string,
    population, lat, long
  )

# Save data
usethis::use_data(county_df, overwrite = TRUE)

# Remove temporary files
rm(temp_df)

# ---- ZIP codes ----------------------------------------------------------------------------------

# Load data
zip_df = readr::read_csv(
  file = "./data-raw/zip_county_crosswalk_2018.csv"
)
temp_df = readr::read_csv(
  file = "./data-raw/zip_code_location_and_population_csv.csv"
)

# Wrangle ZIP data
zip_df = zip_df %>%
  # Keep single ZIP-county observation  (ZIP may map to > 1 counties)
  dplyr::arrange(zip, dplyr::desc(tot_ratio)) %>%
  dplyr::distinct(zip, .keep_all = TRUE) %>%
  # Cast as numerics
  dplyr::mutate(
    fips_string = county,
    fips_code = as.numeric(fips_string),
    zip_string = zip,
    zip_numeric = as.numeric(zip_string)
  ) %>%
  dplyr::select(
    zip_string, zip_numeric, fips_string, fips_code
  ) %>%
  # Merge on state information and restrict to U.S. ZIP codes
  dplyr::inner_join(
    y = county_df %>%
      dplyr::select(fips_string, county_state) %>%
      dplyr::rename(state = county_state),
    by = c("fips_string" = "fips_string")
  )

# Append on ZCTA (subset of ZIP) data
zip_df = zip_df %>%
  dplyr::left_join(
    y = temp_df %>%
      dplyr::select(
        -dplyr::one_of(c("zip_numeric", "land_meters", "water_meters"))
      ),
    by = c("zip_string" = "zip_char")
  )

# Save data
usethis::use_data(zip_df, overwrite = TRUE)

# Remove temporary files
rm(temp_df)


# ---- State border coordinates -------------------------------------------------------------------

# Load the data
border_coord_df = readr::read_csv(
  file = "./data-raw/state_borders.csv"
)

# Wrangle the data
border_coord_df = border_coord_df %>%
  dplyr::select(-dplyr::one_of(c("st1_fips", "st2_fips"))) %>%
  # Correct longitude
  dplyr::mutate(
    st1st2 = gsub(" ", "", st1st2),
    long = -1*long
  ) %>%
  # Un-pack first and second state
  dplyr::mutate(
    state_one = sapply(st1st2, FUN = function(x) { unlist(strsplit(x, "-",))[1] }),
    state_two = sapply(st1st2, FUN = function(x) { unlist(strsplit(x, "-",))[2] })
  ) %>%
  dplyr::arrange(
    bordindx, milemark
  )

# Merge on next value for constructing partition
border_coord_df = border_coord_df %>%
  dplyr::group_by(bordindx) %>%
  dplyr::mutate(
    next_lat = dplyr::lead(lat),
    next_long = dplyr::lead(long),
    next_milemark = dplyr::lead(milemark)
  ) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(diff_mmilemark = next_milemark - milemark)

# Refine border partitions
for(i in c(1:nrow(border_coord_df))) {
  temp_df = border_coord_df[i, ]
  if(is.na(temp_df$next_milemark)) {
    between_points = temp_df %>%
      data.frame() %>%
      dplyr::select(lat, long, bordindx, st1st2)
  } else {
    dist = floor(temp_df$next_milemark - temp_df$milemark)
    alphas = c(0:dist)/dist
    between_points = data.frame(
      lat = (1-alphas)*temp_df$lat + alphas*temp_df$next_lat,
      long = (1-alphas)*temp_df$long + alphas*temp_df$next_long,
      stringsAsFactors = FALSE
    ) %>%
      dplyr::mutate(
        bordindx = temp_df$bordindx,
        st1st2 = temp_df$st1st2
      )
  }
  if(i == 1) {
    temp_df_storage = between_points
  } else {
    temp_df_storage = dplyr::bind_rows(
      temp_df_storage,
      between_points
    )
  }
}

# Re-name file and get uniques
border_coord_df = temp_df_storage %>%
  dplyr::distinct(lat, long, bordindx, st1st2)

# Save the file
usethis::use_data(border_coord_df, overwrite = TRUE)

# Remove temporary files
rm(temp_df_storage, between_points, temp_df)


# ---- Border counties ----------------------------------------------------------------------------

# Wrangle the data
border_county_pairs_df = adjacent_county_df %>%
  dplyr::filter(county_state != neighbor_state) %>%
  dplyr::mutate(
    pair_id = ifelse(
      fips_code <= neighbor_fips_code,
      paste0(fips_string, "_", neighbor_fips_string),
      paste0(neighbor_fips_string, "_", fips_string)
    )
  )

temp_df = select(border_county_pairs_df, pair_id, lat, long, neighbor_lat)


#Load Packages
require(tidyverse)

#Load the Adjacent County Data
temp_df = rGeography.list_adjacent_counties()

#Keep Only Pairs Which Are Cross-Border and Create Unique Identifiers
temp_df = temp_df %>% filter( county_state != neighbor_state ) %>%
  mutate( pair_identifier = ifelse( fips_code <= neighbor_fips_code,
                                    paste0(fips_string, "_", neighbor_fips_string),
                                    paste0(neighbor_fips_string, "_", fips_string) ) )

#Calculate Distance Between Cross-Border Pair Population Centers
temp_df = temp_df %>% mutate( distance_between = rGeography.distance_between_county_population_centers( fips_code, neighbor_fips_code ) )

#Save the File for Distribution
temp_file = paste0(geography_data_directories(), "border_county_dataset.csv")
if( !file.exists(temp_file) ){ write.csv( temp_df, file = temp_file ) }

#Return the Dataset
return( temp_df )



