# UI Source
# Required libraries
require(shiny)
require(shinydashboard)
require(shinyBS)
require(shinybusy)
require(shinyFeedback)
require(shinymanager)
require(shinyalert)
require(plotly)
require(DiagrammeR)
require(DT)

# Inactivity Function
inactivity <- "function idleTimer() {
    var t = setTimeout(logout, 120000);
    window.onmousemove = resetTimer;
    window.onmousedown = resetTimer;
    window.onclick = resetTimer;
    window.onscroll = resetTimer;
    function logout(){
        window.close();
    }
    function resetTime() {
        clearTimeout(t);
        t = setTimeout(logout, 120000);
    }
}"
#####DASHBOARD HEADER######
header <- dashboardHeader(title = 'SoxTracker')

#####DASHBOARD SIDEBAR######
sidebar <- dashboardSidebar(sidebarMenu(
    # Today's Game
    menuItem("Today's Action", tabName = 'currentGame', icon = icon("dashboard")),

    # Standings
    menuItem("Standings", tabName = 'seasonStandings', icon = icon("th")),
    
    # Stats
    menuItem("Stats", tabName = 'seasonStats', icon = icon("th")),
    
    # Schedule
    menuItem("Schedule", tabName = 'seasonSchedule', icon = icon("th")),

    # Prospect Rankings
    menuItem("Prospect Rankings", tabName = 'prospectRank', icon = icon("th"))
))

#####DASHBOARD MAIN BODY######
body <- dashboardBody(
  # Add link to CSS styles
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "syles.css")
  ),
  tabItems(
    # Today's Game
    tabItem(tabName = 'currentGame',
        fluidRow(
            valueBoxOutput("todaysDate"),
            valueBoxOutput("totalGamesOutput"),
            valueBoxOutput("redSoxCheck")
        ),
        # Dynamically create value boxes based on the number of games
        fluidRow(
          uiOutput("dynamicMatchup")
        )),

    # Standings
    tabItem(tabName = 'seasonStandings',
            fluidRow(
              # Filter options for leagues and division
              box(width = 4, title = "Filters", status = "primary", solidHeader = TRUE,
                  selectInput("leagueFilter", "Select League",
                              choices = c("MLB", "AL", "NL"), selected = "AL"),
                  selectInput("divisionFilter", "Select Division",
                              choices = c("All", "Central", "East", "West"), selected = "East")
                  ),
              # Render the standings table
              box(width = 8, title = "MLB Standings", status = "info", solidHeader = TRUE,
                  DTOutput("standingsTable"))
            )),
    
    # Stats
    tabItem(tabName = 'seasonStats'),
    
    # Schedule
    tabItem(tabName = 'seasonSchedule'),

    # Prospect Rankings
    tabItem(tabName = 'prospectRank')
))

#####RENDER UI######
ui <- secure_app(tags_top = tags$img(src = 'app_logo.jpeg', height = 400, width =400),
        head_auth = tags$script(inactivity),
        dashboardPage(title = 'Track the Sox', header, sidebar, body, skin = 'black'))