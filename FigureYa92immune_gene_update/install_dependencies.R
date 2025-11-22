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
  "ggstatsplot",  # 强大的绘图系统
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

# Verify installations
cat("\n3. Verifying installations...\n")
required_packages <- c("data.table", "dplyr", "tidyr", "ggstatsplot", "ggplot2")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed = FALSE
    # 如果未安装，尝试再次安装
    # If not installed, try to install again
    cat("  Attempting to reinstall", pkg, "...\n")
    safe_install(pkg)
  }
}

cat("\nInstallation completed!\n")
