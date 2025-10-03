#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(requireNamespace(package_name, quietly = TRUE))
}

# Function to install CRAN packages
install_cran_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("Installing CRAN package:", package_name, "\n")
    tryCatch({
      install.packages(package_name, dependencies = TRUE, quiet = TRUE)
      cat("✓ Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("✗ Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("✓ Package already installed:", package_name, "\n")
  }
}

# Function to install Bioconductor packages
install_bioc_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("Installing Bioconductor package:", package_name, "\n")
    tryCatch({
      if (!is_package_installed("BiocManager")) {
        install.packages("BiocManager", quiet = TRUE)
      }
      BiocManager::install(package_name, update = FALSE, ask = FALSE, quiet = TRUE)
      cat("✓ Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("✗ Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("✓ Package already installed:", package_name, "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装BiocManager
if (!is_package_installed("BiocManager")) {
  cat("Installing BiocManager...\n")
  install.packages("BiocManager", quiet = TRUE)
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("ggplot2", "ggrepel", "ggthemes", "dplyr", "tidyr", "readr")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("GEOquery", "limma")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 验证所有必需的包是否安装成功
cat("\n===========================================\n")
cat("Verifying package installation...\n")

required_packages <- c("ggplot2", "ggrepel", "ggthemes", "GEOquery", "limma")
all_installed <- TRUE

for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is ready\n")
  } else {
    cat("✗", pkg, "is MISSING\n")
    all_installed <- FALSE
  }
}

if (all_installed) {
  cat("\n✅ All packages installed successfully!\n")
  cat("You can now run your R scripts in this directory.\n")
} else {
  cat("\n❌ Some packages failed to install.\n")
  cat("Please check the error messages above and try manual installation.\n")
  
  # 提供手动安装建议
  cat("\nManual installation commands:\n")
  cat("install.packages(c('ggplot2', 'ggrepel', 'ggthemes', 'dplyr', 'tidyr', 'readr'))\n")
  cat("if (!require('BiocManager', quietly = TRUE))\n")
  cat("    install.packages('BiocManager')\n")
  cat("BiocManager::install(c('GEOquery', 'limma'))\n")
}
