#' Tukey_groups internal helper function
#'
#' Internal helper that is called after the grouping.
#'
#' @param df A data.frame.
#' @param y The name of the y (dependent) variable.
#' @param x The name of the x (independent) variable.
#' @param pos The y value at which the letter annotation should be placed in the plot.
#' @param alpha The significance threshhold alpha for the the Tukey-HSD test.
#' @keywords internal
#' @export

internal_tukey <- function(
  df,
  y,
  x,
  pos,
  alpha
) {
  model_formula <- formula(paste0(quo_name(y), "~", quo_name(x)))
  aov1 <- aov(model_formula, data = df)
  groups <- agricolae::HSD.test(
    aov1,
    quo_name(x),
    alpha = alpha
  )
  groups$groups[[quo_name(x)]] <- rownames(groups$groups)
  groups$groups[[quo_name(y)]] <- pos
  return(groups[["groups"]])
}
