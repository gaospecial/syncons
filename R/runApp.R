#' Run Shiny App locally
#'
#' @return a shiny app
#' @export
run_shinyApp = function(){
  check_package("shiny")
  app = system.file(
    "shiny",
    "shinyApp.R",
    package = "syncons",
    mustWork = TRUE
  )
  if(interactive()) shiny::runApp(app)
}

check_package = function(package){
  if (!requireNamespace(package, quietly = TRUE)){
    stop(glue::glue("The '{package}' package is required but not installed.",
               "\tPlease run `install.packages('{package}')` and retry...",
               .sep = "\n"))
  }
}
