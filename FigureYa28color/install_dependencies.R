#!/usr/bin/env Rscript
# R dependency installation script for FigureYa project
# Installs CRAN and GitHub packages and verifies installation

options("repos" = c(CRAN = "https://cloud.r-project.org/"))

is_package_installed <- function(package_name) {
  package_name %in% rownames(installed.packages())
}

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

install_github_package <- function(repo) {
  pkg <- sub(".*/", "", repo)
  if (!is_package_installed(pkg)) {
    cat("Installing GitHub package:", repo, "\n")
    tryCatch({
      devtools::install_github(repo, quiet = TRUE)
      cat("✓ Successfully installed:", repo, "\n")
    }, error = function(e) {
      cat("✗ Failed to install", repo, ":", e$message, "\n")
    })
  } else {
    cat("✓ GitHub package already installed:", pkg, "\n")
  }
}

cat("Starting R package installation for FigureYa project...\n")
cat("===================================================\n")

# 1. 安装CRAN包
cat("\n1. Installing CRAN packages...\n")
cran_packages <- c("devtools", "ggplot2", "stringr", "reshape2", "dichromat", "EBImage", "scales", "rgl")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 2. 安装GitHub包
cat("\n2. Installing GitHub packages...\n")
library(devtools)  # 确保devtools已安装
github_packages <- c("ramnathv/rblocks", "woobe/rPlotter")
for (repo in github_packages) {
  install_github_package(repo)
}

cat("\n===================================================\n")
cat("Package installation completed!\n")

# 3. 验证安装
cat("\nVerifying package installation:\n")
required_packages <- c(cran_packages, "rblocks", "rPlotter")
all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed <- FALSE
  }
}

# 4. 简单测试核心包功能（示例：scales, rgl, rPlotter）
if (is_package_installed("scales")) {
  cat("\nTesting scales package...\n")
  tryCatch({
    library(scales)
    cat("✓ scales package loaded successfully\n")
    test_values <- c(0.1234, 1234.567, 0.0001234)
    cat("Testing percent format:", percent(test_values), "\n")
    cat("Testing comma format:", comma(test_values), "\n")
    cat("Testing scientific format:", scientific(test_values), "\n")
    cat("✓ scales main functions are working properly\n")
  }, error = function(e) {
    cat("✗ scales test failed:", e$message, "\n")
  })
}

if (is_package_installed("rgl")) {
  cat("\nTesting rgl package...\n")
  tryCatch({
    library(rgl)
    cat("✓ rgl package loaded successfully\n")
    if (exists("plot3d") && exists("open3d") && exists("points3d")) {
      cat("✓ rgl main functions are available\n")
    }
  }, error = function(e) {
    cat("✗ rgl test failed:", e$message, "\n")
  })
}

if (is_package_installed("rPlotter")) {
  cat("\nTesting rPlotter package...\n")
  tryCatch({
    library(rPlotter)
    cat("✓ rPlotter package loaded successfully\n")
    # 这里可添加简单功能测试，如 rPlotter::show_col(c("#FF0000", "#00FF00", "#0000FF"))
  }, error = function(e) {
    cat("✗ rPlotter test failed:", e$message, "\n")
  })
}

cat("\n===================================================\n")
if (all_installed) {
  cat("✅ All required packages installed successfully!\n")
  cat("You can now use all dependencies in your R scripts.\n")
} else {
  cat("⚠️  Some packages failed to install. You may need to:\n")
  cat("1. Check your internet connection\n")
  cat("2. Install missing packages manually\n")
  cat("3. Check for any system dependencies\n")
}

cat("\nUsage examples:\n")
cat("library(scales)    # For formatting numbers and dates\n")
cat("library(rgl)       # For 3D graphics\n")
cat("library(rPlotter)  # For color palette extraction\n")
