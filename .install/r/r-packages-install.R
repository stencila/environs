#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop('Please provide a package file.\n', call.=FALSE)
}

# Set CRAN mirror
options(repos=structure(c(CRAN='https://cran.rstudio.com')))

# Install `em!
filename <- args[1]
for (line in readLines(filename)) {
  line <- trimws(line)
  if (nchar(line) > 0 && line[1] != '#') {
    parts <- strsplit(sub('(([^:]+)\\:)?([^= ]+)(==(.+))?', '\\2,\\3,\\5,', line, perl=TRUE), ',')[[1]]
    source <- ifelse(parts[1]=='', 'cran', parts[1])
    name <- parts[2]
    version <- parts[3]
    if (source == 'cran') {
      if (version != '') stop('Versioning not currently supported for CRAN packages')
      install.packages(name)
    } else if (source == 'github') {
      if (!require(devtools, quietly=TRUE)) install.packages('devtools')
      devtools::install_github(name, ref=version)
    } else {
      stop(paste0('Unknown source for package: ', source, '\n'), call.=FALSE)
    }
  }
}
