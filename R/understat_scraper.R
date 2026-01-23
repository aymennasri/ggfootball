 utils::globalVariables(c(".data"))
# R/understat_scraper.R, originally from ewenme/understatr
#' @noRd

home_url <- "https://understat.com"

AJAX_HEADERS <- c(
  "X-Requested-With" = "XMLHttpRequest",
  "Accept" = "application/json, text/javascript, */*; q=0.01",
  "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

request_ajax <- function(endpoint) {
  url <- glue::glue("{home_url}/{endpoint}")

  response <- httr::GET(url, httr::add_headers(.headers = AJAX_HEADERS), httr::timeout(30))

  if (httr::status_code(response) != 200) {
    stop(glue::glue("Understat API request failed with status {httr::status_code(response)}.\nURL: {url}"))
  }

  raw_content <- httr::content(response, as = "raw")
  if (identical(httr::headers(response)[["content-encoding"]], "gzip") && length(raw_content) > 2 &&
      raw_content[1] == 0x1f && raw_content[2] == 0x8b) {
    content <- rawToChar(gzcon(rawConnection(raw_content)))
  } else {
    content <- rawToChar(raw_content)
  }

  jsonlite::fromJSON(content)
}

`%||%` <- function(x, y) if (is.null(x)) y else x

#' @noRd
get_match_shots <- function(match_id) {

  if (!grepl("^\\d+$", match_id)) {
    stop("Invalid match_id: must be a numeric string")
  }

  match_data <- request_ajax(glue::glue("getMatchData/{match_id}"))

  if (is.null(match_data$shots) || length(match_data$shots) == 0) {
    stop(glue::glue("No shot data found for match ID {match_id} on Understat."))
  }

  shots_h <- match_data$shots$h
  shots_a <- match_data$shots$a
  shots_h_nrow <- nrow(shots_h %||% data.frame())
  shots_a_nrow <- nrow(shots_a %||% data.frame())

  if (shots_h_nrow > 0) shots_h$h_a <- "h"
  if (shots_a_nrow > 0) shots_a$h_a <- "a"

  shots_data <- switch(
    as.character(c(shots_h_nrow > 0) + 2 * (shots_a_nrow > 0)),
    "1" = shots_a,
    "2" = shots_h,
    "3" = dplyr::bind_rows(shots_h, shots_a),
    stop("No shot data available")
  )

  shots_data$match_id <- match_id

  shots_h_data <- match_data$shots$h
  if (!"h_team" %in% names(shots_data) && "h_team" %in% names(shots_h_data)) {
    shots_data$h_team <- shots_h_data$h_team[1]
  }
  if (!"a_team" %in% names(shots_data) && "a_team" %in% names(shots_h_data)) {
    shots_data$a_team <- shots_h_data$a_team[1]
  }
  if (!"h_goals" %in% names(shots_data) && "h_goals" %in% names(shots_h_data)) {
    shots_data$h_goals <- shots_h_data$h_goals[1]
  }
   if (!"a_goals" %in% names(shots_data) && "a_goals" %in% names(shots_h_data)) {
    shots_data$a_goals <- shots_h_data$a_goals[1]
  }

  numeric_cols <- c("minute", "X", "Y", "xG", "h_goals", "a_goals")
  for (col in numeric_cols) {
    if (col %in% names(shots_data)) {
      shots_data[[col]] <- as.numeric(shots_data[[col]])
    }
  }

  tibble::as_tibble(shots_data)
}
