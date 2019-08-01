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
#' @format A data frame with 18,474 rows (3,109 counties) and 14 variables with unorder duplicates:
#' \describe{
#'   \item{county_name}{Name of first county.}
#'   \item{county_state}{Postal service code of first county.}
#'   \item{fips_code}{County FIPS code for first county, in numeric format.}
#'   \item{fips_string}{County FIPS code for first county, in original string format.}
#'   \item{population}{Population of first county as of 2010.}
#'   \item{lat}{Latitude of first county center of population as of 2010.}
#'   \item{long}{Longitude of first county center of population as of 2010.}
#'   \item{neighbor_name}{Name of adjacent neighboring county of first county (could be many).}
#'   \item{neighbor_state}{Postal service code of neigboring county.}
#'   \item{neighbor_fips_code}{County FIPS code for neigboring county, in numeric format.}
#'   \item{neighbor_string}{County FIPS code for neigboring county, in original string format.}
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
#' @format A data frame with 3,109 rows and 7 variables:
#' \describe{
#'   \item{county_name}{Name of county.}
#'   \item{county_state}{Postal service code of county.}
#'   \item{fips_code}{County FIPS code for county, in numeric format.}
#'   \item{fips_string}{County FIPS code for county, in original string format.}
#'   \item{population}{Population of county as of 2010.}
#'   \item{lat}{Latitude of county center of population as of 2010.}
#'   \item{long}{Longitude of county center of population as of 2010.}
#' }
#' @source See \code{adjacent_county_df} documentation.
"county_df"


#' Continental U.S. counties
#'
#' A dataset containing identifiers for all counties in the 48 continental United States
#' and D.C.
#'
#' @format A data frame with 3,109 rows and 7 variables:
#' \describe{
#'   \item{county_name}{Name of county.}
#'   \item{county_state}{Postal service code of county.}
#'   \item{fips_code}{County FIPS code for county, in numeric format.}
#'   \item{fips_string}{County FIPS code for county, in original string format.}
#'   \item{population}{Population of county as of 2010.}
#'   \item{lat}{Latitude of county center of population as of 2010.}
#'   \item{long}{Longitude of county center of population as of 2010.}
#' }
#' @source See \code{adjacent_county_df} documentation.
"zip_df"

#' Continental U.S. counties
#'
#' A dataset containing identifiers for all counties in the 48 continental United States
#' and D.C.
#'
#' @format A data frame with 3,109 rows and 7 variables:
#' \describe{
#'   \item{county_name}{Name of county.}
#'   \item{county_state}{Postal service code of county.}
#'   \item{fips_code}{County FIPS code for county, in numeric format.}
#'   \item{fips_string}{County FIPS code for county, in original string format.}
#'   \item{population}{Population of county as of 2010.}
#'   \item{lat}{Latitude of county center of population as of 2010.}
#'   \item{long}{Longitude of county center of population as of 2010.}
#' }
#' @source See \code{adjacent_county_df} documentation.
"border_coord_df"
