library(shiny)
library(ggplot2)
library(plotly)

shinyUI(
  fluidPage(
    theme = "bootstrap.css",
    navbarPage(title = "Edgar Anderson's Iris Data",
               tabPanel("Iris Dataset",
                        # Header or Title Panel
                        titlePanel(title = h2("Pairs Scatter Plot and Pearson's correlation", 
                                              align = "center")),
                        plotOutput("Pairs")),
               navbarMenu(title = "Exploratory Data Analysis",
                          tabPanel("Summary",
                                   # Header or Title Panel
                                   titlePanel(title = h2("General Statistics", 
                                                         align = "center")),
                                   tableOutput("summary"),
                                   align = "center"),
                          tabPanel("Principal Component Analysis (PCA)",
                                    # Header or Title Panel
                                    titlePanel(title = h2("Principal Component Analysis after Log transformation", 
                                                          align = "center")),
                                               plotOutput("PCAs")
       
                                   )
                          ),
               tabPanel("KNN",
                        # Header or Title Panel
                        titlePanel(title = h2("Predictor K-Nearest Neighbors", 
                                              align = "center")),
               # Body
               sidebarLayout(
                 # Sidebar Panel
                 sidebarPanel(h4("Options"),
                              selectInput("inKNN",
                                          "Pre-Process",
                                          choices = c("Regular",
                                                      "PCA"),
                                          selected = "PCA"),
                              
                             sliderInput(inputId = "fold",
                                         label = "Choose a Fold Number",
                                         value = 5, min = 2, max =10),
                             sliderInput(inputId = "repet",
                                         label = "Choose a Reptition Number",
                                         value = 2, min = 1, max =10),
                             actionButton(inputId = "goKNN",
                                          label = "RUN")
                             ,width = 2),
                 
                 
                 
                 # Main Panel 
                 #  00             
                 mainPanel(
                   verbatimTextOutput("descrKNN"),
                   tableOutput("KNN"),
                   align = "center",
                   width = 10)
               )
               ),
               
               tabPanel("Decision Tree",
                        # Header or Title Panel
                        titlePanel(title = h2("Predictor Decision Tree", 
                                              align = "center")),
                        # Body
                        sidebarLayout(
                          # Sidebar Panel
                          sidebarPanel(h4("Options"),
                                       sliderInput(inputId = "DTpart",
                                                   label = "Choose Data Partition",
                                                   value = 0.75, min = 0.6, max = 0.95),
                                       actionButton(inputId = "goDT",
                                                    label = "RUN")
                                       ,width = 2),
                          
                          # Main Panel 
                          #  00             
                          mainPanel(
                            plotOutput("DTree"),
                            verbatimTextOutput("testDTree"),
                            width = 10)
                          
                        )
               ),
                tabPanel("Other Predictors",
                        # Header or Title Panel
                        titlePanel(title = h2("Examples of the use of different Predictors", 
                                    align = "center")),
                        sidebarLayout(
                                     # Sidebar Panel
                                               
                              sidebarPanel(h4("Options"),
                                          selectInput("predictor",
                                                      "Predictor",
                                                      choices = c("SVM"="svmRadial","Random Forest"="rf"),
                                                      selected = "svmRadial"),
                                          sliderInput(inputId = "OTHERpart",
                                                        label = "Choose Data Partition",
                                                        value = 0.75, min = 0.6, max = 0.95),
                                          width = 2),
                                               
                                               # Main Panel 
                                               #  00             
                              mainPanel(
                                  tableOutput("OthersTable"),
                                  tableOutput("OthersByClass"),
                                  verbatimTextOutput("OthersOverall"),
                                  align = "center",
                                          width = 10)
                                   )
                          ),
               tabPanel("Documentation",
                        # Header or Title Panel
                        titlePanel(title = h2("Documentation", 
                                              align = "center")),
                        verbatimTextOutput("Info"),
                        htmlOutput("Documentation")
               )
               
               
               )
               
               
    )
  )
