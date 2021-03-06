# general utility fxns ------------------------------
sc <- function(l) Filter(Negate(is.null), l)

pluck <- function(x, name, type) {
  if (missing(type)) {
    lapply(x, "[[", name)
  } else {
    vapply(x, "[[", name, FUN.VALUE = type)
  }
}

last <- function(x) x[length(x)][[1]]

# base datacite url ------------------------------
datacite_base <- function() "http://oai.datacite.org/oai"

# condition  ----------------------------------------
# Simple condition generator as shown here
# http://adv-r.had.co.nz/Exceptions-Debugging.html#condition-handling
condition <- function(subclass, message, call = sys.call(-1), ...) {
  structure(
    class = unique(c(subclass, "condition")),
    list(message = message, call = call),
    ...
  )
}

# is it a condition?
is.condition <- function(x) inherits(x, "condition")

# return result from main oai functions --------------
oai_give <- function(x, as) {
  if (!as %in% c('df', 'list', 'raw')) {
    stop(sprintf("'%s' not in acceptable set: df, list, raw", as) ,
         call. = FALSE)
  }
  switch(
    as,
    df = tibble::as_tibble(rbind.fill(x)),
    list = x,
    raw = x
  )
}

# check urls ----------------------------------------
check_url <- function(x) {
  if (!all(is.url(x))) {
    stop("One or more of your URLs appears to not be a proper URL",
         call. = FALSE)
  }
}

is.url <- function(x, ...){
  grepl("https?://", x)
}

# while_oai helpers ----------------------------------------
parse_listid <- function(x, as = "df") {
  sc(lapply(x, function(z) {
    if (xml2::xml_name(z) != "resumptionToken") {
      get_headers(z, as = as)
    }
  }))
}

get_data <- function(x, as = "df") {
  sc(lapply(x, function(z) {
    if (xml2::xml_name(z) != "resumptionToken") {
      tmp <- xml2::xml_children(z)
      hd <- get_headers(tmp[[1]], as = as)
      met <- get_metadata(tmp, as = as)
      switch(
        as,
        df = {
          if (!is.null(met)) {
            data.frame(hd, met, stringsAsFactors = FALSE)
          } else {
            hd
          }
        },
        list = list(headers = hd, metadata = met),
        raw = z
      )
    }
  }))
}

get_headers <- function(m, as = "df") {
  tmpm <- lapply(xml2::xml_children(m), function(w) {
    as.list(stats::setNames(xml2::xml_text(w), xml2::xml_name(w)))
  })
  switch(as, df = rbind_df(tmpm), list = unlist(tmpm, recursive = FALSE))
}

get_metadata <- function(x, as = "df") {
  status <- unlist(xml2::xml_attrs(x))
  if (length(status) != 0) {
    NULL
  } else {
    tmp <- xml2::xml_children(xml2::xml_children(x))
    tmpm <- lapply(tmp, function(w) {
      as.list(stats::setNames(xml2::xml_text(w), xml2::xml_name(w)))
    })
    switch(as, df = rbind_df(tmpm), list = unlist(tmpm, recursive = FALSE))
  }
}

rbind_df <- function(x) {
  data.frame(rbind(unlist(x)), stringsAsFactors = FALSE)
}

get_sets <- function(x, as = "df") {
  switch(
    as,
    df = {
      rbind.fill(sc(lapply(x, function(z) {
        if (xml2::xml_name(z) != "resumptionToken") {
          tmp <- xml2::xml_children(z)
          rbind_df(as.list(stats::setNames(xml2::xml_text(tmp), xml2::xml_name(tmp))))
        }
      })))
    },
    list = {
      sc(lapply(x, function(z) {
        if (xml2::xml_name(z) != "resumptionToken") {
          tmp <- xml2::xml_children(z)
          as.list(stats::setNames(xml2::xml_text(tmp), xml2::xml_name(tmp)))
        }
      }))
    }
  )
}

check_as <- function(x) {
  assert(x, "character")
  if (!x %in% c("parsed", "raw")) stop("'as' must be one of 'parsed' or 'raw'")
}

assert <- function(x, y) {
  if (!is.null(x)) {
    if (!inherits(x, y)) {
      stop(deparse(substitute(x)), " must be of class ",
          paste0(y, collapse = ", "), call. = FALSE)
    }
  }
}
