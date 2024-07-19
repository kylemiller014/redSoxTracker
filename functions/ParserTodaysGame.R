# URL Endpoint: 'http://statsapi.mlb.com/api/v1/schedule/games/?sportId=1'
# Required Libraries
library(httr)
library(jsonlite)

# Define function
# ParserTodayGame <- function() {}

res = GET("http://statsapi.mlb.com/api/v1/schedule/games/?sportId=1")
rawToChar(res$content)
data = fromJSON(rawToChar(res$content), flatten = TRUE)

names(data)
data$totalItems
data$dates$games

gamesDF <- data.frame(data$dates$games)
names(gamesDF)
teamsDf <- gamesDF$teams.away.score
gamesDF$teams

finalDf <- teamsDf[,1:2]
colnames(teamsDf)[c(1,2,3,4,6)] <- c("AWAY_TEAM_WINS", "AWAY_TEAM_LOSSES","AWAY_TEAM_PCT",
                               "AWAY_SCORE", "AWAY_NAME")
names(teamsDf)
#,"HOME_TEAM_WINS", "HOME_TEAM_LOSSES","HOME_TEAM_PCT","HOME_SCORE", "HOME_NAME"
awayTeam <- teamsDf[,1]
teamsDf[1,1]
select(teamsDf,away$leagueRecord$wins)
fixed <- teamsDf[,c(1,2)]
