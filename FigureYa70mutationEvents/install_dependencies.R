#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
# This script installs required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(requireNamespace(package_name, quietly = TRUE))
}

# Function to install CRAN packages
install_cran_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("Installing CRAN package:", package_name, "\n")
    tryCatch({
      install.packages(package_name, dependencies = TRUE, quiet = TRUE)
      cat("✓ Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("✗ Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("✓ Package already installed:", package_name, "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 安装CRAN包
cat("\nInstalling required CRAN packages...\n")
required_packages <- c(
  "reshape2",       # 数据重塑包：用于数据结构转换（宽表/长表）
  "RColorBrewer",   # 颜色调色板包：提供科学配色方案
  "Cairo",          # 高质量图形输出包：支持多种格式输出
  "readr",          # 数据读取包：高效读取结构化数据
  "corrplot",       # 相关性可视化包：绘制相关矩阵图
  "openxlsx",       # Excel文件操作包：读写Excel文件
  "data.table"      # 高效数据处理包
)

for (pkg in required_packages) {
  install_cran_package(pkg)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# 验证安装
cat("\nVerifying package installation:\n")
all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed <- FALSE
  }
}

# 测试包加载
cat("\nTesting package loading...\n")
test_packages <- function() {
  tryCatch({
    library(reshape2)
    cat("✓ reshape2 loaded successfully\n")
  }, error = function(e) {
    cat("✗ reshape2 loading failed:", e$message, "\n")
  })
  
  tryCatch({
    library(RColorBrewer)
    cat("✓ RColorBrewer loaded successfully\n")
  }, error = function(e) {
    cat("✗ RColorBrewer loading failed:", e$message, "\n")
  })
  
  tryCatch({
    library(Cairo)
    cat("✓ Cairo loaded successfully\n")
  }, error = function(e) {
    cat("✗ Cairo loading failed:", e$message, "\n")
  })
  
  tryCatch({
    library(readr)
    cat("✓ readr loaded successfully\n")
  }, error = function(e) {
    cat("✗ readr loading failed:", e$message, "\n")
  })
  
  tryCatch({
    library(corrplot)
    cat("✓ corrplot loaded successfully\n")
  }, error = function(e) {
    cat("✗ corrplot loading failed:", e$message, "\n")
  })
  
  tryCatch({
    library(openxlsx)
    cat("✓ openxlsx loaded successfully\n")
  }, error = function(e) {
    cat("✗ openxlsx loading failed:", e$message, "\n")
  })
  
  tryCatch({
    library(data.table)
    cat("✓ data.table loaded successfully\n")
  }, error = function(e) {
    cat("✗ data.table loading failed:", e$message, "\n")
  })
}

cat("\nYou can now run your R scripts in this directory.\n")
