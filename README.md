
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tukeygrps

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/tukeygrps)](https://cran.r-project.org/package=tukeygrps)
<!-- badges: end -->

Tukeygrps provides simple wrapper functions for the annotation of
(gg)plots according to statistical differences between groups determined
by a parametric Tukey-HSD test or a non-parametric Kruskal-Wallis test.
The underlying statistical functions are called from the *agricolae*
package.

## Installation

You can install tukeygrps from github using devtools:

``` r
install.packages("devtools")
library("devtools")
install_github("leonardblaschek/tukeygrps")
```

## Examples

### Parametric multiple comparisons

The distributions and sample numbers in these example datasets don’t
always allow for the use of a parametric test such as the Tukey-HSD.
Before you use this function, make sure that your observations are:

  - **normally** distributed
  - **homoscedastic**
  - **independent** within and between groups
  - **equal** in sample size

If they are **not**, scroll down to the *non-parametric comparisons*.

Here we use letter\_groups() with stat\_method = “tukey” to add letters
to a geom\_point plot. Alpha is set to 0.001, the letters are printed at
y = 0, and there are no additional grouping variables.

``` r
library(tukeygrps)
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

tukey_letters <- letter_groups(mpg, hwy, class, "tukey", print_position = 0, stat_alpha = 0.001)

head(tukey_letters)
#>                mean groups      class hwy
#> compact    28.29787      a    compact   0
#> subcompact 28.14286      a subcompact   0
#> midsize    27.29268      a    midsize   0
#> 2seater    24.80000     ab    2seater   0
#> minivan    22.36364     bc    minivan   0
#> suv        18.12903     cd        suv   0

ggplot() +
  geom_jitter(
    data = mpg,
    aes(
      x = class,
      y = hwy
    ),
    width = 0.1
  ) +
  geom_text(
    data = tukey_letters,
    aes(
      x = class,
      y = hwy,
      label = groups
    )
  ) +
  coord_flip()
```

<img src="man/figures/README-example no groups-1.png" width="100%" />

Here we split the statistical analysis by two grouping variables (“cut”
and “color”), set the alpha to 0.05 and print the letters at y = -1000.

``` r
library(tukeygrps)
library(tidyverse)

data(diamonds)
diamonds <- diamonds %>%
  filter(cut %in% c("Ideal", "Premium", "Very Good") & color %in% c("D", "E", "F"))
head(diamonds)
#> # A tibble: 6 x 10
#>   carat cut       color clarity depth table price     x     y     z
#>   <dbl> <ord>     <ord> <ord>   <dbl> <dbl> <int> <dbl> <dbl> <dbl>
#> 1  0.23 Ideal     E     SI2      61.5    55   326  3.95  3.98  2.43
#> 2  0.21 Premium   E     SI1      59.8    61   326  3.89  3.84  2.31
#> 3  0.22 Premium   F     SI1      60.4    61   342  3.88  3.84  2.33
#> 4  0.2  Premium   E     SI2      60.2    62   345  3.79  3.75  2.27
#> 5  0.32 Premium   E     I1       60.9    58   345  4.38  4.42  2.68
#> 6  0.23 Very Good E     VS2      63.8    55   352  3.85  3.92  2.48

tukey_letters <- letter_groups(
  diamonds,
  price,
  clarity,
  "tukey",
  cut,
  color,
  print_position = -1000,
  stat_alpha = 0.05,
)

head(tukey_letters)
#> # A tibble: 6 x 6
#> # Groups:   cut, color [1]
#>   cut       color   mean groups clarity price
#>   <ord>     <ord>  <dbl> <chr>  <chr>   <dbl>
#> 1 Very Good D     10298. a      IF      -1000
#> 2 Very Good D      4425. b      SI2     -1000
#> 3 Very Good D      3235. c      SI1     -1000
#> 4 Very Good D      3145. c      VS2     -1000
#> 5 Very Good D      2988. c      VVS1    -1000
#> 6 Very Good D      2955. c      VS1     -1000

ggplot() +
  geom_jitter(
    data = diamonds,
    aes(
      x = clarity,
      y = price
    ),
    size = 1,
    width = 0.1,
    alpha = 0.25
  ) +
  geom_boxplot(
    data = diamonds,
    aes(
      x = clarity,
      y = price
    ),
    outlier.alpha = 0,
    fill = rgb(1, 1, 1, 0.5)
  ) +
  geom_text(
    data = tukey_letters,
    aes(
      x = clarity,
      y = price,
      label = groups
    ),
    size = 3
  ) +
  facet_grid(cut ~ color) +
  coord_flip()
```

<img src="man/figures/README-example-1.png" width="100%" />

### Non-parametric multiple comparisons

In case the above requirements for parametric tests are not met, we can
fall back to the non-parametric Kruskal–Wallis test with *p*-value
adjustment for multiple comparisons. Here we place the letter codes 0.5
standard deviations above the maximum values.

``` r
library(tukeygrps)
library(tidyverse)

data(diamonds)
diamonds <- diamonds %>%
  filter(cut %in% c("Ideal", "Premium", "Very Good") & color %in% c("D", "E", "F"))
head(diamonds)
#> # A tibble: 6 x 10
#>   carat cut       color clarity depth table price     x     y     z
#>   <dbl> <ord>     <ord> <ord>   <dbl> <dbl> <int> <dbl> <dbl> <dbl>
#> 1  0.23 Ideal     E     SI2      61.5    55   326  3.95  3.98  2.43
#> 2  0.21 Premium   E     SI1      59.8    61   326  3.89  3.84  2.31
#> 3  0.22 Premium   F     SI1      60.4    61   342  3.88  3.84  2.33
#> 4  0.2  Premium   E     SI2      60.2    62   345  3.79  3.75  2.27
#> 5  0.32 Premium   E     I1       60.9    58   345  4.38  4.42  2.68
#> 6  0.23 Very Good E     VS2      63.8    55   352  3.85  3.92  2.48

kruskal_letters <- letter_groups(diamonds, price, clarity, "kruskal", cut, color, print_position = "above", print_adjust = 0.5)

head(kruskal_letters)
#> # A tibble: 6 x 6
#> # Groups:   cut, color [1]
#>   cut       color  mean groups clarity  price
#>   <ord>     <ord> <dbl> <chr>  <chr>    <dbl>
#> 1 Very Good D     1243. a      IF      20304.
#> 2 Very Good D      895. b      SI2     20288.
#> 3 Very Good D      794. bc     I1       5578.
#> 4 Very Good D      765. c      SI1     18048.
#> 5 Very Good D      731. c      VS2     18915.
#> 6 Very Good D      686. c      VS1     18512.

ggplot() +
  geom_jitter(
    data = diamonds,
    aes(
      x = clarity,
      y = price
    ),
    size = 1,
    width = 0.1,
    alpha = 0.25
  ) +
  geom_boxplot(
    data = diamonds,
    aes(
      x = clarity,
      y = price
    ),
    outlier.alpha = 0,
    fill = rgb(1, 1, 1, 0.5)
  ) +
  geom_text(
    data = kruskal_letters,
    aes(
      x = clarity,
      y = price,
      label = groups
    ),
    size = 3
  ) +
  facet_grid(cut ~ color) +
  coord_flip()
```

<img src="man/figures/README-example non-parametric-1.png" width="100%" />
