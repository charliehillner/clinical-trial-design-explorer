# R/explanation_engine.R

#' Generate a contextual explanation for a group sequential design
#'
#' Transforms a calculated design result into a structured explanation object.
#' The function is independent of Shiny and can therefore be tested separately.
#'
#' @param design_result Result returned by calculate_design().
#'
#' @return A structured list containing summary, rationale, interpretation,
#'   trade-offs, statistical details, and a contextual learning hint.
#'
#' @examples
#' design <- calculate_design(
#'   alpha = 0.025,
#'   sided = 1,
#'   number_of_analyses = 3,
#'   information_times = c(0.33, 0.67, 1),
#'   boundary_type = "obrien_fleming"
#' )
#'
#' explanation <- generate_explanation(design)
generate_explanation <- function(design_result) {
  validate_explanation_input(design_result)
  
  settings <- design_result$settings
  boundaries <- design_result$boundaries
  fixed_design <- design_result$fixed_design
  
  boundary_type <- settings$boundary_type
  number_of_analyses <- settings$number_of_analyses
  
  first_information <- boundaries$information_fraction[1]
  first_boundary <- boundaries$z_boundary[1]
  first_alpha_spent <- boundaries$alpha_spent[1]
  
  final_boundary <- tail(boundaries$z_boundary, 1)
  final_alpha_spent <- tail(boundaries$cumulative_alpha_spent, 1)
  
  fixed_boundary <- fixed_design$z_boundary
  
  list(
    title = create_explanation_title(boundary_type),
    
    summary = create_summary(
      boundary_type = boundary_type,
      number_of_analyses = number_of_analyses
    ),
    
    current_design = create_current_design_interpretation(
      boundary_type = boundary_type,
      number_of_analyses = number_of_analyses,
      first_information = first_information,
      first_boundary = first_boundary,
      fixed_boundary = fixed_boundary,
      first_alpha_spent = first_alpha_spent
    ),
    
    rationale = create_rationale(
      boundary_type = boundary_type,
      first_information = first_information
    ),
    
    trade_offs = create_trade_offs(
      boundary_type = boundary_type,
      first_information = first_information,
      number_of_analyses = number_of_analyses
    ),
    
    statistical_details = create_statistical_details(
      alpha = settings$alpha,
      sided = settings$sided,
      first_alpha_spent = first_alpha_spent,
      final_alpha_spent = final_alpha_spent,
      final_boundary = final_boundary,
      fixed_boundary = fixed_boundary
    ),
    
    takeaway = create_takeaway(
      boundary_type = boundary_type
    ),
    
    learning_hint = create_learning_hint(
      boundary_type = boundary_type,
      first_information = first_information,
      number_of_analyses = number_of_analyses
    )
  )
}


create_explanation_title <- function(boundary_type) {
  switch(
    boundary_type,
    obrien_fleming = "O'Brien–Fleming Design",
    pocock = "Pocock Design",
    stop(
      paste("Unsupported boundary type:", boundary_type),
      call. = FALSE
    )
  )
}


create_summary <- function(boundary_type, number_of_analyses) {
  if (number_of_analyses == 1L) {
    return(
      paste(
        "This configuration contains only a final analysis and therefore",
        "behaves like a conventional fixed design."
      )
    )
  }
  
  switch(
    boundary_type,
    
    obrien_fleming = paste(
      "This design is highly conservative during early interim analyses.",
      "Only a small portion of the overall Type I error is allocated early,",
      "so stopping for efficacy requires very strong statistical evidence."
    ),
    
    pocock = paste(
      "This design distributes the Type I error more evenly across analyses.",
      "Early stopping is therefore more attainable than under an",
      "O'Brien–Fleming design, but the final boundary is more demanding."
    )
  )
}


create_current_design_interpretation <- function(
    boundary_type,
    number_of_analyses,
    first_information,
    first_boundary,
    fixed_boundary,
    first_alpha_spent
) {
  if (number_of_analyses == 1L) {
    return(
      paste0(
        "The design contains one analysis at 100% of the planned information. ",
        "Its efficacy boundary is Z = ",
        format_number(first_boundary, 2),
        ", which corresponds to the fixed-design boundary."
      )
    )
  }
  
  boundary_difference <- first_boundary - fixed_boundary
  
  information_description <- describe_information_level(
    first_information
  )
  
  boundary_description <- describe_boundary_difference(
    boundary_difference
  )
  
  paste0(
    "The first interim analysis is scheduled after ",
    format_percent(first_information),
    " of the planned statistical information has been collected. ",
    "This represents a ",
    information_description,
    " amount of information. ",
    "The first efficacy boundary is Z = ",
    format_number(first_boundary, 2),
    ", compared with Z = ",
    format_number(fixed_boundary, 2),
    " for the corresponding fixed design. ",
    "The early boundary is therefore ",
    boundary_description,
    ". ",
    "Only ",
    format_probability(first_alpha_spent),
    " of the overall Type I error is allocated to the first analysis."
  )
}


create_rationale <- function(boundary_type, first_information) {
  information_sentence <- if (first_information < 0.30) {
    paste(
      "At this early point, only a limited amount of information is",
      "available and the estimated treatment effect may still be unstable."
    )
  } else if (first_information < 0.60) {
    paste(
      "At this point, a meaningful but still incomplete amount of",
      "statistical information is available."
    )
  } else {
    paste(
      "The first analysis takes place relatively late, when a substantial",
      "amount of statistical information has already been collected."
    )
  }
  
  boundary_sentence <- switch(
    boundary_type,
    
    obrien_fleming = paste(
      "The O'Brien–Fleming approach therefore requires overwhelming",
      "evidence before allowing an early rejection of the null hypothesis.",
      "This keeps the probability of an early false-positive decision",
      "extremely small."
    ),
    
    pocock = paste(
      "The Pocock approach allocates more Type I error to early analyses.",
      "This lowers the early efficacy boundary and makes early stopping",
      "more realistic, while still controlling the overall Type I error."
    )
  )
  
  paste(
    information_sentence,
    boundary_sentence
  )
}


create_trade_offs <- function(
    boundary_type,
    first_information,
    number_of_analyses
) {
  if (number_of_analyses == 1L) {
    return(
      list(
        early_false_positive_protection = 3L,
        early_stopping_opportunity = 1L,
        early_evidence_required = 3L,
        similarity_to_fixed_design = 5L
      )
    )
  }
  
  information_adjustment <- if (first_information < 0.30) {
    1L
  } else if (first_information >= 0.60) {
    -1L
  } else {
    0L
  }
  
  if (boundary_type == "obrien_fleming") {
    return(
      list(
        early_false_positive_protection = 5L,
        early_stopping_opportunity = clamp_rating(
          2L - information_adjustment
        ),
        early_evidence_required = clamp_rating(
          5L + information_adjustment
        ),
        similarity_to_fixed_design = 5L
      )
    )
  }
  
  list(
    early_false_positive_protection = 4L,
    early_stopping_opportunity = clamp_rating(
      4L - information_adjustment
    ),
    early_evidence_required = clamp_rating(
      3L + information_adjustment
    ),
    similarity_to_fixed_design = 3L
  )
}


create_statistical_details <- function(
    alpha,
    sided,
    first_alpha_spent,
    final_alpha_spent,
    final_boundary,
    fixed_boundary
) {
  list(
    overall_alpha = alpha,
    sided = sided,
    first_alpha_spent = first_alpha_spent,
    final_cumulative_alpha_spent = final_alpha_spent,
    final_boundary = final_boundary,
    fixed_design_boundary = fixed_boundary,
    final_boundary_difference = final_boundary - fixed_boundary
  )
}


create_takeaway <- function(boundary_type) {
  switch(
    boundary_type,
    
    obrien_fleming = paste(
      "This design is well suited to settings in which an early",
      "false-positive conclusion should be strongly avoided, while the final",
      "analysis should remain close to the decision rule of a fixed design."
    ),
    
    pocock = paste(
      "This design is well suited to settings in which several analyses",
      "should have a realistic opportunity to stop the trial early, accepting",
      "a somewhat more demanding final efficacy boundary in return."
    )
  )
}


create_learning_hint <- function(
    boundary_type,
    first_information,
    number_of_analyses
) {
  if (number_of_analyses == 1L) {
    return(
      paste(
        "Add at least one interim analysis to explore how repeated testing",
        "changes efficacy boundaries and alpha allocation."
      )
    )
  }
  
  if (
    boundary_type == "obrien_fleming" &&
    first_information < 0.40
  ) {
    return(
      paste(
        "Try moving the first interim analysis to a later information time.",
        "With more information available, the first efficacy boundary will",
        "become less extreme."
      )
    )
  }
  
  if (boundary_type == "obrien_fleming") {
    return(
      paste(
        "Switch to a Pocock design and compare the first boundary.",
        "Pocock allocates more Type I error early and therefore requires",
        "less extreme evidence for early stopping."
      )
    )
  }
  
  if (first_information < 0.40) {
    return(
      paste(
        "Compare this configuration with O'Brien–Fleming boundaries.",
        "The difference is especially visible when the first analysis occurs",
        "after only a small fraction of the planned information."
      )
    )
  }
  
  paste(
    "Move the first analysis earlier and observe how both the efficacy",
    "boundary and the early alpha allocation change."
  )
}


describe_information_level <- function(information_fraction) {
  if (information_fraction < 0.25) {
    return("very limited")
  }
  
  if (information_fraction < 0.50) {
    return("limited")
  }
  
  if (information_fraction < 0.75) {
    return("substantial")
  }
  
  "large"
}


describe_boundary_difference <- function(boundary_difference) {
  if (boundary_difference >= 1.5) {
    return("substantially higher")
  }
  
  if (boundary_difference >= 0.75) {
    return("clearly higher")
  }
  
  if (boundary_difference >= 0.25) {
    return("moderately higher")
  }
  
  "close to the fixed-design boundary"
}


clamp_rating <- function(value) {
  max(1L, min(5L, as.integer(value)))
}


format_number <- function(value, digits = 2) {
  formatC(
    value,
    format = "f",
    digits = digits
  )
}


format_percent <- function(value) {
  paste0(
    formatC(
      100 * value,
      format = "f",
      digits = 0
    ),
    "%"
  )
}


format_probability <- function(value) {
  if (value < 0.0001) {
    return("< 0.0001")
  }
  
  formatC(
    value,
    format = "f",
    digits = 4
  )
}


validate_explanation_input <- function(design_result) {
  if (!is.list(design_result)) {
    stop(
      "'design_result' must be a list returned by calculate_design().",
      call. = FALSE
    )
  }
  
  required_sections <- c(
    "settings",
    "boundaries",
    "fixed_design"
  )
  
  missing_sections <- setdiff(
    required_sections,
    names(design_result)
  )
  
  if (length(missing_sections) > 0L) {
    stop(
      paste0(
        "'design_result' is missing required sections: ",
        paste(missing_sections, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }
  
  required_settings <- c(
    "alpha",
    "sided",
    "number_of_analyses",
    "boundary_type"
  )
  
  missing_settings <- setdiff(
    required_settings,
    names(design_result$settings)
  )
  
  if (length(missing_settings) > 0L) {
    stop(
      paste0(
        "'design_result$settings' is missing: ",
        paste(missing_settings, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }
  
  required_boundary_columns <- c(
    "information_fraction",
    "z_boundary",
    "alpha_spent",
    "cumulative_alpha_spent"
  )
  
  missing_boundary_columns <- setdiff(
    required_boundary_columns,
    names(design_result$boundaries)
  )
  
  if (length(missing_boundary_columns) > 0L) {
    stop(
      paste0(
        "'design_result$boundaries' is missing columns: ",
        paste(missing_boundary_columns, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }
  
  invisible(TRUE)
}