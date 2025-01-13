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
header <- dashboardHeader(title = 'RedSox Tracker')

#####DASHBOARD SIDEBAR######
sidebar <- dashboardSidebar(sidebarMenu(
    # Today's Game
    menuItem("Today's Action", tabName = 'currentGame', icon = icon("dashboard")),

    # Schedule
    menuItem("Schedule", tabName = 'seasonSchedule', icon = icon("th")),

    # Prospect Rankings
    menuItem("Prospect Rankings", tabName = 'prospectRank', icon = icon("th")),

    # Standings
    menuItem("Standings", tabName = 'seasonStandings', icon = icon("th")),

    # Stats
    menuItem("Stats", tabName = 'seasonStats', icon = icon("th")),

    # Field Rendering
    menuItem("Fenway", tabName = 'fenwayDetails', icon = icon("th"))
))

#####DASHBOARD MAIN BODY######
body <- dashboardBody(tabItems(
    # Today's Game
    tabItem(tabName = 'currentGame',
        fluidRow(
            valueBoxOutput("todaysDate"),
            valueBoxOutput("totalGamesOutput"),
            valueBoxOutput("redSoxCheck")
        )),

    # Schedule
    tabItem(tabName = 'seasonSchedule'),

    # Prospect Rankings
    tabItem(tabName = 'prospectRank'),

    # Standings
    tabItem(tabName = 'seasonStandings'),

    # Stats
    tabItem(tabName = 'seasonStats'),

    # Field Rendering
    tabItem(tabName = 'fenwayDetails')
))

#####RENDER UI######
ui <- secure_app(tags_top = tags$img(src = 'app_logo.jpeg', height = 400, width =400),
        head_auth = tags$script(inactivity),
        dashboardPage(title = 'Track the Sox', header, sidebar, body, skin = 'black'))