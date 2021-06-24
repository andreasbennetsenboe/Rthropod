plot_standings <- function(x) {
  ggplot(
    x, 
    aes(
      Team, 
      Score,
      fill=Type
    )
  ) +
    geom_bar(
      stat="identity",
      position = position_dodge(),
      width=0.5
    ) +
    geom_text(
      aes(
        label=(Score)
      ), 
      vjust=-0.5, 
      position = position_dodge(0.5), 
      size=3
    ) +
    theme_minimal()
}