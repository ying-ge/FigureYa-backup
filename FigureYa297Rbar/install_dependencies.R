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
basic_packages <- c("ggplot2", "magick", "remotes", "devtools")
for (pkg in basic_packages) {
  install_cran_package(pkg)
}

# Install system dependencies first (important for Linux environments)
cat("\nInstalling system dependencies...\n")
if (.Platform$OS.type == "unix") {
  # Try to install system dependencies for transformr and other packages
  system("sudo apt-get update && sudo apt-get install -y libudunits2-dev libgdal-dev libgeos-dev libproj-dev")
}

# Install transformr first (dependency for gganimate)
cat("\nInstalling transformr...\n")
if (!install_cran_package("transformr")) {
  install_github_package("thomasp85/transformr")
}

# Install gridpattern (dependency for ggpattern)
cat("\nInstalling gridpattern...\n")
if (!install_cran_package("gridpattern")) {
  install_github_package("trevorld/gridpattern")
}

# Install ggpattern
cat("\nInstalling ggpattern...\n")
if (!install_cran_package("ggpattern")) {
  install_github_package("coolbutuseless/ggpattern")
}

# Install gganimate (if needed)
cat("\nInstalling gganimate...\n")
if (!install_cran_package("gganimate")) {
  install_github_package("thomasp85/gganimate")
}

# Verify all packages are installed
cat("\n===========================================\n")
cat("Verifying package installation...\n")

required_packages <- c("transformr", "gridpattern", "ggpattern", "gganimate")
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
  }
}

cat("\nPackage installation completed!\n")
cat("You can now run your R scripts in this directory.\n")

# Try to load the problematic package to confirm it works
cat("\nTesting ggpattern package...\n")
tryCatch({
  library(ggpattern)
  cat("✓ ggpattern loaded successfully!\n")
}, error = function(e) {
  cat("✗ Failed to load ggpattern:", e$message, "\n")
})
