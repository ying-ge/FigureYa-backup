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
      cat("Warning: Failed to install CRAN package '", package_name, "': ", e$message, "\n")
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
      cat("Warning: Failed to install Bioconductor package '", package_name, "': ", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

# Function to install SeuratData packages
install_seurat_data <- function() {
  if (!is_package_installed("SeuratData")) {
    cat("Installing SeuratData...\n")
    tryCatch({
      if (!is_package_installed("remotes")) {
        install.packages("remotes")
      }
      # Install SeuratData
      remotes::install_github("satijalab/seurat-data")
      cat("Successfully installed: SeuratData\n")
    }, error = function(e) {
      cat("Warning: Failed to install SeuratData from GitHub: ", e$message, "\n")
    })
  } else {
    cat("Package already installed: SeuratData\n")
  }
  
  # Install pbmc3k dataset
  if (!is_package_installed("pbmc3k.SeuratData")) {
    cat("Installing pbmc3k.SeuratData...\n")
    tryCatch({
      # Install the dataset
      if (is_package_installed("SeuratData")) {
        SeuratData::InstallData("pbmc3k")
        cat("Successfully installed: pbmc3k.SeuratData\n")
      } else {
        cat("Warning: Cannot install pbmc3k data because SeuratData is not available\n")
      }
    }, error = function(e) {
      cat("Warning: Failed to install pbmc3k.SeuratData: ", e$message, "\n")
    })
  } else {
    cat("Package already installed: pbmc3k.SeuratData\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# First install BiocManager if not already installed
if (!is_package_installed("BiocManager")) {
  cat("Installing BiocManager...\n")
  install.packages("BiocManager")
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("RColorBrewer", "Seurat", "dplyr", "ggplot2", "magrittr", "remotes")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("monocle")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# Special installation for SeuratData
cat("\nInstalling SeuratData packages...\n")
install_seurat_data()

cat("\n===========================================\n")
cat("Package installation completed!\n")

# Check if all required packages are installed
cat("\nChecking installed packages:\n")
all_packages <- c(cran_packages, bioc_packages, "SeuratData", "pbmc3k.SeuratData")
for (pkg in all_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
  }
}

cat("You can now run your R scripts in this directory.\n")
