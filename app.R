# App Logic 
library(shiny)
library(shinymanager)
library(shinydashboard)
library(plotly)
library(ggplot2)
library(shinyBS)
library(shinybusy)
library(shinyFeedback)
library(shinythemes)
library(RMySQL)
library(DBI)
library(dplyr)
library(tidyverse)
library(tidyselect)
library(skimr)
library(qcc)
library(compareDF)
library(scales)
library(arsenal)
library(htmlwidgets)
library(reactlog)
library(DiagrammeR)

source("ui.R")
source("server.R")

# Disconnect all db connections
onStop(function(){
  dbDisconnect(conn)
})

# Get credentials from config file
dbCreds <- config::get()

# Set IP host address
options("shiny.host" = dbCreds$shinyHost)

# Set port number
options("shiny.port" = dbCreds$shinyPort)

if (interactive()){
  runApp(host = getOption("shiny.host"),
  port = getOption("shiny.port"),
  shinyApp(ui = ui, server = server))
}