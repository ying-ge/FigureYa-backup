#!/usr/bin/env Rscript
# R dependency installation script for scales and rgl packages
# This script installs scales and rgl packages

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
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

cat("Starting R package installation for scales and rgl...\n")
cat("===================================================\n")

# 安装CRAN包（只安装scales和rgl）
cat("\n1. Installing CRAN packages...\n")
cran_packages <- c("scales", "rgl")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

cat("\n===================================================\n")
cat("Package installation completed!\n")

# 验证安装
cat("\nVerifying package installation:\n")
required_packages <- c("scales", "rgl")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed <- FALSE
  }
}

# 测试scales包功能
if (is_package_installed("scales")) {
  cat("\nTesting scales package...\n")
  tryCatch({
    library(scales)
    cat("✓ scales package loaded successfully\n")
    # 测试一些常用函数
    test_values <- c(0.1234, 1234.567, 0.0001234)
    cat("Testing percent format:", percent(test_values), "\n")
    cat("Testing comma format:", comma(test_values), "\n")
    cat("Testing scientific format:", scientific(test_values), "\n")
    cat("✓ scales main functions are working properly\n")
  }, error = function(e) {
    cat("✗ scales test failed:", e$message, "\n")
  })
}

# 测试rgl包功能
if (is_package_installed("rgl")) {
  cat("\nTesting rgl package...\n")
  tryCatch({
    library(rgl)
    cat("✓ rgl package loaded successfully\n")
    # 检查主要函数是否存在
    if (exists("plot3d") && exists("open3d") && exists("points3d")) {
      cat("✓ rgl main functions are available\n")
      
      # 简单的3D绘图测试（可选）
      if (interactive()) {
        cat("Creating simple 3D plot...\n")
        open3d()
        x <- rnorm(100)
        y <- rnorm(100)
        z <- rnorm(100)
        plot3d(x, y, z, col = "blue", size = 3)
        cat("✓ 3D plot created successfully\n")
      }
    }
  }, error = function(e) {
    cat("✗ rgl test failed:", e$message, "\n")
  })
}

cat("\n===================================================\n")
if (all_installed) {
  cat("✅ All required packages installed successfully!\n")
  cat("You can now use scales and rgl in your R scripts.\n")
} else {
  cat("⚠️  Some packages failed to install. You may need to:\n")
  cat("1. Check your internet connection\n")
  cat("2. Install missing packages manually:\n")
  cat("   install.packages(c('scales', 'rgl'))\n")
  cat("3. Check for any system dependencies\n")
}

cat("\nUsage examples:\n")
cat("library(scales)  # For formatting numbers and dates\n")
cat("library(rgl)     # For 3D graphics\n")
