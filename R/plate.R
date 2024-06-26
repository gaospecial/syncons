###################
##    NOTE
###################
#
# COMBINATION SEPARATOR
#
# I used a backslash separator (i.e. "/") to join different strain into a
# synthetic combination. For example, when combined strains A1, B11, C2,
# the combination id is "A1/B11/C2". Please note the separator should not
# be contained in any strain id/names.
#

#######################################
## (PART) Experimental Table Generation
#######################################


#' Assign multiple strains to one or more specified plates
#'
#' @param strains a character vector specifing the strain names
#' @param strain_sep separator used to join strains into combination
#' @param plate_type specify plate type, either 24, 96, or 384.
#' @param plate_prefix plate prefix
#' @param return_layout return the layout of plate, instead of a sample table if TRUE
#'
#' @return a tibble
#' @export
#'
#' @examples
#'   assign_plate(letters[1:5])
assign_plate = function(strains,
                        strain_sep = "/",
                        plate_type = c("24","96","384"),
                        plate_prefix = "P",
                        return_layout = FALSE){
  if (!is.character(plate_type)) plate_type = as.character(plate_type)
  plate_type = match.arg(plate_type)
  nstrain = length(strains)
  valid_plate_types = valid_plate_type(nstrain)
  if (!(plate_type %in% valid_plate_types)) {
    warning("Plate type is not valid, resetting to ", valid_plate_types[[length(valid_plate_types)]])
    plate_type = valid_plate_types[[length(valid_plate_types)]]
  }
  n_plate_max = switch(plate_type, "24" = 4, "96" = 6, "384" = 8)
  strain_add = strains[1:n_plate_max]
  strain_bases = strain_combination(strains = strains[-(1:n_plate_max)], strain_sep = strain_sep)
  plates = lapply(seq_along(strain_bases), function(i){
      one_plate(plate_type = plate_type,
                plate_name = paste0(plate_prefix, i),
                strain_base = strain_bases[[i]],
                strain_add = strain_add,
                strain_sep = strain_sep,
                return_layout = return_layout)
  })
  table = dplyr::bind_rows(plates)
  return(table)
}

valid_plate_type = function(nstrain){
  if (nstrain < 4 | nstrain > 11) stop("Applicable nubmer of strains is from 4 to 11.")
  if (nstrain >= 8) return(c("24","96","384"))
  if (nstrain >= 6) return(c("24","96"))
  return("24")
}

#' The composition of community in a single 24-, 96- or 384-well plate
#'
#' We use a fast, extensible method to generate multiple SynComs in every
#' possible composition. The smallest unit is either a 4 x 4 plate (24 well)
#' for 16 SynComs, a 8x8 plate (96 well) for 64 SynComs, or a 16 x 16
#' plate (384 well) for 256 SynComs. Based on this,
#' one can generate as many as plates, and in that cases the combination
#' of SynComs could be multiplied in batch. For each time we
#' add an extra strain, the number of total plates will double to fulfill
#' all additional strain combinations. In other words, the possible
#' combination of $n$ strain equals to $2^n$.
#'
#' @param plate_type specify plate type, either 24, 96, or 384.
#' @param plate_name will be used as the prefix in combination id
#' @param strain_base the base strain or community in a single plate
#' @param strain_add the id of added strains
#' @param strain_sep separator used to join strains into combination
#' @param return_layout return the layout of plate, instead of a sample table if TRUE
#'
#' @return a tibble
#' @export
#' @md
#'
#' @examples
#'   one_plate("24")
#'   one_plate("96")
#'   one_plate("384")
one_plate = function(plate_type = c("24","96","384"),
                     plate_name = NULL,
                     strain_base = NULL,
                     strain_add = NULL,
                     strain_sep = "/",
                     return_layout = FALSE){
  if (!is.character(plate_type)) plate_type = as.character(plate_type)
  plate_type = match.arg(plate_type)
  dim = switch(plate_type, "24" = c(4,4), "96" = c(8,8), "384" = c(16,16))
  n_well = dim[1] * dim[2]
  if (is.null(strain_add)) strain_add = paste0("S", 1:log2(n_well))
  if (2^length(strain_add) > n_well) {
    stop(glue::glue("A {plate_type}-well plate meets with {log2(n_well)} strains.",
                    "Please relocate these strains to more plates", .sep = "\n"))
  } else if (2^length(strain_add) < n_well) {
    stop(glue::glue("A {plate_type}-well plate meets with {log2(n_well)} strains.",
                    "Please select a small plate and try again.", .sep = "\n"))
  }
  add_all = lapply(seq_along(strain_add), function(i){
    array(rep(c(strain_add[[i]], ""), each = n_well/2^i, times = 2^(i - 1)), dim)
  })
  if (!is.null(strain_base)) {
    if (length(strain_base) > 1) strain_base = paste0(strain_base, collapse = strain_sep)
    add_all$base = array(rep(strain_base, times = n_well), dim)
  }
  combination = purrr::reduce(add_all, paste, sep = strain_sep) |>
    gsub(pattern = paste0(strain_sep, "+"), replacement = strain_sep) |>
    trimws(whitespace = strain_sep)
  well = paste0(rep(LETTERS[1:dim[2]],times = dim[2]),rep(1:dim[1], each = dim[1]))
  data = tibble::tibble(
    combination_id = paste0(plate_name, well),
    well = well,
    combination = combination
  )
  if (return_layout) {
    data = data |>
      dplyr::mutate(row = sub("[0-9]+","", well), col = sub('[A-Z]+',"", well)) |>
      dplyr::select(row, col, combination) |>
      tidyr::pivot_wider(names_from = col, values_from = combination) |>
      dplyr::mutate(row = paste0(plate_name, row))
  } else {
    data = data |> dplyr::select(-well)
  }

  return(data)
}

#' Sort combination in a string
#'
#' String is used as combination name. However, the combination of A and B can be
#' "A/B" or "B/A", this would make it difficult in comparison of combination names.
#' By using this function, the name of strains included in a combination will be sorted
#' alphabetically, so that the combination names can be identical and human-friendly.
#'
#' @param strain_combination a string or a character vector
#' @param strain_sep separator
#'
#' @return a string
#' @export
#'
#' @examples
#'   sort_combination("A1/A11/A2/B3/D5/C11")
#'   sort_combination(c("A1/A11/A2/B3/D5/C11","A1/A11/A25/B3/D18/C11") )
sort_combination = function(strain_combination, strain_sep = "/"){
  l = lapply(strain_combination, function(s){
    stringr::str_split(s, strain_sep, simplify = TRUE) |>
      stringr::str_sort(numeric = TRUE) |>
      paste0(collapse = strain_sep)
  })
  unlist(l)
}


#' All the possible combination of multiple strains
#'
#' @param strains names of strains, can be any integers
#' @param strain_sep separator used to join strains into combination
#'
#' @return a character vector
#' @export
#'
#' @examples
#'   strain_combination(c("A","B","C"))
strain_combination = function(strains, strain_sep = "/"){
  comb_id = combinations(length(strains))
  comb_str = sapply(comb_id, function(i) strains[i])
  combinations = sapply(comb_str, function(i) paste0(i, collapse = strain_sep))
  return(combinations)
}

#' all possible combinations of n sets
#'
#' @param n dim
combinations = function(n) {
  l = lapply(0:n, function(x){
    m = utils::combn(n,x)
    matrix2list(m)
  })
  unlist(l, recursive = F)
}

matrix2list = function(matrix) {
  lapply(seq_len(ncol(matrix)), function(i) matrix[,i])
}

