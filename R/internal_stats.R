#' letter_groups internal helper function
#'
#' Internal helper that is called after the grouping.
#'
#' @param df A data frame.
#' @param y The name of the y (dependent) variable.
#' @param x The name of the x (independent) variable.
#' @param stat_method The statistical test applied. Either "tukey" or "kruskal".
#' @param print_position The y position at which the letter annotation will be placed in the plot. One of "above", "mean", "below", or a numeric value.
#' @param print_adjust Adjustment of the letter position multiples of the overall standard deviations. Defaults to 1.
#' @param stat_alpha The significance threshold alpha. Defaults to 0.05.
#' @param p_adj_method Method for p value adjustment, see ?dunn.test::dunn.test for details. One of "none", "bonferroni", "sidak", "holm", "hs", "hochberg", "bh", "by". Defaults to "holm".
#' @param table A logical value indicating whether to return a data frame with the letter codes according to significance (table = FALSE, default), or a table containing the calculated statistics (P-values, df, etc.).
#' @keywords internal
#' @export

internal_stats <- function(df,
                           y,
                           x,
                           stat_method,
                           print_position,
                           print_adjust,
                           stat_alpha,
                           p_adj_method,
                           table) {
  if (table == TRUE) {
    if (stat_method == "kruskal") {
      kruskal <- kruskal.test(
        unlist(df[dplyr::quo_name(y)]),
        unlist(df[dplyr::quo_name(x)]))
      dunn <- tibble::as_tibble(dunn.test::dunn.test(
        unlist(df[dplyr::quo_name(y)]),
        unlist(df[dplyr::quo_name(x)]),
        method = p_adj_method
      )) %>%
        # remove spaces to meet multcompView input requirements
        mutate(comparisons = stringr::str_replace_all(comparisons, " - ", "-"))
      
      # kruskal statistics
      kruskal_tab <- broom::tidy(kruskal) %>% 
        dplyr::select(statistic, "df" = parameter, p.value) %>% 
        dplyr::mutate(method = "Kruskal-Wallis test (non-parametric)")
      # dunn comparisons
      dunn_tab <- dunn %>% 
        dplyr::select("contrast" = comparisons, 
                      "adj.p.value" = P.adjusted) %>% 
        dplyr::mutate(method = "Dunn test (non-parametric)",
                      contrast = stringr::str_replace_all(contrast, "PLACEHOLDER", "-"))
      table <- tibble::tibble("kruskal" = kruskal_tab,
                              "dunn" = dunn_tab)
    } else if (stat_method == "tukey") {
      # parametric Tukey HSD test
      model_formula <- formula(paste0(dplyr::quo_name(y), "~", dplyr::quo_name(x)))
      aov1 <- aov(model_formula, data = df)
      base_tukey <- TukeyHSD(
        aov1,
        dplyr::quo_name(x)
      )
      # anova statistics
      anova_tab <- broom::tidy(aov1) %>% 
        dplyr::filter(term == dplyr::quo_name(x)) %>% 
        dplyr::select(statistic, df, p.value) %>% 
        dplyr::mutate(method = "ANOVA (parametric)")
      # tukey comparisons
      tukey_tab <- broom::tidy(base_tukey) %>% 
        dplyr::select(contrast, adj.p.value) %>% 
        dplyr::mutate(method = "Tukey HSD test (parametric)",
                      contrast = stringr::str_replace_all(contrast, "PLACEHOLDER", "-"))
      table <- tibble::tibble("anova" = anova_tab,
                              "tukey" = tukey_tab)
    } else {
      stop("Specify a method for the statistical analysis (either 'tukey' or 'kruskal')")
    }
    return(table)
  } else {
    # non-parametric Kruskal-Wallis test with Dunn's test for multiple comparisons
    if (stat_method == "kruskal") {
      dunn <- tibble::as_tibble(dunn.test::dunn.test(
        unlist(df[dplyr::quo_name(y)]),
        unlist(df[dplyr::quo_name(x)]),
        method = p_adj_method
      )) %>%
        # remove spaces to meet multcompView input requirements
        mutate(comparisons = str_replace(comparisons, " - ", "-"))
      
      # transform adjusted P values to a named vector
      dunn_vector <- dunn %>%
        dplyr::select(P.adjusted) %>%
        tibble::deframe()
      names(dunn_vector) <- dunn$comparisons
      
      # calculate letter codes
      model_formula <- formula(paste0(dplyr::quo_name(y), "~", dplyr::quo_name(x)))
      groups <- data.frame(
        multcompView::multcompLetters2(
          model_formula,
          dunn_vector,
          threshold = stat_alpha,
          data = data.frame(df)
        )["Letters"]
      )
    } else if (stat_method == "tukey") {
      # parametric Tukey HSD test
      model_formula <- formula(paste0(dplyr::quo_name(y), "~", dplyr::quo_name(x)))
      aov1 <- aov(model_formula, data = df)
      base_tukey <- TukeyHSD(
        aov1,
        dplyr::quo_name(x)
      )
      # calculate letter codes
      groups <- data.frame(
        multcompView::multcompLetters2(
          model_formula,
          base_tukey[[dplyr::quo_name(x)]][, 4],
          threshold = stat_alpha,
          data = data.frame(df)
        )["Letters"]
      )
    } else {
      stop("Specify a method for the statistical analysis (either 'tukey' or 'kruskal')")
    }
    raw_sd <- df %>% dplyr::summarise(sd = sd(!!y, na.rm = TRUE))
    if (print_position == "above") {
      print_position_calc <- df %>%
        dplyr::group_by(!!x) %>%
        dplyr::summarise(!!y := max(!!y, na.rm = TRUE) + print_adjust * raw_sd$sd)
      groups[[dplyr::quo_name(x)]] <- rownames(groups)
      groups <- dplyr::left_join(groups, print_position_calc)
    } else if (print_position == "mean") {
      print_position_calc <- df %>%
        dplyr::group_by(!!x) %>%
        dplyr::summarise(!!y := mean(!!y, na.rm = TRUE) + print_adjust * raw_sd$sd)
      groups[[dplyr::quo_name(x)]] <- rownames(groups)
      groups <- dplyr::left_join(groups, print_position_calc)
    } else if (print_position == "below") {
      print_position_calc <- df %>%
        dplyr::group_by(!!x) %>%
        dplyr::summarise(!!y := min(!!y, na.rm = TRUE) - print_adjust * raw_sd$sd)
      groups[[dplyr::quo_name(x)]] <- rownames(groups)
      groups <- dplyr::left_join(groups, print_position_calc)
    } else {
      groups <- groups %>%
        tibble::rownames_to_column(var = quo_name(x)) %>%
        mutate(!!y := print_position)
    }
    groups <- groups %>% 
      dplyr::mutate(!!x := stringr::str_replace_all(!!x, "PLACEHOLDER", fixed("-")))
    return(groups)
  }
}
