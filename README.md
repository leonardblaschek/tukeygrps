
<!-- README.md is generated from README.Rmd. Please edit that file -->

tukeygrps
=========

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/tukeygrps)](https://cran.r-project.org/package=tukeygrps)
<!-- badges: end -->

Tukeygrps provides simple wrapper functions for the annotation of
(gg)plots according to statistical differences between groups determined
by a parametric Tukey-HSD test from {stats} or a non-parametric
Kruskal-Wallis test with Dunn’s test for multiple comparisons from
{dunn.test}.

Installation
------------

You can install tukeygrps from github using remotes:

    install.packages("remotes")
    library("remotes")
    install_github("leonardblaschek/tukeygrps")

Examples
--------

*Parametric* multiple comparisons like the Tukey HSD (honest significant
differences) test shown in section **1** are only recommended in cases
where the data fulfill all of the following conditions:

-   **normally** distributed
-   **homoscedastic**
-   **independent** within and between groups
-   **equal** in sample size

If you have strong evidence that they do not fulfill these conditions,
consider a *non-parametric* method of comparison, like the
Kruskal-Wallis test followed by Dunn’s multiple comparisons shown in
section **2**.

### 1. Parametric multiple comparisons

Here we use letter\_groups() with stat\_method = “tukey” to add letters
to a geom\_point plot. Alpha is set to 0.001, the letters are printed at
y = 0, and there are no additional grouping variables.

    library(tukeygrps)
    library(tidyverse)

    data(mpg)
    head(mpg)
    #> # A tibble: 6 x 11
    #>   manufacturer model displ  year   cyl trans      drv     cty   hwy fl    class 
    #>   <chr>        <chr> <dbl> <int> <int> <chr>      <chr> <int> <int> <chr> <chr> 
    #> 1 audi         a4      1.8  1999     4 auto(l5)   f        18    29 p     compa…
    #> 2 audi         a4      1.8  1999     4 manual(m5) f        21    29 p     compa…
    #> 3 audi         a4      2    2008     4 manual(m6) f        20    31 p     compa…
    #> 4 audi         a4      2    2008     4 auto(av)   f        21    30 p     compa…
    #> 5 audi         a4      2.8  1999     6 auto(l5)   f        16    26 p     compa…
    #> 6 audi         a4      2.8  1999     6 manual(m5) f        18    26 p     compa…

    tukey_letters <- letter_groups(mpg, hwy, class, "tukey", print_position = 0, stat_alpha = 0.001)

    head(tukey_letters)
    #>        class Letters hwy
    #> 1    compact       a   0
    #> 2 subcompact       a   0
    #> 3    midsize       a   0
    #> 4    2seater      ab   0
    #> 5    minivan      bc   0
    #> 6        suv      cd   0

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
          label = Letters
        )
      ) +
      coord_flip()

<img src="man/figures/README-example no groups-1.png" width="100%" />

Here we split the statistical analysis by two grouping variables (“cut”
and “color”), set the alpha to 0.05 and print the letters 0.5 standard
deviations below the respective minimum value.

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
      print_position = "below",
      print_adjust = 0.5,
      stat_alpha = 0.05,
    )

    head(tukey_letters)
    #> # A tibble: 6 x 5
    #> # Groups:   cut, color [1]
    #>   cut       color Letters clarity  price
    #>   <ord>     <ord> <chr>   <chr>    <dbl>
    #> 1 Very Good D     a       IF       -591.
    #> 2 Very Good D     b       SI2     -1349.
    #> 3 Very Good D     c       SI1     -1287.
    #> 4 Very Good D     c       VS2     -1405.
    #> 5 Very Good D     bc      VVS1    -1304.
    #> 6 Very Good D     c       VS1     -1405.

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
          label = Letters
        ),
        size = 3
      ) +
      facet_grid(cut ~ color) +
      coord_flip()

<img src="man/figures/README-example-1.png" width="100%" />

### 2. Non-parametric multiple comparisons

In case the above requirements for parametric tests are not met, we can
fall back to the non-parametric Kruskal–Wallis test followed by Dunn’s
test and *p*-value adjustment for multiple comparisons. Here we place
the letter codes 0.5 standard deviations above the maximum values.

    library(tukeygrps)
    library(tidyverse)

    data(diamonds)
    diamonds <- diamonds %>%
      filter(cut %in% c("Ideal", "Premium", "Very Good") & color %in% c("D", "E", "F"))

    kruskal_letters <- letter_groups(
      diamonds,
      price,
      clarity,
      "kruskal",
      cut,
      color,
      print_position = "above",
      print_adjust = 0.5,
      p_adj_method = "holm"
    )

    head(kruskal_letters)

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
          label = Letters
        ),
        size = 3
      ) +
      facet_grid(cut ~ color) +
      coord_flip()

<img src="man/figures/README-example non-parametric-1.png" width="100%" />
