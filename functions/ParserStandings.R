library(httr)
library(jsonlite)
library(dplyr)

getTodaysStandings <- function() {
  # Create look up data frame for divisions and league designators
  team_lookup <- data.frame(
    # List of all the team names in no particular order
    team_name = c(
    "Angels", "Astros", "Athletics", "Blue Jays", "Braves", "Brewers", "Cardinals", "Cubs", "D-backs", "Dodgers", "Giants", "Guardians",
    "Mariners", "Marlins", "Mets", "Nationals", "Orioles", "Padres", "Phillies", "Pirates", "Rangers", "Rays",  "Red Sox",
     "Reds" , "Rockies", "Royals", "Tigers", "Twins", "White Sox", "Yankees"  
    ),
    league = c(
      "AL", "AL", "AL", "AL", "NL", "NL", "NL", "NL", "NL", "NL", "NL", "AL",
      "AL", "NL", "NL", "NL", "AL", "NL", "NL", "NL", "AL", "AL", "AL",
      "NL", "NL", "AL", "AL", "AL", "AL", "AL"
    ),
    division = c(
      "West", "West", "West", "East", "East", "Central", "Central", "Central", "West", "West", "West", "Central",
      "West", "East", "East", "East", "East", "West", "East", "Central", "West", "East", "East",
      "Central", "West", "Central", "Central", "Central", "Central", "East"
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
  
  # Add columns for league and division
  standings <- merge(standingsDf, team_lookup, by = "team_name", all.x = TRUE)
  
  # Change column namining conventions
  # Standard Names:
  # [1] "team_name"                   "season"                      "divisionRank"                "leagueRank"                  "wildCardRank"               
  # [6] "sportRank"                   "gamesPlayed"                 "gamesBack"                   "wildCardGamesBack"           "leagueGamesBack"            
  # [11] "springLeagueGamesBack"       "sportGamesBack"              "divisionGamesBack"           "conferenceGamesBack"         "lastUpdated"                
  # [16] "runsAllowed"                 "runsScored"                  "divisionChamp"               "divisionLeader"              "wildCardLeader"             
  # [21] "hasWildcard"                 "clinched"                    "eliminationNumber"           "eliminationNumberSport"      "eliminationNumberLeague"    
  # [26] "eliminationNumberDivision"   "eliminationNumberConference" "wildCardEliminationNumber"   "wins"                        "losses"                     
  # [31] "runDifferential"             "winningPercentage"           "team_id"                     "team_link"                   "leagueRecord_wins"          
  # [36] "leagueRecord_losses"         "leagueRecord_ties"           "leagueRecord_pct"            "records_splitRecords"        "records_divisionRecords"    
  # [41] "records_overallRecords"      "records_leagueRecords"       "league"                      "division"      
  # New names for table rendering
  cleanerNames <- c("Team", "Season", "divisionRank", "leagueRank", "wildCardRank", 
                    "mlbRank", "GP", "GB", "WC GB", "LG GB", 
                    "SLG GB", "MLB GB", "DIV GB", "CONF GB", "Last Updated", 
                    "RA", "RS", "divChampFlag", "divLeadFlag", "wcLeadFlag",
                    "hasWildcard", "clinchedFlag", "eliminationNumber", "eliminationNumberMlb", "eliminationNumberLeague",
                    "eliminationNumberDivision", "eliminationNumberConference", "wildCardEliminationNumber", "W", "L",
                    "DIFF", "PCT", "team_id", "team_link", "leagueRecord_wins" ,"leagueRecord_losses", "leagueRecord_ties",
                    "leagueRecord_pct", "records_splitRecords", "records_divisionRecords", "records_overallRecords",
                    "records_leagueRecords" , "League",  "Division")  
  
  # New order for df
  cleanerOrder <- c(
    # First row - primary table fields for initial display
    "Season", "Team", "W", "L", "PCT", "GB", "RS", "RA", "DIFF", "Last Updated", "League", "Division",
    # Ranks Breakdown
    "divisionRank", "leagueRank", "wildCardRank", "mlbRank",
    # Games Back Breakdown
    "WC GB", "LG GB", "SLG GB", "MLB GB", "DIV GB", "CONF GB",
    # Flags
    "divChampFlag", "divLeadFlag", "wcLeadFlag",  "hasWildcard", "clinchedFlag",
    # Elimination Numbers
    "eliminationNumber", "eliminationNumberMlb", "eliminationNumberLeague", "eliminationNumberDivision", "eliminationNumberConference", "wildCardEliminationNumber",
    # Team IDs
    "team_id", "team_link",
    # League Stats
    "leagueRecord_wins" ,"leagueRecord_losses", "leagueRecord_ties", "leagueRecord_pct",
    # Splits
    "records_splitRecords", "records_divisionRecords", "records_overallRecords","records_leagueRecords"
    )
  
  # Set new names
  colnames(standings) <- cleanerNames
  
  # Set new ordering
  standingsCleaned <- standings[, cleanerOrder]
  
  # Final cleaning of the data frame
  standingsFinal <- standingsCleaned %>%
    # Clean up any dashes passed by the API
    mutate(
      across(where(is.character),
             ~ replace(.x, .x == "-", "0"))
    ) %>%
    # Convert data types to correct values
    mutate(
      # To Numeric
      across(c("PCT","GB", "WC GB", "LG GB", "SLG GB", "MLB GB", "DIV GB", "CONF GB",
               "eliminationNumber", "eliminationNumberMlb", "eliminationNumberLeague", 
               "eliminationNumberDivision", "eliminationNumberConference", "wildCardEliminationNumber",
               "leagueRecord_pct"), as.numeric),
      # To Integer
      across(c( "divisionRank", "leagueRank", "wildCardRank", "mlbRank"), as.integer)
    )
  
  return(standingsFinal)
}