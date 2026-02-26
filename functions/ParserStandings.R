library(httr)
library(jsonlite)
library(dplyr)

getTodaysStandings <- function() {
  # Create look up data frame for divisions and league designators
  team_lookup <- data.frame(
    # List of all the team names in no particular order
    team_name = c(
      "Yankees", "Red Sox", "Blue Jays", "Rays", "Orioles", "Guardians", "White Sox", "Twins", "Royals", 
      "Astros", "Rangers", "Mariners", "Angels", "Athletics", "Mets", "Phillies",
      "Braves", "Marlins", "Mets", "Nationals", "Pirates", "Cubs", "Cardinals", "Brewers",
      "Dodgers", "Giants", "Padres", "Diamondbacks", "Rockies", "Reds"
    ),
    league = c(
      rep("AL", 14), rep("NL", 16)
    ),
    division = c(
      "East","East","East","East","East","Central","Central","Central", "Central",
      "West","West","West","West","West",
      "East","East","East","East","East","East","Central","Central","Central","Central",
      "West","West","West","West","West","Central"
    ),
    stringsAsFactors = FALSE
  )
  # Build URL based on todays date
  url <- paste0("https://statsapi.mlb.com/api/v1/standings?sportId=1&leagueId=103,104&standingsType=regularSeason")
  
  # GET request
  res <- GET(url)
  
  # An attempt at error handling
  if (res$status_code != 200) {
    warning("Failed to fetch MLB standings (status ", res$status_code, ")")
    return(NULL)
  }
  
  # Parse JSON
  data <- fromJSON(rawToChar(res$content), flatten = TRUE)
  
  # Create empty list for data frames
  allTeamsDf <- list()
  
  # Filter to df within df within df...
  teamRecordsByDiv <- data$records$teamRecords
  
  # Combine all divisions into one data frame
  for(i in 1:length(teamRecordsByDiv)){
    df <- as.data.frame(teamRecordsByDiv[i])
    allTeamsDf[[length(allTeamsDf) + 1]] <- df
  }
  
  # Create single dataframe to actually mess with
  standingsDf <- do.call(rbind, allTeamsDf)
  
  # Replace . with _ 
  colnames(standingsDf) <- str_replace_all(colnames(standingsDf), "\\.", "_")
  
  # Add columns for league and divison
  standings <- merge(standingsDf, team_lookup, by = "team_name", all.x = TRUE)
  
  return(standings)
}