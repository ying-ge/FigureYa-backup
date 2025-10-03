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
    }, error = function(e) {  # 修复这里：error = function
      cat("Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

# Function to install packages with system dependencies
install_with_deps <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("Installing package with system dependencies:", package_name, "\n")
    
    # For ridge package which requires GSL
    if (package_name == "ridge") {
      cat("Installing system dependencies for ridge package...\n")
      
      # Try to install GSL system dependency
      system_deps_installed <- tryCatch({
        if (Sys.info()["sysname"] %in% c("Linux", "Darwin")) {
          # For Linux systems
          if (file.exists("/etc/debian_version")) {
            system("sudo apt-get update && sudo apt-get install -y libgsl-dev")
          } else if (file.exists("/etc/redhat-release")) {
            system("sudo yum install -y gsl-devel")
          } else if (Sys.info()["sysname"] == "Darwin") {
            system("brew install gsl")
          }
          TRUE
        } else {
          cat("Please install GSL library manually for your system\n")
          FALSE
        }
      }, error = function(e) {
        cat("Failed to install system dependencies:", e$message, "\n")
        FALSE
      })
      
      if (system_deps_installed) {
        install_cran_package(package_name)
      } else {
        cat("Skipping ridge package installation due to missing system dependencies\n")
      }
    } else {
      install_cran_package(package_name)
    }
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# First install BiocManager if not present
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager")
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c(
  "sva", 
  "preprocessCore", 
  "impute"
)

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("car", "cowplot", "ggplot2", "glmnet", "tidyverse")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Install ridge package separately with system dependencies
cat("\nInstalling ridge package (requires system dependencies)...\n")
install_with_deps("ridge")

cat("\n===========================================\n")
cat("Package installation completed!\n")

# Verify installation
cat("\nVerifying package installation:\n")
required_packages <- c(
  "sva", "preprocessCore", "impute", "car", "cowplot", 
  "ggplot2", "glmnet", "ridge"
)

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
  cat("\n✅ All required packages installed successfully!\n")
} else {
  cat("\n⚠️ Some packages failed to install. You may need to install them manually.\n")
}

cat("You can now run your R scripts in this directory.\n")
