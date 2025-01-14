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
require(shinyalert)
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
require(stringr)

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
        return(credentials)
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
      # Update data presented to users every 10000 milliseconds
      invalidateLater(60000)
      df <- ParserTodayGame()
      if(nrow(df) < 1){
        shinyalert("API returned NULL... either it's the offseason or my code is broken... Time travel back to August 30th, 2024 while I get this figured out...", type = "error")
        df <- GetDataFromDb(dbCreds$ip, dbCreds$port, dbCreds$user, dbCreds$pass, "SELECT * FROM shiny.offlinemode_0830;")
      }
      df
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
      currentGames <<- nrow(todaysGames)
      valueBox(currentGames, "Total Games Today", icon = icon("calendar"),
               color = 'blue', width = 4)
    })
    
    # Render Value Box 3: "redSoxCheck"
    output$redSoxCheck <- renderValueBox({
      redSoxDf <- getTodaysGames()
      awayTeam <- grepl('Boston Red Sox' , redSoxDf$dates_games_teams_away_team_name)
      homeTeams <- grepl('Boston Red Sox' ,redSoxDf$dates_games_teams_home_team_name)
      
      # Check if the Red Sox are active today
      if(!all(awayTeam) || !all(homeTeam)){
        redSoxPlaying <- 'YES'
        redSoxColor <- 'green'
      } else{
        redSoxPlaying <- 'NO'
        redSoxColor <- 'red'
      }

      valueBox(redSoxPlaying, "RedSox in Action?", icon = icon("th"),
               color = redSoxColor, width = 4)
    })
    
    # Dynamically render daily match ups
    #dynamically create the right number of htmlOutput
    # renderUI
    output$dynamicMatchup <- renderUI({
      dailyDf <- getTodaysGames()
      dailyCount <- nrow(dailyDf)
      dailyMatchupList <- lapply(1:dailyCount, function(i) {
        matchupList <- paste0("matchup", i)
        valueBoxOutput(matchupList)
      })
      
      tagList(dailyMatchupList)
    }) 
    
    for (i in 1:16) {
      local({
        thisI <- i
        matchupName <- paste0("matchup", thisI)
        
        output[[matchupName]] <- renderUI({
          # Concatenate team names and scores
          # Red Sox vs. Atlanta Braves
          # Score
          # Status (in progress, delayed, coming soon, etc.)
          oneMoreTime <- getTodaysGames()
          gameStatus <- oneMoreTime[thisI, 30]
          homeTeamName <- oneMoreTime[thisI, 50]
          homeTeamScore <- oneMoreTime[thisI,43]
          homeTeamWin <- oneMoreTime[thisI,46]
          homeTeamLoss <- oneMoreTime[thisI,47]
          awayTeamName <- oneMoreTime[thisI, 41]
          awayTeamScore <- oneMoreTime[thisI,34]
          awayTeamWin <- oneMoreTime[thisI,37]
          awayTeamLoss <- oneMoreTime[thisI,38]
          if(gameStatus == "In Progress"){
            gameScore <- paste0(gameStatus, ": ", awayTeamScore, " - ", homeTeamScore)
          } else{
            gameScore <- paste0(gameStatus ,": 0 - 0")
          }
          namingConvention <- paste0(awayTeamName,"(",awayTeamWin," - ",awayTeamLoss,")"," @ ",
                                     homeTeamName,"(",homeTeamWin," - ",homeTeamLoss,")")
          if(gameStatus == "In Progess"){
            colorCheck <- "lightblue"
          } else if (gameStatus == "Scheduled"){
            colorCheck <- "olive"
          } else if(gameStatus == "Pre-Game") {
            colorCheck <- "orange"
          } else{
            colorCheck <- "red"
          }
          
          valueBox(
            gameScore,
            namingConvention,
            width = 20,
            color = colorCheck
          )
        })
      })
    }
}