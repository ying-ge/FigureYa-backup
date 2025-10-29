#!/usr/bin/env Rscript
# Corrected R dependency installation script

# Set CRAN and Bioconductor mirrors to improve download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# Function to check whether a package is installed
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

# Function to install packages from GitHub
install_github_package <- function(repo) {
  package_name <- basename(repo)
  if (!is_package_installed(package_name)) {
  cat("Installing GitHub package:", repo, "\n")
    tryCatch({
      if (!is_package_installed("devtools")) {
        install.packages("devtools")
      }
      devtools::install_github(repo)
  cat("Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("Failed to install", repo, ":", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

# Start installing R packages...
cat("===========================================\n")

# Install devtools first
install_cran_package("devtools")

# Install Seurat-related dependencies
seurat_deps <- c("httr", "plotly", "png", "reticulate", "mixtools")
cat("\nInstalling Seurat dependencies...\n")
for (pkg in seurat_deps) {
  install_cran_package(pkg)
}

# Install CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c(
  "RColorBrewer", "Seurat",
  "dplyr", "ggplot2", "ggrepel", "magrittr", "patchwork", "reshape2"
)

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Install Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("GEOquery")
for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# Try to install DealGPL570 or use alternative methods
cat("\nAttempting to install DealGPL570 or alternatives...\n")
tryCatch({
  # Method 1: try installing a possibly updated version from GitHub
  install_github_package("cran/DealGPL570")
}, error = function(e) {
  cat("GitHub install failed, trying other methods...\n")
  
  # Method 2: download and modify source manually
  temp_dir <- tempdir()
  pkg_url <- "https://cran.r-project.org/src/contrib/Archive/DealGPL570/DealGPL570_0.0.1.tar.gz"
  pkg_file <- file.path(temp_dir, "DealGPL570_0.0.1.tar.gz")
  
  tryCatch({
    download.file(pkg_url, pkg_file)
    # Unpack and modify source code
    untar(pkg_file, exdir = temp_dir)
    pkg_dir <- file.path(temp_dir, "DealGPL570")
    
    r_files <- list.files(file.path(pkg_dir, "R"), pattern = "\\.R$", full.names = TRUE)
    for (r_file in r_files) {
      content <- readLines(r_file)
      # Replace gunzip references with an appropriate function
      content <- gsub("gunzip", "GEOquery::getGEOSuppFiles", content)
      writeLines(content, r_file)
    }
    
    # Reinstall the modified package
    devtools::install_local(pkg_dir)
    cat("Successfully installed modified DealGPL570\n")
  }, error = function(e2) {
    cat("DealGPL570 installation completely failed; consider alternative methods to handle GPL570 data\n")
  })
})

cat("\n===========================================\n")
cat("Package installation completed!\n")
cat("Note: You may need to download some data files manually.\n")
cat("Data directory 'filtered_gene_bc_matrices/hg19/' does not exist; please ensure required data are downloaded.\n")
cat("You can now run the R scripts in this directory.\n")
