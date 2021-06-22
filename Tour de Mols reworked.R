library(tidyverse)

####---- Udfyld: instruktor initialer, holdnavne og antal deltagere, bruges desuden til at indtaste quizpoint----####

instruktor <- c("ABB", "CK", "SK", "CB")

allehold <- list(
  c(  
    Holdnavn1 <- "1. Team Ho 1, 2",
    deltagere1 <- 4,
    quiz.point1 <- 12 + 15 + 9 + 21 - 25   #skriv alle point i ét regnestykke i denne linje for hvert hold
  ),
  
  c(
    Holdnavn2 <- "2. Klippespringerne",
    deltagere2 <- 3.5,
    quiz.point2 <- 12 + 15 + 15 + 39 - 100
  ),
  
  c(
    Holdnavn3 <- "3. Pismyrene",
    deltagere3 <- 4,
    quiz.point3 <- 9 + 6 + 9 + 15 - 25
  ),
  
  c(
    Holdnavn4 <- "4. Team Trehornet Skarnbasse",
    deltagere4 <- 3.5,
    quiz.point4 <- 15 + 15 + 12 + 39 - 50
  ),
  
  c(
    Holdnavn5 <- "5. Arachnitten",
    deltagere5 <- 4,
    quiz.point5 <- 18 + 15 + 15 + 54 + 100
  ),
  
  c(
    Holdnavn6 <- "6. Malaise campisterne",
    deltagere6 <- 4,
    quiz.point6 <- 15 + 15 + 12 + 24 - 100
  ),
  
  c(
    Holdnavn7 <- "Ved-dyrene",
    deltagere7 <- 4,
    quiz.point7 <- 15 + 15 + 9 + 36 - 20
  ) # !OBS! Hvis hold 8 findes, sæt da et komma efter denne slutparentes, hvis det ikke findes slet da kommaet
  
#  c(
#  Holdnavn8 <- "Naturligvis",
#  deltagere8 <- 4,
#  quiz.point8 <- 3 + 3 + 15 + 21 - 30
#  ) # !OBS! Hvis hold 8 ikke findes sæt da et '#' før hver af linjerne 51-55. Hvis hold 8 findes, fjern da disse.
)

####---- Indlæs skemaer (Her skal der evt. fjernes/tilføjes hold og justeres kommaseparator)----####

skemaer <- list(
  skema1 <- read.csv2("1.csv", sep = ";"), # !OBS! nogle .csv er adskilt af , andre af ; tilpas dette i 'sep = '-argumentet
  skema2 <- read.csv2("2.csv", sep = ";"), 
  skema3 <- read.csv2("3.csv", sep = ";"), 
  skema4 <- read.csv2("4.csv", sep = ";"), 
  skema5 <- read.csv2("5.csv", sep = ","), 
  skema6 <- read.csv2("6.csv", sep = ","), 
  skema7 <- read.csv2("7.csv", sep = ";") # !OBS! Hvis hold 8 findes, sæt da et komma efter denne slutparentes.
#  skema8 <- read.csv2("8.csv", sep = ";") # !OBS! Hvis hold 8 ikke findes, sæt da et '#' før denne linje
)


####--- Ryd op i skemaer (rør ikke)---####
skemaer.renset <- list()

for (i in 1:length(skemaer)) {
  skemaer.renset[[i]] <- skemaer[[i]] %>%
    mutate(Rødliste = case_when(
      Rødliste %in% c("LC", "Lc", "lc", "NA", "Na", "na", "DD", "Dd", "dd", "NE", "Ne", "ne") ~ 0,
      Rødliste %in% c("NT", "Nt", "nt") ~ 1,
      Rødliste %in% c("VU", "Vu", "vu") ~ 2,
      Rødliste %in% c("EN", "En", "en") ~ 3,
      Rødliste %in% c("CR", "Cr", "cr") ~ 4,
      Rødliste %in% c("RE", "Re", "re") ~ 5,
      TRUE ~ as.numeric(Rødliste)
    )
    ) %>%
    replace_na(list(Livshistoriepoint=0, Nøglepoint = 0, Rødliste = 0)) %>%
    distinct(Slægt, Artsnavn, .keep_all = TRUE) %>%
    select(ID, Slægt, Artsnavn, Familie, Orden, Klasse, Nøglepoint, Livshistoriepoint, Initialer, Rødliste) %>%
    filter(Initialer %in% instruktor)
}

####---- Pointberegning (rør ikke)----####

art.point <- list()

  for (i in 1:length(skemaer.renset)) {
    art.point[[i]] <- skemaer.renset[[i]] %>%       
    distinct(Slægt, Artsnavn) %>%
    summarise(n())
  }


fordybning.point <- list()

for (i in 1:length(skemaer.renset)) {
  fordybning.point[[i]] <- skemaer.renset[[i]] %>%
    count(Familie) %>%
    filter(n>4) %>%
    summarise(n=sum(n))
}


familie.point <- list()

for (i in 1:length(skemaer.renset)) {
  familie.point[[i]] <- skemaer.renset[[i]] %>%
    summarise(n_distinct(Familie))
}


orden.point <- list()

for (i in 1:length(skemaer.renset)) {
  orden.point[[i]] <- skemaer.renset[[i]] %>%
    summarise(n_distinct(Orden)*3)
}


klasse.point <- list()

for (i in 1:length(skemaer.renset)) {
  klasse.point[[i]] <- skemaer.renset[[i]] %>%
    summarise(n_distinct(Klasse)*5)
}


nøgle.point <- list()

for (i in 1:length(skemaer.renset)) {
  nøgle.point[[i]] <- skemaer.renset[[i]] %>%
    summarise(sum(Nøglepoint))
}


rødliste.point <- list()

for (i in 1:length(skemaer.renset)) {
  rødliste.point[[i]] <- skemaer.renset[[i]] %>%
    summarise(sum(Rødliste))
}


livshistorie.point <- list()

for (i in 1:length(skemaer.renset)) {
  livshistorie.point[[i]] <- skemaer.renset[[i]] %>%
    summarise(sum(Livshistoriepoint))
}

####---- Point sammenfatning (rør ikke)----####
allehold <- data.frame(t(matrix(unlist(allehold), nrow = 3)))

quizpoint <- as.numeric(allehold$X3)

pointlist <- list()

for (i in 1:length(skemaer)) {
  pointlist[[i]] <- (art.point[[i]] + familie.point[[i]] + orden.point[[i]] + klasse.point[[i]] + fordybning.point[[i]] + livshistorie.point[[i]] + rødliste.point[[i]] + nøgle.point[[i]]
  ) / deltagere1 * 4 + quizpoint[i]
}

####---- Figurer (rør ikke)----####

Score <- c(unlist(pointlist))

Arter <- c(unlist(art.point))

allehold <- cbind(allehold, Score, Arter)

point.stilling <- allehold %>%
  pivot_longer(c(Score, Arter), names_to = "Type", values_to = "Score") %>%
  mutate(Score=as.integer(Score)) %>%
  select("Hold" = X1, Type, Score)

ggplot(
  point.stilling, 
  aes(
    Hold, 
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

