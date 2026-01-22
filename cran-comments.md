## R CMD check results

0 errors | 0 warnings | 0 notes

## Fixes for CRAN submission

Added graceful error handling for Internet resources as per CRAN policy:

- Added tryCatch blocks to `get_match_shots()` in R/understat_scraper.R to provide informative error messages when:
  - Understat is unavailable
  - Match ID is invalid or not found
  - Page structure has changed and data cannot be parsed

All error messages now include:
- Clear description of what went wrong
- Suggested user actions
- Original error details for debugging
