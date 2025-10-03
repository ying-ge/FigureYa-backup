#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# Function to install CRAN packages (vectorized)
install_cran_packages <- function(packages) {
  for (pkg in packages) {
    if (!is_package_installed(pkg)) {
      cat("Installing CRAN package:", pkg, "\n")
      tryCatch({
        install.packages(pkg, dependencies = TRUE)
        cat("Successfully installed:", pkg, "\n")
      }, error = function(e) {
        stop("Failed to install CRAN package ", pkg, ": ", e$message)
      })
    } else {
      cat("Package already installed:", pkg, "\n")
    }
  }
}

# Function to install Bioconductor packages (vectorized)
install_bioc_packages <- function(packages) {
  # Check for BiocManager and install if not present
  if (!is_package_installed("BiocManager")) {
    install.packages("BiocManager")
  }
  
  # Filter out already installed packages
  packages_to_install <- packages[!sapply(packages, is_package_installed)]
  
  if (length(packages_to_install) > 0) {
    cat("Installing Bioconductor package(s):", paste(packages_to_install, collapse=", "), "\n")
    tryCatch({
      BiocManager::install(packages_to_install, update = FALSE, ask = FALSE)
      cat("Successfully submitted for installation:", paste(packages_to_install, collapse=", "), "\n")
    }, error = function(e) {
      stop("Failed to install Bioconductor packages: ", e$message)
    })
  } else {
    cat("All required Bioconductor packages are already installed.\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# --- Step 1: Install Bioconductor Packages FIRST ---
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("clusterProfiler", "GSVA", "SpatialExperiment")
install_bioc_packages(bioc_packages)


# --- Step 2: Install CRAN Packages ---
# 'magick' is a CRAN package but depends on a system library (libmagick++-dev)
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("gplots", "pheatmap", "magick")
install_cran_packages(cran_packages)


cat("\n===========================================\n")
cat("Package installation completed!\n")
cat("You can now run your R scripts in this directory.\n")
