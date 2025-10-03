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

# Function to install GitHub packages
install_github_package <- function(repo) {
  pkg_name <- basename(repo)
  if (!is_package_installed(pkg_name)) {
    cat("Installing GitHub package:", repo, "\n")
    tryCatch({
      if (!is_package_installed("remotes")) {
        install.packages("remotes")
      }
      remotes::install_github(repo)
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

# Installing Seurat dependencies first
cat("\nInstalling Seurat dependencies...\n")
seurat_deps <- c("httr", "plotly", "png", "reticulate", "mixtools", "remotes")

for (pkg in seurat_deps) {
  install_cran_package(pkg)
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("CellChat", "RColorBrewer", "Seurat", "dplyr", "magrittr", "patchwork", "pheatmap", "presto")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Install SeuratData from GitHub
cat("\nInstalling SeuratData packages from GitHub...\n")
github_packages <- c("satijalab/seurat-data")  # Main SeuratData package

for (pkg in github_packages) {
  install_github_package(pkg)
}

# Install ifnb.SeuratData using SeuratData's installation function
if (!is_package_installed("ifnb.SeuratData")) {
  cat("\nInstalling ifnb.SeuratData dataset...\n")
  tryCatch({
    if (is_package_installed("SeuratData")) {
      # Use the InstallData function from SeuratData package
      SeuratData::InstallData("ifnb")
      cat("Successfully installed: ifnb.SeuratData\n")
    } else {
      # Fallback: try to install directly from GitHub
      cat("SeuratData not available, trying direct GitHub installation...\n")
      remotes::install_github("satijalab/seurat-data", subdir = "ifnb.SeuratData")
      cat("Successfully installed: ifnb.SeuratData\n")
    }
  }, error = function(e) {
    cat("Failed to install ifnb.SeratData:", e$message, "\n")
    cat("You may need to manually install it using:\n")
    cat("remotes::install_github('satijalab/seurat-data', subdir = 'ifnb.SeuratData')\n")
  })
} else {
  cat("Package already installed: ifnb.SeuratData\n")
}

# Verify all packages are installed
cat("\nVerifying package installation...\n")
required_packages <- c("CellChat", "Seurat", "SeuratData", "ifnb.SeuratData", "dplyr", "patchwork")
missing_packages <- c()

for (pkg in required_packages) {
  if (!is_package_installed(pkg)) {
    missing_packages <- c(missing_packages, pkg)
    cat("MISSING:", pkg, "\n")
  } else {
    cat("OK:", pkg, "\n")
  }
}

cat("\n===========================================\n")
if (length(missing_packages) == 0) {
  cat("All packages successfully installed!\n")
  cat("You can now run your R scripts in this directory.\n")
} else {
  cat("Some packages failed to install:", paste(missing_packages, collapse = ", "), "\n")
  cat("You may need to install them manually.\n")
}

# Load SeuratData to verify it works
cat("\nTesting SeuratData installation...\n")
if (is_package_installed("SeuratData")) {
  tryCatch({
    library(SeuratData)
    cat("SeuratData loaded successfully!\n")
  }, error = function(e) {
    cat("Error loading SeuratData:", e$message, "\n")
  })
}
