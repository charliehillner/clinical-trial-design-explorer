test_that("calculate_design returns the expected result structure", {
  result <- calculate_design(
    alpha = 0.025,
    sided = 1,
    number_of_analyses = 3,
    information_times = c(0.33, 0.67, 1),
    boundary_type = "obrien_fleming"
  )
  
  expect_type(result, "list")
  
  expect_named(
    result,
    c("settings", "boundaries", "fixed_design")
  )
  
  expect_s3_class(result$boundaries, "data.frame")
  
  expect_named(
    result$boundaries,
    c(
      "analysis",
      "information_fraction",
      "z_boundary",
      "nominal_p_value",
      "alpha_spent",
      "cumulative_alpha_spent"
    )
  )
})


test_that("calculate_design creates one boundary per analysis", {
  number_of_analyses <- 3
  
  result <- calculate_design(
    alpha = 0.025,
    sided = 1,
    number_of_analyses = number_of_analyses,
    information_times = c(0.33, 0.67, 1),
    boundary_type = "obrien_fleming"
  )
  
  expect_equal(
    nrow(result$boundaries),
    number_of_analyses
  )
  
  expect_equal(
    result$boundaries$analysis,
    seq_len(number_of_analyses)
  )
})


test_that("information times are preserved in the result", {
  information_times <- c(0.25, 0.50, 0.75, 1)
  
  result <- calculate_design(
    alpha = 0.025,
    sided = 1,
    number_of_analyses = 4,
    information_times = information_times,
    boundary_type = "obrien_fleming"
  )
  
  expect_equal(
    result$boundaries$information_fraction,
    information_times,
    tolerance = 1e-10
  )
  
  expect_equal(
    result$settings$information_times,
    information_times,
    tolerance = 1e-10
  )
})


test_that("cumulative alpha spending reaches the specified alpha", {
  alpha <- 0.025
  
  result <- calculate_design(
    alpha = alpha,
    sided = 1,
    number_of_analyses = 3,
    information_times = c(0.33, 0.67, 1),
    boundary_type = "obrien_fleming"
  )
  
  final_alpha_spent <- tail(
    result$boundaries$cumulative_alpha_spent,
    1
  )
  
  expect_equal(
    final_alpha_spent,
    alpha,
    tolerance = 1e-6
  )
})


test_that("two-sided designs split alpha equally between both tails", {
  alpha <- 0.05
  
  result <- calculate_design(
    alpha = alpha,
    sided = 2,
    number_of_analyses = 3,
    information_times = c(0.33, 0.67, 1),
    boundary_type = "obrien_fleming"
  )
  
  expect_equal(
    result$settings$alpha,
    0.05
  )
  
  expect_equal(
    result$settings$alpha_per_tail,
    0.025
  )
  
  final_alpha_spent <- tail(
    result$boundaries$cumulative_alpha_spent,
    1
  )
  
  expect_equal(
    final_alpha_spent,
    alpha,
    tolerance = 1e-6
  )
})


test_that("the fixed-design boundary is calculated correctly", {
  one_sided <- calculate_design(
    alpha = 0.025,
    sided = 1,
    number_of_analyses = 3,
    information_times = c(0.33, 0.67, 1),
    boundary_type = "obrien_fleming"
  )
  
  two_sided <- calculate_design(
    alpha = 0.05,
    sided = 2,
    number_of_analyses = 3,
    information_times = c(0.33, 0.67, 1),
    boundary_type = "obrien_fleming"
  )
  
  expected_boundary <- stats::qnorm(0.975)
  
  expect_equal(
    one_sided$fixed_design$z_boundary,
    expected_boundary
  )
  
  expect_equal(
    two_sided$fixed_design$z_boundary,
    expected_boundary
  )
})


test_that("O'Brien-Fleming has a higher early boundary than Pocock", {
  common_arguments <- list(
    alpha = 0.025,
    sided = 1,
    number_of_analyses = 3,
    information_times = c(0.33, 0.67, 1)
  )
  
  obrien_fleming <- do.call(
    calculate_design,
    c(
      common_arguments,
      list(boundary_type = "obrien_fleming")
    )
  )
  
  pocock <- do.call(
    calculate_design,
    c(
      common_arguments,
      list(boundary_type = "pocock")
    )
  )
  
  obrien_fleming_first_boundary <-
    obrien_fleming$boundaries$z_boundary[1]
  
  pocock_first_boundary <-
    pocock$boundaries$z_boundary[1]
  
  expect_gt(
    obrien_fleming_first_boundary,
    pocock_first_boundary
  )
})


test_that("O'Brien-Fleming spends less alpha at the first analysis", {
  common_arguments <- list(
    alpha = 0.025,
    sided = 1,
    number_of_analyses = 3,
    information_times = c(0.33, 0.67, 1)
  )
  
  obrien_fleming <- do.call(
    calculate_design,
    c(
      common_arguments,
      list(boundary_type = "obrien_fleming")
    )
  )
  
  pocock <- do.call(
    calculate_design,
    c(
      common_arguments,
      list(boundary_type = "pocock")
    )
  )
  
  expect_lt(
    obrien_fleming$boundaries$alpha_spent[1],
    pocock$boundaries$alpha_spent[1]
  )
})


# Validation tests
test_that("alpha must lie strictly between zero and one", {
  expect_error(
    calculate_design(alpha = 0),
    "'alpha' must be a single numeric value strictly between 0 and 1",
    fixed = TRUE
  )
  
  expect_error(
    calculate_design(alpha = 1),
    "'alpha' must be a single numeric value strictly between 0 and 1",
    fixed = TRUE
  )
  
  expect_error(
    calculate_design(alpha = -0.025),
    "'alpha' must be a single numeric value strictly between 0 and 1",
    fixed = TRUE
  )
})


test_that("sided must be either one or two", {
  expect_error(
    calculate_design(sided = 0),
    "'sided' must be either 1 or 2",
    fixed = TRUE
  )
  
  expect_error(
    calculate_design(sided = 3),
    "'sided' must be either 1 or 2",
    fixed = TRUE
  )
})


test_that("number of analyses must lie between one and five", {
  expect_error(
    calculate_design(
      number_of_analyses = 0,
      information_times = numeric(0)
    ),
    "'number_of_analyses' must be an integer between 1 and 5",
    fixed = TRUE
  )
  
  expect_error(
    calculate_design(
      number_of_analyses = 6,
      information_times = seq_len(6) / 6
    ),
    "'number_of_analyses' must be an integer between 1 and 5",
    fixed = TRUE
  )
})


test_that("number of information times must match number of analyses", {
  expect_error(
    calculate_design(
      number_of_analyses = 3,
      information_times = c(0.5, 1)
    ),
    "'information_times' must contain exactly 3 values",
    fixed = TRUE
  )
})


test_that("information times must be strictly increasing", {
  expect_error(
    calculate_design(
      number_of_analyses = 3,
      information_times = c(0.5, 0.4, 1)
    ),
    "'information_times' must be strictly increasing",
    fixed = TRUE
  )
  
  expect_error(
    calculate_design(
      number_of_analyses = 3,
      information_times = c(0.5, 0.5, 1)
    ),
    "'information_times' must be strictly increasing",
    fixed = TRUE
  )
})


test_that("the final information time must equal one", {
  expect_error(
    calculate_design(
      number_of_analyses = 3,
      information_times = c(0.25, 0.5, 0.75)
    ),
    "The final information time must equal 1",
    fixed = TRUE
  )
})


test_that("only supported boundary types are accepted", {
  expect_error(
    calculate_design(
      boundary_type = "haybittle_peto"
    ),
    "'boundary_type' must be one of: obrien_fleming, pocock",
    fixed = TRUE
  )
})

# allowed corner cases
test_that("a fixed design with one analysis is supported", {
  result <- calculate_design(
    alpha = 0.025,
    sided = 1,
    number_of_analyses = 1,
    information_times = 1,
    boundary_type = "obrien_fleming"
  )
  
  expect_equal(
    nrow(result$boundaries),
    1
  )
  
  expect_equal(
    result$boundaries$information_fraction,
    1
  )
  
  expect_equal(
    result$boundaries$z_boundary,
    result$fixed_design$z_boundary,
    tolerance = 1e-6
  )
})


test_that("five analyses are supported", {
  result <- calculate_design(
    alpha = 0.025,
    sided = 1,
    number_of_analyses = 5,
    information_times = seq_len(5) / 5,
    boundary_type = "pocock"
  )
  
  expect_equal(
    nrow(result$boundaries),
    5
  )
  
  expect_equal(
    tail(result$boundaries$information_fraction, 1),
    1
  )
})