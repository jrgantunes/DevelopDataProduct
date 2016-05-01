library(shiny)
library(reshape2)
library(repmis)
library(ggrepel)
library(gridExtra)
library(RODBC)
library(plotly)
library(AppliedPredictiveModeling)
library(caret)
#library(rattle)
library(rpart.plot)
library(randomForest)
library(e1071)
library(ggbiplot)
library(dplyr)
library(kernlab)

shinyServer(
  function(input, output) {
    
    data(iris)
    TrainData <- iris[,1:4]
    TrainClasses <- iris[,5]
    v <- reactiveValues(data = NULL)
    observeEvent(input$goKNN,{v$preKNN <- input$inKNN}, ignoreNULL = FALSE)
    observeEvent(input$goKNN,{v$fold <- input$fold}, ignoreNULL = FALSE)
    observeEvent(input$goKNN,{v$repet <- input$repet}, ignoreNULL = FALSE)
    observeEvent(input$goDT, {v$DTpart <- input$DTpart}, ignoreNULL = FALSE)
    #observeEvent(input$goRArq,{v$aviaoRArq <- input$aviaoRArq})
    #observeEvent(input$goR16,{v$aviaoR16 <- input$aviaoR16})
    
    output$Info <- renderPrint({
      #cat("Extra info")
      writeLines("Summary\n
                 For the Developing Data Products Course Project, I have developed a Shiny Application for use with the Iris data in R.\n
                 App Purpose\n
                 The delivered Shiny App enables the exploration of the Edgar Anderson's Iris Data. This dataset is an excelent source to try and experience the Prediction functions learned during the Data Science Specialization course.\n
                 Please click below to find Extra Documentation and Explanation of the Shiny App (by this the help is considered inside the Shiny App)")
      
    })
    
    output$Documentation <- renderUI({
      
      tags$a(href = "http://rpubs.com/m2012049/IrisData", "Documentation and Instructions")
      
    })
    
    output$Pairs <- renderPlot({
      panel.pearson <- function(x, y, ...) {
        horizontal <- (par("usr")[1] + par("usr")[2]) / 2;
        vertical <- (par("usr")[3] + par("usr")[4]) / 2;
        text(horizontal, vertical, format(abs(cor(x,y)), digits=2))
      }
      pairs(iris[1:4], main = "Edgar Anderson's Iris Data", pch = 21, cex = 1.5, cex.axis = 1.5, cex.main = 1.5, bg = c("red","green3","blue")[unclass(iris$Species)], upper.panel=panel.pearson)
      pairs
    },height = 800)
    
    output$summary <- renderTable({
      summary(iris)
    })
    
    
    output$PCAs <- renderPlot({
      
    # log transform 
    log.ir <- log(iris[, 1:4])
    ir.species <- iris[, 5]
    
    # apply PCA - scale. = TRUE is highly 
    # advisable, but default is FALSE. 
    ir.pca <- prcomp(log.ir,
                     center = TRUE,
                     scale. = TRUE) 
    
    
    
    g <- ggbiplot(ir.pca, obs.scale = 1, var.scale = 1, 
                  groups = ir.species, ellipse = TRUE,
                  circle = TRUE)
    g <- g + scale_color_discrete(name = '')
    g <- g + theme(legend.direction = 'horizontal', 
                   legend.position = 'top')
    g
    
    }, height = 750)
    
    
    #output$aviaobySector <- renderPlot({
      
    #}, height = 1000)
  
    output$descrKNN <- renderPrint({
      
       
      cat("Cross-Validated (",v$fold,"fold, repeated",v$repet,"times) Confusion Matrix\n(entries are un-normalized aggregated counts)")

      })
    output$KNN <- renderTable({
    
      if(v$preKNN == "Regular"){knnPrePro <- c("center", "scale")}
      else{knnPrePro <- c("pca")}  
      
      
    knn <- train(TrainData, TrainClasses,
                     method = "knn",
                     preProcess = knnPrePro,
                     tuneLength = 10,
                     trControl = trainControl(method = "repeatedcv",
                                              number=v$fold,
                                              repeats=v$repet))
    
    XtabKNN <- confusionMatrix(knn, "none")
      
    newXtabKNN <- XtabKNN [[1]]
    
    newXtabKNN
    })
    
    output$DTree <- renderPlot({
      set.seed(1)
      toDivide <- createDataPartition(y = iris$Species, 
                                      p = v$DTpart,
                                      list = FALSE)
      dtTraining <- iris[toDivide,]
      dtTesting <- iris[-toDivide,]
      set.seed(1)
      modFitA1 <- rpart(Species ~ ., 
                        data = dtTraining, 
                        method = "class")
      #The resulting Decision Tree
      #fancyRpartPlot(modFitA1)
      plot(modFitA1, uniform = TRUE, main = "Decision Tree")
      text(modFitA1, use.n=TRUE, all=TRUE, cex=.8)
    })
      
    output$testDTree <- renderPrint({
      set.seed(1)
      toDivide <- createDataPartition(y = iris$Species, 
                                      p = v$DTpart,
                                      list = FALSE)
      dtTraining <- iris[toDivide,]
      dtTesting <- iris[-toDivide,]
      set.seed(1)
      modFitA1 <- rpart(Species ~ ., 
                        data = dtTraining, 
                        method = "class")
      
      predictionsA1 <- predict(modFitA1, dtTesting, type = "class")
      xtabDT <-confusionMatrix(predictionsA1, dtTesting$Species)
      
      print(xtabDT$overall)
      
    })  
    
    output$OthersTable <- renderTable({
     
      set.seed(1)
      toDivide <- createDataPartition(y = iris$Species, 
                                      p = input$OTHERpart,
                                      list = FALSE)
      
      dtTraining <- iris[toDivide,]
      dtTesting <- iris[-toDivide,]
      
      set.seed(1)
      modFitGBR <- train(dtTraining$Species ~ .,
                         data = dtTraining,
                         method = input$predictor, 
                         preProcess = c("center", "scale"), 
                         trControl = trainControl(method = "cv", 
                                                  number = 20))
      
      predictionsGBR <- predict(modFitGBR, newdata = dtTesting)
      otherALL <- confusionMatrix(predictionsGBR, dtTesting$Species)
      
      otherTABLE <- otherALL$table
      otherTABLE
    })
  
    output$OthersOverall <- renderPrint({
      
      set.seed(1)
      toDivide <- createDataPartition(y = iris$Species, 
                                      p = input$OTHERpart,
                                      list = FALSE)
      
      dtTraining <- iris[toDivide,]
      dtTesting <- iris[-toDivide,]
      
      set.seed(1)
      modFitGBR <- train(dtTraining$Species ~ .,
                         data = dtTraining,
                         method = input$predictor, 
                         preProcess = c("center", "scale"), 
                         trControl = trainControl(method = "cv", 
                                                  number = 20))
      
      predictionsGBR <- predict(modFitGBR, newdata = dtTesting)
      otherALL <- confusionMatrix(predictionsGBR, dtTesting$Species)
      
      otherOverall <- otherALL$overall
      otherOverall
    })
    
    
    output$OthersByClass <- renderTable({
      
      set.seed(1)
      toDivide <- createDataPartition(y = iris$Species, 
                                      p = input$OTHERpart,
                                      list = FALSE)
      
      dtTraining <- iris[toDivide,]
      dtTesting <- iris[-toDivide,]
      
      set.seed(1)
      modFitGBR <- train(dtTraining$Species ~ .,
                         data = dtTraining,
                         method = input$predictor, 
                         preProcess = c("center", "scale"), 
                         trControl = trainControl(method = "cv", 
                                                  number = 2))
      
      predictionsGBR <- predict(modFitGBR, newdata = dtTesting)
      otherALL <- confusionMatrix(predictionsGBR, dtTesting$Species)
      
      otherByClass <- otherALL$byClass
      otherByClass
    })
    
    
      
  })