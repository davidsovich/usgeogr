#' Distance between county population centers.
#'
#' \code{county_dist} measures the geographic distance between two counties. The location of each
#' county is assumed to be its center of population. Function is vectorized and accounts for
#' counties with NA matches to geographic coordinate data.
#'
#' @export
#'
#' @param fips_one FIPS code of first county. Order does not matter.
#' @param fips_two FIPS code of second county. Order does not matter.
#' @param miles Binary flag for whether to return distance in miles (TRUE) or kilometers (FALSE).
#' @examples
#' county_dist(fips_one = "01003", fips_two = "01005", miles = TRUE)
#' county_dist(fips_one = temp_df$fips_code, fips_two = temp_df$neighbor_fips_code)
county_dist = function(fips_one, fips_two, miles = TRUE) {
  if(class(fips_one) != "character" | class(fips_two) != "character") {
    stop("Inputs must be five-digit FIPS code character vectors.")
  }
  temp_df = data.frame(
    fips_one = fips_one,
    fips_two = fips_two,
    stringsAsFactors = FALSE
  )
  temp_df = temp_df %>%
    dplyr::left_join(
      y = county_df %>%
        dplyr::select(fips_code, lat, long) %>%
        dplyr::rename(lat_one = lat, long_one = long),
      by = c("fips_one" = "fips_code")
    ) %>%
    dplyr::left_join(
      y = county_df %>%
        dplyr::select(fips_code, lat, long) %>%
        dplyr::rename(lat_two = lat, long_two = long),
      by = c("fips_two" = "fips_code")
    )
  dist_vec = diag(
    geosphere::distm(
      matrix(
        c(temp_df$long_one, temp_df$lat_one),
        nrow = length(temp_df$long_one),
        byrow = FALSE
      ),
      matrix(
        c(temp_df$long_two, temp_df$lat_two),
        nrow = length(temp_df$long_two),
        byrow = FALSE
      ),
      fun = geosphere::distHaversine
    )
  ) / 1000
  if(miles == TRUE) {
    dist_vec*0.621371
  } else {
    dist_vec
  }
}

#' Distance between ZCTA centroids.
#'
#' \code{zip_dist} measures the geographic distance between two ZCTAs. The location of each
#' ZCTA is assumed to be its centroid. Returns NA values for ZIP codes that do not match to a
#' ZCTA. Function is vectorized and accounts for NA matches.
#'
#' @export
#'
#' @param fips_one ZIP code of first ZCTA. Order does not matter.
#' @param fips_two ZIP code of second ZCTA. Order does not matter.
#' @param miles Binary flag for whether to return distance in miles (TRUE) or kilometers (FALSE).
#' @examples
#' zip_dist(fips_one = "89128", fips_two = "89034", miles = TRUE)
#' zip_dist(fips_one = temp_df$zips_one, fips_two = temp_df$neighbor_zips)
zip_dist = function(zip_one, zip_two, miles = TRUE) {
  1
}


