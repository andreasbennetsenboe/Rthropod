
<!-- README.md is generated from README.Rmd. Please edit that file -->

# touRdemols

<!-- badges: start -->
<!-- badges: end -->

The package touRdemols is a collection of functions that can be used to
efficiently calculate and display the standings in a Tour de Mols
competition.

## Background

The competition is a central part of the Arthropod Field Course for
first year undergraduate students at Aarhus University, but can probably
be applied anywhere in the world for any larger taxon. The competition
dates back to …

## The practical stuff

Multiple teams compete to find the most species. Teams consist of
varying numbers of persons, but the points are standardized to a team
size of four.

The point system rewards a number of things:

-   Encountering a new species (1 point)  
-   Encountering a new family (defaults to 1 point\*)  
-   Encountering a new order (defaults to 3 points\*)  
-   Encountering a new class (defaults to 5 points\*)  
-   Getting good at a family. When you encounter a certain number of
    species within a family an extra point is rewarded per species
    (threshold is four species\*). This is used to encourage people to
    get comfortable at a specific key.  
-   Encountering red listed species. Species listed in the categories
    NT, VU, EN, CR, RE on the regional IUCN Redlist are rewarded with
    more points than other species.\*

’\*’ values can be set differently with the parameters in
calculate\_standings().

## Installation

You can install the released version of touRdemols from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("andreasbennetsenboe/touRdemols")
```

## Example

The folder ‘exampledata’ contains seven data sets from teams that
competed against each other in the Tour de Mols. We use these here to
illustrate how to use the package. Furthermore it contains a little test
data set to show how the data should be structured:

    #>   ID   Class      Order        Family         Genus      Species Keyingpoint
    #> 1  1 Insecta Coleoptera    Elateridae    Negastrius   sabulicola           1
    #> 2  2 Insecta Coleoptera Curculionidae     Mogulones       javeti           1
    #> 3  3 Insecta Coleoptera Curculionidae Trachyphloeus  scabriculus           1
    #> 4  4 Insecta Coleoptera    Elateridae       Ampedus     nigrinus           1
    #> 5  5 Insecta Coleoptera    Elateridae       Ampedus erythrogonus           2
    #> 6  6 Insecta Coleoptera    Elateridae       Ampedus     promorum           2
    #>   Lifehistorypoint Initials Redlist               Team Members Quizpoint
    #> 1               NA      ABB      LC 1. Weevil Rock You       3        50
    #> 2               NA      ABB      LC                         NA        NA
    #> 3               NA      ABB      LC                         NA        NA
    #> 4               NA      ABB      LC                         NA        NA
    #> 5                5      ABB      NT                         NA        NA
    #> 6               NA      ABB      LC                         NA        NA

For people that are not used to working with R or .csv files one can use
the ‘pointscheme.xlsx’ to record your observations and then save as a
.csv file and just name it the integer that represents your group. When
all schemes are sent to you at the end of the day you can start
importing. Do this as a list of teams:

``` r
library(touRdemols)

list.of.teams <- list(
  team1 <- read.csv2("exampledata/1.csv", sep = ";"),
  team2 <- read.csv2("exampledata/2.csv", sep = ";"), 
  team3 <- read.csv2("exampledata/3.csv", sep = ";"), 
  team4 <- read.csv2("exampledata/4.csv", sep = ";"), 
  team5 <- read.csv2("exampledata/5.csv", sep = ","), 
  team6 <- read.csv2("exampledata/6.csv", sep = ","), 
  team7 <- read.csv2("exampledata/7.csv", sep = ";")
)
```

You then feed this vector to the function calculate\_standings(). If you
want to change anything in the point system, the function has a number
of parameters for this, see the help file ?calculate\_standings for
details.

    #> Warning in eval_tidy(pair$rhs, env = default_env): NAs introduced by coercion
    #> # A tibble: 14 x 3
    #>    Team                         Type    Score
    #>    <chr>                        <chr>   <int>
    #>  1 1. Team Ho 1, 2              Score     309
    #>  2 1. Team Ho 1, 2              Species    57
    #>  3 2. Klippespringerne          Score     326
    #>  4 2. Klippespringerne          Species    43
    #>  5 3. Pismyrene                 Score     269
    #>  6 3. Pismyrene                 Species    44
    #>  7 4. Team Trehornet Skarnbasse Score     468
    #>  8 4. Team Trehornet Skarnbasse Species    53
    #>  9 5. Arachnitten               Score     512
    #> 10 5. Arachnitten               Species    92
    #> 11 6. Malaise campisterne       Score     311
    #> 12 6. Malaise campisterne       Species    51
    #> 13 Ved-dyrene                   Score     180
    #> 14 Ved-dyrene                   Species    25

The result is a tibble that is ready for the next function that does the
plotting:

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />
