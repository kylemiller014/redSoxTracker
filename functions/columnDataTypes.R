# Simple function to create data frame of column names and data types
columnClasses <- function(df) {
    data.frame(variable = names(df),
    class = unname(sapply(df, class))
    )
}