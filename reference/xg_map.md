# Plot shots xG of a football match

Plot shots xG of a football match

## Usage

``` r
xg_map(match_id, title = "")
```

## Arguments

- match_id:

  Desired match ID from understat.com

- title:

  Plot title; empty by default

## Value

Interactive ggiraph transparent plot displaying both teams shots side by
side printed to the Viewer.

## Examples

``` r
if (FALSE) { # \dontrun{
xg_map(26631, title = "xG Map")
} # }
```
