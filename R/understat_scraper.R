utils::globalVariables(c(".data"))
# R/understat_scraper.R, originally from ewenme/understatr
#' @noRd

home_url <- "https://understat.com"

# scrape helpers ----------------------------------------------------------

# get script part of html page
get_script <- function(x) {
  as.character(rvest::html_nodes(x, "script"))
}

# subset data element of html page
get_data_element <- function(x, element_name) {
  stringi::stri_unescape_unicode(stringr::str_subset(x, element_name))
}

# fix json element for parsing
fix_json <- function(x) {
  extracted <- unlist(stringr::str_extract_all(x, "\\[.*?\\]"))
  stringr::str_subset(extracted, "\\[\\]", negate = TRUE)
}

# get player name part of html page
get_player_name <- function(x) {
  player_name <- rvest::html_nodes(x, ".header-wrapper:first-child")
  trimws(rvest::html_text(player_name))
}

# R/get_match_shots.R
#' @noRd


get_match_shots <- function(match_id) {

  # Build match URL using package's internal home_url
  match_url <- glue::glue("{home_url}/match/{match_id}")

  # Read match page HTML
  match_page <- rvest::read_html(match_url)

  # Use internal helper functions
  match_data <- get_script(match_page)
  shots_data <- get_data_element(match_data, "shotsData")
  shots_data <- fix_json(shots_data)

  # Process JSON data
  shots_data <- lapply(shots_data, jsonlite::fromJSON)
  shots_data <- do.call("rbind", shots_data)

  # Add match ID and clean data
  shots_data$match_id <- match_id
  shots_data <- readr::type_convert(shots_data)

  tibble::as_tibble(shots_data)
}
