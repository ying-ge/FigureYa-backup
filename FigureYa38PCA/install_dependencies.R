#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options(repos = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# Function to install CRAN packages
install_cran_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("Installing CRAN package:", package_name, "\n")
    tryCatch({
      install.packages(package_name, dependencies = TRUE)
      cat("✅ Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("❌ Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("✅ Package already installed:", package_name, "\n")
  }
}

# Function to install Bioconductor packages
install_bioc_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("Installing Bioconductor package:", package_name, "\n")
    tryCatch({
      if (!is_package_installed("BiocManager")) {
        install.packages("BiocManager")
      }
      BiocManager::install(package_name, update = FALSE)
      cat("✅ Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("❌ Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("✅ Package already installed:", package_name, "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("dplyr", "ggplot2", "plyr", "devtools", "reshape2", "tidyr")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 安装其他可能需要的包
cat("\nInstalling additional useful packages...\n")
additional_packages <- c("tidyverse", "data.table", "RColorBrewer", "pheatmap", "survival", "survminer")

for (pkg in additional_packages) {
  install_cran_package(pkg)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# Test if key packages can be loaded
cat("\nTesting key packages...\n")
test_packages <- c("dplyr", "ggplot2", "plyr", "reshape2", "tidyr")

for (pkg in test_packages) {
  if (require(pkg, quietly = TRUE, character.only = TRUE)) {
    cat("✅", pkg, "package loaded successfully!\n")
  } else {
    cat("❌", pkg, "package could not be loaded.\n")
  }
}

cat("\nYou can now run your R scripts in this directory.\n")
cat("If any packages failed to install, try installing them manually:\n")
cat("install.packages('package_name')\n")
