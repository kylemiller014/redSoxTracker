# App Logic 
library(shiny)
library(shinymanager)
library(plotly)
library(ggplot2)
# source("ui.R")
# source("server.R")

ui <- fluidPage(
  "Hello, world!"
)
server <- function(input, output, session) {
}

shinyApp(ui, server)