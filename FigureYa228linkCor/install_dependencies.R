#!/usr/bin/env Rscript
# Fixed R dependency installation script - offline version

# Set mirrors for better download performance (for other packages that need internet)
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

# Function to install packages from local tar.gz files
install_local_package <- function(tar_file) {
  package_name <- gsub("\\.tar\\.gz$", "", basename(tar_file))
  package_name <- gsub("-master$", "", package_name)  # Remove -master suffix
  
  if (!is_package_installed(package_name)) {
    cat("Installing package from local file:", tar_file, "\n")
    tryCatch({
      # Check if file exists
      if (!file.exists(tar_file)) {
        stop(paste("File does not exist:", tar_file))
      }
      
      # Install local package
      install.packages(tar_file, repos = NULL, type = "source")
      cat("Successfully installed from local file:", package_name, "\n")
    }, error = function(e) {
      cat("Local installation failed", tar_file, ":", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# First install ggcor dependencies (if any)
cat("\nInstalling ggcor dependencies...\n")
ggcor_dependencies <- c("ggplot2", "dplyr", "tidyr", "tibble", "rlang", "tidygraph", "vegan", "ade4")
for (pkg in ggcor_dependencies) {
  install_cran_package(pkg)
}

# Install ggcor from local file
cat("\nInstalling ggcor from local file...\n")
local_packages <- c("ggcor-master.tar.gz")
for (pkg_file in local_packages) {
  install_local_package(pkg_file)
}

# Install other CRAN packages
cat("\nInstalling other CRAN packages...\n")
cran_packages <- c("ade4", "data.table", "ggnewscale")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Install Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("GSVA")
for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}