% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/count_identifiers.R
\name{count_identifiers}
\alias{count_identifiers}
\title{Count OAI-PMH identifiers for a data provider.}
\usage{
count_identifiers(url = "http://oai.datacite.org/oai", prefix = "oai_dc",
  ...)
}
\arguments{
\item{url}{OAI-PMH base url}

\item{prefix}{Specifies the metadata format that the records will be
returned in.}

\item{...}{Curl options passed on to \code{\link[httr]{GET}}}
}
\description{
Count OAI-PMH identifiers for a data provider.
}
\examples{
\dontrun{
count_identifiers()
count_identifiers(c(
 "http://oai.datacite.org/oai",
 "http://archivesic.ccsd.cnrs.fr/oai/oai.php",
 "http://www.hindawi.com/oai-pmh/oai.aspx"
))

# curl options
library("httr")
count_identifiers(config = verbose())
}
}
