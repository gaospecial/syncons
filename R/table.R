

# a DT table
DT_table = function(df){
  df |>
    DT::datatable(extensions = c("Buttons"),
                  rownames = FALSE,
                  options = list(
                    dom = 'Bfrtip',
                    scrollX = TRUE,
                    buttons = list(
                      'pageLength',
                      list(extend = "excel",
                           filename = paste0(substitute(df)),
                           header = TRUE)
                    )
                  ))
}
