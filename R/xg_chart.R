#' Plot an xG chart of a football match
#'
#' @param match_id Match ID from understat.com
#' @param home_team_color Color used for the home team
#' @param away_team_color Color used for the away team
#' @param competition Competition name as a subtitle; empty by default.
#' @param bg_color Chart background color; defaults to "#FFF1E5"
#' @param plot_bg_color Plot background color; defaults to "#FFF1E5"
#'
#' @return Interactive highcharter plot displaying the xG chart of both teams.
#' @export
#'
#' @examples xg_chart(26631, "red", "grey", competition = "Premier League")

xg_chart <- function(match_id, home_team_color, away_team_color,
                     competition = "", bg_color = "#FFF1E5", plot_bg_color = "#FFF1E5"){

  # Icons from icons8.com
  folder <- system.file("assets", package = "ggfootball")
  my_files <- list.files(folder, full.names = TRUE)
  goal_path <- my_files[grep("goal\\.png$", my_files, ignore.case = TRUE)]
  own_goal_path <- my_files[grep("own_goal\\.png$", my_files, ignore.case = TRUE)]

  goal_icon <- base64enc::base64encode(readBin(goal_path[1], "raw", file.info(goal_path[1])$size))
  own_goal_icon <- base64enc::base64encode(readBin(own_goal_path[1], "raw", file.info(own_goal_path[1])$size))
  suppressMessages({
    match <- get_match_shots(match_id) |>
      dplyr::mutate(
        h_a = dplyr::case_when(
          result == "OwnGoal" & h_a == 'a' ~ 'h',
          result == "OwnGoal" & h_a == 'h' ~ 'a',
          TRUE ~ h_a)
      )
    match$player_assisted <- ifelse(is.na(match$player_assisted), "None", match$player_assisted)

    match$situation <- gsub("([a-z])([A-Z])", "\\1 \\2", match$situation)
    match$lastAction <- gsub("([a-z])([A-Z])", "\\1 \\2", match$lastAction)

    # Prepare data for home and away teams
    home_data <- match |>
      dplyr::filter(.data$h_a == "h") |>
      dplyr::arrange(.data$minute) |>
      dplyr::mutate(cumulativexG = cumsum(.data$xG))

    away_data <- match |>
      dplyr::filter(.data$h_a == "a") |>
      dplyr::arrange(.data$minute) |>
      dplyr::mutate(cumulativexG = cumsum(.data$xG))

    # Get team names and scores
    home_team <- unique(match$h_team)[1]
    away_team <- unique(match$a_team)[1]

    # Get season info
    season <-  glue::glue("{match$season[1]}/{match$season[1] + 1}")
    date <- format(match$date[1], "%A, %d %B %Y")

    # Calculate max values for axis limits
    max_minute <- ifelse(max(match$minute) < 90, 90, max(match$minute))
    max_xg <- ceiling(max(c(home_data$cumulativexG, away_data$cumulativexG)))

    extend_data <- function(data, max_minute) {
      if (nrow(data) > 0) {
        last_xg <- utils::tail(data$cumulativexG, 1)
        last_row <- utils::tail(data, 1)
        data |>
          tibble::add_row(
            minute = max_minute,
            h_a = last_row$h_a,
            h_team = last_row$h_team,
            a_team = last_row$a_team,
            cumulativexG = last_xg
          )
      } else {
        data
      }
    }

    home_data <- home_data |> extend_data(max_minute)
    away_data <- away_data |> extend_data(max_minute)

    # Create the highchart
    highcharter::highchart() |>
      highcharter::hc_chart(backgroundColor = bg_color, plotBackgroundColor = plot_bg_color) |>
      highcharter::hc_title(
        text = glue::glue("<span style='color:{home_team_color}'>{home_team} {match$h_goals[1]}</span>
                - <span style='color:{away_team_color}'>{match$a_goals[1]} {away_team}</span>"),
        style = list(fontSize = "30px", fontFamily = "Karla"),
        align = "left",
        useHTML = TRUE
      ) |>
      highcharter::hc_subtitle(
        text = glue::glue("<span>{competition} {season} | {date}</span>"),
        style = list(fontSize = "15px", fontFamily = "Karla"),
        align = "left",
        useHTML = TRUE
      ) |>
      highcharter::hc_xAxis(
        title = list(text = "Minute", style = list(fontFamily = "Karla")),
        min = 0,
        max = max_minute,
        tickInterval = 15
      ) |>
      highcharter::hc_yAxis(
        title = list(text = "Expected goals", style = list(fontFamily = "Karla")),
        min = 0,
        max = max_xg,
        tickInterval = 1
      ) |>
      highcharter::hc_add_series(
        data = home_data,
        type = "line",
        step = "left",
        name = "Home xG",
        color = home_team_color,
        lineWidth = 2,
        highcharter::hcaes(x = .data$minute, y = .data$cumulativexG),
        stickyTracking = FALSE
      ) |>
      highcharter::hc_add_series(
        data = away_data,
        type = "line",
        step = "left",
        name = "Away xG",
        color = away_team_color,
        lineWidth = 2,
        highcharter::hcaes(x = .data$minute, y = .data$cumulativexG),
        stickyTracking = FALSE
      ) |>
      highcharter::hc_add_series(
        data = home_data |> dplyr::filter(.data$result == "Goal" & .data$h_a == "h"),
        type = "scatter",
        name = "Home Goals",
        color = home_team_color,
        marker = list(radius = 8,
                      symbol = highcharter::JS(paste0(" 'url(data:image/png;base64,", goal_icon, ")' "))),
        highcharter::hcaes(x = .data$minute, y = .data$cumulativexG),
        stickyTracking = FALSE,
        dataLabels = list(enabled = TRUE,
                          format = "{point.player}<br>({point.minute}')<br>",
                          shape = "callout",
                          style = list(fontFamily = "Karla",
                                       textOutline = "none",
                                       fontWeight = "normal"),
                          y = -5
        )
      ) |>
      highcharter::hc_add_series(
        data = away_data |> dplyr::filter(.data$result == "Goal" & .data$h_a == "a"),
        type = "scatter",
        name = "Away Goals",
        color = away_team_color,
        marker = list(radius = 8,
                      symbol = highcharter::JS(paste0(" 'url(data:image/png;base64,", goal_icon, ")' "))),
        highcharter::hcaes(x = .data$minute, y = .data$cumulativexG),
        stickyTracking = FALSE,
        dataLabels = list(enabled = TRUE,
                          format = "{point.player}<br>({point.minute}')<br>",
                          shape = "callout",
                          style = list(fontFamily = "Karla",
                                       textOutline = "none",
                                       fontWeight = "normal"),
                          y = -5
        )
      ) |>
      highcharter::hc_add_series(
        data = away_data |>
          rbind(home_data) |>
          dplyr::filter(.data$result == "OwnGoal"),
        type = "scatter",
        name = "Own Goals",
        color = away_team_color,
        marker = list(radius = 8,
                      symbol = highcharter::JS(paste0(" 'url(data:image/png;base64,", own_goal_icon, ")' "))),
        highcharter::hcaes(x = .data$minute, y = .data$cumulativexG),
        stickyTracking = FALSE,
        dataLabels = list(enabled = TRUE,
                          format = "{point.player}<br>({point.minute}')<br>",
                          shape = "callout",
                          style = list(fontFamily = "Karla",
                                       textOutline = "none",
                                       fontWeight = "normal"),
                          y = -5)
      ) |>
      highcharter::hc_legend(enabled = TRUE,
                itemStyle = list(fontFamily = "Karla", fontWeight = "normal", fontSize = "16px"),
                style = list(fontFamily = "Karla")) |>
      highcharter::hc_credits(
        enabled = TRUE,
        text = "Data: Understat",
        style = list(fontSize = "15px", fontFamily = "Karla"),
        href = glue::glue("https://understat.com/match/{match_id}")
      ) |>
      highcharter::hc_tooltip(
        shared = FALSE,
        headerFormat = "<b>Minute {point.x}'</b><br>",
        pointFormat = "{series.name}: {point.y:.2f}<br>",
        style = list(fontFamily = "Karla"),
        stickOnContact = TRUE,
        snap = 10
      ) |>
      highcharter::hc_plotOptions(
        line = list(
          marker = list(enabled = FALSE)
        ),
        scatter = list(
          tooltip = list(
            pointFormat = "<b>{point.situation}</b><br>Last Action: {point.lastAction}<br>Assisted by: {point.player_assisted}",
            headerFormat = NULL
          )
        )
      )
  })
}
