library(shiny)
library(bslib)
#library(ggplot2)

source("R/design_calculation.R")

source("modules/mod_design_input.R")
source("modules/mod_boundary_plot.R")
source("modules/mod_results_table.R")


ui <- page_sidebar(
  title = "Clinical Trial Design Explorer",
  
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly"
  ),
  
  sidebar = sidebar(
    title = "Design settings",
    width = 320,
    
    mod_design_input_ui("design_input")
  ),
  
  div(
    class = "mb-4",
    
    h2("Group Sequential Design Explorer"),
    
    p(
      class = "lead text-muted",
      paste(
        "Explore how interim analyses affect efficacy boundaries",
        "and the allocation of the overall Type I error."
      )
    )
  ),
  
  navset_card_tab(
    nav_panel(
      title = "Boundary plot",
      
      card_body(
        mod_boundary_plot_ui("boundary_plot")
      )
    ),
    
    nav_panel(
      title = "Boundary table",
      
      card_body(
        mod_results_table_ui("results_table")
      )
    )
  )
)


server <- function(input, output, session) {
  
  design_parameters <-
    mod_design_input_server("design_input")
  
  design_result <- reactive({
    parameters <- design_parameters()
    
    do.call(
      calculate_design,
      parameters
    )
  })
  
  mod_boundary_plot_server(
    id = "boundary_plot",
    design_result = design_result
  )
  
  mod_results_table_server(
    id = "results_table",
    design_result = design_result
  )
}


shinyApp(
  ui = ui,
  server = server
)