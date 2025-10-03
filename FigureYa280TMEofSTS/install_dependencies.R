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
      cat("Warning: Failed to install CRAN package '", package_name, "': ", e$message, "\n")
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
      cat("Warning: Failed to install Bioconductor package '", package_name, "': ", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

# Function to install packages from GitHub
install_github_package <- function(repo, subdir = NULL) {
  package_name <- basename(repo)
  if (!is_package_installed(package_name)) {
    cat("Installing GitHub package:", repo, "\n")
    tryCatch({
      if (!is_package_installed("remotes")) {
        install.packages("remotes")
      }
      if (!is.null(subdir)) {
        remotes::install_github(repo, subdir = subdir)
      } else {
        remotes::install_github(repo)
      }
      cat("Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("Warning: Failed to install GitHub package '", repo, "': ", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

# Function to install from source URL
install_source_package <- function(url) {
  package_name <- gsub(".*/([^/]+)\\.tar\\.gz", "\\1", url)
  if (!is_package_installed(package_name)) {
    cat("Installing from source:", url, "\n")
    tryCatch({
      install.packages(url, repos = NULL, type = "source")
      cat("Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("Warning: Failed to install from source '", url, "': ", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# First install remotes and BiocManager if not already installed
if (!is_package_installed("remotes")) {
  install_cran_package("remotes")
}
if (!is_package_installed("BiocManager")) {
  install_cran_package("BiocManager")
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("ClassDiscovery", "RColorBrewer", "devtools", "gplots")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("ComplexHeatmap", "GSVA")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# Check if all required packages are installed
cat("\nChecking installed packages:\n")
required_packages <- c(cran_packages, bioc_packages)
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
  cat("\nAll required packages are installed successfully!\n")
  cat("You can now run your R scripts in this directory.\n")
} else {
  cat("\nSome packages failed to install. You may need to install them manually.\n")
}
