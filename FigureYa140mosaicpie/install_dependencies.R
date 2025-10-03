#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))

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
      return(TRUE)
    }, error = function(e) {
      cat("Warning: Failed to install CRAN package '", package_name, "': ", e$message, "\n")
      return(FALSE)
    })
  } else {
    cat("Package already installed:", package_name, "\n")
    return(TRUE)
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# Installing CRAN packages
cat("\nInstalling required CRAN packages...\n")
required_packages <- c("readxl", "ggplot2", "reshape2")

for (pkg in required_packages) {
  install_cran_package(pkg)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# Check if all required packages are installed
cat("\nChecking installed packages:\n")
all_installed <- TRUE

for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed <- FALSE
  }
}

if (all_installed) {
  cat("\nAll required packages are successfully installed!\n")
} else {
  cat("\nSome packages failed to install. You may need to install them manually.\n")
}

cat("You can now run your R scripts in this directory.\n")
