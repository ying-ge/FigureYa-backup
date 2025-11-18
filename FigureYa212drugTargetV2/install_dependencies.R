#!/usr/bin/env Rscript

# Set mirrors
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# Check whether a package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# Install CRAN packages
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

# Install Bioconductor packages
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

cat("Starting R package installation for FigureYa212drugTargetV2...\n")
cat("===========================================\n")

# Install BiocManager if missing
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager")
}

# Install Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("impute", "sva")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# Install CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c(
  "tidyverse",
  "ISOpureR",
  "SimDesign",
  "cowplot",
  "ridge",
  "car"
)

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")