#' Tukey-HSD plot annotation
#'
#' This is a simple wrapper function that outputs a data frame that can be used to annotate your plot with letter codes according to a Tukey HSD test. In addition to the data and formula, the function takes as input a positional variable for placement on the plot, an alpha for the Tukey-HSD test, and grouping variables for faceted plots. The underlying statistical functions are called from the 'agricolae' package.
#'
#' @param df A data.frame.
#' @param y_var The name of the y (dependent) variable.
#' @param x_var The name of the x (independent) variable.
#' @param ... Any number of grouping variables for faceted plots.
#' @param print_position The y position at which the letter annotation will be placed in the plot. One of "above", "mean", "below", or a numeric value.
#' @param print_adjust Adjustment of the letter position multiples of the overall standard deviations. Defaults to 1.
#' @param stat_alpha The significance threshold alpha for the the Tukey HSD test. Defaults to 0.05.
#' @keywords Tukey-HSD, parametric, annotation
#' @export
#' @examples
#' test_data <- tibble(value = rnorm(1000), sample = sample(LETTERS[1:5], 1000, replace = TRUE), group = sample(LETTERS[24:26], 1000, replace = TRUE))
#' annotation_df <- tukey_groups(test_data, value, sample, group, stat_alpha = 0.001, print_position = "above", print_adjust = 0.5)

tukey_groups <- function(
  df,
  y,
  x,
  ...,
  print_position = 0,
  print_adjust = 1,
  stat_alpha = 0.05) {
  y <- enquo(y)
  x <- enquo(x)
  grp <- enquos(...)

  df %>%
    group_by(!!!grp) %>%
    group_modify(~ data.frame(internal_tukey(., y, x, print_position, print_adjust, stat_alpha)))
}

