library(RmySQL)
library(DBI)
library(expss)
library(tidyr)
source("./functions/ParserTodaysGame.R")

dataFrameToDataBase <- function(userSchema, userTableName){
    # Get database credentials
    dbCreds <- config::get()
    host <- dbCreds$ip
    port <- dbCreds$port
    username <- dbCreds$user
    password <- dbCreds$pass

    # Run ParserTodaysGame
    df <- ParserTodayGame()

    # Get column names for sql table
    colNames <- colnames(df)

    # Get last row in data frame
    endRow <- nrow(df)

    # Establish data connection
    conn <- dbConnect(MySQL(), host = host, port = port, username = username, password = password)
    # if(dbExistsTable(conn, Id(schema = userSchema, table = userTableName)) == TRUE)
    #   {
    #   print("Table already exists... check schema/table name provided")
    #   }
    # else
    #   {
    #   dbCreateTable(conn,Id(schema = userSchema, table = userTableName),df) 
    #   }

    # loop through each row in dataframe and insert into database
    for(i in 1:endRow){
        query <- paste0(
            "INSERT INTO shiny.offlineMode_0830(",
            paste0(colNames, collapse = ","),") VALUES(",
            paste0(c(sQuote(df[i,1], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,2], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,3], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,4], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,5], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,6], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,7], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,8], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,9], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,10], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,11], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,12], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,13], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,14], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,15], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,16], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,17], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,18], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,19], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,20], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,21], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,22], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,23], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,24], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,25], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,26], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,27], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,28], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,29], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,30], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,31], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,32], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,33], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,34], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,35], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,36], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,37], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,38], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,39], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,40], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,41], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,42], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,43], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,44], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,45], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,46], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,47], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,48], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,49], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,50], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,51], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,52], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,53], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,54], options(useFancyQuotes = FALSE)),",",
                    sQuote(df[i,55], options(useFancyQuotes = FALSE))
            ), collapse = " "),");")

        # Send query to database
        dbSendQuery(conn, query)
    }
    # Close out database connection
    dbDisconnect(conn)
}