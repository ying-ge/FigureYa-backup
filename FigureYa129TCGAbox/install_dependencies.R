#!/usr/bin/env Rscript
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# Function to install CRAN packages
install_cran_packages <- function(packages) {
  packages_to_install <- packages[!sapply(packages, is_package_installed)]
  if (length(packages_to_install) == 0) {
    cat("All required CRAN packages are already installed.\n")
    return()
  }
  for (pkg in packages_to_install) {
    cat("Installing CRAN package:", pkg, "\n")
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
      cat("Successfully installed:", pkg, "\n")
    }, error = function(e) {
      stop("Failed to install CRAN package ", pkg, ": ", e$message)
    })
  }
}

# --- Main Installation Logic ---
cat("Starting R package installation...\n")
cat("===========================================\n")

# Install core CRAN packages, including 'remotes' for versioned install
cat("\nInstalling core CRAN packages...\n")
cran_packages <- c(
  "remotes", "data.table", "ggplot2", "ggpubr", 
  "ggsignif", "gtools", "tidyverse"
)
install_cran_packages(cran_packages)

cat("\n===========================================\n")
cat("Package installation completed!\n")
