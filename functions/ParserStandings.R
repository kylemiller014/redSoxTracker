library(httr)
library(jsonlite)
library(dplyr)

getTodaysStandings <- function() {
  # Create look up data frame for divisions and league designation
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
  
  # Check for column deltas
  allColumnNames <- unique(unlist(lapply(allTeamsDf, names)))
  
  # Align all data frames to same columns
  allTeamsDf_aligned <- lapply(allTeamsDf, function(df) {
    missing_cols <- setdiff(allColumnNames, names(df))
    
    # Add missing columns as NA
    for (col in missing_cols) {
      df[[col]] <- NA
    }
    
    # Ensure consistent column order
    df <- df[, allColumnNames]
    
    return(df)
  })
  
  
  # Create single dataframe to actually mess with
  standingsDf <- do.call(rbind, allTeamsDf_aligned)
  
  # Replace . with _ 
  colnames(standingsDf) <- str_replace_all(colnames(standingsDf), "\\.", "_")
  
  # Add columns for league and division
  standings <- merge(standingsDf, team_lookup, by = "team_name", all.x = TRUE)
  
  # Change column naming conventions
  # Standard Names:
  # [1] "season"                      "divisionRank"                "leagueRank"                  "sportRank"                   "gamesPlayed"                
  # [6] "gamesBack"                   "wildCardGamesBack"           "leagueGamesBack"             "springLeagueGamesBack"       "sportGamesBack"             
  # [11] "divisionGamesBack"           "conferenceGamesBack"         "lastUpdated"                 "runsAllowed"                 "runsScored"                 
  # [16] "divisionChamp"               "divisionLeader"              "hasWildcard"                 "clinched"                    "eliminationNumber"          
  # [21] "eliminationNumberSport"      "eliminationNumberLeague"     "eliminationNumberDivision"   "eliminationNumberConference" "wildCardEliminationNumber"  
  # [26] "wins"                        "losses"                      "runDifferential"             "winningPercentage"           "wildCardRank"               
  # [31] "wildCardLeader"              "team.id"                     "team.name"                   "team.link"                   "streak.streakCode"          
  # [36] "streak.streakType"           "streak.streakNumber"         "leagueRecord.wins"           "leagueRecord.losses"         "leagueRecord.ties"          
  # [41] "leagueRecord.pct"            "records.splitRecords"        "records.divisionRecords"     "records.overallRecords"      "records.leagueRecords"      
  # [46] "records.expectedRecords"   
  # New names for table rendering
  cleanerNames <- c("Team", "Season", "divisionRank", "leagueRank", "mlbRank", "GP", 
                    "GB", "WC GB", "LG GB", "SLG GB", "MLB GB", 
                    "DIV GB", "CONF GB", "Last Updated", "RA", "RS",
                    "divChampFlag", "divLeadFlag", "hasWildcard", "clinchedFlag", "eliminationNumber", 
                    "eliminationNumberMlb", "eliminationNumberLeague", "eliminationNumberDivision", "eliminationNumberConference", "wildCardEliminationNumber", 
                    "W", "L","DIFF", "PCT", "wildCardRank", 
                    "wcLeadFlag", "team_id", "team_link", "STRK", 
                    "streakType", "streakNum","leagueRecord_wins" ,"leagueRecord_losses", "leagueRecord_ties",
                    "leagueRecord_pct", "records_splitRecords", "records_divisionRecords", "records_overallRecords", "records_leagueRecords" , 
                    "records_expectedRecords", "League",  "Division")  
  
  # New order for df
  cleanerOrder <- c(
    # First row - primary table fields for initial display
    "Season", "Team", "W", "L", "PCT", "GB", "RS", "RA", "DIFF", "STRK", "Last Updated", "League", "Division",
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
    "records_splitRecords", "records_divisionRecords", "records_overallRecords","records_leagueRecords", "records_expectedRecords"
    )
  
  # Safer name handling
  valid_len <- min(length(colnames(standings)), length(cleanerNames))
  colnames(standings)[1:valid_len] <- cleanerNames[1:valid_len]
  
  # Safe ordering
  existingCols <- intersect(cleanerOrder, colnames(standings))
  standingsCleaned <- standings[, cleanerOrder, drop = FALSE]
  
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