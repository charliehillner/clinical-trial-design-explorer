mod_explanation_ui <- function(id) {
  ns <- NS(id)
  
  uiOutput(
    outputId = ns("explanation")
  )
}


mod_explanation_server <- function(id, explanation) {
  moduleServer(id, function(input, output, session) {
    
    output$explanation <- renderUI({
      explanation_data <- explanation()
      
      req(explanation_data)
      
      tagList(
        explanation_header_ui(explanation_data),
        
        layout_columns(
          col_widths = c(7, 5),
          
          explanation_main_column_ui(explanation_data),
          
          explanation_side_column_ui(explanation_data)
        )
      )
    })
  })
}


explanation_header_ui <- function(explanation) {
  div(
    class = "mb-4",
    
    div(
      class = "d-flex align-items-center gap-2 mb-2",
      
      span(
        class = "badge text-bg-primary",
        "Context-aware explanation"
      ),
      
      span(
        class = "text-muted small",
        "Based on the currently selected design"
      )
    ),
    
    h2(
      class = "mb-2",
      explanation$title
    ),
    
    p(
      class = "lead text-muted mb-0",
      explanation$summary
    )
  )
}


explanation_main_column_ui <- function(explanation) {
  div(
    explanation_text_card_ui(
      title = "What does the current design imply?",
      content = explanation$current_design,
      accent_class = "border-primary"
    ),
    
    explanation_text_card_ui(
      title = "Why does this happen?",
      content = explanation$rationale
    ),
    
    explanation_text_card_ui(
      title = "Take-away",
      content = explanation$takeaway,
      accent_class = "border-success"
    )
  )
}


explanation_side_column_ui <- function(explanation) {
  div(
    trade_offs_card_ui(
      explanation$trade_offs
    ),
    
    statistical_details_card_ui(
      explanation$statistical_details
    ),
    
    learning_hint_card_ui(
      explanation$learning_hint
    )
  )
}


explanation_text_card_ui <- function(
    title,
    content,
    accent_class = NULL
) {
  card(
    class = paste(
      "mb-3 explanation-card",
      accent_class
    ),
    
    card_header(
      class = "fw-semibold",
      title
    ),
    
    card_body(
      p(
        class = "mb-0 explanation-text",
        content
      )
    )
  )
}


trade_offs_card_ui <- function(trade_offs) {
  card(
    class = "mb-3",
    
    card_header(
      div(
        class = "d-flex justify-content-between align-items-center",
        
        span(
          class = "fw-semibold",
          "Qualitative trade-offs"
        ),
        
        span(
          class = "badge text-bg-secondary",
          "1–5"
        )
      )
    ),
    
    card_body(
      trade_off_rating_ui(
        label = "Protection against early false positives",
        value = trade_offs$early_false_positive_protection
      ),
      
      trade_off_rating_ui(
        label = "Opportunity for early stopping",
        value = trade_offs$early_stopping_opportunity
      ),
      
      trade_off_rating_ui(
        label = "Evidence required early",
        value = trade_offs$early_evidence_required
      ),
      
      trade_off_rating_ui(
        label = "Similarity to a fixed design",
        value = trade_offs$similarity_to_fixed_design,
        add_margin = FALSE
      ),
      
      hr(),
      
      p(
        class = "small text-muted mb-0",
        paste(
          "These ratings are qualitative teaching aids.",
          "They are not statistical estimates."
        )
      )
    )
  )
}


trade_off_rating_ui <- function(
    label,
    value,
    add_margin = TRUE
) {
  validated_value <- max(
    1L,
    min(5L, as.integer(value))
  )
  
  percentage <- validated_value / 5 * 100
  
  div(
    class = if (add_margin) {
      "mb-3"
    } else {
      NULL
    },
    
    div(
      class = "d-flex justify-content-between mb-1",
      
      span(
        class = "small",
        label
      ),
      
      span(
        class = "small fw-semibold",
        paste0(validated_value, "/5")
      )
    ),
    
    div(
      class = "progress explanation-progress",
      role = "progressbar",
      `aria-label` = label,
      `aria-valuenow` = validated_value,
      `aria-valuemin` = 1,
      `aria-valuemax` = 5,
      
      div(
        class = "progress-bar",
        style = paste0(
          "width: ",
          percentage,
          "%"
        )
      )
    )
  )
}


statistical_details_card_ui <- function(details) {
  card(
    class = "mb-3",
    
    card_header(
      class = "fw-semibold",
      "Statistical details"
    ),
    
    card_body(
      statistic_row_ui(
        label = "Overall alpha",
        value = format_explanation_probability(
          details$overall_alpha
        )
      ),
      
      statistic_row_ui(
        label = "Test",
        value = if (details$sided == 1L) {
          "One-sided"
        } else {
          "Two-sided"
        }
      ),
      
      statistic_row_ui(
        label = "Alpha spent at first analysis",
        value = format_explanation_probability(
          details$first_alpha_spent
        )
      ),
      
      statistic_row_ui(
        label = "Final cumulative alpha",
        value = format_explanation_probability(
          details$final_cumulative_alpha_spent
        )
      ),
      
      statistic_row_ui(
        label = "Final Z-boundary",
        value = format_explanation_number(
          details$final_boundary
        )
      ),
      
      statistic_row_ui(
        label = "Fixed-design Z-boundary",
        value = format_explanation_number(
          details$fixed_design_boundary
        ),
        add_border = FALSE
      )
    )
  )
}


statistic_row_ui <- function(
    label,
    value,
    add_border = TRUE
) {
  div(
    class = paste(
      "d-flex justify-content-between gap-3 py-2",
      if (add_border) {
        "border-bottom"
      }
    ),
    
    span(
      class = "text-muted",
      label
    ),
    
    span(
      class = "fw-semibold text-end",
      value
    )
  )
}


learning_hint_card_ui <- function(learning_hint) {
  card(
    class = "mb-3 border-info",
    
    card_header(
      class = "fw-semibold",
      "Try this next"
    ),
    
    card_body(
      div(
        class = "d-flex gap-3",
        
        div(
          class = "explanation-hint-icon",
          "?"
        ),
        
        p(
          class = "mb-0",
          learning_hint
        )
      )
    )
  )
}


format_explanation_number <- function(
    value,
    digits = 3
) {
  formatC(
    value,
    format = "f",
    digits = digits
  )
}


format_explanation_probability <- function(value) {
  if (value < 0.0001) {
    return("< 0.0001")
  }
  
  formatC(
    value,
    format = "f",
    digits = 4
  )
}