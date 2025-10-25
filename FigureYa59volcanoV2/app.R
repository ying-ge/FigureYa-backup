# FigureYa59volcanoV2 Shiny App
# Author(s): Haitao Wang
# Reviewer(s): Ying Ge, Yijing Chen
# Date: 2025-10-25

# Academic Citation
# If you use this code in your work or research, we kindly request that you cite our publication:
# Xiaofan Lu, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed. https://doi.org/10.1002/imm3.70005

# Load required packages
if (!require(shiny)) install.packages("shiny")
if (!require(DT)) install.packages("DT")

library(ggplot2)   # 加载绘图核心库 | Core plotting library
library(ggrepel)   # 防止标签重叠的智能标注 | Smart label repulsion to avoid overlaps
library(ggthemes)  # 提供额外主题与配色 | Additional themes and color palettes
library(gridExtra) # 多图排版与网格布局 | Arrange multiple plots and grid layout
library(grid)      # Grid graphics system for pathway legend
library(DT)        # Interactive tables
library(shiny)     # Web application framework

Sys.setenv(LANGUAGE = "en") #显示英文报错信息 | Display English error messages
options(stringsAsFactors = FALSE) #禁止chr转成factor | prohibit the conversion of chr to factor

# 基因名的颜色，需大于等于pathway的数量，这里自定义了足够多的颜色
# the color of the gene name needs to be greater than or equal to the number of pathway, and here a sufficient number of colors have been customized
mycol <- c("darkgreen","chocolate4","blueviolet","#223D6C","#D20A13","#088247","#58CDD9","#7A142C","#5D90BA","#431A3D","#91612D","#6E568C","#E0367A","#D8D155","#64495D","#7CC767")

# Load example data for demonstration
example_data <- read.csv("easy_input_limma.csv")
# Fix the unnamed first column
if (is.na(colnames(example_data)[1])) {
  colnames(example_data)[1] <- "X"
}
example_data$label <- example_data$X
example_data$gsym <- example_data$label

example_selected <- read.csv("easy_input_selected.csv")

# Define UI
ui <- fluidPage(
  titlePanel("FigureYa59volcanoV2 - Interactive Volcano Plot"),

  sidebarLayout(
    sidebarPanel(
      width = 3,

      h4("Data Upload / 数据上传"),

      # Main data file upload
      fileInput("mainData", "Main Data File (CSV)",
                accept = c(".csv"),
                multiple = FALSE),

      # Selected genes file upload
      fileInput("selectedGenes", "Selected Genes File (CSV, optional)",
                accept = c(".csv"),
                multiple = FALSE),

      hr(),

      h4("Plot Parameters / 绘图参数"),

      # Plot mode
      selectInput("plotMode", "Plot Mode / 绘图模式:",
                  choices = c("Advanced" = "advanced",
                             "Classic" = "classic"),
                  selected = "advanced"),

      # Thresholds
      numericInput("logFCcut", "Log2 Fold Change Cutoff:",
                   value = 1.5, min = 0, max = 10, step = 0.1),

      numericInput("pvalCut", "P-value Cutoff:",
                   value = 0.05, min = 0.001, max = 0.5, step = 0.001),

      # Advanced thresholds (only shown for advanced mode)
      conditionalPanel(
        condition = "input.plotMode == 'advanced'",

        numericInput("logFCcut2", "Log2 Fold Change Cutoff 2:",
                     value = 2.5, min = 0, max = 10, step = 0.1),

        numericInput("pvalCut2", "P-value Cutoff 2:",
                     value = 0.0001, min = 0.00001, max = 0.5, step = 0.00001),

        numericInput("logFCcut3", "Log2 Fold Change Cutoff 3:",
                     value = 5, min = 0, max = 15, step = 0.1),

        numericInput("pvalCut3", "P-value Cutoff 3:",
                     value = 0.00001, min = 0.000001, max = 0.5, step = 0.000001)
      ),

      hr(),

      h4("Display Options / 显示选项"),

      # Gene labeling threshold
      numericInput("logFClabel", "Show gene names for |log2FC| >:",
                   value = 9, min = 1, max = 15, step = 0.5),

      # Use default data checkbox
      checkboxInput("useDefaultData", "Use example data",
                    value = TRUE),

      hr(),

      # Download button
      downloadButton("downloadPlot", "Download Plot (PDF)")

    ),

    mainPanel(
      width = 9,

      tabsetPanel(
        tabPanel("Volcano Plot",
                 plotOutput("volcanoPlot", height = "600px")),

        tabPanel("Data Preview",
                 DT::dataTableOutput("mainDataPreview")),

        tabPanel("Selected Genes",
                 DT::dataTableOutput("selectedGenesPreview")),

        tabPanel("About",
                 h3("About FigureYa59volcanoV2"),
                 p("This interactive volcano plot application is based on the FigureYa framework for biomedical data visualization."),
                 br(),
                 h4("Citation:"),
                 p("Xiaofan Lu, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed. https://doi.org/10.1002/imm3.70005"),
                 br(),
                 h4("Features:"),
                 tags$ul(
                   tags$li("Interactive parameter adjustment"),
                   tags$li("Multiple visualization modes (Classic and Advanced)"),
                   tags$li("Custom gene highlighting"),
                   tags$li("Real-time plot updates"),
                   tags$li("PDF export functionality")
                 )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {

  # Reactive values for storing data
  values <- reactiveValues(
    mainData = NULL,
    selectedGenes = NULL
  )

  # Load default data initially
  observe({
    if (input$useDefaultData) {
      values$mainData <- example_data
      values$selectedGenes <- example_selected
    }
  })

  # Handle main data file upload
  observeEvent(input$mainData, {
    req(input$mainData)

    data <- read.csv(input$mainData$datapath)

    # Validate required columns
    required_cols <- c("logFC", "P.Value")
    if (!all(required_cols %in% colnames(data))) {
      showModal(modalDialog(
        title = "Error",
        "The main data file must contain columns: logFC, P.Value",
        footer = modalButton("OK")
      ))
      return()
    }

    # Ensure we have gene names
    if ("X" %in% colnames(data)) {
      data$label <- data$X
    } else if ("gene" %in% colnames(data)) {
      data$label <- data$gene
    } else {
      # If the first column has no name, use it as gene names
      if (is.na(colnames(data)[1]) || colnames(data)[1] == "") {
        data$label <- data[[1]]
        colnames(data)[1] <- "X"
      } else {
        data$label <- rownames(data)
      }
    }

    data$gsym <- data$label

    values$mainData <- data
  })

  # Handle selected genes file upload
  observeEvent(input$selectedGenes, {
    req(input$selectedGenes)

    selected <- read.csv(input$selectedGenes$datapath)

    # Ensure pathway column exists
    if (!"pathway" %in% colnames(selected)) {
      selected$pathway <- "Default"
    }

    values$selectedGenes <- selected
  })

  # Reactive expression for processed data
  processedData <- reactive({
    req(values$mainData)

    x <- values$mainData

    # Calculate plot parameters
    xmin <- (range(x$logFC)[1] - (range(x$logFC)[1] + 10))
    xmax <- (range(x$logFC)[1] + (10 - range(x$logFC)[1]))
    ymin <- 0
    ymax <- max(-log10(x$P.Value)) * 1.1

    # Set colors and sizes based on plot mode
    if (input$plotMode == "classic") {
      x$color_transparent <- ifelse((x$P.Value < input$pvalCut & x$logFC > input$logFCcut),
                                   "red",
                                   ifelse((x$P.Value < input$pvalCut & x$logFC < -input$logFCcut),
                                         "blue", "grey"))
      size <- ifelse((x$P.Value < input$pvalCut & abs(x$logFC) > input$logFCcut), 4, 2)

    } else if (input$plotMode == "advanced") {
      n1 <- length(x[, 1])
      cols <- rep("grey", n1)
      names(cols) <- rownames(x)

      cols[x$P.Value < input$pvalCut & x$logFC > input$logFCcut] <- "#FB9A99"
      cols[x$P.Value < input$pvalCut2 & x$logFC > input$logFCcut2] <- "#ED4F4F"
      cols[x$P.Value < input$pvalCut & x$logFC < -input$logFCcut] <- "#B2DF8A"
      cols[x$P.Value < input$pvalCut2 & x$logFC < -input$logFCcut2] <- "#329E3F"

      color_transparent <- adjustcolor(cols, alpha.f = 0.5)
      x$color_transparent <- color_transparent

      n1 <- length(x[, 1])
      size <- rep(1, n1)

      size[x$P.Value < input$pvalCut & x$logFC > input$logFCcut] <- 2
      size[x$P.Value < input$pvalCut2 & x$logFC > input$logFCcut2] <- 4
      if (input$pvalCut3 < input$pvalCut2) {
        size[x$P.Value < input$pvalCut3 & x$logFC > input$logFCcut3] <- 6
      }
      size[x$P.Value < input$pvalCut & x$logFC < -input$logFCcut] <- 2
      size[x$P.Value < input$pvalCut2 & x$logFC < -input$logFCcut2] <- 4
      if (input$pvalCut3 < input$pvalCut2) {
        size[x$P.Value < input$pvalCut3 & x$logFC < -input$logFCcut3] <- 6
      }
    }

    # Merge with selected genes
    selectgenes <- NULL
    if (!is.null(values$selectedGenes) && nrow(values$selectedGenes) > 0) {
      selectgenes <- merge(values$selectedGenes, x, by = "gsym", all.x = TRUE)
      if (is.null(selectgenes$pathway)) {
        selectgenes$pathway <- "Default"
      }
    }

    list(
      data = x,
      size = size,
      xmin = xmin,
      xmax = xmax,
      ymin = ymin,
      ymax = ymax,
      selectgenes = selectgenes
    )
  })

  # Generate volcano plot
  output$volcanoPlot <- renderPlot({
    req(values$mainData)

    processed <- processedData()
    x <- processed$data
    size <- processed$size
    ymin <- processed$ymin
    ymax <- processed$ymax

    # Base plot
    p1 <- ggplot(data = x, aes(logFC, -log10(P.Value), label = label)) +
      geom_point(alpha = 0.6, size = size, colour = x$color_transparent) +

      labs(x = bquote(~Log[2]~"(fold change)"),
           y = bquote(~-Log[10]~italic("P-value")),
           title = "") +
      ylim(c(ymin, ymax)) +
      scale_x_continuous(
        breaks = c(-10, -5, -input$logFCcut, 0, input$logFCcut, 5, 10),
        labels = c(-10, -5, -input$logFCcut, 0, input$logFCcut, 5, 10),
        limits = c(-11, 11)
      ) +

      # Threshold lines
      geom_vline(xintercept = c(-input$logFCcut, input$logFCcut),
                color = "grey40", linetype = "longdash", lwd = 0.5) +
      geom_hline(yintercept = -log10(input$pvalCut),
                color = "grey40", linetype = "longdash", lwd = 0.5) +

      theme_bw(base_size = 12) +
      theme(panel.grid = element_blank())

    # Add advanced mode lines
    if (input$plotMode == "advanced") {
      p1 <- p1 +
        geom_vline(xintercept = c(-input$logFCcut2, input$logFCcut2),
                  color = "grey40", linetype = "longdash", lwd = 0.5) +
        geom_hline(yintercept = -log10(input$pvalCut2),
                  color = "grey40", linetype = "longdash", lwd = 0.5)
    }

    # Add gene labels for high logFC
    if (input$logFClabel > 0) {
      p1 <- p1 +
        geom_text_repel(aes(x = logFC, y = -log10(P.Value),
                           label = ifelse(abs(logFC) > input$logFClabel, rownames(x), "")),
                      colour = "darkred", size = 5,
                      box.padding = unit(0.35, "lines"),
                      point.padding = unit(0.3, "lines"))
    }

    # Add selected genes highlighting
    if (!is.null(processed$selectgenes) && nrow(processed$selectgenes) > 0) {
      selectgenes <- processed$selectgenes

      p1 <- p1 +
        # Black circles around selected genes
        geom_point(data = selectgenes, alpha = 1, size = 4.6, shape = 1,
                   stroke = 1, color = "black") +

        # Gene names for selected genes
        geom_text_repel(data = selectgenes,
                        show.legend = FALSE,
                        aes(colour = pathway),
                        size = 5, box.padding = unit(0.35, "lines"),
                        point.padding = unit(0.3, "lines")) +
        scale_color_manual(values = mycol) +
        guides(color = guide_legend(title = NULL))

      # Add pathway legend
      np <- length(unique(selectgenes$pathway))
      if (np > 0) {
        labelsInfo <- data.frame(
          pathway = names(table(selectgenes$pathway)),
          col = mycol[1:np]
        )

        pathwayTable <- tableGrob(
          labelsInfo$pathway,
          rows = c(rep("", np)),
          cols = "",
          theme = ttheme_minimal(base_colour = labelsInfo$col)
        )

        p1 <- p1 +
          annotation_custom(
            grob = pathwayTable,
            ymin = ymax - 2, ymax = ymax,
            xmin = -11, xmax = -9
          )
      }
    }

    p1
  }, height = 600, width = 800)

  # Data preview tables
  output$mainDataPreview <- DT::renderDataTable({
    if (!is.null(values$mainData)) {
      DT::datatable(values$mainData,
                   options = list(scrollX = TRUE, pageLength = 10),
                   caption = "Main Differential Expression Data")
    }
  })

  output$selectedGenesPreview <- DT::renderDataTable({
    if (!is.null(values$selectedGenes)) {
      DT::datatable(values$selectedGenes,
                   options = list(scrollX = TRUE, pageLength = 10),
                   caption = "Selected Genes for Highlighting")
    }
  })

  # Create reactive plot for download
  plotForDownload <- reactive({
    req(values$mainData)

    processed <- processedData()
    x <- processed$data
    size <- processed$size
    ymin <- processed$ymin
    ymax <- processed$ymax

    # Generate the same plot as in renderPlot
    p1 <- ggplot(data = x, aes(logFC, -log10(P.Value), label = label)) +
      geom_point(alpha = 0.6, size = size, colour = x$color_transparent) +

      labs(x = bquote(~Log[2]~"(fold change)"),
           y = bquote(~-Log[10]~italic("P-value")),
           title = "") +
      ylim(c(ymin, ymax)) +
      scale_x_continuous(
        breaks = c(-10, -5, -input$logFCcut, 0, input$logFCcut, 5, 10),
        labels = c(-10, -5, -input$logFCcut, 0, input$logFCcut, 5, 10),
        limits = c(-11, 11)
      ) +

      # Threshold lines
      geom_vline(xintercept = c(-input$logFCcut, input$logFCcut),
                color = "grey40", linetype = "longdash", lwd = 0.5) +
      geom_hline(yintercept = -log10(input$pvalCut),
                color = "grey40", linetype = "longdash", lwd = 0.5) +

      theme_bw(base_size = 12) +
      theme(panel.grid = element_blank())

    # Add advanced mode lines
    if (input$plotMode == "advanced") {
      p1 <- p1 +
        geom_vline(xintercept = c(-input$logFCcut2, input$logFCcut2),
                  color = "grey40", linetype = "longdash", lwd = 0.5) +
        geom_hline(yintercept = -log10(input$pvalCut2),
                  color = "grey40", linetype = "longdash", lwd = 0.5)
    }

    # Add gene labels for high logFC
    if (input$logFClabel > 0) {
      p1 <- p1 +
        geom_text_repel(aes(x = logFC, y = -log10(P.Value),
                           label = ifelse(abs(logFC) > input$logFClabel, rownames(x), "")),
                      colour = "darkred", size = 5,
                      box.padding = unit(0.35, "lines"),
                      point.padding = unit(0.3, "lines"))
    }

    # Add selected genes highlighting
    if (!is.null(processed$selectgenes) && nrow(processed$selectgenes) > 0) {
      selectgenes <- processed$selectgenes

      p1 <- p1 +
        # Black circles around selected genes
        geom_point(data = selectgenes, alpha = 1, size = 4.6, shape = 1,
                   stroke = 1, color = "black") +

        # Gene names for selected genes
        geom_text_repel(data = selectgenes,
                        show.legend = FALSE,
                        aes(colour = pathway),
                        size = 5, box.padding = unit(0.35, "lines"),
                        point.padding = unit(0.3, "lines")) +
        scale_color_manual(values = mycol) +
        guides(color = guide_legend(title = NULL))

      # Add pathway legend
      np <- length(unique(selectgenes$pathway))
      if (np > 0) {
        labelsInfo <- data.frame(
          pathway = names(table(selectgenes$pathway)),
          col = mycol[1:np]
        )

        pathwayTable <- tableGrob(
          labelsInfo$pathway,
          rows = c(rep("", np)),
          cols = "",
          theme = ttheme_minimal(base_colour = labelsInfo$col)
        )

        p1 <- p1 +
          annotation_custom(
            grob = pathwayTable,
            ymin = ymax - 2, ymax = ymax,
            xmin = -11, xmax = -9
          )
      }
    }

    return(p1)
  })

  # Download plot
  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste0("volcano_plot_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      ggsave(file, plot = plotForDownload(), width = 8, height = 6, dpi = 300)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)