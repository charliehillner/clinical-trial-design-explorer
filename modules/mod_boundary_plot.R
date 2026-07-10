# modules/mod_boundary_plot.R

mod_boundary_plot_ui <- function(id) {
  ns <- NS(id)
  
  plotOutput(
    outputId = ns("boundary_plot"),
    height = "450px"
  )
}


mod_boundary_plot_server <- function(id, design_result) {
  moduleServer(id, function(input, output, session) {
    
    output$boundary_plot <- renderPlot({
      result <- design_result()
      boundary_data <- result$boundaries
      
      plot_data <- data.frame(
        information_fraction =
          boundary_data$information_fraction,
        z_boundary =
          boundary_data$z_boundary,
        analysis =
          factor(boundary_data$analysis)
      )
      
      ggplot2::ggplot(
        plot_data,
        ggplot2::aes(
          x = information_fraction,
          y = z_boundary
        )
      ) +
        ggplot2::geom_hline(
          yintercept = result$fixed_design$z_boundary,
          linetype = "dashed",
          linewidth = 0.7
        ) +
        ggplot2::geom_line(
          linewidth = 1
        ) +
        ggplot2::geom_point(
          size = 3
        ) +
        ggplot2::scale_x_continuous(
          limits = c(0, 1),
          breaks = seq(0, 1, by = 0.2),
          labels = scales::label_percent()
        ) +
        ggplot2::labs(
          title = boundary_plot_title(result),
          subtitle = paste(
            "The dashed line represents the corresponding",
            "fixed-design boundary."
          ),
          x = "Information fraction",
          y = "Upper Z-boundary"
        ) +
        ggplot2::theme_minimal(base_size = 14) +
        ggplot2::theme(
          panel.grid.minor = ggplot2::element_blank(),
          plot.title.position = "plot"
        )
    })
  })
}


boundary_plot_title <- function(result) {
  boundary_label <- switch(
    result$settings$boundary_type,
    obrien_fleming = "O'Brien–Fleming",
    pocock = "Pocock"
  )
  
  paste(boundary_label, "efficacy boundaries")
}