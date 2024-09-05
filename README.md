
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggfootball

<!-- badges: start -->
<!-- badges: end -->

An R package for plotting [understat](understat.com) data; an xG chart
and a shot map.

## Installation

You can install the development version of ggfootball from
[GitHub](https://github.com/) with:

``` r
remotes::install_github("aymennasri/ggfootball")
```

## Example

``` r
library(ggfootball)

# xG chart
xg_chart(match_id = 26631, home_team_color = "red", away_team_color = "grey", competition = "Premier League")

# Shot/xG map
shot_map(match_id = 26631, title = "Shot Map")
```
