#' kruskal_groups internal helper function
#'
#' Internal helper that is called after the grouping.
#'
#' @param df A data.frame.
#' @param y_var The name of the y (dependent) variable.
#' @param x_var The name of the x (independent) variable.
#' @param print_position The y position at which the letter annotation will be placed in the plot. One of "above", "mean", "below", or a numeric value.
#' @param print_adjust Adjustment of the letter position multiples of the overall standard deviations. Defaults to 1.
#' @param stat_alpha The significance threshold alpha for the the Kruskal-Wallis test. Defaults to 0.05.
#' @param p_adj_method Method for p value adjustment. One of "none","holm","hommel", "hochberg", "bonferroni", "BH", "BY" or "fdr". Defaults to "holm".
#' @keywords internal
#' @export

internal_kruskal <- function(
                             df,
                             y,
                             x,
                             print_position,
                             print_adjust,
                             stat_alpha,
                             p_adj_method) {
  if (print_position == "above") {
    groups <- agricolae::kruskal(
      df[quo_name(y)],
      df[quo_name(x)],
      alpha = stat_alpha,
      p.adj = quo_name(p_adj_method)
    )
    raw_sd <- df %>% summarise(sd = sd(!!y))
    print_position_calc <- df %>%
      group_by(!!x) %>%
      summarise(!!y := max(!!y) + print_adjust * raw_sd$sd)
    groups$groups[[quo_name(x)]] <- rownames(groups$groups)
    groups$groups <- left_join(groups$groups, print_position_calc)
    colnames(groups$groups)[1] <- "mean"
    return(groups[["groups"]])
  } else if (print_position == "mean") {
    groups <- agricolae::kruskal(
      df[quo_name(y)],
      df[quo_name(x)],
      alpha = stat_alpha,
      p.adj = quo_name(p_adj_method)
    )
    raw_sd <- df %>% summarise(sd = sd(!!y))
    print_position_calc <- df %>%
      group_by(!!x) %>%
      summarise(!!y := mean(!!y) + print_adjust * raw_sd$sd)
    groups$groups[[quo_name(x)]] <- rownames(groups$groups)
    groups$groups <- left_join(groups$groups, print_position_calc)
    colnames(groups$groups)[1] <- "mean"
    return(groups[["groups"]])
  } else if (print_position == "below") {
    groups <- agricolae::kruskal(
      df[quo_name(y)],
      df[quo_name(x)],
      alpha = stat_alpha,
      p.adj = quo_name(p_adj_method)
    )
    raw_sd <- df %>% summarise(sd = sd(!!y))
    print_position_calc <- df %>%
      group_by(!!x) %>%
      summarise(!!y := min(!!y) + print_adjust * raw_sd$sd)
    groups$groups[[quo_name(x)]] <- rownames(groups$groups)
    groups$groups <- left_join(groups$groups, print_position_calc)
    colnames(groups$groups)[1] <- "mean"
    return(groups[["groups"]])
  } else {
    groups <- agricolae::kruskal(
      df[quo_name(y)],
      df[quo_name(x)],
      alpha = stat_alpha,
      p.adj = quo_name(p_adj_method)
    )
    groups$groups[[quo_name(x)]] <- rownames(groups$groups)
    groups$groups[[quo_name(y)]] <- print_position
    colnames(groups$groups)[1] <- "mean"
    return(groups[["groups"]])
  }
}
