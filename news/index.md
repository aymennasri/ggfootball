# Changelog

## ggfootball 0.3.0

- **BREAKING CHANGE**: Migrated Understat scraper from HTML parsing to
  AJAX API calls. This changes the internal data structure and column
  names returned by `get_match_shots()`.

- Added gzip decompression handling for compressed responses.

- Added input validation for match_id parameter.

- Fixed type conversion issues for numeric columns (minute, xG, goals,
  etc.).

- Improved error handling with clearer messages.

- Removed unused dependencies: rvest, stringi, stringr, readr.

## ggfootball 0.2.2

CRAN release: 2026-01-23

- Added graceful error handling for Internet resources per CRAN policy.

## ggfootball 0.2.1

CRAN release: 2025-03-22

- Reduced dependencies.

## ggfootball 0.2.0

CRAN release: 2025-01-31

- **BREAKING**: Changed the name of the `background_color` argument of
  [`xg_chart()`](http://aymennasri.me/ggfootball/reference/xg_chart.md)
  to `bg_color`.

- **BREAKING**: Changed the default value of the `competition` argument
  of
  [`xg_chart()`](http://aymennasri.me/ggfootball/reference/xg_chart.md)
  from “Premier League” to empty.

- Added a new argument `plot_bg_color` for
  [`xg_chart()`](http://aymennasri.me/ggfootball/reference/xg_chart.md)
  to allow the color modification of the whole plot background.

- Changed the documentation accordingly.

## ggfootball 0.1.0

CRAN release: 2025-01-30

- Successful CRAN submission.

## ggfootball 0.0.0.9000

- First commit.
- Added function for plotting xG/shots map using ‘Understat’ data
  [`xg_map()`](http://aymennasri.me/ggfootball/reference/xg_map.md).
- Added function for plotting xG charts using ‘Understat’ data
  [`xg_chart()`](http://aymennasri.me/ggfootball/reference/xg_chart.md).
