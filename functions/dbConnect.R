library(RMySQL)
library(DBI)

GetDataFromDb <- function(host, port, username, password, sqlQuery, limit = -1){
    conn <- dbConnect(MySQL(), host=host, port=port, username=username, password=password)
    queryResult <- dbSendQuery(conn, sqlQuery)
    df <- dbFetch(queryResult, limit)
    dbClearResult(queryResult)
    dbDisconnect(conn)
    return(df)
}