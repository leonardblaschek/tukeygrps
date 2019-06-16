#' kruskal_groups internal helper function
#'
#' Internal helper that is called after the grouping.
#'
#' @param df A data.frame.
#' @param y The name of the y (dependent) variable.
#' @param x The name of the x (independent) variable.
#' @param pos The y value at which the letter annotation will be placed in the plot.
#' @param alpha The significance threshhold alpha for the the Kruskal-Wallis test.
#' @param p_adj Method for p value adjustment. One of "none","holm","hommel", "hochberg", "bonferroni", "BH", "BY" or "fdr".
#' @keywords internal
#' @export

internal_kruskal <- function(
  df,
  y,
  x,
  pos,
  alpha,
  p_adj
) {
  groups <- agricolae::kruskal(
    df[quo_name(y)],
    df[quo_name(x)],
    alpha = alpha,
    p.adj = quo_name(p_adj)
  )
  groups$groups[[quo_name(x)]] <- rownames(groups$groups)
  groups$groups[[quo_name(y)]] <- pos
  colnames(groups$groups)[1] <- "mean"
  return(groups[["groups"]])
}

