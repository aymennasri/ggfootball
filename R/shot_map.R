#' Plot shots from a football match
#'
#' @param match_id Desired match ID from understat.com
#' @param title Plot title; empty by default
#'
#' @return Interactive ggiraph plot displaying both teams shots side by side printed to the Viewer.
#' @export
#'
#' @examples shot_map(26631, title = "xG Map")
#'
#' @import ggsoccer
#' @import ggiraph
#' @import ggplot2
#' @importFrom gdtools register_gfont

shot_map <- function(match_id, title = ""){
  register_gfont("Karla")
  match <- get_match_shots(match_id) %>%
    select(
      .data$minute, .data$result, .data$X, .data$Y, .data$xG, .data$player,
      .data$h_a, .data$situation, .data$shotType, .data$h_team, .data$a_team,
      .data$h_goals, .data$a_goals, .data$date, .data$player_assisted, .data$lastAction
    )

  match$shotType <- gsub("([a-z])([A-Z])", "\\1 \\2", match$shotType)
  match$result <- gsub("([a-z])([A-Z])", "\\1 \\2", match$result)
  match$result <- case_when(match$result == "Missed Shots" ~ "Missed Shot",
                             TRUE ~ match$result)

  match$X <- ifelse(match$result == "Own Goal" & match$xG < 0.1,
                    1 - match$X,
                    match$X)

  match$h_a <- case_when(match$h_a == "h" ~ glue("{match$h_team}"),
                         match$h_a == "a" ~ glue("{match$a_team}"),
                         TRUE ~ match$h_a)

  result_colors <- c(
    "Goal" = "#4CBB17",
    "Saved Shot" = "#FFD300",
    "Shot On Post" = "#FFA500",
    "Blocked Shot" = "#FF0000",
    "Missed Shot" = "#C0C0C0",
    "Own Goal" = "red4"
  )

  result_shapes <- c(
    "Goal" = 21, "Missed Shot" = 22,
    "Blocked Shot" = 24, "Saved Shot" = 23,
    "Shot On Post" = 25, "Own Goal" = 19
  )

  girafe(ggobj = ggplot(match) +
           annotate_pitch(goals = goals_line) +
           theme_pitch() +
           geom_point_interactive(
             aes(
               x = .data$X * 100 , y = .data$Y * 100,
               fill = factor(.data$result, levels = c("Goal", "Own Goal", "Saved Shot", "Shot On Post", "Blocked Shot", "Missed Shot")),
               size = .data$xG,
               shape = factor(.data$result, levels = c("Goal", "Own Goal", "Saved Shot", "Shot On Post", "Blocked Shot", "Missed Shot")),
               tooltip = glue(
                 "<span>{player} ({minute}')<br>
                        Assisted by {player_assisted}<br>
                        {shotType}<br>
                        {round(xG, 2)} xG
                  </span>"
               ),
               data_id = glue("{player}")), stroke = 0.75, alpha = 0.9) +
           scale_shape_manual_interactive(values = result_shapes) +
           scale_fill_manual_interactive(values = result_colors) +
           coord_flip(xlim = c(52.45, 101)) +
           scale_y_reverse() +
           labs(
             title = title,
             caption = "Data: Understat"
           ) +
           theme(legend.position = "bottom",
                 strip.text = element_text(size = 12),
                 plot.background = element_rect(fill = "transparent", color = NA),
                 panel.background = element_rect(fill = "transparent", color = NA),
                 title = element_text(face = "bold", size = 20),
                 plot.title = element_text(hjust = 0.5),
                 legend.title.position = "top",
                 legend.title = element_text(face = "bold", size = 10),
                 plot.caption = element_text(face = "plain", size = 8),
                 legend.box.background = element_rect(fill = "transparent", color = NA)
                 ) +
           guides(fill = guide_legend(title = "Shot Outcome", nrow = 1, override.aes = list(size = 5, stroke = 1)),
                  shape = guide_legend(title = "Shot Outcome", ncol = 2),
                  size = guide_legend(title = "xG Value", override.aes = list(shape = 21, fill = "gray"))) +
           facet_wrap_interactive(~ .data$h_a, interactive_on = "both"),
         options = list(
           opts_hover(css = ""),
           opts_hover_inv(css = 'opacity:0.1;'),
           opts_toolbar(
             saveaspng = FALSE
           ),
           opts_tooltip(
             opacity = 0.8
           )),
           fonts = list(sans = "Karla")
  )
}
