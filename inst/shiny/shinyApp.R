library(shiny)
# library(syncons)
devtools::load_all(path = rprojroot::find_root("DESCRIPTION"))
library(bslib)

# SHINY UI ------------------------------------------------------------------

ui = page_sidebar(
  theme = bs_theme(version = 5),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "shiny.css")
  ),

  title = "Synthetic Community Constructor",
  sidebar = sidebar(width = "20%",
    textAreaInput("strain_name", "Enter Strain Names By Rows:", paste0("S", 1:6, collapse = "\n")),
    radioButtons("plate_type", "Select Plate Type:", c("24", "96", "384")),
    checkboxInput("return_layout", "Return Plate Layout"),

    # 按钮
    actionButton("get", "Get!"),
  ),

  card(
      uiOutput('message'),
      uiOutput('diagram'),
      uiOutput("table"),
  )

)




# SERVER SIDE FUNCTIONS ---------------------------------------------------


server = function(input, output, session) {

  observeEvent(input$strain_name, {
    strain_name = input$strain_name |> strsplit(split = "[\n\r]+") |> unlist()
    updateRadioButtons(inputId = "plate_type", choices = valid_plate_type(length(strain_name)))
  })

  observeEvent(input$plate_type, {
    # 当 plate_type 发生变化时，显示加样顺序
    output$diagram = renderUI(img(src = paste0(input$plate_type, "-well.png"), width = "100%"))
    output$table = renderUI("")
  })

  # 监听画图按钮的点击事件
  observeEvent(input$get, {
    # 获取输入
    strain_name = input$strain_name |> strsplit(split = "[\n\r]+") |> unlist()

    # 处理 message
    output$diagram = renderUI("")

    # 生成表格
    table = assign_plate(strains = strain_name,
                         plate_type = input$plate_type,
                         return_layout = input$return_layout)

    # 输出结果
    output$table = renderUI(DT_table(table))
  })

}




# RUN shinyApp() ----------------------------------------------------------

shinyApp(ui, server)
