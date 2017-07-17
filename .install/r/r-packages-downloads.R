# A script for obtaining CRAN download statistics to estimate
# popularity of packages

if (!require(cranlogs)) {
	devtools::install_github("metacran/cranlogs")
	library(cranlogs)
}

# Get download stats. At time of writing top 100 was the most obtainable
downloads <- cran_top_downloads('last-month', count = 100)

# Output on separate lines for `r-packages-install.R`
cat(paste(sort(downloads$package), collapse='\n'))
