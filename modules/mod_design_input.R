# modules/mod_design_input.R

mod_design_input_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h4("Trial design"),
    
    numericInput(
      inputId = ns("alpha"),
      label = "Overall significance level",
      value = 0.025,
      min = 0.001,
      max = 0.2,
      step = 0.005
    ),
    
    radioButtons(
      inputId = ns("sided"),
      label = "Test",
      choices = c(
        "One-sided" = 1,
        "Two-sided" = 2
      ),
      selected = 1
    ),
    
    sliderInput(
      inputId = ns("number_of_analyses"),
      label = "Number of analyses",
      min = 1,
      max = 5,
      value = 3,
      step = 1
    ),
    
    radioButtons(
      inputId = ns("boundary_type"),
      label = "Stopping boundary",
      choices = c(
        "O'Brien–Fleming" = "obrien_fleming",
        "Pocock" = "pocock"
      ),
      selected = "obrien_fleming"
    ),
    
    hr(),
    
    div(
      class = "text-muted",
      strong("Information times"),
      p(
        "For this first version, analyses are equally spaced ",
        "according to statistical information."
      )
    ),
    
    verbatimTextOutput(
      outputId = ns("information_times")
    )
  )
}


mod_design_input_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    design_parameters <- reactive({
      number_of_analyses <- as.integer(input$number_of_analyses)
      
      list(
        alpha = input$alpha,
        sided = as.integer(input$sided),
        number_of_analyses = number_of_analyses,
        information_times =
          seq_len(number_of_analyses) / number_of_analyses,
        boundary_type = input$boundary_type
      )
    })
    
    output$information_times <- renderText({
      times <- design_parameters()$information_times
      
      paste(
        format(
          round(times, 2),
          nsmall = 2
        ),
        collapse = "  ·  "
      )
    })
    
    return(design_parameters)
  })
}