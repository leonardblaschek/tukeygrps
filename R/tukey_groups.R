#' Tukey-HSD plot annotation
#'
#' This is a simple helper function that outputs a data frame that can be used to annotate your plot with different letters according to Tukey-HSD significant differences between groups. In addition to the data and formula, the function takes as input a positional variable for placement on the plot, an alpha for the Tukey-HSD test, and a grouping variable for faceted plots.
#'
#' @param df A data.frame.
#' @param y_var The name of the y (dependent) variable.
#' @param x_var The name of the x (independent) variable.
#' @param pos_var The y value at which the letter annotation should be placed in the plot.
#' @param alpha_var The significance threshhold alpha for the the Tukey-HSD test.
#' @param grp_var A grouping variable for faceted plots.
#' @keywords Tukey-HSD, annotation
#' @import agricolae, dplyr
#' @export
#' @examples
#' test_data <- tibble(value = rnorm(1000), sample = sample(LETTERS[1:5], 1000, replace = TRUE), group = sample(LETTERS[24:26], 1000, replace = TRUE))
#' head(test_data)
#' annotation_df <- tukey_groups(test_data, value, sample, 1, 0.001, group)
#' head(annotation_df)

tukey_groups <- function(
                         df,
                         y_var,
                         x_var,
                         pos_var,
                         alpha_var,
                         grp_var) {
  y <- enquo(y_var)
  x <- enquo(x_var)
  grp <- enquo(grp_var)

  df %>%
    group_by(!!grp) %>%
    group_modify(~ data.frame(internal_tukey(., y, x, pos_var, alpha_var)))
}
