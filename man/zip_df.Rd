% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{zip_df}
\alias{zip_df}
\title{Continental U.S. ZIP codes.}
\format{A data frame with 38,879 rows and 9 variables:
\describe{
  \item{zip_code}{ZIP code identifier, in original string format.}
  \item{fips_code}{FIPS code for ZIP code county, in original string format. Some ZIP codes
  may map into multiple counties; only one county match is kept -- the county with
  the largest fraction of population.}
  \item{population_2010}{ZCTA population in 2010. Null if ZIP is not also a ZCTA.}
  \item{housing_units_2010}{ZCTA housing units in 2010. Null if ZIP is not also a ZCTA.}
  \item{land_miles}{Number of square miles of land in 2010. Null if ZIP is not also a ZCTA.}
  \item{water_miles}{Number of square miles of water in 2010. Null if ZIP is not also a ZCTA.}
  \item{lat}{Latitude. Null if ZIP is not also a ZCTA.}
  \item{long}{Longitude. Null if ZIP is not also a ZCTA.}
}}
\source{
\url{https://www.huduser.gov/portal/datasets/usps_crosswalk.html}
}
\usage{
zip_df
}
\description{
A dataset containing identifiers for all ZIP codes in the 48 continental United States
and D.C. Spatial identifiers and population only included for ZIP codes that map into
ZIP code tabulation areas (\url{https://en.wikipedia.org/wiki/ZIP_Code_Tabulation_Area}).
}
\keyword{datasets}
