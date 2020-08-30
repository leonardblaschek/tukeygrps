#' Statistical plot annotation
#'
#' This is a simple wrapper function that outputs a data frame that can be used to annotate your plot with letter codes according to significant differences between groups. The The function currently supports the parametric Tukey HSD test {stats}, and the non-parametric Kruskal-Wallis test with Dunn's test for multiple comparisons {dunn.test}. In addition to the data and formula, the function takes as input a positional variable for placement on the plot, the threshold for statistical significance alpha, the method for p-value adjustment, and grouping variables for faceted plots.
#'
#' @param df A data frame.
#' @param y The name of the y (dependent) variable.
#' @param x The name of the x (independent) variable.
#' @param stat_method The statistical test applied. Either "tukey" or "kruskal".
#' @param ... Any number of grouping variables for faceted plots.
#' @param print_position The y position at which the letter annotation will be placed in the plot. One of "above", "mean", "below", or a numeric value.
#' @param print_adjust Adjustment of the letter position multiples of the overall standard deviations. Defaults to 1.
#' @param stat_alpha The significance threshold alpha. Defaults to 0.05.
#' @param p_adj_method Method for p value adjustment, see ?dunn.test::dunn.test for details. One of "none", "bonferroni", "sidak", "holm", "hs", "hochberg", "bh", "by". Defaults to "holm".
#' @keywords Kruskal-Wallis, Tukey HSD, annotation
#' @export
#' @examples
#' test_data <- tibble(value = rnorm(1000), sample = sample(LETTERS[1:5], 1000, replace = TRUE), group = sample(LETTERS[24:26], 1000, replace = TRUE))
#' annotation_df <- letter_groups(test_data, value, sample, "tukey", group, stat_alpha = 0.001, print_position = "above", print_adjust = 0.5, p_adj_method = "holm")
letter_groups <- function(
                          df,
                          y,
                          x,
                          stat_method,
                          ...,
                          print_position = 0,
                          print_adjust = 1,
                          stat_alpha = 0.05,
                          p_adj_method = "holm") {
  y <- dplyr::enquo(y)
  x <- dplyr::enquo(x)
  grp <- dplyr::enquos(...)

  df %>%
    dplyr::mutate(!!x := str_replace(!!x, fixed("-"), "PLACEHOLDER")) %>%
    dplyr::group_by(!!!grp) %>%
    dplyr::group_modify(~ data.frame(internal_stats(., y, x, stat_method, print_position, print_adjust, stat_alpha, p_adj_method))) %>%
    dplyr::mutate(!!x := str_replace(!!x, "PLACEHOLDER", fixed("-")))
}
