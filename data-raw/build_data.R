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
devtools::load_all()

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
  )
  #%>%
  # Create fips numeric - string distinctions
  #dplyr::mutate(
  #  fips_string = fips_code,
  #  fips_code = as.numeric(fips_code),
  #  neighbor_fips_string = neighbor_fips_code,
  #  neighbor_fips_code = as.numeric(neighbor_fips_code)
  #)

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
  dplyr::mutate(
    temp_fips_code = as.numeric(fips_code)
  ) %>%
  dplyr::left_join(
    y = temp_df %>%
      select(fips_code, population, lat, long),
    by = c("temp_fips_code" = "fips_code")
  ) %>%
  dplyr::select(-one_of("temp_fips_code")) %>%
  # Merge on neighbor county coordinates
  dplyr::mutate(
    temp_neighbor_fips_code = as.numeric(neighbor_fips_code)
  ) %>%
  dplyr::left_join(
    y = temp_df %>%
      select(fips_code, population, lat, long) %>%
      rename(
        neighbor_fips_code = fips_code,
        neighbor_population = population,
        neighbor_lat = lat,
        neighbor_long = long
      ),
    by = c("temp_neighbor_fips_code" = "neighbor_fips_code")
  )  %>%
  dplyr::select(-one_of("temp_neighbor_fips_code")) %>%
  # Reorder columns
  dplyr::select(
    county_name, county_state, fips_code,
    population, lat, long,
    neighbor_name, neighbor_state, neighbor_fips_code,
    neighbor_population, neighbor_lat, neighbor_long
  ) %>%
  # Remove county matches to themselves
  dplyr::filter(
    fips_code != neighbor_fips_code
  )

# Save data
usethis::use_data(adjacent_county_df, overwrite = TRUE)

# Remove temporary files
rm(temp_county, temp_neighbor, temp_df)

# ---- Counties -----------------------------------------------------------------------------------

# Wrangle adjacent county data and merge on coordinates
county_df = adjacent_county_df %>%
  dplyr::distinct(
    county_name, county_state, fips_code,
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
    fips_code = county,
    zip_code = zip,
  ) %>%
  dplyr::select(
    zip_code, fips_code
  ) %>%
  # Merge on state information and restrict to U.S. ZIP codes
  dplyr::inner_join(
    y = county_df %>%
      dplyr::select(fips_code, county_state) %>%
      dplyr::rename(state = county_state),
    by = c("fips_code" = "fips_code")
  )

# Append on ZCTA (subset of ZIP) data
zip_df = zip_df %>%
  dplyr::left_join(
    y = temp_df %>%
      dplyr::select(
        -dplyr::one_of(c("zip_numeric", "land_meters", "water_meters"))
      ),
    by = c("zip_code" = "zip_char")
  )

# Save data
usethis::use_data(zip_df, overwrite = TRUE)

# Remove temporary files
rm(temp_df)


# ---- State border coordinates -------------------------------------------------------------------

# Load the data
border_coord_df = readr::read_csv(
  file = "./data-raw/state_borders.csv"
) %>%
  dplyr::mutate(st1st2 = gsub("IL-IA", "IA-IL", st1st2))

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


# ---- Cross-border county pairs ------------------------------------------------------------------

# Wrangle the data
cbcp_df = adjacent_county_df %>%
  dplyr::filter(county_state != neighbor_state) %>%
  dplyr::mutate(
    cbcp_id = ifelse(
      fips_code <= neighbor_fips_code,
      paste0(fips_code, "_", neighbor_fips_code),
      paste0(neighbor_fips_code, "_", fips_code)
    ),
    state_border_id = ifelse(
      county_state <= neighbor_state,
      paste0(county_state, "-", neighbor_state),
      paste0(neighbor_state, "-", county_state)
    )
  )

# Calculate distances between counties
cbcp_df = cbcp_df %>%
  dplyr::mutate(
    dist_bt_centers = county_dist(fips_code, neighbor_fips_code)
  )

# Reduce variables
cbcp_df = cbcp_df %>%
  dplyr::select(
    fips_code, county_state,
    cbcp_id, state_border_id,
    neighbor_fips_code, neighbor_state,
    dist_bt_centers
  )

# Save the file
usethis::use_data(cbcp_df, overwrite = TRUE)

# ---- State-border strip county assignments -----------------------------------------------------

# Wrangle the data
sbscp_df = adjacent_county_df %>%
  dplyr::filter(county_state != neighbor_state) %>%
  dplyr::mutate(
    state_border_id = ifelse(
      county_state <= neighbor_state,
      paste0(county_state, "-", neighbor_state),
      paste0(neighbor_state, "-", county_state)
    )
  ) %>%
  dplyr::select(fips_code, county_state, state_border_id)

# Calculate closest distances to borders
sbscp_df = sbscp_df %>%
  dplyr::mutate(
    dist_to_border = county_to_state_border(
      fips_code = fips_code
    ),
    border_dist_ref = county_to_state_border(
      fips_code = fips_code,
      return_state_border_id = TRUE
    )
  )

# Calculate number of mathces for each fips_code (some will = 0; closest to non-adjacent border!)
sbscp_df = sbscp_df %>%
  dplyr::group_by(fips_code) %>%
  dplyr::mutate(
    num_obs = dplyr::n(),
    num_matches = sum(as.numeric(border_dist_ref == state_border_id))
  ) %>%
  dplyr::ungroup()

# Keep closest observation or alphabetically first observation if zero matches
sbscp_df = sbscp_df %>%
  dplyr::arrange(fips_code, state_border_id) %>%
  dplyr::distinct(fips_code, .keep_all = TRUE) %>%
  dplyr::mutate(
    final_id = ifelse(
      num_matches >= 1,
      border_dist_ref,
      state_border_id
    )
  )

# Limit variable set
sbscp_df = sbscp_df %>%
  dplyr::select(fips_code, county_state, final_id, dist_to_border) %>%
  dplyr::rename(state_border_id = final_id)

# Add on information for state border strip (final analysis should restrict based on this)
sbscp_df = sbscp_df %>%
  dplyr::group_by(state_border_id) %>%
  dplyr::mutate(
    num_counties_in_strip = dplyr::n(),
    num_states_in_strip = dplyr::n_distinct(county_state)
  ) %>%
  dplyr::ungroup()

# Save the file
usethis::use_data(sbscp_df, overwrite = TRUE)

# ---- Couplet and relaxed couplet county assignemnts ---------------------------------------------

# Wrangle the data
cpcp_df = adjacent_county_df %>%
  dplyr::filter(county_state != neighbor_state) %>%
  dplyr::mutate(
    fips_pair = ifelse(
      fips_code <= neighbor_fips_code,
      paste0(fips_code, "-", neighbor_fips_code),
      paste0(neighbor_fips_code, "-", fips_code)
    ),
    fips_obs_1 = ifelse(
      fips_code <= neighbor_fips_code,
      fips_code,
      neighbor_fips_code
    ),
    fips_obs_2 = ifelse(
      fips_code <= neighbor_fips_code,
      neighbor_fips_code,
      fips_code
    )
  ) %>%
  dplyr::select(
    fips_code, neighbor_fips_code, county_state, neighbor_state,
    fips_pair, fips_obs_1, fips_obs_2
  )

# Append number of times each county appears in data
cpcp_df = cpcp_df %>%
  dplyr::group_by(fips_obs_1) %>%
  dplyr::mutate(total_fips_obs_1 = dplyr::n()) %>%
  dplyr::ungroup() %>%
  dplyr::group_by(fips_obs_2) %>%
  dplyr::mutate(total_fips_obs_2 = dplyr::n()) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(fips_pair_obs = total_fips_obs_1 + total_fips_obs_2) %>%
  dplyr::arrange(fips_pair_obs, fips_pair, fips_code)

# Construct couplets - algorithm begins with county pair with least number of matches
temp_df = cpcp_df
couplet_vector = NULL
for(x in unique(temp_df$fips_pair)) {
  inner_temp_df = temp_df %>%
    dplyr::filter(fips_pair == x)
  if(nrow(inner_temp_df) >= 2) {
    couplet_vector = c(couplet_vector, x)
    temp_df = temp_df %>%
      dplyr::filter(!(fips_code %in% unique(inner_temp_df$fips_code)))
  }
}

# Assign couplet pair identifier to matched counties
cpcp_df = cpcp_df %>%
  dplyr::mutate(
    cpcp_id = ifelse(
      fips_pair %in% couplet_vector,
      fips_pair,
      NA
    )
  )

# Assign couplet pair identifier of neighboring to unmatched counties
cpcp_df = cpcp_df %>%
  dplyr::left_join(
    y = cpcp_df %>%
      dplyr::distinct(fips_code, .keep_all = TRUE) %>%
      dplyr::select(fips_code, cpcp_id) %>%
      dplyr::rename(neighbor_cpcp_id = cpcp_id),
    by = c("neighbor_fips_code" = "fips_code")
  ) %>%
  dplyr::mutate(
    relaxed_cpcp_id = ifelse(
      !is.na(cpcp_id),
      cpcp_id,
      neighbor_cpcp_id
    ),
    sort_flag = ifelse(
      !is.na(cpcp_id),
      0,
      ifelse(
        !is.na(relaxed_cpcp_id),
        1,
        2
      )
    )
  ) %>%
  dplyr::arrange(
    fips_code, sort_flag, relaxed_cpcp_id,
  ) %>%
  dplyr::distinct(
    fips_code, .keep_all = TRUE
  ) %>%
  dplyr::select(
    fips_code, county_state, cpcp_id, relaxed_cpcp_id
  )

# Add on metadata for pairings
cpcp_df = cpcp_df %>%
  dplyr::mutate(
    cpcp_remove_flag = as.numeric(is.na(cpcp_id)),
    relaxed_cpcp_remove_flag = as.numeric(is.na(relaxed_cpcp_id))
  )

# Save the file
usethis::use_data(cpcp_df, overwrite = TRUE)

# Remove temporary files
rm(temp_df, couplet_vector, inner_temp_df)


# ---- Max neighbor county assignments  -----------------------------------------------------------

# Wrangle the data
mxcp_df = adjacent_county_df %>%
  dplyr::filter(county_state != neighbor_state)

# Count number of times neighbor is adjacent to another county
temp_df = mxcp_df %>%
  dplyr::group_by(neighbor_fips_code) %>%
  summarise(num_neighbor = dplyr::n())

# Merge on matches for counties and neighbors
mxcp_df = mxcp_df %>%
  dplyr::left_join(
    y = temp_df %>%
      dplyr::rename(num_county = num_neighbor),
    by = c("fips_code" = "neighbor_fips_code")
  ) %>%
  dplyr::left_join(
    y = temp_df,
    by = c("neighbor_fips_code" = "neighbor_fips_code")
  ) %>%
  dplyr::select(
    fips_code, county_state, neighbor_fips_code,
    num_county, num_neighbor
  )

# Assign cluster for each adjacent pair based on observation with more adjacent counties
mxcp_df = mxcp_df %>%
  dplyr::mutate(
    mxcp_id = ifelse(
      num_county >= num_neighbor,
      fips_code,
      neighbor_fips_code
    ),
    mxcp_counts = ifelse(
      num_county >= num_neighbor,
      num_county,
      num_neighbor
    )
  )

# Count number of distinct counties in each cluster
mxcp_df = mxcp_df %>%
  dplyr::group_by(mxcp_id) %>%
  dplyr::mutate(distinct_in_cluster = dplyr::n_distinct(fips_code)) %>%
  dplyr::ungroup()

# First-pass matches: most distinct observations in cluster
temp_df = mxcp_df %>%
  dplyr::arrange(fips_code, dplyr::desc(distinct_in_cluster)) %>%
  dplyr::distinct(fips_code, .keep_all = TRUE) %>%
  dplyr::group_by(mxcp_id) %>%
  dplyr::mutate(num_in_cluster = dplyr::n()) %>%
  dplyr::ungroup() %>%
  data.frame()

# First-pass matches: set singleton clusters to NA
temp_df = temp_df %>%
  dplyr::mutate(
    mxcp_id = ifelse(
      num_in_cluster < 2,
      NA,
      mxcp_id
    )
  )

# Second-pass matches: merge on first-pass and neighbor assignments
mxcp_df = mxcp_df %>%
  dplyr::inner_join(
    y = temp_df %>%
      dplyr::select(fips_code, mxcp_id) %>%
      dplyr::rename(county_mxcp_id = mxcp_id),
    by = c("fips_code" = "fips_code")
  ) %>%
  dplyr::inner_join(
    y = temp_df %>%
      dplyr::select(fips_code, mxcp_id, num_in_cluster) %>%
      dplyr::rename(
        neighbor_mxcp_id = mxcp_id,
        neighbor_num_in_cluster = num_in_cluster
      ),
    by = c("neighbor_fips_code" = "fips_code")
  )

# Second-pass matches: assign to neighbor's cluster, sorted by largest
mxcp_df = mxcp_df %>%
  dplyr::mutate(
    relaxed_mxcp_id = ifelse(
      !is.na(county_mxcp_id),
      county_mxcp_id,
      neighbor_mxcp_id
    ),
    relaxed_mxcp_id = ifelse(
      is.na(relaxed_mxcp_id),
      ifelse(
        fips_code <= neighbor_fips_code,
        fips_code,
        neighbor_fips_code
      ),
      relaxed_mxcp_id
    ),
    sort_flag = ifelse(
      !is.na(relaxed_mxcp_id),
      0,
      1
    )
  ) %>%
  dplyr::arrange(
    fips_code, sort_flag,
    dplyr::desc(neighbor_num_in_cluster), relaxed_mxcp_id
  ) %>%
  dplyr::distinct(
    fips_code, .keep_all = TRUE
  )

# Count observations in each cluster
mxcp_df = mxcp_df %>%
  dplyr::select(
    fips_code, county_state,
    county_mxcp_id, relaxed_mxcp_id
  ) %>%
  dplyr::group_by(relaxed_mxcp_id) %>%
  dplyr::mutate(num_relaxed = dplyr::n()) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(
    relaxed_mxcp_id = ifelse(
      num_relaxed < 2,
      NA,
      relaxed_mxcp_id
    )
  ) %>%
  dplyr::rename(mxcp_id = county_mxcp_id) %>%
  dplyr::mutate(
    mxcp_remove_flag = as.numeric(is.na(mxcp_id)),
    relaxed_mxcp_remove_flag = as.numeric(is.na(relaxed_mxcp_id))
  )

# Save the file
usethis::use_data(mxcp_df, overwrite = TRUE)

# Remove temporary files
rm(temp_df)

# ---- Cross-border ZIP codes ---------------------------------------------------------------------





