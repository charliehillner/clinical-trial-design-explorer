mod_alpha_spending_plot_ui <- function(id) {
  ns <- NS(id)
  
  plotOutput(
    outputId = ns("alpha_spending_plot"),
    height = "450px"
  )
}


mod_alpha_spending_plot_server <- function(id, design_result) {
  moduleServer(id, function(input, output, session) {
    
    output$alpha_spending_plot <- renderPlot({
      result <- design_result()
      
      req(result)
      
      boundary_data <- result$boundaries
      overall_alpha <- result$settings$alpha
      
      reference_data <- data.frame(
        information_fraction = c(0, 1),
        cumulative_alpha_spent = c(0, overall_alpha)
      )
      
      ggplot2::ggplot(
        boundary_data,
        ggplot2::aes(
          x = information_fraction,
          y = cumulative_alpha_spent
        )
      ) +
        
        # Observed/design-specific alpha spending
        ggplot2::geom_line(
          linewidth = 1
        ) +
        
        ggplot2::geom_point(
          size = 3
        ) +
        
        # Reference: proportional alpha spending
        ggplot2::geom_line(
          data = reference_data,
          ggplot2::aes(
            x = information_fraction,
            y = cumulative_alpha_spent
          ),
          linetype = "dotted",
          linewidth = 0.8
        ) +
        
        # Overall alpha budget
        ggplot2::geom_hline(
          yintercept = overall_alpha,
          linetype = "dashed"
        ) +
        
        ggplot2::scale_x_continuous(
          breaks = seq(0, 1, by = 0.2),
          labels = scales::label_percent()
        ) +
        
        ggplot2::scale_y_continuous(
          labels = scales::label_number(
            accuracy = 0.001
          )
        ) +
        
        ggplot2::coord_cartesian(
          xlim = c(0, 1),
          ylim = c(0, overall_alpha * 1.05)
        ) +
        
        ggplot2::labs(
          title = "Cumulative Alpha Spending",
          subtitle = paste(
            "Overall Type I error:",
            formatC(
              overall_alpha,
              format = "f",
              digits = 3
            )
          ),
          x = "Information fraction",
          y = "Cumulative alpha spent"
        ) +
        
        ggplot2::theme_minimal(base_size = 13)
    })
  })
}