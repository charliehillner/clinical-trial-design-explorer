# modules/mod_results_table.R

mod_results_table_ui <- function(id) {
  ns <- NS(id)
  
  tableOutput(
    outputId = ns("boundary_table")
  )
}


mod_results_table_server <- function(id, design_result) {
  moduleServer(id, function(input, output, session) {
    
    output$boundary_table <- renderTable(
      {
        result <- design_result()
        boundary_data <- result$boundaries
        
        data.frame(
          Analysis = boundary_data$analysis,
          
          `Information fraction` =
            round(
              boundary_data$information_fraction,
              3
            ),
          
          `Z-boundary` =
            round(
              boundary_data$z_boundary,
              3
            ),
          
          `Nominal p-value` =
            format_p_value(
              boundary_data$nominal_p_value
            ),
          
          `Alpha spent` =
            format_probability(
              boundary_data$alpha_spent
            ),
          
          `Cumulative alpha spent` =
            format_probability(
              boundary_data$cumulative_alpha_spent
            ),
          
          check.names = FALSE
        )
      },
      striped = TRUE,
      bordered = FALSE,
      hover = TRUE,
      spacing = "m",
      align = "crrrrr"
    )
  })
}


format_p_value <- function(values) {
  ifelse(
    values < 0.0001,
    "< 0.0001",
    formatC(
      values,
      format = "f",
      digits = 4
    )
  )
}


format_probability <- function(values) {
  formatC(
    values,
    format = "f",
    digits = 6
  )
}