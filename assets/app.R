library(shiny)
library(visNetwork)

organisation <- read.csv2("D:/Project Organisational Database/organisation.csv", stringsAsFactors = FALSE)
organisation$email <- paste0(gsub(" ","\\.",tolower(organisation$name)),"@embedded-pepper.com")
organisation <- organisation[order(organisation$name),]


ui <- fluidPage(
  titlePanel(title=div(img(src="http://goodlifegarden.ucdavis.edu/blog/wp-content/uploads/2011/07/jala_pepper2.jpg", width = "10%"), "Embedded Pepper:", strong("who-is-who"))),
  #titlePanel('Embedded Pepper'),
  tags$hr(),
  fluidRow(
    column(4, selectInput("name","Who are you looking for?",choices = organisation$name))  ),
  fluidRow(
    column(3, htmlOutput("picture")),
    column(5, htmlOutput("info"))
  ),
  tags$hr(),
  fluidRow(
    column(4, selectInput("team","What team are you looking for?",choices = unique(organisation$team)))#,
    #column(4, selectInput("position","What position are you looking for?",choices = c("",unique(organisation$job_title))))
  ),
  htmlOutput("teaminfo"),
  tableOutput("table"),
  tags$hr(),
  htmlOutput("organigram"),
  visNetworkOutput("network", height = "700px")
)

server <- function(input, output){
  #src = organisation$photo_link[organisation$name == input$name]
  output$picture <- renderText({
    c('<img src="',organisation$photo_link[organisation$name == input$name],'" width = "300px", height = "auto">')
  })
  output$info <- renderText({
    c('<p><b>Name: </b>',organisation$name[organisation$name == input$name],'</p>',
      '<p><b>Position: </b>',organisation$job_title[organisation$name == input$name],'</p>',
      '<p><b>Team: </b>',organisation$team[organisation$name == input$name],'</p>',
      '<p><b>Department: </b>',organisation$department[organisation$name == input$name],'</p>',
      '<p><b>Email: </b>',organisation$email[organisation$name == input$name],'</p></br>')
  })
  output$teaminfo <- renderText({
    c('</br><p><b>Team Info: </b>',input$team)
  })
  output$table <- renderTable({
    organisation[organisation$team == input$team,!names(organisation) %in% c("id","superior_id","photo_link","score")]
  })
  output$organigram <- renderText({
    c('</br><p><b>Organigram</b></p>')
  })
  output$network <- renderVisNetwork({
    # minimal example
    links <- organisation[,c("id","superior_id")]
    names(links)<- c("from","to")
    nodes <- organisation
    nodes$title <- paste0(nodes$name,", ",nodes$team,", ",nodes$department)
    nodes$label <- nodes$name
    nodes$color.background <- c("slategrey", "tomato", "gold", "green")[as.factor(nodes$department)]
    nodes$color.highlight.background <- "lightblue"
    nodes$size <- nodes$score * 10
    nodes$font.size <- 21
    visNetwork(nodes, links, main = " ") %>%
      visOptions(highlightNearest = TRUE, 
                 selectedBy = "department")
  })
}

shinyApp(ui, server)


