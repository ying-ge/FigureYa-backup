#!/usr/bin/env Rscript
# R Package Installation Script for essential data processing and visualization packages

# Set up repositories
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Function to check if package is installed
is_installed <- function(pkg) {
  pkg %in% rownames(installed.packages())
}

# Function to install with error handling
safe_install <- function(pkg) {
  cat("Installing package:", pkg, "\n")
  tryCatch({
    install.packages(pkg, quiet = TRUE)
    if (is_installed(pkg)) {
      cat("✓ Successfully installed:", pkg, "\n")
      return(TRUE)
    } else {
      cat("✗ Installation may have failed:", pkg, "\n")
      return(FALSE)
    }
  }, error = function(e) {
    cat("✗ Error installing", pkg, ":", e$message, "\n")
    return(FALSE)
  })
}

cat("Starting installation of required packages...\n")
cat("=============================================\n")

# Install core packages
cat("\n1. Installing core data processing and visualization packages...\n")
core_packages <- c(
  "data.table",   # 高性能数据处理
  "dplyr",        # 数据操作工具
  "tidyr",        # 数据整理工具
  "ggplot2"       # 强大的绘图系统
)

# Install each package
for (pkg in core_packages) {
  if (!is_installed(pkg)) {
    safe_install(pkg)
  } else {
    cat("✓", pkg, "is already installed\n")
  }
}

# Install additional utility packages that complement the core set
cat("\n2. Installing additional utility packages...\n")
utility_packages <- c(
  "purrr",        # 函数式编程工具
  "readr",        # 数据读取工具
  "stringr",      # 字符串处理
  "forcats",      # 因子处理
  "scales"        # 图形标度调整
)

for (pkg in utility_packages) {
  if (!is_installed(pkg)) {
    safe_install(pkg)
  } else {
    cat("✓", pkg, "is already installed\n")
  }
}

# Verify installations
cat("\n3. Verifying installations...\n")
required_packages <- c("data.table", "dplyr", "tidyr", "ggplot2")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed = FALSE
  }
}

cat("\n=============================================\n")
if (all_installed) {
  cat("All required packages installed successfully!\n")
  cat("You can now run your R scripts with:\n")
  cat("library(data.table)\n")
  cat("library(dplyr)\n")
  cat("library(tidyr)\n")
  cat("library(ggplot2)\n")
} else {
  cat("Some packages failed to install. You may need to:\n")
  cat("1. Check your internet connection\n")
  cat("2. Try manual installation: install.packages('package_name')\n")
}

# Test loading the core packages
cat("\n4. Testing package loading...\n")
try({
  library(data.table)
  cat("✓ data.table loaded successfully\n")
}, silent = TRUE)

try({
  library(dplyr)
  cat("✓ dplyr loaded successfully\n")
}, silent = TRUE)

try({
  library(tidyr)
  cat("✓ tidyr loaded successfully\n")
}, silent = TRUE)

try({
  library(ggplot2)
  cat("✓ ggplot2 loaded successfully\n")
}, silent = TRUE)

cat("\nInstallation completed!\n")
