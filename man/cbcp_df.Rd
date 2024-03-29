% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{cbcp_df}
\alias{cbcp_df}
\title{Cross-border county pairs.}
\format{A data frame with 2,616 rows and 15 variables:
\describe{
  \item{fips_code}{County FIPS code for first county, in original string format. Each FIPS
  code may have greater than one replicate in the data.}
  \item{county_state}{State postal code corresponding to FIPS code.}
  \item{neighbor_fips_code}{County FIPS code for paired county, in original string format.}
  \item{county_state}{State postal code corresponding to neighbor FIPS code.}
  \item{cbcp_id}{Cross-border county pair identifier for the county and its pair.
  A single FIPS code may have multiple
  entires corresponding to each of its bordering counties and their cross-border county pair
  identifier. Each cross-border county pair identifier has two entries in the dataset.}
  \item{state_border_id}{Border identifier for county and its neighbor.}
  \item{dist_bt_centers}{Distance (in miles) between paired county population centers.}
}}
\source{
See \code{adjacent_county_df}.
}
\usage{
cbcp_df
}
\description{
A dataset containing all of the unique cross-border county pairs in the continental United
States. The dataset is constructed using the methods in in Dube, Lester, and Reich (RESTAT,
2010). Specifically, only border counties are included in the dataset, and if a county
is adjacent to p > 1 counties along a border, then the county will have p > 1 replicates in
the dataset. Cross-border county pairs are uniquely identified by \code{cbcp_id}. Additional
metadata: (1) Number of unique border counties = 1,184 (2) Number of unique cross-border county
pairs = 1,308 (3) Distribution of number of pairs for counties: 1 (256), 2 (586), 3 (239),
4 (63), 5+ (40)
}
\keyword{datasets}
