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
      uiOutput("citation")
  )

)


# SERVER SIDE FUNCTIONS ---------------------------------------------------


server = function(input, output, session) {

  output$citation = renderPrint(markdown("**Citation**: \n * Tian, Q., Shi, X., Li, Z., Chen, J., Hu, Y., Lv, D., Wu, S., Zhang, Z., Wu, C., He, J., Wan, Y., Chen, Y., Cai, P., Xu, Z., & Gao, C.-H. (2024). An efficient, low-cost and scalable method for constructing a thousand of synthetic communities (SynComs). BIO-101, e2405576. https://doi.org/10.21769/BioProtoc.2405576\n * 田箐韵, 师鑫, 李自枭, 陈钧婷, 胡雅涵, 吕达, 吴书凤, 张志鹏, 吴尘聊, 何佳琪, 万艳红, 陈彦昭, 蔡鹏, 徐志辉, & 高春辉. (2024). 一种高效、低成本、可扩展的合成菌群构建方法. Bio-101, e2405401. https://doi.org/10.21769/BioProtoc.2405401"))

  validate_strain_name = function(){
    strain_name = input$strain_name |> strsplit(split = "[\n\r]+") |> unlist()
    if (length(strain_name) < 4 | length(strain_name) > 11){
      showNotification("Error: Applicable number of strains is from 4 to 11. Please edit your strain names.", duration = 5, type = "error", id = "strain-name-notification")
      return(NULL)
    } else {
      return(strain_name)
    }
  }

  observeEvent(input$strain_name, {
    strain_name = validate_strain_name()
    if (is.null(strain_name)) return()
    updateRadioButtons(inputId = "plate_type", choices = syncons:::valid_plate_type(length(strain_name)))
    showNotification("Notice: only applicable plate types are shown.", duration = 5, type = "warning", id = "strain-name-notification")
  })

  observeEvent(input$plate_type, {
    # 当 plate_type 发生变化时，显示加样顺序
    output$message = renderPrint(markdown("**Note**: Please check the following diagram to verify the sequence that would be used to make strain combinations, as you have changed plate type recently."))
    output$diagram = renderUI(img(src = paste0(input$plate_type, "-well.png"), width = "100%"))
    output$table = renderUI("")
  })

  # 监听画图按钮的点击事件
  observeEvent(input$get, {
    # 获取输入
    strain_name = validate_strain_name()
    if (is.null(strain_name)) return()

    # 处理 message
    output$message = renderPrint(markdown("**Notes**: The following table lists all the combination id and composition of your SynComs. You may *view*, *sort*, *search* or export to *Excel* as you wish."))
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
