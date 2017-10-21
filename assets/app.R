library(shiny)
library(visNetwork)
library(stringr)

organisation <- read.csv2("D:/Project Organisational Database/organisation.csv", stringsAsFactors = FALSE)
organisation$email <- paste0(gsub(" ","\\.",tolower(organisation$name)),"@embedded-pepper.com")
supervisors <- unique(organisation[,c("id","name")])
supervisors <- subset(supervisors, id %in% organisation$supervisor_id)
names(supervisors) <- c("supervisor_id","supervisor") 
organisation <- merge(organisation, supervisors, by = "supervisor_id", all.x=TRUE)
organisation$supervisor[is.na(organisation$supervisor)] <- ""
organisation <- organisation[order(organisation$name),]

filter_by <- c("jobtitle","team","department","supervisor")

ui <- fluidPage(
  #titlePanel("Organigram"),
  tags$hr(),
  htmlOutput("title"),
  #titlePanel(title=div(img(src="http://goodlifegarden.ucdavis.edu/blog/wp-content/uploads/2011/07/jala_pepper2.jpg", width = "10%"), "Embedded Pepper:", strong("who-is-who"))),
  tags$hr(),
  fluidRow(
    column(4, selectInput("name","Who are you looking for?",choices = organisation$name))  ),
  fluidRow(
    column(3, htmlOutput("picture")),
    column(5, htmlOutput("info"))
  ),
  tags$hr(),
  fluidRow(
    #column(3, selectInput("sub","Search by...",choices = names(organisation)[names(organisation) %in% filter_by])),
    column(3, selectInput("sub","Search by...",choices = str_to_title(filter_by))),
    uiOutput('columns')
  ),
  htmlOutput("teaminfo"),
  tableOutput("table"),
  tags$hr(),
  htmlOutput("organigram"),
  visNetworkOutput("network", height = "700px")
)

server <- function(input, output){
  output$title <- renderText({
    '<div> <h1><img src="http://goodlifegarden.ucdavis.edu/blog/wp-content/uploads/2011/07/jala_pepper2.jpg", width = "10%"> Embedded Pepper: <b>who-is-who</b> </h1></div>'
  })
  output$columns = renderUI({
    fluidRow(
      column(3, selectInput('selected', 'Select: ', unique(organisation[,tolower(input$sub)])))
    )
  })
  output$picture <- renderText({
    c('<img src="',organisation$photo_link[organisation$name == input$name],'" width = "300px", height = "auto">')
  })
  output$info <- renderText({
    c('<div style="margin-left:2cm;"><p><b>Name: </b>',organisation$name[organisation$name == input$name],'</p>',
      '<p><b>Position: </b>',organisation$jobtitle[organisation$name == input$name],'</p>',
      '<p><b>Team: </b>',organisation$team[organisation$name == input$name],'</p>',
      '<p><b>Department: </b>',organisation$department[organisation$name == input$name],'</p>',
      '<p><b>Email: </b>',organisation$email[organisation$name == input$name],'</p></div></br>')
  })
  output$teaminfo <- renderText({
    c('</br><p><b>',input$sub,'Info: </b>',input$selected)
  })
  output$table <- renderTable({
    organisation[organisation[,tolower(input$sub)] == input$selected,!names(organisation) %in% c("id","supervisor_id","photo_link","score")]
  })
  output$organigram <- renderText({
    c('</br><p><b>Organigram</b></p>')
  })
  output$network <- renderVisNetwork({
    # minimal example
    links <- organisation[,c("id","supervisor_id")]
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


