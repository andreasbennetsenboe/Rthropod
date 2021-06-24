#' Calculate standings
#' 
#' Calculates the standings in the competition.
#'
#' @param teams a list containing a data.frame for each team, see the README document for the format.
#' @param instructors a vector of character strings containing the initials of the teachers.
#' @param family_reward an integer indicating the number of points rewarded for every new family encountered
#' @param order_reward an integer indicating the number of points rewarded for every new order encountered
#' @param class_reward an integer indicating the number of points rewarded for every new class encountered
#' @param expert_threshold The number of species within a family that has to be encountered for each species to start counting double. set this too a very high number if the feature is not desired.
#' @param NT_reward an integer indicating the number of points rewarded when encountering a species listed as Near Threatened on the regional IUCN list.
#' @param VU_reward an integer indicating the number of points rewarded when encountering a species listed as Vulnerable on the regional IUCN list.
#' @param EN_reward an integer indicating the number of points rewarded when encountering a species listed as Endangered on the regional IUCN list.
#' @param CR_reward an integer indicating the number of points rewarded when encountering a species listed as Critically endangered on the regional IUCN list.
#' @param RE_reward an integer indicating the number of points rewarded when encountering a species listed as Regionally Extinct on the regional IUCN list.
#'
#' @return a tibble ready to use in plot_standings().
#' @export
calculate_standings <- function(teams, 
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
      dplyr::mutate(Redlist = dplyr::case_when(
        Redlist %in% c("LC", "Lc", "lc", "NA", "Na", "na", "DD", "Dd", "dd", "NE", "Ne", "ne") ~ 0,
        Redlist %in% NT ~ NT_reward,
        Redlist %in% VU ~ VU_reward,
        Redlist %in% EN ~ EN_reward,
        Redlist %in% CR ~ CR_reward,
        Redlist %in% RE ~ RE_reward,
        TRUE ~ as.numeric(Redlist)
      )
      ) %>%
      tidyr::replace_na(list(Lifehistorypoints=0, Keyingpoints = 0, Redlist = 0)) %>%
      dplyr::distinct(Genus, Species, .keep_all = TRUE) %>%
      dplyr::select(ID, Class, Order, Family, Genus, Species, Keyingpoint, Lifehistorypoint, Initials, Redlist) %>%
      dplyr::filter(Initials %in% Instructors)
  }
  
  species.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    species.point[[i]] <- teams.tidy[[i]] %>%       
      dplyr::distinct(Genus, Species) %>%
      dplyr::summarise(dplyr::n())
  }
  
  expert.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    expert.point[[i]] <- teams.tidy[[i]] %>%
      dplyr::count(Family) %>%
      dplyr::filter(n>expert_threshold) %>%
      dplyr::summarise(n=sum(n))
  }
  
  family.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    family.point[[i]] <- teams.tidy[[i]] %>%
      dplyr::summarise(dplyr::n_distinct(Family)*family_reward)
  }
  
  order.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    order.point[[i]] <- teams.tidy[[i]] %>%
      dplyr::summarise(dplyr::n_distinct(Order)*order_reward)
  }
  
  class.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    class.point[[i]] <- teams.tidy[[i]] %>%
      dplyr::summarise(dplyr::n_distinct(Class)*class_reward)
  }
  
  keying.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    keying.point[[i]] <- teams.tidy[[i]] %>%
      dplyr::summarise(sum(Keyingpoint, na.rm = TRUE))
  }
  
  redlist.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    redlist.point[[i]] <- teams.tidy[[i]] %>%
      dplyr::summarise(sum(Redlist))
  }
  
  lifehistory.point <- list()
  
  for (i in 1:length(teams.tidy)) {
    lifehistory.point[[i]] <- teams.tidy[[i]] %>%
      dplyr::summarise(sum(Lifehistorypoint, na.rm = TRUE))
  }
  
  team.members <- c()
  for (i in 1:length(teams)) {
    team.members[i] <- dplyr::first(teams[[i]]$Members)
  }
  
  team.names <- c()
  for (i in 1:length(teams)) {
    team.names[i] <- dplyr::first(teams[[i]]$Team)
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
    tidyr::pivot_longer(c(Score, Species), names_to = "Type", values_to = "Score") %>%
    dplyr::mutate(Score=as.integer(Score)) %>%
    dplyr::select("Team" = team.names, Type, Score)
}