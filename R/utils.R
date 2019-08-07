# ---- x mile long border segments ----------------------------------------------------------------

x_mile_segments = function(segment_length) {
  temp_df = border_coord_df %>%
    dplyr::group_by(bordindx) %>%
    dplyr::mutate(
      row_num = dplyr::row_number()
    ) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(bordindx) %>%
    dplyr::mutate(
      max_row_num = max(row_num)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::filter(
      row_num == 1 |
      row_num == max_row_num |
      (row_num %% segment_length) == 0
    ) %>%
    dplyr::mutate(
      segment_id = paste0(st1st2, "-", bordindx, "-", row_num)
    )
  temp_df
}

# ---- x mile segment match for ZIP ---------------------------------------------------------------

x_mile_match = function(zip_code, segment_length) {
  output_df = data.frame(
    zip_code = zip_code,
    stringsAsFactors = FALSE
  )
  temp_df = output_df %>%
    dplyr::left_join(
      y = zip_df %>%
        dplyr::select(zip_code, lat, long),
      by = c("zip_code" = "zip_code")
    ) %>%
    dplyr::filter(!is.na(lat), !is.na(long)) %>%
    dplyr::distinct(zip_code, .keep_all = TRUE)
  sgmnt_match_df = x_mile_segments(segment_length = segment_length)
  for(i in c(1:length(temp_df$zip_code))) {
    inner_df = temp_df[i, ]
    dist_vec = as.numeric(
      geosphere::distm(
        matrix(
          c(inner_df$long, inner_df$lat),
          nrow = length(inner_df$long),
          byrow = FALSE
        ),
        matrix(
          c(sgmnt_match_df$long, sgmnt_match_df$lat),
          nrow = length(sgmnt_match_df$long),
          byrow = FALSE
        ),
        fun = geosphere::distHaversine
      )
    ) / 1000
    if(miles == TRUE) { dist_vec = dist_vec*0.621371 }
    temp_store_data = data.frame(
      zip_code = inner_df$zip_code,
      min_dist = dist_vec[which.min(dist_vec)],
      bordindx = sgmnt_match_df[which.min(dist_vec), "bordindx"],
      state_border_id = sgmnt_match_df[which.min(dist_vec), "st1st2"],
      segment_id  = sgmnt_match_df[which.min(dist_vec), "segment_id"],
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
      by = c("zip_code" = "zip_code")
    )
  output_df
}

# ---- x mile segment match for counties ----------------------------------------------------------

county_x_mile_match = function(fips_code, segment_length) {
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
  sgmnt_match_df = x_mile_segments(segment_length = segment_length)
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
          c(sgmnt_match_df$long, sgmnt_match_df$lat),
          nrow = length(sgmnt_match_df$long),
          byrow = FALSE
        ),
        fun = geosphere::distHaversine
      )
    ) / 1000
    if(miles == TRUE) { dist_vec = dist_vec*0.621371 }
    temp_store_data = data.frame(
      fips_code = inner_df$fips_code,
      min_dist = dist_vec[which.min(dist_vec)],
      bordindx = sgmnt_match_df[which.min(dist_vec), "bordindx"],
      state_border_id = sgmnt_match_df[which.min(dist_vec), "st1st2"],
      segment_id  = sgmnt_match_df[which.min(dist_vec), "segment_id"],
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
  output_df
}


