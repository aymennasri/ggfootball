# Plot an xG chart of a football match

Plot an xG chart of a football match

## Usage

``` r
xg_chart(
  match_id,
  home_team_color,
  away_team_color,
  competition = "",
  bg_color = "#FFF1E5",
  plot_bg_color = "#FFF1E5"
)
```

## Arguments

- match_id:

  Match ID from understat.com

- home_team_color:

  Color used for the home team

- away_team_color:

  Color used for the away team

- competition:

  Competition name as a subtitle; empty by default.

- bg_color:

  Chart background color; defaults to "#FFF1E5"

- plot_bg_color:

  Plot background color; defaults to "#FFF1E5"

## Value

Interactive highcharter plot displaying the xG chart of both teams.

## Examples

``` r
xg_chart(26631, "red", "grey", competition = "Premier League")
#> Error in get_match_shots(match_id): No shot data found for match ID 26631 on Understat.
#> The match may not have shot data available or the page structure may have changed.
```
