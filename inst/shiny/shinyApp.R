library(shiny)
library(syncons)
# devtools::load_all(path = rprojroot::find_root("DESCRIPTION"))
library(bslib)

# SHINY UI ------------------------------------------------------------------

ui = page_sidebar(
  theme = bs_theme(version = 5),
  tags$head({
    tags$link(rel = "stylesheet", type = "text/css", href = "shiny.css")
  }),

  title = "Synthetic Community Constructor",
  sidebar = sidebar(width = "30%",
    div(id = "shiny-notification-strain-name-notification"),
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
    if (length(strain_name) < 4 | length(strain_name) > 11){
      showNotification("Error: Applicable number of strains is from 4 to 11. Please edit your strain names.", duration = NULL, type = "error", id = "strain-name-notification")
      return()
    }
    updateRadioButtons(inputId = "plate_type", choices = syncons:::valid_plate_type(length(strain_name)))
    showNotification("Notice: only applicable plate types are shown.", duration = NULL, type = "warning", id = "strain-name-notification")
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
    removeNotification("strain-name-notification")
    output$diagram = renderUI("")

    # 生成表格
    table = assign_plate(strains = strain_name,
                         plate_type = input$plate_type,
                         return_layout = input$return_layout)

    # 输出结果
    output$table = renderUI(syncons:::DT_table(table))
  })

}




# RUN shinyApp() ----------------------------------------------------------

shinyApp(ui, server)
