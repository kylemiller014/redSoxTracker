# Required Libraries
library(httr)
library(jsonlite)
library(tibble)
library(stringr)
library(dplyr)
library(tidyr)
library(lubridate)

# Get the data you require
res <- GET('http://statsapi.mlb.com/api/v1/schedule/games/?sportId=1&startDate=2025-03-28&endDate=2025-09-29')

# Create raw datafram
data <- fromJSON(rawToChar(res$content), flatten = TRUE)
