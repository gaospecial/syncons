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

#' The composition of community in a 8x8 plate (64 SynComs)
#'
#' We use a fast, extensible method to generate multiple SynComs in every
#' possible composition. The smallest unit is a 8x8 plate with 64 SynComs,
#' which are all the combinations of six different strains. Based on this,
#' one can generate as many as plates, and in that cases the combination
#' of SynComs could be 64x2, 64x2x2, 64x2x2, and so on. For each time we
#' add an extra strain, the number of total plates will double to fulfill
#' all additional strain combinations. In other words, the possible
#' combination of $n$ strain equals to $2^n$.
#'
#' @param plate_type specify plate type, either 24, 96, or 384.
#' @param plate_name a prefix in combination id
#' @param strain_base the base strain or community in a single plate
#' @param strain_add the id of added strains, which should contains 6 members
#' @param dim c(8,8)
#' @param return_array return an array if TRUE
#' @param strain_seq separator
#'
#' @return a tibble or an array
#' @export
#'
#' @examples
#'   one_plate(plate_name="",strain_base="",strain_add=LETTERS[1:6])
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
  }
  if (2^length(strain_add) < n_well) {
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
      tibble::column_to_rownames(var = "row")
  } else {
    data = data |> dplyr::select(-well)
  }

  return(data)
}


#######################################
## (PART) Combination Relationship
#######################################


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
      paste0(collapse = sep)
  })
  unlist(l)
}


#' all possible combinations of n sets
#'
#' @param n dim
#'
#' @importFrom utils combn
combinations = function(n) {
  l = lapply(seq_len(n), function(x){
    m = combn(n,x)
    matrix2list(m)
  })
  unlist(l, recursive = F)
}

matrix2list = function(matrix) {
  lapply(seq_len(ncol(matrix)), function(i) matrix[,i])
}

