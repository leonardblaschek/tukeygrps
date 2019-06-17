#' tukey_groups internal helper function
#'
#' Internal helper that is called after the grouping.
#'
#' @param df A data.frame.
#' @param y_var The name of the y (dependent) variable.
#' @param x_var The name of the x (independent) variable.
#' @param print_position The y position at which the letter annotation will be placed in the plot. One of "above", "mean", "below", or a numeric value.
#' @param print_adjust Adjustment of the letter position multiples of the overall standard deviations. Defaults to 1.
#' @param stat_alpha The significance threshold alpha for the the Tukey HSD test. Defaults to 0.05.
#' @keywords internal
#' @export

internal_tukey <- function(
  df,
  y,
  x,
  print_position,
  print_adjust,
  stat_alpha) {
  if (print_position == "above") {
    model_formula <- formula(paste0(quo_name(y), "~", quo_name(x)))
    aov1 <- aov(model_formula, data = df)
    groups <- agricolae::HSD.test(
      aov1,
      quo_name(x),
      alpha = stat_alpha
    )
    raw_sd <- df %>% summarise(sd = sd(!!y))
    print_position_calc <- df %>%
      group_by(!!x) %>%
      summarise(!!y := max(!!y) + print_adjust * raw_sd$sd)
    groups$groups[[quo_name(x)]] <- rownames(groups$groups)
    groups$groups <- left_join(groups$groups, print_position_calc)
    return(groups[["groups"]])
  } else if (print_position == "mean") {
    model_formula <- formula(paste0(quo_name(y), "~", quo_name(x)))
    aov1 <- aov(model_formula, data = df)
    groups <- agricolae::HSD.test(
      aov1,
      quo_name(x),
      alpha = stat_alpha
    )
    raw_sd <- df %>% summarise(sd = sd(!!y))
    print_position_calc <- df %>%
      group_by(!!x) %>%
      summarise(!!y := mean(!!y) + print_adjust * raw_sd$sd)
    groups$groups[[quo_name(x)]] <- rownames(groups$groups)
    groups$groups <- left_join(groups$groups, print_position_calc)
    return(groups[["groups"]])
  } else if (print_position == "below") {
    model_formula <- formula(paste0(quo_name(y), "~", quo_name(x)))
    aov1 <- aov(model_formula, data = df)
    groups <- agricolae::HSD.test(
      aov1,
      quo_name(x),
      alpha = stat_alpha
    )
    raw_sd <- df %>% summarise(sd = sd(!!y))
    print_position_calc <- df %>%
      group_by(!!x) %>%
      summarise(!!y := min(!!y) + print_adjust * raw_sd$sd)
    groups$groups[[quo_name(x)]] <- rownames(groups$groups)
    groups$groups <- left_join(groups$groups, print_position_calc)
    return(groups[["groups"]])
  } else {
    model_formula <- formula(paste0(quo_name(y), "~", quo_name(x)))
    aov1 <- aov(model_formula, data = df)
    groups <- agricolae::HSD.test(
      aov1,
      quo_name(x),
      alpha = stat_alpha
    )
    groups$groups[[quo_name(x)]] <- rownames(groups$groups)
    groups$groups[[quo_name(y)]] <- print_position
    return(groups[["groups"]])
  }
}