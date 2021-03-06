#' Count OAI-PMH identifiers for a data provider.
#'
#' @export
#' @template url_ddd
#' @param prefix Specifies the metadata format that the records will be
#' returned in
#' @details Note that some OAI providers do not include the entry
#' `completeListSize`
#' (<http://www.openarchives.org/OAI/openarchivesprotocol.html#FlowControl>)
#' in which case we return an NA - which does not mean 0, but rather we don't
#' know.
#' @examples \dontrun{
#' count_identifiers()
#'
#' # curl options
#' # library("httr")
#' # count_identifiers(config = verbose())
#' }
count_identifiers <- function(url = "http://export.arxiv.org/oai2", 
  prefix = 'oai_dc', ...) {

  check_url(url)
  args <- sc(list(verb = 'ListIdentifiers', metadataPrefix = prefix))
  plyr::rbind.fill(lapply(url, ci, args = args, ...))
}

ci <- function(x, args, ...) {
  res <- GET(x, query = args, ...)
  xml <- xml2::read_xml(content(res, "text", encoding = "UTF-8"))
  handle_errors(xml)
  children <- xml_children(xml_children(xml))
  count <- as.numeric(
    xml_attr(
      children[sapply(children, xml_name) == "resumptionToken"],
      "completeListSize"
    )
  )
  data.frame(url = x, count = count, stringsAsFactors = FALSE)
}
