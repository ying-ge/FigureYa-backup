#!/usr/bin/env Rscript
# Auto-generated R dependency installation script for ternary plots
# This script installs all required R packages for this project

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

cat("Starting R package installation for ternary plots...\n")
cat("===========================================\n")

# 安装所有CRAN包
cat("\nInstalling CRAN packages...\n")
cran_packages <- c(
  "directlabels", "ggplot2", "proto", "scales", "tidyverse", 
  "dplyr", "grid", "gtable", "plyr", "MASS", "compositions"
)

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 验证安装
cat("\n===========================================\n")
cat("Verifying installation...\n")

required_packages <- c("ggplot2", "directlabels", "scales", "tidyverse")
success_count <- 0

for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is ready\n")
    success_count <- success_count + 1
  } else {
    cat("✗", pkg, "is MISSING\n")
  }
}

cat("\nInstallation summary:\n")
cat("Successfully installed:", success_count, "/", length(required_packages), "packages\n")

if (success_count == length(required_packages)) {
  cat("✅ All packages installed successfully!\n")
  cat("You can now run your ternary plot scripts.\n")
} else {
  cat("⚠️  Some packages failed to install.\n")
}

cat("\nInstallation completed!\n")
