#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
# This script installs all required R packages for FigureYa211multiCohortImmSubtype
# Updated to use tidyestimate instead of the old estimate package

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
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
      cat("Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
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
      BiocManager::install(package_name, update = FALSE, ask = FALSE)
      cat("Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

cat("Starting R package installation for FigureYa211multiCohortImmSubtype...\n")
cat("===========================================\n")

# 首先安装 BiocManager（如果需要）
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager")
}

# CRAN packages required
# Updated: replaced 'estimate' with 'tidyestimate'
cran_packages <- c("tidyestimate", "pheatmap", "survival", "survminer",
                   "ggplot2", "dplyr", "tidyr", "ggpubr", "reshape2",
                   "tibble", "readr")

# Bioconductor packages required
bioc_packages <- c("sva", "ConsensusClusterPlus", "GSVA", "preprocessCore")

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# Additional immunology packages
cat("\nInstalling additional immunology packages...\n")
additional_bioc_packages <- c("immunedeconv", "limma", "edgeR")
for (pkg in additional_bioc_packages) {
  install_bioc_package(pkg)
}

# Verification
cat("\n===========================================\n")
cat("Package installation completed!\n")

# Check if all required packages are installed
cat("\nVerifying package installation:\n")
required_packages <- c("sva", "tidyestimate", "ConsensusClusterPlus", "pheatmap",
                      "survival", "survminer")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed <- FALSE
  }
}

# Test key packages
cat("\nTesting key packages...\n")
test_packages <- c("sva", "tidyestimate", "survival")
for (pkg in test_packages) {
  if (is_package_installed(pkg)) {
    tryCatch({
      library(pkg, character.only = TRUE)
      cat("✓", pkg, "package loaded successfully\n")
    }, error = function(e) {
      cat("✗ Error loading", pkg, ":", e$message, "\n")
    })
  }
}

cat("\nYou can now run FigureYa211multiCohortImmSubtype.Rmd!\n")
