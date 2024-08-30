library(RmySQL)
library(DBI)
library(expss)
library(tidyr)
source("./functions/ParserTodaysGame.R")

dataFrameToDataBase <- function(){
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

    # Get last row in dataframe
    endRow <- nrow(df)

    # Establish data connection
    conn <- dbConnect(MySQL(),host,port,username,password)
    # loop through each row in dataframe and insert into database
    for(i in 1:endRow){
        query <- paste0(
            "INSERT INTO shiny.data_for_testing (",
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
                    sQuote(df[i,21], options(useFancyQuotes = FALSE))
            ), collapse = " "),");")
        
        # Send query to database
        dbSendQuery(conn, query)
    }
    # Close out database connection
    dbDisconnect(conn)
}