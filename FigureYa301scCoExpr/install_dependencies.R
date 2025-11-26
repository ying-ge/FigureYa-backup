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

# Install CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("ggplot2", "magrittr", "patchwork", "ggpubr", "Seurat")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Install SeuratData from GitHub
cat("\nInstalling SeuratData from GitHub...\n")
if (!install_github_package("satijalab/seurat-data", "SeuratData")) {
  # Alternative installation method
  cat("Trying alternative installation method for SeuratData...\n")
  tryCatch({
    if (!is_package_installed("remotes")) {
      install.packages("remotes")
    }
    remotes::install_github("satijalab/seurat-data")
    cat("Successfully installed SeuratData via remotes\n")
  }, error = function(e) {
    cat("Alternative installation also failed:", e$message, "\n")
  })
}

# Download from http://seurat.nygenome.org/src/contrib/pbmc3k.SeuratData_3.1.4.tar.gz
# Install pbmc3k.SeuratData locally if not already installed
if (!requireNamespace("pbmc3k.SeuratData", quietly = TRUE)) {
  cat("Installing pbmc3k.SeuratData_3.1.4.tar.gz from local file...\n")
  tryCatch({
    install.packages("pbmc3k.SeuratData_3.1.4.tar.gz", repos = NULL, type = "source")
    cat("pbmc3k.SeuratData installed successfully!\n")
  }, error = function(e) {
    cat("Failed to install pbmc3k.SeuratData locally:", e$message, "\n")
  })
} else {
  cat("pbmc3k.SeuratData package already installed.\n")
}

cat("\nPackage installation completed!\n")
cat("You can now run your R scripts in this directory.\n")
