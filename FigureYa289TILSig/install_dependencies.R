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

# Function to add gunzip workaround to GEOquery
add_gunzip_workaround <- function() {
  cat("Adding gunzip workaround to GEOquery...\n")
  tryCatch({
    # Create a gunzip function that uses R's internal gzip utilities
    gunzip <- function(gzfile, destfile = NULL, remove = TRUE) {
      if (is.null(destfile)) {
        destfile <- sub("\\.gz$", "", gzfile)
      }
      # Use R's built-in gunzip functionality
      utils::gunzip(gzfile, destfile, remove = remove)
      return(destfile)
    }
    
    # Add the function to GEOquery namespace
    environment(GEOquery)$gunzip <- gunzip
    cat("Successfully added gunzip workaround\n")
  }, error = function(e) {
    cat("Failed to add gunzip workaround:", e$message, "\n")
  })
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# Install BiocManager if not present
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager")
}

# Installing essential Bioconductor packages first (required for DealGPL570)
cat("\nInstalling essential Bioconductor packages...\n")
essential_bioc_packages <- c("GEOquery", "affy")

for (pkg in essential_bioc_packages) {
  install_bioc_package(pkg)
}

# Add gunzip workaround before installing DealGPL570
add_gunzip_workaround()

# Install hgu133plus2cdf from local file if available, otherwise from Bioconductor
cat("\nInstalling hgu133plus2cdf package...\n")
hgu133plus2cdf_file <- "hgu133plus2cdf_2.18.0.tar.gz"
if (file.exists(hgu133plus2cdf_file)) {
  cat("Installing hgu133plus2cdf from local file:", hgu133plus2cdf_file, "\n")
  install_local_tar_gz(hgu133plus2cdf_file)
} else {
  cat("Local hgu133plus2cdf file not found, installing from Bioconductor...\n")
  install_bioc_package("hgu133plus2cdf")
}

# First install DealGPL570 from local tar.gz file after dependencies are ready
cat("\nInstalling DealGPL570 from local file...\n")
deal_gpl570_file <- "DealGPL570_0.0.1.tar.gz"

if (file.exists(deal_gpl570_file)) {
  install_local_tar_gz(deal_gpl570_file)
} else {
  cat("ERROR: Local file not found:", deal_gpl570_file, "\n")
  cat("Please make sure DealGPL570_0.0.1.tar.gz is in the current directory\n")
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("stringr", "survival", "tibble", "dplyr", "tidyverse")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing remaining Bioconductor packages
cat("\nInstalling remaining Bioconductor packages...\n")
bioc_packages <- c("limma", "sva", "GenomicFeatures", "rtracklayer")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# Final verification
cat("\nVerifying installation...\n")
required_packages <- c("DealGPL570", "stringr", "survival", "tibble", "dplyr", "tidyverse", "GEOquery", "limma", "sva", "GenomicFeatures", "rtracklayer", "affy", "hgu133plus2cdf")
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("[OK]", pkg, "installed successfully\n")
  } else {
    cat("[FAIL]", pkg, "installation failed\n")
  }
}

cat("You can now run your R scripts in this directory.\n")
