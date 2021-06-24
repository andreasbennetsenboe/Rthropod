#' Make a plot of the standings
#'
#'Takes a tibble prepared by calculate_standings() and makes an overview plot of the competition standings.
#'
#' @param x A tibble prepared by calculate_standings()
#'
#' @return a ggplot2 barplot.
#' @export
plot_standings <- function(x) {
  ggplot2::ggplot(
    x, 
    ggplot2::aes(
      Team, 
      Score,
      fill=Type
    )
  ) +
    ggplot2::geom_bar(
      stat="identity",
      position = ggplot2::position_dodge(),
      width=0.5
    ) +
    ggplot2::geom_text(
      ggplot2::aes(
        label=(Score)
      ), 
      vjust=-0.5, 
      position = ggplot2::position_dodge(0.5), 
      size=3
    ) +
    ggplot2::theme_minimal()+ 
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle=45,hjust=1))
}