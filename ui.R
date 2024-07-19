# UI Source
# Required libraries
require(shiny)
require(shinydashboard)
require(shinyBS)
require(shinybusy)
require(shinyFeedback)
require(shinymanager)
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
header <- dashboardHeader(title = 'How are the Sox Looking...?')

#####DASHBOARD SIDEBAR######
sidebar <- dashboardSidebar(sidebarMenu(
    # Today's Game
    menuItem("Today's Action", tabname = 'currentGame', icon = icon("dashboard"), startExpanded = TRUE),

    # Schedule
    menuItem("Schedule", tabname = 'seasonSchedule', icon = icon("th")),

    # Prospect Rankings
    menuItem("Prospect Rankings", tabname = 'prospectRank', icon = icon("th")),

    # Standings
    menuItem("Standings", tabname = 'seasonStandings', icon = icon("th")),

    # Stats
    menuItem("Stats", tabname = 'seasonStats', icon = icon("th")),

    # Field Rendering
    menuItem("Fenway", tabname = 'fenwayDetails', icon = icon("th"))
))

#####DASHBOARD MAIN BODY######
body <- dashboardBody(tabItems(
    # Today's Game
    tabItem(tabName = 'currentGame'),

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
#####DASHBOARD HEADER######

#####RENDER UI######
ui <- secure_app(tags_top = tags$img(src = 'app_logo.jpg', height = 400, width =400),
        head_auth = tags$script(inactivity),
        dashboardPage(title = 'redsoxTracker', header, sidebar, body))