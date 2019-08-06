#' U.S. states
#'
#' A dataset containing identifiers for the 50 U.S. states and D.C.
#'
#' @format A data frame with 51 rows and 2 variables:
#' \describe{
#'   \item{state}{Name of state in capital letters.}
#'   \item{state_code}{Postal service state code.}
#' }
"state_df"

#' Adjacent continental U.S. counties
#'
#' A dataset containing identifiers for all adjacent (bordering) counties in the 48 continental
#' United States and D.C.
#'
#' @format A data frame with 18,474 rows (3,109 counties) and 12 variables with unorder duplicates:
#' \describe{
#'   \item{county_name}{Name of first county.}
#'   \item{county_state}{Postal service code of first county.}
#'   \item{fips_code}{County FIPS code for first county, in original string format.}
#'   \item{population}{Population of first county as of 2010.}
#'   \item{lat}{Latitude of first county center of population as of 2010.}
#'   \item{long}{Longitude of first county center of population as of 2010.}
#'   \item{neighbor_name}{Name of adjacent neighboring county of first county (could be many).}
#'   \item{neighbor_state}{Postal service code of neigboring county.}
#'   \item{neighbor_fips_code}{County FIPS code for neigboring county, in original string format.}
#'   \item{neighbor_population}{Population of neigboring county as of 2010.}
#'   \item{neighbor_lat}{Latitude of neigboring county center of population as of 2010.}
#'   \item{neighbor_long}{Longitude of neigboring county center of population as of 2010.}
#' }
#' @source \url{https://www.census.gov/programs-surveys/geography.html}
"adjacent_county_df"


#' Continental U.S. counties
#'
#' A dataset containing identifiers for all counties in the 48 continental United States
#' and D.C.
#'
#' @format A data frame with 3,109 rows and 6 variables:
#' \describe{
#'   \item{county_name}{Name of county.}
#'   \item{county_state}{Postal service code of county.}
#'   \item{fips_code}{County FIPS code for county, in original string format.}
#'   \item{population}{Population of county as of 2010.}
#'   \item{lat}{Latitude of county center of population as of 2010.}
#'   \item{long}{Longitude of county center of population as of 2010.}
#' }
#' @source See \code{adjacent_county_df} documentation.
"county_df"


#' Continental U.S. ZIP codes.
#'
#' A dataset containing identifiers for all ZIP codes in the 48 continental United States
#' and D.C. Spatial identifiers and population only included for ZIP codes that map into
#' ZIP code tabulation areas (\url{https://en.wikipedia.org/wiki/ZIP_Code_Tabulation_Area}).
#'
#' @format A data frame with 38,879 rows and 9 variables:
#' \describe{
#'   \item{zip_code}{ZIP code identifier, in original string format.}
#'   \item{fips_code}{FIPS code for ZIP code county, in original string format. Some ZIP codes
#'   may map into multiple counties; only one county match is kept -- the county with
#'   the largest fraction of population.}
#'   \item{population_2010}{ZCTA population in 2010. Null if ZIP is not also a ZCTA.}
#'   \item{housing_units_2010}{ZCTA housing units in 2010. Null if ZIP is not also a ZCTA.}
#'   \item{land_miles}{Number of square miles of land in 2010. Null if ZIP is not also a ZCTA.}
#'   \item{water_miles}{Number of square miles of water in 2010. Null if ZIP is not also a ZCTA.}
#'   \item{lat}{Latitude. Null if ZIP is not also a ZCTA.}
#'   \item{long}{Longitude. Null if ZIP is not also a ZCTA.}
#' }
#' @source \url{https://www.huduser.gov/portal/datasets/usps_crosswalk.html}
"zip_df"

#' Continental U.S. border coordinates.
#'
#' A dataset containing coordinates for mile-long strips of all borders between states in
#' the continental U.S.
#'
#' @format A data frame with 21,603 rows and 4 variables:
#' \describe{
#'   \item{lat}{Latitude of mile-long border point.}
#'   \item{long}{Longitude of mile-long border point.}
#'   \item{bordindx}{Unique border-segment (e.g., AL-FL) numeric identifer.}
#'   \item{st1st2}{Unique alphabetized border-segment (e.g., AL-FL) identifier.}
#' }
#' @source \url{http://users.econ.umn.edu/~holmes/data/BorderData.html}
"border_coord_df"

#' Cross-border county pairs.
#'
#' A dataset containing all of the unique cross-border county pairs in the continental United
#' States. The dataset is constructed using the methods in in Dube, Lester, and Reich (RESTAT,
#' 2010). Specifically, only border counties are included in the dataset, and if a county
#' is adjacent to p > 1 counties along a border, then the county will have p > 1 replicates in
#' the dataset. Cross-border county pairs are uniquely identified by \code{cbcp_id}. Additional
#' metadata: (1) Number of unique border counties = 1,184 (2) Number of unique cross-border county
#' pairs = 1,308 (3) Distribution of number of pairs for counties: 1 (256), 2 (586), 3 (239),
#' 4 (63), 5+ (40)
#'
#' @format A data frame with 2,616 rows and 15 variables:
#' \describe{
#'   \item{fips_code}{County FIPS code for first county, in original string format. Each FIPS
#'   code may have greater than one replicate in the data.}
#'   \item{county_state}{State postal code corresponding to FIPS code.}
#'   \item{neighbor_fips_code}{County FIPS code for paired county, in original string format.}
#'   \item{county_state}{State postal code corresponding to neighbor FIPS code.}
#'   \item{cbcp_id}{Cross-border county pair identifier for the county and its pair.
#'   A single FIPS code may have multiple
#'   entires corresponding to each of its bordering counties and their cross-border county pair
#'   identifier. Each cross-border county pair identifier has two entries in the dataset.}
#'   \item{state_border_id}{Border identifier for county and its neighbor.}
#'   \item{dist_bt_centers}{Distance (in miles) between paired county population centers.}
#' }
#' @source See \code{adjacent_county_df}.
"cbcp_df"

#' State border strip county assignments.
#'
#' A dataset that assigns each border county to a unique state border pair strip (e.g., AL-FL).
#' For counties that reside along multiple state-border strips (e.g., AZ-NV, NV-UT), the county
#' is assigned to the state-border strip to which its center of population is closest. If a county
#' is closest to a state-border strip that it is not adjacent with, the next closest adjacent
#' state-border strip is chosen. State-border pair strips are identified by \code{state_border_id}.
#'
#' @format A data frame with 1,184 rows and 3 variables:
#' \describe{
#'   \item{fips_code}{County FIPS code, in original string format. Unique identifier.}
#'   \item{county_state}{State postal code corresponding to FIPS code.}
#'   \item{state_border_id}{Border identifier for closest state border strip.}
#'   \item{dist_to_border}{Distance (in miles) of population center to the closest adjacent
#'   state border strip.}
#'   \item{num_counties_in_strip}{Number of unique adjacent counties belong to state border pair
#'   strip. Fixed effect specifications will eliminate those with a single county.}
#'   \item{num_states_in_strip}{Number of unique states corresponding to unique adjacent counties
#'   that belong to the state border pair strip. Fixed effect specifications focused on cross-
#'   border variation will eliminate those with a single state in the state border pair.}
#' }
#' @source See \code{adjacent_county_df}.
"sbscp_df"

#' Couplet and relaxed couplet county assignments.
#'
#' A dataset that assigns each county to a unique cluster using the "couplet" algorithm. Couplet
#' clusters are defined as cross-border county pairs in which each constituent county does not
#' appear in any other cross-border county pairs. Because each border county may belong to several
#' cross-border county pairs, the "couplet" algorithm is needed to partition the space with the
#' goal of maximizing the total number of couplet clusters. Couplet clusters are identified by
#' \code{cpcp_id}; some counties are excluded from any couplet clusters by the algorithm. To
#' resolve the issue of non-assignment of some border counties, the \code{relaxed_cpcp_id}
#' identifier assigns non-matched border counties to the couplet their cross-borde neighbor.
#' Metadata includes: (1) 499 unique couplet clusters mapped to 998 border counties, (2) 186
#' border counties without a matched couplet cluster, (3) 499 unique relaxed couplet clusters
#' mapped to 1,183 border counties, (4) 1 border county without a matched relaxed couplet cluster.
#'
#' @format A data frame with 1,184 rows and 6 variables:
#' \describe{
#'   \item{fips_code}{County FIPS code, in original string format. Unique identifier.}
#'   \item{county_state}{State postal code corresponding to FIPS code.}
#'   \item{cpcp_id}{Couplet cluster pair identifier.}
#'   \item{relaxed_cpcp_id}{Relaxed couplet cluster pair identifier.}
#'   \item{cpcp_remove_flag}{Binary flag equal to one if a county is unmatched to a couplet
#'   cluster.}
#'   \item{relaxed_cpcp_remove_flag}{Binary flag equal to one if a county is unmatched to a
#'   relaxed couplet cluster.}
#' }
#' @source See \code{adjacent_county_df}.
"cpcp_df"

#' Max-method and relaxed max-method county assignments.
#'
#' A dataset that assigns each border county to a unique cluster using the "max-method" algorithm
#' and the "relaxed max-method" algorithm. See vignette for description of the algorithm. Max-method
#' clusters are identified by \code{mxcp_id}; relaxed max-method clusters are identified by
#' \code{relaxed_mxcp_id}. If there is only one county in a cluster, then the algorithm assigns the
#' identifier to be NA. Metadata: (1) 256 unique non-null max-method and relaxed max-method
#' clusters, (2) 296 counties without an assigned max-method cluster, (3) 120 counties without
#' an assigned relaxed max-method cluster, (4) 85 (80) max-method (relaxed max-method) clusters
#' with 2 constituent counties, 62 (58) with 3 counties, 53 (52) with 4 counties, 32 (32) with
#' 5 counties, 14 (30) with 6 counties, 7 (22) with 7 counties, 1 (8) with 8 counties, 1 (2) with
#' 9 counties, and 1 (1) with 10 counties.
#'
#' @format A data frame with 1,184 rows and 6 variables:
#' \describe{
#'   \item{fips_code}{County FIPS code, in original string format. Unique identifier.}
#'   \item{county_state}{State postal code corresponding to FIPS code.}
#'   \item{mxcp_id}{Max-method cluster identifier.}
#'   \item{relaxed_mxcp_id}{Relaxed max-method cluster identifier.}
#'   \item{mxcp_remove_flag}{Binary flag equal to one if a county is unmatched to a max-method
#'   cluster with at least two constituent counties.}
#'   \item{relaxed_mxcp_remove_flag}{Binary flag equal to one if a county is unmatched to a
#'   relaxed max-method cluster with at least two constiuent counties.}
#' }
#' @source See \code{adjacent_county_df}.
"mxcp_df"


