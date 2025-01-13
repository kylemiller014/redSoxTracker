# URL Endpoint: 'http://statsapi.mlb.com/api/v1/schedule/games/?sportId=1'
# Required Libraries
library(httr)
library(jsonlite)
library(tibble)
library(stringr)
library(dplyr)
library(tidyr)

# Define function
ParserTodayGame <- function() {
  # Initial GET Call to Today's Game API
  res <- GET("http://statsapi.mlb.com/api/v1/schedule/games/?sportId=1")
  
  # Create raw datafram
  data <- fromJSON(rawToChar(res$content), flatten = TRUE)
  
  # Convert raw data frame to unlisted tibble
  dataRaw <- enframe(unlist(data))
  
  # Replace . with _
  rgxDelim <- "\\."
  dataRaw$name <- str_replace_all(dataRaw$name, rgxDelim, "_")
  
  # Create list of unique columns
  # Remove digits
  cleanedNames <- str_replace_all(dataRaw$name, "[:digit:]", "")
  
  # Unique column names
  uniqueColumns <- unique(cleanedNames)
  
  # Columns for specific game information
  todaysGamesColumns <- uniqueColumns[11:65]
  
  # Determine number of games happening today
  numGames <- dataRaw[dataRaw$name == "totalItems",]

  # Loop through each column name
  # Create a new dataframe with column names
  parsedTodaysGames <- data.frame(matrix(nrow = as.integer(numGames$value), ncol = length(todaysGamesColumns)))
  colnames(parsedTodaysGames) <- todaysGamesColumns
  
  for(i in 1:length(todaysGamesColumns)){
    values <- dataRaw %>%
      filter(grepl(todaysGamesColumns[i], dataRaw$name))
    if (length(values$value) > as.integer(numGames$value)){
      values <- values[1:as.integer(numGames$value),]
    }
    parsedTodaysGames[,i] <- values$value
  }
  return(parsedTodaysGames)
}
