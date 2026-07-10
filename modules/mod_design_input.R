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
    
    radioButtons(
      inputId = ns("information_time_mode"),
      label = "Information times",
      choices = c(
        "Equally spaced" = "equally_spaced",
        "Custom" = "custom"
      ),
      selected = "equally_spaced"
    ),
    
    conditionalPanel(
      condition = sprintf(
        "input['%s'] === 'custom'",
        ns("information_time_mode")
      ),
      
      uiOutput(
        outputId = ns("custom_information_times")
      )
    ),
    
    div(
      class = "mt-3",
      
      strong("Selected information times"),
      
      verbatimTextOutput(
        outputId = ns("information_times_preview")
      )
    )
  )
}


mod_design_input_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    number_of_analyses <- reactive({
      as.integer(input$number_of_analyses)
    })
    
    
    equally_spaced_information_times <- reactive({
      k <- number_of_analyses()
      
      seq_len(k) / k
    })
    
    
    output$custom_information_times <- renderUI({
      k <- number_of_analyses()
      
      if (k == 1L) {
        return(
          div(
            class = "text-muted",
            p(
              "A design with one analysis has no interim analyses. ",
              "The final information time is fixed at 1."
            )
          )
        )
      }
      
      default_times <- equally_spaced_information_times()
      
      interim_inputs <- lapply(
        seq_len(k - 1L),
        function(index) {
          numericInput(
            inputId = session$ns(
              paste0("information_time_", index)
            ),
            label = paste("Analysis", index),
            value = round(default_times[index], 2),
            min = 0.01,
            max = 0.99,
            step = 0.01
          )
        }
      )
      
      tagList(
        interim_inputs,
        
        div(
          class = "form-group",
          
          tags$label(
            class = "control-label",
            paste("Analysis", k)
          ),
          
          div(
            class = "form-control bg-light",
            "1.00 (final analysis)"
          )
        ),
        
        div(
          class = "text-muted small",
          paste(
            "Information times must be strictly increasing.",
            "The final analysis is fixed at 1."
          )
        )
      )
    })
    
    
    custom_information_times <- reactive({
      k <- number_of_analyses()
      
      if (k == 1L) {
        return(1)
      }
      
      interim_times <- vapply(
        seq_len(k - 1L),
        function(index) {
          value <- input[[
            paste0("information_time_", index)
          ]]
          
          if (is.null(value)) {
            return(NA_real_)
          }
          
          as.numeric(value)
        },
        numeric(1)
      )
      
      c(interim_times, 1)
    })
    
    
    selected_information_times <- reactive({
      if (input$information_time_mode == "equally_spaced") {
        return(equally_spaced_information_times())
      }
      
      information_times <- custom_information_times()
      
      validate(
        need(
          !anyNA(information_times),
          "Please enter an information time for every analysis."
        ),
        
        need(
          all(is.finite(information_times)),
          "Information times must be finite numeric values."
        ),
        
        need(
          all(information_times > 0),
          "Information times must be greater than 0."
        ),
        
        need(
          all(information_times <= 1),
          "Information times must not exceed 1."
        ),
        
        need(
          all(diff(information_times) > 0),
          paste(
            "Information times must be strictly increasing.",
            "For example: 0.25, 0.50, 1.00."
          )
        )
      )
      
      information_times
    })
    
    
    design_parameters <- reactive({
      list(
        alpha = input$alpha,
        sided = as.integer(input$sided),
        number_of_analyses = number_of_analyses(),
        information_times = selected_information_times(),
        boundary_type = input$boundary_type
      )
    })
    
    
    output$information_times_preview <- renderText({
      information_times <- selected_information_times()
      
      paste(
        format(
          round(information_times, 2),
          nsmall = 2
        ),
        collapse = "  ·  "
      )
    })
    
    
    return(design_parameters)
  })
}