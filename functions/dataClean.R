library(skimr)

# Simple function to clean data frames and save to local file system (./data)
DataClean <- function(df, path) {
    dfClean <- df[, colSums(is.na(df)) != nrow(df)]
    dfClean <- type.convert(dfClean, as_is = TRUE)
    dfClean$DTG <- as.POSIXct(dfClean$DTG, tz='UTC')
    dfSkim <- skim(dfClean)
    write.csv(dfSkim, path)
    return(dfClean)
}