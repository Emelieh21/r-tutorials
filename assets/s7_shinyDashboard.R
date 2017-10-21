#S7Data shinyApp
setwd("D:/s7-data-2017-09-21/datafiles")
input.files <- list.files()

#df <- readRDS("s7data_full.rds")
df <- data.frame(NA,NA,NA)
names(df) <- c("V2","V4","V6")

library(shiny)
library(ggplot2)
library(shinydashboard)
library(data.table)
library(shinycssloaders)

options(shiny.maxRequestSize=600*1024^2) 

ui <- dashboardPage(skin = "black",
  #dashboardHeader(title = "S7 Logger"),#, disable = TRUE),
  dashboardHeader(#title = HTML('<img src="images.png", width = "100px", height = "auto">')),
    title = tags$a(href='http://www.relayr.io',
                   tags$img(src="images.png", style="width:100px;height:auto;"))),
  dashboardSidebar(#width = "270px",
    #tags$hr(),
    tags$br(),
    strong(textOutput("title1"),style="text-align:center;"),
    # tags$style("
    #   .checkbox { /* checkbox is a div class*/
    #            margin-bottom:0px; /*set the margin, so boxes don't overlap*/
    #            }"),
    checkboxInput("preview","Convert preview only"),
    fileInput('file_converter','Choose ZIP or LOG to convert: ',
              accept=c('.zip', '.log')),
    #checkboxInput("preview","Convert preview only"),
    span(textOutput("debug"), style="text-align:center;color:green"),
    tags$hr(),
    strong(textOutput("title2"),style="text-align:center;"),
    #actionButton("convert","Convert"),
    fileInput('file_select', 'Choose RDS File',
              accept=c('.rds')),
    #actionButton("upload", "Upload"),
    #selectInput("file_select", label = "Select an input file: ", choices = c(input.files,"Upload new file")),
    #sliderInput("data_select", label = "Select data range: ", min = 0, max = nrow(df), value = c(0,500)),
    #uiOutput("data_selection"),
    #tags$hr(),
    #uiOutput("variable_selection"),
    tags$hr(),
    strong(textOutput("title3"),style="text-align:center;"),
    selectInput("variable_select", label = "Select a variable: ", choices = unique(df$V4), multiple=TRUE),
    actionButton("go", "Draw the plot")
  ),
  dashboardBody(
    uiOutput("logo"),
    #strong(textOutput("title4"),style="text-align:center;font-size=80px;"),
    tags$br(),
    sliderInput("data_select", label = "Select data range: ", min = 0, max = nrow(df), value = c(0,500), width="175%"),
    withSpinner(plotOutput("visualization"))
  )
)

server <- function(input, output, session){
  output$logo <- renderUI({
    HTML('<center><img src="logger_trans.png", height="70px"><center>')
  })
  output$title1 <- renderText({"Data Conversion"})
  output$title2 <- renderText({"Data Input"})
  output$title3 <- renderText({"Variable Selection"})
  output$title4 <- renderText({"S7 LOGGER"})
  myData <- reactive({
    #if(input$upload == 0){return()}
    req(input$file_select)
    inFile <- input$file_select
    #if (is.null(inFile)) return(df)
    isolate({
      #input$upload
      df <- readRDS(inFile$datapath)
      updateSelectInput(session, inputId = "variable_select", label = "Select a variable: ", choices = unique(df$V4))
      updateSliderInput(session, inputId = "data_select", label = "Select data range: ", min = 0, max = nrow(df), value = c(0,500))
      return(df)
    })
  })
  convert <- reactive({
    req(input$file_converter)
    inFile <- input$file_converter
    #input$convert
    isolate({
      if (grepl(".zip",filename)==TRUE){
        message("Unzipping file...")
        filename <- gsub(".zip",".log",as.character(inFile$name))
        unzip(zipfile = inFile$datapath, filename)
      }
      if (input$preview == TRUE){
        chunk_size=10000
        i=0
        container=data.frame()
        while(TRUE){
          if (i == 0){
            chunk=fread(filename, showProgress = TRUE, skip = 9, sep=" ",nrows=chunk_size)
          } else {
            chunk=fread(filename, showProgress = TRUE, sep=" ",nrows=chunk_size, skip=(chunk_size*i)+9)
          }
          chunk <- subset(chunk, select=c("V1","V3","V5"))
          names(chunk) <- c("V2","V4","V6")
          chunk$V2 <- as.POSIXct(paste0(as.character(Sys.Date())," ",chunk$V2))
          container <- rbind(container, chunk)
          print(i)
          i = i + 1
          if (i == 10) {
            saveRDS(container, gsub(".log",".rds",filename))
            message("RDS saved.")
            break
          }
        } 
      } else {
        chunk_size=10000
        i=0
        container=data.frame()
        while(TRUE){
          if (i == 0){
            chunk=fread(filename, showProgress = TRUE, skip = 9, sep=" ",nrows=chunk_size)
          } else {
            chunk=fread(filename, showProgress = TRUE, sep=" ",nrows=chunk_size, skip=(chunk_size*i)+9)
          }
          chunk <- subset(chunk, select=c("V1","V3","V5"))
          names(chunk) <- c("V2","V4","V6")
          chunk$V2 <- as.POSIXct(paste0(as.character(Sys.Date())," ",chunk$V2))
          container <- rbind(container, chunk)
          print(i)
          i = i + 1
        }
        message("Starting saving now...")
        saveRDS(container, gsub(".log",".rds",filename))
        message("RDS saved.")
      }
      confirm <- "Conversion successful!"
      return(confirm)
    })
  })
  # observeEvent(input$select_file, {
  #   df <- myData()
  # })
  # output$data_selection <- renderUI({
  #   df <- myData()
  #   sliderInput("data_select", label = "Select data range: ", min = 0, max = nrow(df), value = c(0,500))
  # })
   output$debug <- renderText({
     convert()
     #paste0("colnames df: ",paste(colnames(df),collapse=", ")," & nrow: ",nrow(df))
  })
  # output$variable_selection <- renderUI({
  #   df <- myData()
  #  selectInput("variable_select", label = "Select a variable: ", choices = unique(df$V4), multiple=TRUE)
  # })
  output$visualization <- renderPlot({
    df <- myData()
    input$go
    isolate(
      ggplot(subset(df[c(input$data_select[1]:input$data_select[2]),], V4 %in% input$variable_select), aes(x=V2, y=V6, fill = V4, color=V4)) +
        geom_line() +
        ggtitle(paste0("S7 Log Data ",as.character(min(df$V2))," - ",as.character(max(df$V2)))) +
        xlab("Time") +
        ylab("Value")
    )
  })
}

shinyApp(ui, server)
