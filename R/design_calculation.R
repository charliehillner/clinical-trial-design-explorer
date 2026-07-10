#' Calculate a group sequential design
#'
#' Creates an efficacy-only group sequential design using the gsDesign package
#' and transforms the package-specific result into an application-specific
#' result object.
#'
#' @param alpha Total Type I error rate.
#'   For a two-sided design, alpha is split equally between both tails.
#' @param sided Number of test sides. Must be either 1 or 2.
#' @param number_of_analyses Total number of analyses, including the final one.
#' @param information_times Increasing vector of information fractions.
#'   The final value must equal 1.
#' @param boundary_type Boundary family. Supported values are
#'   "obrien_fleming" and "pocock".
#'
#' @return A list containing normalized settings, boundary data, and
#'   fixed-design reference values.
#'
#' @examples
#' calculate_design(
#'   alpha = 0.025,
#'   sided = 1,
#'   number_of_analyses = 3,
#'   information_times = c(1 / 3, 2 / 3, 1),
#'   boundary_type = "obrien_fleming"
#' )

library(gsDesign)

calculate_design <- function(
    alpha = 0.025,
    sided = 1L,
    number_of_analyses = 3L,
    information_times = seq_len(number_of_analyses) / number_of_analyses,
    boundary_type = "obrien_fleming"
) {
  # Validate input
  validate_design_calculation_inputs(
    alpha = alpha,
    sided = sided,
    number_of_analyses = number_of_analyses,
    information_times = information_times,
    boundary_type = boundary_type
  )
  # Map boundary type to package parameters
  if (!requireNamespace("gsDesign", quietly = TRUE)) {
    stop(
      paste(
        "Package 'gsDesign' is required.",
        "Install it with install.packages('gsDesign')."
      ),
      call. = FALSE
    )
  }
  
  gs_boundary_type <- map_boundary_type(boundary_type)
  
  # gsDesign defines alpha as a one-sided Type I error.
  alpha_per_tail <- if (sided == 2L) alpha / 2 else alpha
  
  # Calculate group sequential design
  design <- gsDesign::gsDesign(
    k = number_of_analyses,
    test.type = sided,
    alpha = alpha_per_tail,
    timing = information_times,
    sfu = gs_boundary_type
  )
  
  boundaries <- create_boundary_table(
    design = design,
    sided = sided
  )
  
  fixed_design_boundary <- stats::qnorm(1 - alpha_per_tail)
  
  list(
    settings = list(
      alpha = alpha,
      alpha_per_tail = alpha_per_tail,
      sided = sided,
      number_of_analyses = number_of_analyses,
      information_times = design$timing,
      boundary_type = boundary_type
    ),
    boundaries = boundaries,
    fixed_design = list(
      z_boundary = fixed_design_boundary,
      nominal_p_value = alpha
    )
  )
}

#' Transform a gsDesign result into the application's boundary table
#'
#' @param design Object returned by gsDesign::gsDesign().
#' @param sided Number of test sides.
#'
#' @return A data.frame with one row per analysis.
create_boundary_table <- function(design, sided) {
  z_boundaries <- as.numeric(design$upper$bound)
  alpha_spent_per_tail <- as.numeric(design$upper$spend)
  
  nominal_p_values <- if (sided == 1L) {
    stats::pnorm(z_boundaries, lower.tail = FALSE)
  } else {
    2 * stats::pnorm(abs(z_boundaries), lower.tail = FALSE)
  }
  
  alpha_spent <- if (sided == 1L) {
    alpha_spent_per_tail
  } else {
    2 * alpha_spent_per_tail
  }
  
  data.frame(
    analysis = seq_len(design$k),
    information_fraction = as.numeric(design$timing),
    z_boundary = z_boundaries,
    nominal_p_value = nominal_p_values,
    alpha_spent = alpha_spent,
    cumulative_alpha_spent = cumsum(alpha_spent),
    stringsAsFactors = FALSE
  )
}


#' Map application boundary names to gsDesign boundary identifiers
#'
#' @param boundary_type Application-specific boundary name.
#'
#' @return Character identifier understood by gsDesign.
map_boundary_type <- function(boundary_type) {
  boundary_types <- c(
    obrien_fleming = "OF",
    pocock = "Pocock"
  )
  
  unname(boundary_types[[boundary_type]])
}


#' Validate inputs required for group sequential design calculation
#'
#' This validation can later be moved to R/validation.R without changing
#' calculate_design().
validate_design_calculation_inputs <- function(
    alpha,
    sided,
    number_of_analyses,
    information_times,
    boundary_type
) {
  if (
    length(alpha) != 1L ||
    !is.numeric(alpha) ||
    is.na(alpha) ||
    !is.finite(alpha) ||
    alpha <= 0 ||
    alpha >= 1
  ) {
    stop(
      "'alpha' must be a single numeric value strictly between 0 and 1.",
      call. = FALSE
    )
  }
  
  if (
    length(sided) != 1L ||
    !is.numeric(sided) ||
    is.na(sided) ||
    !(sided %in% c(1, 2))
  ) {
    stop(
      "'sided' must be either 1 or 2.",
      call. = FALSE
    )
  }
  
  if (
    length(number_of_analyses) != 1L ||
    !is.numeric(number_of_analyses) ||
    is.na(number_of_analyses) ||
    number_of_analyses %% 1 != 0 ||
    number_of_analyses < 1 ||
    number_of_analyses > 5
  ) {
    stop(
      "'number_of_analyses' must be an integer between 1 and 5.",
      call. = FALSE
    )
  }
  
  if (
    !is.numeric(information_times) ||
    anyNA(information_times) ||
    any(!is.finite(information_times))
  ) {
    stop(
      "'information_times' must contain only finite numeric values.",
      call. = FALSE
    )
  }
  
  if (length(information_times) != number_of_analyses) {
    stop(
      paste0(
        "'information_times' must contain exactly ",
        number_of_analyses,
        " values."
      ),
      call. = FALSE
    )
  }
  
  if (any(information_times <= 0) || any(information_times > 1)) {
    stop(
      "'information_times' must be greater than 0 and no greater than 1.",
      call. = FALSE
    )
  }
  
  if (
    length(information_times) > 1L &&
    any(diff(information_times) <= 0)
  ) {
    stop(
      "'information_times' must be strictly increasing.",
      call. = FALSE
    )
  }
  
  tolerance <- sqrt(.Machine$double.eps)
  
  if (abs(tail(information_times, 1L) - 1) > tolerance) {
    stop(
      "The final information time must equal 1.",
      call. = FALSE
    )
  }
  
  supported_boundary_types <- c(
    "obrien_fleming",
    "pocock"
  )
  
  if (
    length(boundary_type) != 1L ||
    !is.character(boundary_type) ||
    is.na(boundary_type) ||
    !(boundary_type %in% supported_boundary_types)
  ) {
    stop(
      paste0(
        "'boundary_type' must be one of: ",
        paste(supported_boundary_types, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }
  
  invisible(TRUE)
}