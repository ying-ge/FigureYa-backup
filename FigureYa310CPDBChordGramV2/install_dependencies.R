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

# Function to install ktplots from GitHub with zktuong repository
install_ktplots <- function() {
  if (!is_package_installed("ktplots")) {
    cat("Installing ktplots from GitHub (zktuong repository)...\n")
    tryCatch({
      if (!is_package_installed("devtools")) {
        install.packages("devtools")
      }
      devtools::install_github('zktuong/ktplots', dependencies = TRUE)
      cat("Successfully installed: ktplots\n")
    }, error = function(e) {
      cat("Failed to install ktplots:", e$message, "\n")
      cat("You may need to install it manually: devtools::install_github('zktuong/ktplots', dependencies = TRUE)\n")
    })
  } else {
    cat("Package already installed: ktplots\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# First install devtools for GitHub packages
cat("\nInstalling devtools package...\n")
install_cran_package("devtools")

# Install ktplots from GitHub (zktuong repository)
cat("\nInstalling ktplots from zktuong repository...\n")
install_ktplots()

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("RColorBrewer", "Seurat", "ggraph", "ggrepel", "grid", "igraph", "reshape2")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("SingleCellExperiment", "circlize")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# Test if ktplots can be loaded
cat("\nTesting ktplots package...\n")
if (require("ktplots", quietly = TRUE)) {
  cat("✅ ktplots package loaded successfully!\n")
  cat("Package version:", as.character(packageVersion("ktplots")), "\n")
} else {
  cat("❌ ktplots package could not be loaded.\n")
  cat("You may need to install it manually:\n")
  cat("devtools::install_github('zktuong/ktplots', dependencies = TRUE)\n")
}

cat("You can now run your R scripts in this directory.\n")
