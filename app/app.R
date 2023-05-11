### Bibliothèques ----

library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(viridis)
library(shiny)
library(sjmisc)
#library(haven)
library(labelled)

#setwd("CHEMIN.DU.DOSSIER")

### Données ----
print(getwd())



data <- as_tibble(read.csv2("data.csv"))

#data_filtre <- data %>% filter(Progress == 100, Speeder == 0)

### Tests exports ----

data_shiny <- data %>%
  mutate_at(vars(age:dom_Typo_panel), .funs = to_factor)

# var_labs <- attr(data_shiny, "variable.labels")
# var_labs <- var_labs[names(data_shiny)]
# attr(data_shiny, "variable.labels") <- var_labs

# data_shiny %>% ggplot(aes(x = Q107, fill = Q107)) + 
#   geom_bar(aes(y = after_stat(count/tapply(count, PANEL, sum)[PANEL]))) + 
#   geom_text(aes(label = percent(round(after_stat(count/tapply(count, PANEL, sum)[PANEL]), 2)), 
#                 y = after_stat(count/tapply(count, PANEL, sum)[PANEL])), stat = "count", vjust = -1) +
#   facet_grid(~ Pays) +
#   scale_y_continuous(labels = percent)

ui <- fluidPage(
  tags$h3("Panel lémanique - Exploration des données"),
  selectInput(inputId = "x", label = "Variable dépendante", 
              choices = c("Test A" = "age")),
  selectInput(inputId = "y", label = "Comparer...", 
              choices = c("Test B" = "formation")),
  checkboxGroupInput(inputId = "z", "Périmètre", choices = levels(data_shiny$dom_Typo_panel), selected = levels(data_shiny$dom_Typo_panel), inline = T),
  plotOutput(outputId = "Histogramme")
)

server <- function(input, output, session) {
  
  data <- reactive({data_shiny %>% filter(dom_Typo_panel %in% input$z)})
  
  output$Histogramme <- renderPlot({
    ggplot(data = data(), aes_string(x = input$x, fill = input$x)) + 
      geom_bar(aes(y = after_stat(count/tapply(count, PANEL, sum)[PANEL]))) + 
      facet_grid(~get(input$y)) +
      geom_text(aes(label = percent(round(after_stat(count/tapply(count, PANEL, sum)[PANEL]), 3), 0.1), 
                    y = after_stat(count/tapply(count, PANEL, sum)[PANEL])), stat = "count", vjust = -0.5) +
      scale_x_discrete(na.translate = F) +
      scale_y_continuous(labels = percent, expand = expansion(mult = c(0, 0.225))) +
      scale_fill_viridis(discrete = T, option = "D") +
      labs(x = var_label(data_shiny[[input$x]]), y = "Proportion") + 
      theme_bw() + theme(text = element_text(size = 12),
                         legend.position = "bottom", 
                         axis.title = element_text(face = "bold"), 
                         strip.text = element_text(face = "italic"),
                         axis.text.x = element_text(angle = 20, hjust = 1))
  })
}

shinyApp(ui = ui, server = server)
