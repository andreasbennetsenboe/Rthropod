#' Title
#'
#' @param teams a list containing a dataframe for each team, see the README document for the format.
#' @param instructors a vector of character strings containing the initials of the teachers.
#' @param family_reward an integer indicating the number of points rewarded for every new family
#' @param order_reward 
#' @param class_reward 
#' @param expert_threshold 
#' @param NT_reward 
#' @param VU_reward 
#' @param EN_reward 
#' @param CR_reward 
#' @param RE_reward 
#'
#' @return a tibble ready to use in plot_standings().
#' @export
calculate <- function(teams, 
                      instructors,
                      family_reward = 1,
                      order_reward  = 3,
                      class_reward = 5,
                      expert_threshold = 4,
                      NT_reward = 1,
                      VU_reward = 2,
                      EN_reward = 3,
                      CR_reward = 4,
                      RE_reward = 5
) {
  
  teams.tidy <- list()
  
  NT <- c("NT", "Nt", "nt")
  EN <- c("EN", "En", "en")
  VU <- c("VU", "Vu", "vu")
  CR <- c("CR", "Cr", "cr")
  RE <- c("RE", "Re", "re")
  
  for (i in 1:length(teams)) {
    teams.tidy[[i]] <- teams[[i]] %>%
      mutate(Redlist = case_when(
        Redlist %in% c("LC", "Lc", "lc", "NA", "Na", "na", "DD", "Dd", "dd", "NE", "Ne", "ne") ~ 0,
        Redlist %in% NT ~ NT_reward,
        Redlist %in% VU ~ VU_reward,
        Redlist %in% EN ~ EN_reward,
        Redlist %in% CR ~ CR_reward,
        Redlist %in% RE ~ RE_reward,
        TRUE ~ as.numeric(Redlist)
      )
      ) %>%
      replace_na(list(Lifehistorypoints=0, Keyingpoints = 0, Redlist = 0)) %>%
      distinct(Genus, Species, .keep_all = TRUE) %>%
      select(ID, Class, Order, Family, Genus, Species, Keyingpoint, Lifehistorypoint, Initials, Redlist) %>%
      filter(Initials %in% Instructors)
  }
  
  species.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    species.point[[i]] <- teams.tidy[[i]] %>%       
      distinct(Genus, Species) %>%
      summarise(n())
  }
  
  expert.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    expert.point[[i]] <- teams.tidy[[i]] %>%
      count(Family) %>%
      filter(n>expert_threshold) %>%
      summarise(n=sum(n))
  }
  
  family.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    family.point[[i]] <- teams.tidy[[i]] %>%
      summarise(n_distinct(Family)*family_reward)
  }
  
  order.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    order.point[[i]] <- teams.tidy[[i]] %>%
      summarise(n_distinct(Order)*order_reward)
  }
  
  class.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    class.point[[i]] <- teams.tidy[[i]] %>%
      summarise(n_distinct(Class)*class_reward)
  }
  
  keying.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    keying.point[[i]] <- teams.tidy[[i]] %>%
      summarise(sum(Keyingpoint, na.rm = TRUE))
  }
  
  redlist.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    redlist.point[[i]] <- teams.tidy[[i]] %>%
      summarise(sum(Redlist))
  }
  
  lifehistory.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    lifehistory.point[[i]] <- teams.tidy[[i]] %>%
      summarise(sum(Lifehistorypoint, na.rm = TRUE))
  }
  
  team.members <- c()
  for (i in 1:length(teams)) {
    team.members[i] <- first(teams[[i]]$Members)
  }
  
  team.names <- c()
  for (i in 1:length(teams)) {
    team.names[i] <- first(teams[[i]]$Team)
  }
  
  quiz.point <- c()
  for (i in 1:length(teams)) {
    quiz.point[i] <- sum(teams[[i]]$Quizpoint, na.rm = TRUE)
  }
  
  pointlist <- list()
  for (i in 1:length(teams)) {
    pointlist[[i]] <- (species.point[[i]] + family.point[[i]] + order.point[[i]] + class.point[[i]] + expert.point[[i]] + lifehistory.point[[i]] + redlist.point[[i]] + keying.point[[i]]
    ) / team.members[i] * 4 + quiz.point[i]
  }
  
  Score <- c(unlist(pointlist))
  
  Species <- c(unlist(species.point))
  
  All_teams <- data.frame(team.names, Score, Species)
  
  All_teams %>%
    pivot_longer(c(Score, Species), names_to = "Type", values_to = "Score") %>%
    mutate(Score=as.integer(Score)) %>%
    select("Team" = team.names, Type, Score)
}