library(dplyr)
library(ggplot2)

data_file <- "data.csv"
if (file.exists(data_file)) {
  # Data file exists so just read it in
  data <- read.csv(data_file)
} else {
  # Define data range and associated URLs to download
  days <- 10
  end <- as.Date(Sys.time()) - 3
  begin <- end - days
  dates <- seq(begin, end, by = "day")
  filenames <- strftime(dates, "%Y-%m-%d.csv.gz")

  # Get data by day and append
  data <- NULL
  for (filename in filenames) {
    path <- file.path("logs", filename)
    if(!file.exists(path)) {
      url <- paste0("http://cran-logs.rstudio.com/", substr(filename, 1, 4), '/', filename)
      download.file(url, path)
    }
    day <- read.csv(path)
    data <- rbind(data, day)
  }

  # Save data for use again
  write.csv(data, data_file)
}

# Count by package
counts <- data %>% group_by(package) %>% count() %>% arrange(-n)

# Calculate cumulative proportion
counts <- within(counts, {
  rank <- 1:nrow(counts)
  perc <- diffinv(n)[-1] / sum(n) * 100
})

# Plot it
counts %>%
  head(1000) %>%
  ggplot(aes(x = rank, y = perc)) +
    geom_line() +
    geom_hline(yintercept = 80, linetype=2, colour = "grey") + 
    labs(x = "Rank", y = "Percentile")

# Write it
counts %>% 
  filter(perc <= 80) %>%
  arrange(package) %>%
  select(package) %>%
  write.table("core.tsv", sep='\t', quote=FALSE, row.names=F)
