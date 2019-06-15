
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tukeygrps

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/tukeygrps)](https://cran.r-project.org/package=tukeygrps)
<!-- badges: end -->

Tukeygrps provides a simple helper function for the letter annotation of
(gg)plots according to statistical differences between groups determined
by a Tukey-HSD test.

## Installation

You can install tukeygrps from github using devtools:

``` r
install.packages("devtools")
install_github("leonardblaschek/tukeygrps")
```

## Example

Here we use tukey\_groups() to quickly add letters to a ggplot. Alpha is
set to 0.001, and the resulting letters indicate statistical differences
within each panel.

``` r
library(tukeygrps)
library(agricolae)
library(tidyverse)

data(mpg)
head(mpg)
#> # A tibble: 6 x 11
#>   manufacturer model displ  year   cyl trans  drv     cty   hwy fl    class
#>   <chr>        <chr> <dbl> <int> <int> <chr>  <chr> <int> <int> <chr> <chr>
#> 1 audi         a4      1.8  1999     4 auto(… f        18    29 p     comp…
#> 2 audi         a4      1.8  1999     4 manua… f        21    29 p     comp…
#> 3 audi         a4      2    2008     4 manua… f        20    31 p     comp…
#> 4 audi         a4      2    2008     4 auto(… f        21    30 p     comp…
#> 5 audi         a4      2.8  1999     6 auto(… f        16    26 p     comp…
#> 6 audi         a4      2.8  1999     6 manua… f        18    26 p     comp…

tukey_letters <- tukey_groups(mpg, hwy, class, 0, 0.001, cyl)

head(tukey_letters)
#> # A tibble: 6 x 4
#> # Groups:   cyl [1]
#>     cyl   hwy groups class     
#>   <int> <dbl> <chr>  <chr>     
#> 1     4     0 a      subcompact
#> 2     4     0 ab     compact   
#> 3     4     0 ab     midsize   
#> 4     4     0 ab     minivan   
#> 5     4     0 b      suv       
#> 6     4     0 b      pickup

ggplot() +
  geom_point(data = mpg, 
             aes(x = class,
                 y = hwy)) +
  geom_text(data = tukey_letters,
            aes(x = class,
                y = hwy,
                label = groups)) +
  facet_wrap(~ cyl) +
  coord_flip()
```

<img src="man/figures/README-example-1.png" width="100%" />

**Note:** The distributions and sample numbers in this example dataset
should discourage anyone from applying a parametric test such as the
Tukey-HSD. Before you use this function, make sure that your
observations are:

  - normally distributed
  - homoscedastic
  - independent within and between groups
  - of similar sample size
