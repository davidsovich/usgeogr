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
  if(length(fips_one) != length(fips_two)) {
    stop("Inputs must be same length -- i.e, in pairs!")
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


#' Distance between county population center and nearest state border.
#'
#' \code{county_to_state_border} outputs the minimum distance between a county population center
#' and the nearest state border. Alternatively, returns the identifier for the nearest state border.
#'
#' @export
#'
#' @param fips_code FIPS code of county.
#' @param return_state_border_id Binary flag for whether to return the state border identifier
#' for the nearest state border instead of the distance. Defaults to FALSE.
#' @param miles Binary flag for whether to return distance in miles (TRUE) or kilometers (FALSE).
#' @examples
#' county_to_state_border(fips_one = "01003", return_state_border_id = FALSE, miles = TRUE)
#' county_to_state_border(fips_one = temp_df$fips_code, return_state_border_id = TRUE)
county_to_state_border = function(fips_code, return_state_border_id = FALSE, miles = TRUE) {
  output_df = data.frame(
    fips_code = fips_code,
    stringsAsFactors = FALSE
  )
  temp_df = output_df %>%
    dplyr::left_join(
      y = county_df %>%
        dplyr::select(fips_code, lat, long),
      by = c("fips_code" = "fips_code")
    ) %>%
    dplyr::filter(!is.na(lat), !is.na(long)) %>%
    dplyr::distinct(fips_code, .keep_all = TRUE)
  for(i in c(1:length(temp_df$fips_code))) {
    inner_df = temp_df[i, ]
    dist_vec = as.numeric(
      geosphere::distm(
        matrix(
          c(inner_df$long, inner_df$lat),
          nrow = length(inner_df$long),
          byrow = FALSE
        ),
        matrix(
          c(border_coord_df$long, border_coord_df$lat),
          nrow = length(border_coord_df$long),
          byrow = FALSE
        ),
        fun = geosphere::distHaversine
      )
    ) / 1000
    if(miles == TRUE) { dist_vec = dist_vec*0.621371 }
    temp_store_data = data.frame(
      fips_code = inner_df$fips_code,
      min_dist = dist_vec[which.min(dist_vec)],
      bordindx = border_coord_df[which.min(dist_vec), "bordindx"],
      state_border_id = border_coord_df[which.min(dist_vec), "st1st2"],
      stringsAsFactors = FALSE
    )
    if(i == 1) {
      store_data = temp_store_data
    } else {
      store_data = dplyr::bind_rows(
        store_data,
        temp_store_data
      )
    }
  }
  output_df = output_df %>%
    dplyr::left_join(
      y = store_data,
      by = c("fips_code" = "fips_code")
    )
  if(return_state_border_id == TRUE) {
    output_df$state_border_id
  } else {
    output_df$min_dist
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
#' @param zip_one ZIP code of first ZCTA. Order does not matter.
#' @param zip_two ZIP code of second ZCTA. Order does not matter.
#' @param miles Binary flag for whether to return distance in miles (TRUE) or kilometers (FALSE).
#' @examples
#' zip_dist(fips_one = "89128", fips_two = "89034", miles = TRUE)
#' zip_dist(fips_one = temp_df$zips_one, fips_two = temp_df$neighbor_zips)
zip_dist = function(zip_one, zip_two, miles = TRUE) {
  if(class(zip_one) != "character" | class(zip_two) != "character") {
    stop("Inputs must be five-digit ZIP code character vectors.")
  }
  if(length(zip_one) != length(zip_two)) {
    stop("Inputs must be same length! i.e, in pairs!")
  }
  temp_df = data.frame(
    zip_one = zip_one,
    zip_two = zip_two,
    stringsAsFactors = FALSE
  )
  temp_df = temp_df %>%
    dplyr::left_join(
      y = zip_df %>%
        dplyr::select(zip_code, lat, long) %>%
        dplyr::rename(lat_one = lat, long_one = long),
      by = c("zip_one" = "zip_code")
    ) %>%
    dplyr::left_join(
      y = zip_df %>%
        dplyr::select(zip_code, lat, long) %>%
        dplyr::rename(lat_two = lat, long_two = long),
      by = c("zip_two" = "zip_code")
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


#' Distance between ZCTA centroids and nearest state border.
#'
#' \code{zip_to_state_border} outputs the minimum distance between a ZCTA centroid and the
#' nearest state border. Alternatively, returns the identifier for the nearest state border.
#'
#' @export
#'
#' @param zip_code Five-digit ZIP code of ZCTA
#' @param return_state_border_id Binary flag for whether to return the state border identifier
#' for the nearest state border instead of the distance. Defaults to FALSE.
#' @param miles Binary flag for whether to return distance in miles (TRUE) or kilometers (FALSE).
#' @examples
#' zip_to_state_border(fips_one = "89128", return_state_border_id = FALSE, miles = TRUE)
#' zip_to_state_border(fips_one = temp_df$zip_code, return_state_border_id = TRUE)
zip_to_state_border = function(zip_code, zip_alpha) {
  output_df = data.frame(
    fips_code = fips_code,
    stringsAsFactors = FALSE
  )
  temp_df = output_df %>%
    dplyr::left_join(
      y = county_df %>%
        dplyr::select(fips_code, lat, long),
      by = c("fips_code" = "fips_code")
    ) %>%
    dplyr::filter(!is.na(lat), !is.na(long)) %>%
    dplyr::distinct(fips_code, .keep_all = TRUE)
  for(i in c(1:length(temp_df$fips_code))) {
    inner_df = temp_df[i, ]
    dist_vec = as.numeric(
      geosphere::distm(
        matrix(
          c(inner_df$long, inner_df$lat),
          nrow = length(inner_df$long),
          byrow = FALSE
        ),
        matrix(
          c(border_coord_df$long, border_coord_df$lat),
          nrow = length(border_coord_df$long),
          byrow = FALSE
        ),
        fun = geosphere::distHaversine
      )
    ) / 1000
    if(miles == TRUE) { dist_vec = dist_vec*0.621371 }
    temp_store_data = data.frame(
      fips_code = inner_df$fips_code,
      min_dist = dist_vec[which.min(dist_vec)],
      bordindx = border_coord_df[which.min(dist_vec), "bordindx"],
      state_border_id = border_coord_df[which.min(dist_vec), "st1st2"],
      stringsAsFactors = FALSE
    )
    if(i == 1) {
      store_data = temp_store_data
    } else {
      store_data = dplyr::bind_rows(
        store_data,
        temp_store_data
      )
    }
  }
  output_df = output_df %>%
    dplyr::left_join(
      y = store_data,
      by = c("fips_code" = "fips_code")
    )
  if(return_state_border_id == TRUE) {
    output_df$state_border_id
  } else {
    output_df$min_dist
  }
}















