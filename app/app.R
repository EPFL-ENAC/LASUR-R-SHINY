### Bibliothèques ----

library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggtext)
library(ggfittext)
library(scales)
library(viridis)
library(shiny)
library(sjmisc)
library(haven)
library(labelled)

#setwd("CHEMIN.DU.DOSSIER")

### Données ----

data <- as_tibble(read_spss("data.sav"))

### Tests exports ----

data_shiny <- data %>% 
  mutate(dist_domtrav_cat = cut(dist_domtrav, 
                                breaks = c(0, 5, 500, 2000, 5000, 10000, 20000, 50000, 100000, +Inf),
                                labels = c("0m", "<500m", "500m-2km", "2km-5km", "5km-10km", "10km-20km",
                                           "20km-50km", "50km-100km", ">100km"), include.lowest = T),
         age = 2023 - Q106,
         age = cut(age, breaks = c(0, 24, 35, 49, 64, +Inf), include.lowest = T)) %>%
  select(Pays, canton_dep, dom_Typo_panel, trav_Typo_panel, dist_domtrav_cat,
         Genre_actuel, revenu, age, formation,
         Q4_1_1_R, Q4_1_2_R, Q4_4_1, Q4_4_2,
         Q10_1_R, Q10_2_R, Q10_6_R, Q10_7_R, Q10_9_R, Q11_1_R, Q11_3_R, Q11_5_R,
         Q62_1_R, Q62_2_R, Q62_3_R, Q62_4_R, Q62_6_R, Q63,
         Q33_1, Q33_3, Q33_4, Q33_5,
         mode_travail, Q5_R, Q15, Q31,
         Q91, Q95_2,
         Q108, Q57, Q53) %>%
  mutate_at(vars(Pays:Q53), .funs = to_factor)

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
              choices = c("Nombre de voitures (conv.)" = "Q4_1_1_R",
                          "Nombre de voitures (élec.)" = "Q4_1_2_R",
                          "Nombre de vélos (conv.)" = "Q4_4_1",
                          "Nombre de vélos (élec.)" = "Q4_4_2",
                          "Abonnement général (CFF)" = "Q10_1_R",
                          "Abonnement 1/2 tarif" = "Q10_2_R",
                          "Léman Pass" = "Q10_6_R",
                          "Abo. communautaire" = "Q10_7_R",
                          "Aucun abo." = "Q10_9_R",
                          "Vignette autoroutière" = "Q11_1_R",
                          "Abo. P+R" = "Q11_3_R",
                          "Abo. autopartage" = "Q11_5_R",
                          "Vignette autoroutière" = "Q11_1_R",
                          "Place privée (domicile)" = "Q62_1_R",
                          "Place publique macaron (domicile)" = "Q62_2_R",
                          "Place publique sans macaron (domicile)" = "Q62_3_R",
                          "Abo. parking (domicile)" = "Q62_4_R",
                          "Aucune place (domicile)" = "Q62_6_R",
                          "Conditions statio. (domicile)" = "Q63",
                          "Type de motorisation" = "Q5_R",
                          "Résidence secondaire (binaire)" = "Q15",
                          "Nombre de sorties quotidiennes" = "Q31",
                          "Part modale (travail)" = "mode_travail",
                          "Fréquence voiture conducteur" = "Q33_1",
                          "Fréquence train" = "Q33_3",
                          "Fréquence transports publics" = "Q33_4",
                          "Fréquence vélo" = "Q33_5",
                          "Pays d'emploi" = "Q108",
                          "Jours télétravaillées" = "Q57",
                          "Flexibilité des horaires" = "Q53",
                          "Aisance transports publics" = "Q91",
                          "Préf. pour les loisirs proches" = "Q95_2")),
  selectInput(inputId = "y", label = "Comparer...", 
              choices = c("Pays" = "Pays",
                          "Typologie domicile" = "dom_Typo_panel",
                          "Typologie travail" = "trav_Typo_panel",
                          "Distances domicile - travail" = "dist_domtrav_cat",
                          "Genre" = "Genre_actuel",
                          "Classes de revenus" = "revenu",
                          "Formation" = "formation",
                          "Classes d'âge" = "age")),
  checkboxGroupInput(inputId = "z", "Périmètre", choices = levels(data_shiny$canton_dep), selected = levels(data_shiny$canton_dep), inline = T),
  plotOutput(outputId = "Histogramme"),
  radioButtons("extension", "Save as...", choices = c("png", "pdf"), inline = T),
  downloadButton("download", "Sauvegarder")
)

server <- function(input, output, session) {
  
  data <- reactive({data_shiny %>% filter(canton_dep %in% input$z)})
  
  plot_output <- reactive({
    ggplot(data = data(), aes_string(x = input$x, fill = input$x)) + 
      geom_bar(aes(y = after_stat(count/tapply(count, PANEL, sum)[PANEL]))) +
      geom_bar_text(aes(label = percent(round(after_stat(count/tapply(count, PANEL, sum)[PANEL]), 3), 0.1), 
                        y = after_stat(count/tapply(count, PANEL, sum)[PANEL])), stat = "count", family = "Times", min.size = 2) +
      facet_grid(~get(input$y)) +
      # geom_text(aes(label = percent(round(after_stat(count/tapply(count, PANEL, sum)[PANEL]), 3), 0.1), 
      #               y = after_stat(count/tapply(count, PANEL, sum)[PANEL])), stat = "count", vjust = -0.5, family = "Times", size = 2) +
      scale_x_discrete(na.translate = F) +
      scale_y_continuous(labels = percent, expand = expansion(mult = c(0, 0.225))) +
      scale_fill_viridis(discrete = T, option = "D") +
      labs(x = var_label(data_shiny[[input$x]]), y = "Proportion") + 
      theme_bw() + theme(text = element_text(family = "Times"),
                         legend.position = "bottom", 
                         axis.title.x = element_textbox_simple(), axis.text.x = element_text(angle = 20, hjust = 1), 
                         axis.title = element_text(face = "bold"), strip.text = element_text(face = "italic"))
  })
  
  output$Histogramme <- renderPlot(plot_output())
  
  output$download <- downloadHandler(
    filename = function() {paste("panel", input$extension, sep = ".")},
    content = function(file) {ggsave(file, plot_output(), device = input$extension, dpi = 300, height = 100, width = 150, units = "mm", scale = 1.5)}
  )
}

shinyApp(ui = ui, server = server)
