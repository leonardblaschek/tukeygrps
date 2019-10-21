#' letter_groups internal helper function
#'
#' Internal helper that is called after the grouping.
#'
#' @param df A data.frame.
#' @param y The name of the y (dependent) variable.
#' @param x The name of the x (independent) variable.
#' @param stat_method The statistical test applied. Either "tukey" or "kruskal".
#' @param print_position The y position at which the letter annotation will be placed in the plot. One of "above", "mean", "below", or a numeric value.
#' @param print_adjust Adjustment of the letter position multiples of the overall standard deviations. Defaults to 1.
#' @param stat_alpha The significance threshold alpha for the the Kruskal-Wallis test. Defaults to 0.05.
#' @param p_adj_method Method for p value adjustment when stat_method = "kruskal". One of "none","holm","hommel", "hochberg", "bonferroni", "BH", "BY" or "fdr". Defaults to "holm".
#' @keywords internal
#' @export

internal_stats <- function(
                           df,
                           y,
                           x,
                           stat_method,
                           print_position,
                           print_adjust,
                           stat_alpha,
                           p_adj_method) {
  if (stat_method == "kruskal") {
    groups <- agricolae::kruskal(
      df[dplyr::quo_name(y)],
      df[dplyr::quo_name(x)],
      alpha = stat_alpha,
      p.adj = p_adj_method
    )
  } else if (stat_method == "tukey") {
    model_formula <- formula(paste0(dplyr::quo_name(y), "~", dplyr::quo_name(x)))
    aov1 <- aov(model_formula, data = df)
    groups <- agricolae::HSD.test(
      aov1,
      dplyr::quo_name(x),
      alpha = stat_alpha
    )
  } else {
    stop("Specify a method for the statistical analysis (either 'tukey' or 'kruskal')")
  }
  colnames(groups$groups)[1] <- "mean"
  raw_sd <- df %>% dplyr::summarise(sd = sd(!!y, na.rm = TRUE))
  if (print_position == "above") {
    print_position_calc <- df %>%
      dplyr::group_by(!!x) %>%
      dplyr::summarise(!!y := max(!!y) + print_adjust * raw_sd$sd)
    groups$groups[[dplyr::quo_name(x)]] <- rownames(groups$groups)
    groups$groups <- dplyr::left_join(groups$groups, print_position_calc)
  } else if (print_position == "mean") {
    print_position_calc <- df %>%
      dplyr::group_by(!!x) %>%
      dplyr::summarise(!!y := mean(!!y) + print_adjust * raw_sd$sd)
    groups$groups[[dplyr::quo_name(x)]] <- rownames(groups$groups)
    groups$groups <- dplyr::left_join(groups$groups, print_position_calc)
  } else if (print_position == "below") {
    print_position_calc <- df %>%
      dplyr::group_by(!!x) %>%
      dplyr::summarise(!!y := min(!!y) + print_adjust * raw_sd$sd)
    groups$groups[[dplyr::quo_name(x)]] <- rownames(groups$groups)
    groups$groups <- dplyr::left_join(groups$groups, print_position_calc)
  } else {
    groups$groups[[dplyr::quo_name(x)]] <- rownames(groups$groups)
    groups$groups[[dplyr::quo_name(y)]] <- print_position
  }
  return(groups[["groups"]])
}
