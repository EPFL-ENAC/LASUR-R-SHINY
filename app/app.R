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
library(haven)
library(labelled)
#windowsFonts(Times = "Times New Roman")

#setwd("Y:/common/LaSUR/06 - Recherche/2021/Panel lémanique/Données/Vague 1")

### Données ----

data <- as_tibble(read_spss("data.sav"))

#data <- as_tibble(read_spss("EPFL_vague1_pond_clean.sav"))

### Tests exports ----

data_shiny <- data %>% 
  mutate(dist_domtrav_cat = cut(dist_domtrav, 
                                breaks = c(0, 5, 500, 2000, 5000, 10000, 20000, 50000, 100000, +Inf),
                                labels = c("0m", "<500m", "500m-2km", "2km-5km", "5km-10km", "10km-20km",
                                           "20km-50km", "50km-100km", ">100km"),
                                include.lowest = T),
         age = 2023 - Q106,
         age = cut(age, breaks = c(0, 24, 35, 49, 64, +Inf), include.lowest = T),
         agglo = as.factor(case_when(AGGLO_CH_dom %in% c("GG_CH", "GG_FR") ~ "Grand Genève",
                                     AGGLO_CH_dom == "AGGLOY" ~ "AggloY", AGGLO_CH_dom == "CHABLAIS" ~ "Chablais",
                                     AGGLO_CH_dom == "MOBUL" ~ "mobul", AGGLO_CH_dom == "PALM" ~ "PALM", AGGLO_CH_dom == "RIVELAC" ~ "Rivelac",
                                     T ~ "Hors agglos")),
         mode_travail = case_when(Q54_R %in% c(2, 3, 7, 8) ~ "TIM", Q54_R %in% c(4, 5, 10) ~ "TP", Q54_R %in% c(6, 9) ~ "MD", Q54_R %in% c(11) ~ "Autres",
                                  (Q55_1_R == 1 | Q55_2_R == 1 | Q55_6_R == 1 | Q55_7_R == 1) & (Q55_3_R == 0 & Q55_4_R == 0 & Q55_5_R == 0  & Q55_9_R == 0 & Q55_10_R == 0) ~ "TIM",
                                  (Q55_3_R == 1 | Q55_4_R == 1 | Q55_9_R == 1) & (Q55_1_R == 0 & Q55_2_R == 0 & Q55_5_R == 0  & Q55_6_R == 0 & Q55_7_R == 0 & Q55_10_R == 0) ~ "TP",
                                  (Q55_5_R == 1 | Q55_8_R == 1) & (Q55_1_R == 0 & Q55_2_R == 0 & Q55_3_R == 0  & Q55_4_R == 0 & Q55_6_R == 0 & Q55_7_R == 0 & Q55_9_R == 0 & Q55_10_R == 0) ~ "MD",
                                  (Q55_1_R == 1 | Q55_2_R == 1 | Q55_6_R == 1 | Q55_7_R == 1) & (Q55_3_R == 1 | Q55_4_R == 1 | Q55_9_R == 1) & (Q55_5_R == 0  & Q55_10_R == 0) ~ "TIM+TP",
                                  (Q55_1_R == 1 | Q55_2_R == 1 | Q55_6_R == 1 | Q55_7_R == 1) & (Q55_5_R == 1) & (Q55_3_R == 0 & Q55_4_R == 0 & Q55_9_R == 0 & Q55_10_R == 0) ~ "TIM+MD",
                                  (Q55_3_R == 1 | Q55_4_R == 1 | Q55_9_R == 1) & (Q55_5_R == 1) & (Q55_1_R == 0 & Q55_2_R == 0 & Q55_6_R == 0 & Q55_7_R == 0 & Q55_10_R == 0) ~ "TP+MD",
                                  (Q55_1_R == 1 | Q55_2_R == 1 | Q55_6_R == 1 | Q55_7_R == 1) & (Q55_3_R == 1 | Q55_4_R == 1 | Q55_9_R == 1) & (Q55_5_R == 1) & (Q55_10_R == 0) ~ "TIM+TP+MD",
                                  Q55_10_R == 1 ~ "Autres",
                                  is.na(Q54_R) ~ "NA",
                                  T ~ as.character("Autres")),
         mode_resid = case_when(Q20_R %in% c(2, 3, 7, 8) ~ "TIM", Q20_R %in% c(4, 5, 11) ~ "TP", Q20_R %in% c(10) ~ "Avion", Q20_R %in% c(6, 9, 12) ~ "Autres",
                                (Q21_1_R == 1 | Q21_2_R == 1 | Q21_6_R == 1 | Q21_7_R == 1) & (Q21_3_R == 0 & Q21_4_R == 0 & Q21_9_R == 0 & Q21_10_R == 0 & Q21_11_R == 0) ~ "TIM",
                                (Q21_3_R == 1 | Q21_4_R == 1 | Q21_10_R == 1) & (Q21_1_R == 0 & Q21_2_R == 0 & Q21_6_R == 0 & Q21_7_R == 0 & Q21_9_R == 0 & Q21_11_R == 0) ~ "TP",
                                (Q21_9_R == 1) & (Q21_1_R == 0 & Q21_2_R == 0 & Q21_3_R == 0  & Q21_4_R == 0 & Q21_6_R == 0 & Q21_7_R == 0 & Q21_10_R == 0 & Q21_11_R == 0) ~ "Avion",
                                (Q21_1_R == 1 | Q21_2_R == 1 | Q21_6_R == 1 | Q21_7_R == 1) & (Q21_3_R == 1 | Q21_4_R == 1 | Q21_10_R == 1) & (Q21_9_R == 0 & Q21_11_R == 0) ~ "TIM+TP",
                                (Q21_1_R == 1 | Q21_2_R == 1 | Q21_6_R == 1 | Q21_7_R == 1) & (Q21_9_R == 1) & (Q21_3_R == 0 & Q21_4_R == 0 & Q21_10_R == 0 & Q21_11_R == 0) ~ "TIM+Avion",
                                (Q21_3_R == 1 | Q21_4_R == 1 | Q21_10_R == 1) & (Q21_9_R == 1) & (Q21_1_R == 0 & Q21_2_R == 0 & Q21_6_R == 0 & Q21_7_R == 0 & Q21_11_R == 0) ~ "TP+Avion",
                                (Q21_1_R == 1 | Q21_2_R == 1 | Q21_6_R == 1 | Q21_7_R == 1) & (Q21_3_R == 1 | Q21_4_R == 1 | Q21_10_R == 1) & (Q21_9_R == 1) & (Q21_11_R == 0) ~ "TIM+TP+Avion",
                                Q21_11_R == 1 ~ "Autres",
                                is.na(Q20_R) ~ "NA",
                                T ~ as.character("Autres"))) %>%
  select(wgt_agg_trim, wgt_cant_trim, IDNO,
         Pays, agglo, canton_dep, dom_Typo_panel, trav_Typo_panel, dist_domtrav_cat,
         Genre_actuel, revenu, age, formation,
         Q4_1_1_R, Q4_1_2_R, Q4_4_1, Q4_4_2,
         Q10_1_R, Q10_2_R, Q10_6_R, Q10_7_R, Q10_9_R, Q11_1_R, Q11_3_R, Q11_5_R,
         Q62_1_R, Q62_2_R, Q62_3_R, Q62_4_R, Q62_6_R, Q63,
         Q33_1, Q33_3, Q33_4, Q33_5,
         mode_travail, mode_resid, Q54_R, Q20_R,
         Q5_R, Q15, Q31,
         Q91, Q95_2,
         Q108, Q57, Q53) %>%
  mutate_at(vars(Pays:Q53), .funs = as_factor) %>%
  mutate(dom_Typo_panel = revalue(dom_Typo_panel, c("Centres de grandes agglomérations" = "Centres d'agglo.", 
                                                    "Agglomérations centres et suburbains" = "Agglo. centres et suburbains")),
         dom_Typo_panel = factor(dom_Typo_panel, c("Centres d'agglo.", "Agglo. centres et suburbains", "Périphéries d'agglomération",
                                                   "Centres secondaires", "Faibles densités et périurbain", "Hors périmètre", "Non réponse")),
         trav_Typo_panel = revalue(trav_Typo_panel, c("Centres de grandes agglomérations" = "Centres d'agglo.", 
                                                    "Agglomérations centres et suburbains" = "Agglo. centres et suburbains")),
         trav_Typo_panel = factor(trav_Typo_panel, c("Centres d'agglo.", "Agglo. centres et suburbains", "Périphéries d'agglomération",
                                                   "Centres secondaires", "Faibles densités et périurbain", "Hors périmètre", "Non réponse")),
         agglo = factor(agglo, c("Grand Genève", "PALM", "AggloY", "Rivelac", "mobul", "Chablais", "Hors agglos")),
         mode_travail = factor(mode_travail, c("TIM", "TP", "MD", "TIM+TP", "TIM+MD", "TP+MD", "TIM+TP+MD", "Autres", "NA")),
         mode_resid = factor(mode_resid, c("TIM", "TP", "Avion", "TIM+TP", "TIM+Avion", "TP+Avion", "TIM+TP+Avion", "Autres", "NA")),
         Q54_R = revalue(Q54_R, c("Je combine plusieurs moyens de transports pour un même trajet" = "Combinaison",
                                  "Uniquement la voiture en tant que conducteur·trice" = "Voiture",
                                  "Uniquement la voiture en tant que passager·ère" = "Voiture",
                                  "Uniquement le train (y compris Léman Express)" = "Train",
                                  "Uniquement les transports publics (sans le train)" = "Autres TP",
                                  "Uniquement le vélo (conventionnel, électrique, en libre-service)" = "Vélo",
                                  "Uniquement la moto" = "2RM",
                                  "Uniquement les deux-roues motorisés type scooter ou cyclomoteur" = "2RM",
                                  "Uniquement la marche à pied" = "Marche",
                                  "Uniquement le bateau" = "Bateau",
                                  "Un autre mode de transport unique (veuillez préciser) :" = "Autres")),
         Q20_R = revalue(Q20_R, c("Je combine plusieurs moyens de transports pour un même trajet" = "Combinaison",
                                  "Uniquement la voiture en tant que conducteur·trice" = "Voiture",
                                  "Uniquement la voiture en tant que passager·ère" = "Voiture",
                                  "Uniquement le train (y compris Léman Express)" = "Train",
                                  "Uniquement les transports publics (sans le train)" = "Autres TP",
                                  "Uniquement le vélo (conventionnel, électrique, en libre-service)" = "Modes doux",
                                  "Uniquement la moto" = "2RM",
                                  "Uniquement les deux-roues motorisés type scooter ou cyclomoteur" = "2RM",
                                  "Uniquement la marche à pied" = "Modes doux",
                                  "Uniquement l'avion" = "Avion",
                                  "Uniquement le bateau" = "Bateau",
                                  "Un autre mode de transport unique (veuillez préciser) :" = "Autres")),
         Q57 = revalue(Q57, c("7 jours par semaine" = "5 jours par semaine ou plus", "6 jours par semaine" = "5 jours par semaine ou plus", "5 jours par semaine" = "5 jours par semaine ou plus"))) %>%
  set_variable_labels(Q4_1_1_R = "Combien avez-vous de véhicules en état de fonctionnement dans votre ménage ? Voitures - Nombre de véhicules conventionnels",
                      Q4_1_2_R = "Combien avez-vous de véhicules en état de fonctionnement dans votre ménage ? Voitures - Nombre de véhicules électriques, hybrides ou autres",
                      Q4_4_1 = "Combien avez-vous de véhicules en état de fonctionnement dans votre ménage ? Vélos - Nombre de véhicules conventionnels",
                      Q4_4_2 = "Combien avez-vous de véhicules en état de fonctionnement dans votre ménage ? Vélos - Nombre de véhicules électriques, hybrides ou autres")

ui <- fluidPage(
  tags$h3("Panel lémanique - Exploration des données"),
  br(), br(), 
  tags$h4("Sélections"),
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
                          "Place privée (domicile)" = "Q62_1_R",
                          "Place publique macaron (domicile)" = "Q62_2_R",
                          "Place publique sans macaron (domicile)" = "Q62_3_R",
                          "Abo. parking (domicile)" = "Q62_4_R",
                          "Aucune place (domicile)" = "Q62_6_R",
                          "Conditions statio. (domicile)" = "Q63",
                          "Type de motorisation" = "Q5_R",
                          "Résidence secondaire (binaire)" = "Q15",
                          "Nombre de sorties quotidiennes" = "Q31",
                          "Choix modal travail (agrégé)" = "mode_travail",
                          "Choix modal travail (unique)" = "Q54_R",
                          "Choix modal résidence sec. (agrégé)" = "mode_resid",
                          "Choix modal résidence sec. (unique)" = "Q20_R",
                          "Fréquence voiture conducteur" = "Q33_1",
                          "Fréquence train" = "Q33_3",
                          "Fréquence transports publics" = "Q33_4",
                          "Fréquence vélo" = "Q33_5",
                          "Pays d'emploi" = "Q108",
                          "Jours télétravaillés" = "Q57",
                          "Flexibilité des horaires" = "Q53",
                          "Aisance transports publics" = "Q91",
                          "Préf. pour les loisirs proches" = "Q95_2")),
  selectInput(inputId = "y", label = "Comparer...", 
              choices = c("Typologie domicile" = "dom_Typo_panel",
                          "Typologie travail" = "trav_Typo_panel",
                          "Agglomérations" = "agglo",
                          "Cantons / départements" = "canton_dep",
                          "Distances domicile - travail" = "dist_domtrav_cat",
                          "Genre" = "Genre_actuel",
                          "Classes de revenus" = "revenu",
                          "Formation" = "formation",
                          "Classes d'âge" = "age")),
  radioButtons("level", "Échelle d'analyse", choices = c("Agglomérations", "Cantons/France"), inline = T),
  conditionalPanel(
    condition = "input.level == 'Agglomérations'", 
    radioButtons(inputId = "za", "Périmètre", choices = levels(data_shiny$agglo), selected = "Grand Genève", inline = T)
    ),
  conditionalPanel(
    condition = "input.level == 'Cantons/France'", 
    checkboxGroupInput(inputId = "zb", "Périmètre", choices = levels(data_shiny$canton_dep), selected = levels(data_shiny$canton_dep), inline = T)
  ),
  br(), br(), 
  tags$h4("Histogrammes détaillés (selon sélections)"),
  plotOutput(outputId = "Histogramme", height = "600px"),
  radioButtons("extension", "Save as...", choices = c("png", "pdf"), inline = T),
  downloadButton("download", "Sauvegarder"),
  br(), br(), 
  tags$h4("Données moyennes (selon sélections)"),
  dataTableOutput(outputId = "Test")
)

server <- function(input, output, session) {
  
  data <- reactive({data_shiny %>% filter(case_when(input$level == "Agglomérations" ~ agglo %in% input$za,
                                                    T ~ canton_dep %in% input$zb), !is.na(get(input$x)),
                                          !is.na(get(input$y)), get(input$y) != "Non réponse", get(input$x) != "NA") %>% 
      group_by_(input$y, input$x) %>%
      mutate(weight = case_when(input$level == "Agglomérations" ~ wgt_agg_trim, T ~ wgt_cant_trim)) %>%
      summarise(total = n(), total_pond = round(sum(weight), 0)) %>% 
      mutate(effectif = sum(total), effectif_pond = sum(total_pond), prop = total / sum(total), prop_pond = total_pond / sum(total_pond))})
  
  data_mean <- reactive({data_shiny %>% filter(case_when(input$level == "Agglomérations" ~ agglo %in% input$za,
                                                          T ~ canton_dep %in% input$zb), !is.na(get(input$x)),
                                                !is.na(get(input$y)), get(input$y) != "Non réponse", get(input$x) != "NA") %>%
      group_by_(input$x) %>% 
      mutate(weight = case_when(input$level == "Agglomérations" ~ wgt_agg_trim, T ~ wgt_cant_trim)) %>%
      summarise(total = n(), total_pond = round(sum(weight), 0)) %>% 
      mutate(effectif = sum(total), effectif_pond = sum(total_pond), 
             prop = paste0(round(100 * total / sum(total), 1), "%"), 
             prop_pond =  paste0(round(100 * total_pond / sum(total_pond), 1), "%")) %>%
      select(input$x, prop, prop_pond) %>% 
      rename(`Modalité choisie` = input$x, `Proportion totale (non pondérée)` = prop, `Proportion totale (pondérée)` = prop_pond)})
  
  plot_output <- reactive({
    ggplot(data = data(), aes_string(x = input$x, fill = input$x)) + 
      geom_bar(aes(y = prop_pond), stat = "identity", position = position_dodge(0.9), width = 0.85) +
      geom_bar_text(aes(y = prop_pond, label = percent(prop_pond, 1), group = input$x), family = "serif") +
      geom_label(aes(x = Inf, y = Inf, fill = NULL, label = paste0("Échantillon = ", effectif_pond)), family = "serif", 
                 label.padding = unit(0.5, "lines"), label.r = unit(0.15, "lines"), hjust = "inward", vjust = "inward", show.legend = F) +
      facet_grid(~ get(input$y)) +
      scale_y_continuous(labels = percent, expand = expansion(mult = c(0, 0.1))) + scale_fill_viridis(discrete = T, option = "D") +
      labs(x = var_label(data_shiny[[input$x]]), y = "Proportions", fill = "") +
      theme_bw() + theme(text = element_text(family = "serif", size = 15), legend.position = "bottom", 
                         axis.title.x = element_textbox_simple(halign = 0.5, margin = margin(t = 1, unit = "cm")), axis.text.x = element_blank(),
                         axis.title = element_text(face = "bold"), strip.text = element_text(face = "italic")) +
      guides(fill = guide_legend(ncol = 2))
  })
  
  output$Histogramme <- renderPlot(plot_output())
  
  output$download <- downloadHandler(
    filename = function() {paste("panel", input$extension, sep = ".")},
    content = function(file) {ggsave(file, plot_output(), device = input$extension, dpi = 300, height = 200, width = 300, units = "mm")}
  )
  
  output$Test <- renderDataTable(data_mean())
  
}

shinyApp(ui = ui, server = server)
