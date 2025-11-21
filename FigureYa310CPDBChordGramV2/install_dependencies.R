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

# Function to install SeuratData package (from GitHub)
install_seurat_data <- function() {
  if (!is_package_installed("SeuratData")) {
    cat("Installing SeuratData package...\n")
    tryCatch({
      # Try CRAN first
      install.packages("SeuratData", repos = "https://cloud.r-project.org/")
      if (!is_package_installed("SeuratData")) {
        # If CRAN fails, try GitHub
        if (!is_package_installed("devtools")) {
          install.packages("devtools", repos = "https://cloud.r-project.org/")
        }
        devtools::install_github("satijalab/seurat-data", quiet = TRUE)
      }
      if (is_package_installed("SeuratData")) {
        cat("Successfully installed: SeuratData\n")
      } else {
        cat("Failed to install SeuratData\n")
      }
    }, error = function(e) {
      cat("Failed to install SeuratData:", e$message, "\n")
    })
  } else {
    cat("Package already installed: SeuratData\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("RColorBrewer", "Seurat", "ggraph", "ggrepel", "grid", "igraph", "reshape2")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("SingleCellExperiment")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# Installing SeuratData (datasets need to be installed separately when needed)
cat("\nInstalling SeuratData package...\n")
cat("Note: To install ifnb dataset, run: SeuratData::InstallData('ifnb')\n")
install_seurat_data()

cat("\n===========================================\n")
cat("Package installation completed!\n")
cat("You can now run your R scripts in this directory.\n")
