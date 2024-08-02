# Server Source
require(shiny)
require(shinymanager)
require(shinydashboard)
require(shinydashboard)
require(shinyWidgets)
require(plotly)
require(ggplot2)
require(shinyBS)
require(shinybusy)
require(shinyFeedback)
require(shinythemes)
require(RMySQL)
require(DBI)
require(dplyr)
require(tidyverse)
require(tidyselect)
require(skimr)
require(qcc)
require(compareDF)
require(scales)
require(arsenal)
require(htmlwidgets)
require(reactlog)
require(DiagrammeR)

# Import additional functions
source("./functions/dbConnect.R")
source("./functions/dataClean.R")
source("./functions/columnDataTypes.R")
source("./functions/ParserTodaysGame.R")

# Output directory for cleaned data
opf <- "./data"

# Output directory for plots
htmlOpf <- "./graphics"

# All the logic lives here...
server <- function(input, output, session){
    ##########GET CREDENTIALS############
    dbCreds <- config::get()

    # Set IP host address
    options("shiny.host" = dbCreds$shinyHost)

    # Set port number
    options("shiny.port" = dbCreds$shinyPort)

    # Function to pull validated credentials from database
    getCredentials <- function(ip, port, username, password){
        credentials <- GetDataFromDb(
            host = dbCreds$ip, 
            port = dbCreds$port, 
            username = dbCreds$user, 
            password = dbCreds$pass, 
            sqlQuery = 'SELECT username, password FROM creds.userInfo;', 
            limit = -1)
    }

    # Inactivity Function
    inactivity <- "function idleTimer() {
    var t = setTimeout(logout, 1200000);
    window.onmousemove = resetTimer;
    window.onmousedown = resetTimer;
    window.onclick = resetTimer;
    window.onscroll = resetTimer;
    function logout(){
        window.close();
        }
    function resetTime() {
        clearTimeout(t);
        t = setTimeout(logout, 1200000);
        }
    }"

    ##########USER INPUT DEFINITONS############
    #genericExample <- reactive({
        #input$genericExample
    #})

    ##########GENERIC FUNCTIONS############
    # General functions and defintions used throughout the application
    # Store plotly graphics locally if desired
    session_store <- reactiveValues()

    # Get user creds from database
    credentials <- getCredentials()

    # Check creds
    result_auth <- secure_server(check_credentials = check_credentials(credentials))

    # Get today's game information [STATIC]
    # getTodaysGames <- eventReactive(result_auth$authorized == TRUE, {
    #   ParserTodayGame()
    #   })
    
    # Get today's game information [DYNAMIC]
    getTodaysGames <- reactivePoll(10000, session,
                                   checkFunc = function() {Sys.time()},
                                   valueFunc = function() {ParserTodayGame() })
    
    # Dynamically get the number of games happening currently
    getCurrentGameCount <- reactive(
      numGames <- nrow(getTodaysGames())
    )
    
    # Render Value Box 1: "todaysDate"
    output$todaysDate <- renderValueBox({
      todaysDF <- getTodaysGames()
      currentDate <- as.POSIXct(todaysDF[1,7])
      valueBox(currentDate, "Today's Date", icon = icon("calendar"),
               color = 'blue', width = 4)
    })
    
    # Render Value Box 2: "totalGamesOutput"
    output$totalGamesOutput <- renderValueBox({
      # todaysGames <- getTodaysGames()
      currentGames <- getCurrentGameCount()
      valueBox(currentGames, "Total Games Today", icon = icon("calendar"),
               color = 'blue', width = 4)
    })
    
    # Render Value Box 3: "redSoxCheck"
    output$redSoxCheck <- renderValueBox({
      redSoxDf <- getTodaysGames()
      redSoxPlaying <- 'YES'
      valueBox(redSoxPlaying, "RedSox in Action?", icon = icon("th"),
               color = 'green', width = 4)
    })
    
    # Output dynamic value boxes
    output$dynamic_matchups <- renderUI({
      num <- getCurrentGameCount()
      matchupList <- lapply(1:num, function(i) {
        valueBoxOutput(paste0("matchup", i))
      })
      do.call(fluidRow, matchupList)
    })
    
    # Output dynamic details for each value box
    output$dynamic_details <- renderUI({
      num <- getCurrentGameCount()
      detailList <- lapply(1:num, function(i) {
        div(id = paste0("details", i),
            h2(paste("Team", i*2-1, "vs Team", i*2, "Matchup Comparison")),
            actionButton(paste0("close",i), "Close"),
            plotOutput(paste0("plot",i))
            )
      })
      do.call(tagList, detailList)
    })
    
    # Observe event to create all the value box and associated details
    observe({
      num <- getCurrentGameCount()
      for (i in 1:num) {
        local({
          j <- 1
          observeEvent(input[[paste0("matchup",j,"_box")]], {
            show(paste0("details",j))
          })
          
          observeEvent(input[[paste0("close", j)]], {
            hide(paste0("details", j))
          })
          
          output[[paste0("matchup", j)]] <- renderValueBox({
            scores <- scoresFunction
            valueBox(
              value = paste(scores[[paste0("team",j*2-1, "_score")]], "vs", scores[[paste0("team",j*2,"_score")]]),
              subtitle = paste(scores[[paste0("team", j*2-1)]], "vs", scores[[paste0("team", j*2)]]),
              icon = icon("futbol-o"),
              color = sample(c("blue", "green", "red"), 1),
              href = "#"
            )
          })
          
          output[[paste0("plot", j)]] <- renderPlotly({
            
          })
        })
      }
    })
}