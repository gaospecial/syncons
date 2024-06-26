% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plate.R
\name{assign_plate}
\alias{assign_plate}
\title{Assign multiple strains to one or more specified plates}
\usage{
assign_plate(
  strains,
  strain_sep = "/",
  plate_type = c("24", "96", "384"),
  plate_prefix = "P",
  return_layout = FALSE
)
}
\arguments{
\item{strains}{a character vector specifing the strain names}

\item{strain_sep}{separator used to join strains into combination}

\item{plate_type}{specify plate type, either 24, 96, or 384.}

\item{plate_prefix}{plate prefix}

\item{return_layout}{return the layout of plate, instead of a sample table if TRUE}
}
\value{
a tibble
}
\description{
Assign multiple strains to one or more specified plates
}
\examples{
  assign_plate(letters[1:5])
}
