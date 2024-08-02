# Server Source
require(shiny)
require(shinymanager)
require(shinydashboard)
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

    # Get today's game information
    getTodaysGames <- eventReactive(result_auth$authorized == TRUE, {
      ParserTodayGame()
      })
    
    # Render Value Box 1: "todaysDate"
    output$todaysDate <- renderValueBox({
      todaysDF <- getTodaysGames()
      currentDate <- as.POSIXct(todaysDF[1,7])
      valueBox(currentDate, "Today's Date", icon = icon("calendar"),
               color = 'blue', width = 4)
    })
    
    # Render Value Box 2: "totalGamesOutput"
    output$totalGamesOutput <- renderValueBox({
      todaysGames <- getTodaysGames()
      currentGames <- nrow(todaysGames)
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
}