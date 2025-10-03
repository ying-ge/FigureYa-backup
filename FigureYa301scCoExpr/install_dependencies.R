#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
# This script installs all required R packages for this project

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
      return(FALSE)
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
  return(TRUE)
}

# Function to install from GitHub
install_github_package <- function(repo, pkg_name = NULL) {
  if (is.null(pkg_name)) {
    pkg_name <- basename(repo)
  }
  
  if (!is_package_installed(pkg_name)) {
    cat("Installing from GitHub:", repo, "\n")
    tryCatch({
      if (!is_package_installed("remotes")) {
        install.packages("remotes")
      }
      remotes::install_github(repo)
      cat("Successfully installed from GitHub:", pkg_name, "\n")
    }, error = function(e) {
      cat("Failed to install from GitHub", repo, ":", e$message, "\n")
      return(FALSE)
    })
  } else {
    cat("Package already installed:", pkg_name, "\n")
  }
  return(TRUE)
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# First install basic dependencies
cat("\nInstalling basic dependencies...\n")
basic_packages <- c("remotes", "devtools", "ggplot2", "magrittr", "patchwork", "ggpubr")
for (pkg in basic_packages) {
  install_cran_package(pkg)
}

# Install Seurat (may have system dependencies)
cat("\nInstalling Seurat...\n")
if (!install_cran_package("Seurat")) {
  # If CRAN installation fails, try GitHub
  install_github_package("satijalab/seurat", "Seurat")
}

# Install SeuratData from GitHub (this is the key package)
cat("\nInstalling SeuratData from GitHub...\n")
if (!install_github_package("satijalab/seurat-data", "SeuratData")) {
  # Alternative installation method
  cat("Trying alternative installation method for SeuratData...\n")
  tryCatch({
    devtools::install_github("satijalab/seurat-data")
    cat("Successfully installed SeuratData via devtools\n")
  }, error = function(e) {
    cat("Alternative installation also failed:", e$message, "\n")
  })
}

# Install other common Seurat-related packages
cat("\nInstalling additional Seurat dependencies...\n")
seurat_deps <- c("cowplot", "dplyr", "tidyr", "reshape2", "RColorBrewer", "viridis")
for (pkg in seurat_deps) {
  install_cran_package(pkg)
}

# Verify installation
cat("\n===========================================\n")
cat("Verifying package installation...\n")

required_packages <- c("Seurat", "SeuratData", "ggplot2", "patchwork")
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
  }
}

# Test loading SeuratData
cat("\nTesting SeuratData package...\n")
tryCatch({
  if (is_package_installed("SeuratData")) {
    library(SeuratData)
    cat("✓ SeuratData loaded successfully!\n")
    
    # Check available datasets
    available_datasets <- AvailableData()
    cat("Available datasets:", length(available_datasets), "\n")
  } else {
    cat("✗ SeuratData not installed\n")
  }
}, error = function(e) {
  cat("✗ Failed to load SeuratData:", e$message, "\n")
})

# If SeuratData installation fails completely, provide manual instructions
if (!is_package_installed("SeuratData")) {
  cat("\n" + strrep("=", 50) + "\n")
  cat("MANUAL INSTALLATION INSTRUCTIONS:\n")
  cat("1. Make sure you have remotes installed: install.packages('remotes')\n")
  cat("2. Install SeuratData manually: remotes::install_github('satijalab/seurat-data')\n")
  cat("3. If that fails, try: devtools::install_github('satijalab/seurat-data')\n")
  cat("4. You may need to install system dependencies first\n")
  cat(strrep("=", 50) + "\n")
}

cat("\nPackage installation completed!\n")
cat("You can now run your R scripts in this directory.\n")
