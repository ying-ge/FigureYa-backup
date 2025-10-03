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

# Function to install GitHub packages
install_github_package <- function(repo) {
  pkg_name <- basename(repo)
  if (!is_package_installed(pkg_name)) {
    cat("Installing GitHub package:", repo, "\n")
    tryCatch({
      if (!is_package_installed("devtools")) {
        install.packages("devtools")
      }
      devtools::install_github(repo)
      cat("Successfully installed:", pkg_name, "\n")
    }, error = function(e) {
      cat("Failed to install", pkg_name, ":", e$message, "\n")
    })
  } else {
    cat("Package already installed:", pkg_name, "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("ggcorrplot", "ggprism", "magrittr", "tidyverse", "devtools")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing GitHub packages
cat("\nInstalling GitHub packages...\n")
github_packages <- c("omnideconv/immunedeconv")  # immunedeconv is on GitHub

for (pkg in github_packages) {
  install_github_package(pkg)
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("SummarizedExperiment", "TCGAbiolinks", "clusterProfiler", "org.Hs.eg.db")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# Note: quantiseqr might also need special handling if it's not on CRAN
# If quantiseqr fails, check if it needs to be installed from GitHub as well
if (!is_package_installed("quantiseqr")) {
  cat("\nAttempting to install quantiseqr...\n")
  tryCatch({
    install_cran_package("quantiseqr")
  }, error = function(e) {
    cat("quantiseqr not found on CRAN, trying GitHub...\n")
    install_github_package("ccbeco/quantiseqr")
  })
}

cat("\n===========================================\n")
cat("Package installation completed!\n")
cat("You can now run your R scripts in this directory.\n")
