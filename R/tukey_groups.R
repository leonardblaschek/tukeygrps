#' Tukey-HSD plot annotation
#'
#' This is a simple wrapper function that outputs a data frame that can be used to annotate your plot with letter codes according to a Tukey HSD test. In addition to the data and formula, the function takes as input a positional variable for placement on the plot, an alpha for the Tukey-HSD test, and grouping variables for faceted plots. The underlying statistical functions are called from the 'agricolae' package.
#'
#' @param df A data.frame.
#' @param y_var The name of the y (dependent) variable.
#' @param x_var The name of the x (independent) variable.
#' @param pos_var The y value at which the letter annotation will be placed in the plot.
#' @param alpha_var The significance threshold alpha for the the Tukey-HSD test.
#' @param ... Any number of grouping variables for faceted plots.
#' @keywords Tukey-HSD, parametric, annotation
#' @export
#' @examples
#' test_data <- tibble(value = rnorm(1000), sample = sample(LETTERS[1:5], 1000, replace = TRUE), group = sample(LETTERS[24:26], 1000, replace = TRUE))
#' annotation_df <- tukey_groups(test_data, value, sample, 1, 0.001, group)

tukey_groups <- function(
                         df,
                         y_var,
                         x_var,
                         pos_var,
                         alpha_var,
                         ...) {
  y <- enquo(y_var)
  x <- enquo(x_var)
  grp <- enquos(...)

  df %>%
    group_by(!!!grp) %>%
    group_modify(~ data.frame(internal_tukey(., y, x, pos_var, alpha_var)))
}
