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

# Function to install package from local tar.gz file
install_local_tar_gz <- function(package_path) {
  cat("Installing package from local tar.gz file:", package_path, "\n")
  tryCatch({
    install.packages(package_path, repos = NULL, type = "source")
    cat("Successfully installed package from local file\n")
  }, error = function(e) {
    cat("Failed to install from local file:", e$message, "\n")
  })
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# First install DealGPL570 from local tar.gz file
cat("\nInstalling DealGPL570 from local file...\n")
deal_gpl570_file <- "DealGPL570_0.0.1.tar.gz"

if (file.exists(deal_gpl570_file)) {
  install_local_tar_gz(deal_gpl570_file)
} else {
  cat("❌ Local file not found:", deal_gpl570_file, "\n")
  cat("Please make sure DealGPL570_0.0.1.tar.gz is in the current directory\n")
}

# Install BiocManager if not present
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager")
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("dplyr", "stringr", "survival", "tibble", "tidyverse")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("GEOquery", "limma", "sva", "affy")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# Final verification
cat("\nVerifying installation...\n")
required_packages <- c("DealGPL570", "GEOquery", "limma", "sva")
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✅", pkg, "installed successfully\n")
  } else {
    cat("❌", pkg, "installation failed\n")
  }
}

cat("You can now run your R scripts in this directory.\n")
