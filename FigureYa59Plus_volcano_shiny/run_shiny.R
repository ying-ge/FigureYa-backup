#!/usr/bin/env Rscript

# FigureYa59volcanoV2 Shiny App Launcher
# 启动火山图交互式应用

# Load required packages
if (!require(shiny)) {
  install.packages("shiny")
  library(shiny)
}

if (!require(DT)) {
  install.packages("DT")
  library(DT)
}

if (!require(ggplot2)) {
  install.packages("ggplot2")
  library(ggplot2)
}

if (!require(ggrepel)) {
  install.packages("ggrepel")
  library(ggrepel)
}

if (!require(ggthemes)) {
  install.packages("ggthemes")
  library(ggthemes)
}

if (!require(gridExtra)) {
  install.packages("gridExtra")
  library(gridExtra)
}

# Set environment
Sys.setenv(LANGUAGE = "en")
options(stringsAsFactors = FALSE)

cat("Starting FigureYa59volcanoV2 Shiny Application...\n")
cat("请在浏览器中打开显示的地址 / Please open the displayed URL in your browser\n")

# Run the Shiny app
shiny::runApp(
  appDir = getwd(),
  host = "0.0.0.0",
  port = 3838,
  launch.browser = TRUE
)