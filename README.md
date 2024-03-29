
<!-- README.md is generated from README.Rmd. Please edit that file -->

# usgeogr

An R data package containing information on U.S. geographic regions.
Best used for streamlining spatial identification strategies.

## Highlights

  - Datasets on commonly analyzed U.S. geographic units, such as states,
    counties, and ZIP codes.

  - Datasets for implementing cross-border identification strategies,
    such as the contiguous cross-border county pair design in Dube,
    Lester, and Reich (ReSTAT, 2010).

  - Helper functions for calculating distances between U.S. geographic
    regions and distances to state borders.

## Usage

A detailed usage description can be found in the
[vignette](https://github.com/davidsovich/usgeogr/blob/master/vignettes/usgeogr.pdf).

Examples:

``` r

#  U.S. geographic region datasets
  
  # Census regions and division
  census_df

  # States
  state_df

  # Counties
  county_df

  # ZIP codes
  zip_df
  
# Cross-border identification strategy datasets
  
  # County-level studies with replicates (Dube, Lester, Reich (ReSTAT, 2010))
  cbcp_df 
  
  # Within-county-level studies or county-level studies without replicates
  cbcounty_df
  
  # ZIP code-level studies or within-ZIP studies using distance to border strips
  cbzip_df
  
# Functions for distance
  
  # Distance between counties
  county_dist(dplyr::asc(county_df$fips_code), dplyr::desc(county_df$fips_code))
  
  # Distance of county to nearest state border
  county_to_state_border(county_df$fips_code)
  
  # Distance between ZIPs
  zip_dist(dplyr::asc(zip_df$zip_code), dplyr::desc(zip_df$zip_code))
  
  # Distance of ZIP to nearest state border
  zip_to_state_border(zip_df$zip_code)
  
```

## Installation

The usgeogr package is not available on CRAN. You can install the
development version from Github:

``` r
library("devtools")
devtools::install_github("davidsovich/usgeogr", build_vignettes = TRUE)
```

## Contact

davidsovich `AT` uky.edu

## History

  - August 7, 2019: Developmental release
