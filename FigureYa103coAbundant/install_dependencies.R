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
    }, error = function(e) {
      cat("Failed to install", package_name, ":", e$message, "\n")
      # Stop execution if a critical package fails
      stop("Halting due to failed installation.")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

# Function to install Bioconductor packages (修复版)
install_bioc_packages <- function(package_names) {  # 改为复数
  # 找出未安装的包
  missing_packages <- package_names[!sapply(package_names, is_package_installed)]
  
  if (length(missing_packages) > 0) {
    cat("Installing Bioconductor package(s):", paste(missing_packages, collapse=", "), "\n")
    tryCatch({
      if (!is_package_installed("BiocManager")) {
        install.packages("BiocManager")
      }
      BiocManager::install(missing_packages, update = FALSE, ask = FALSE)
      cat("Successfully installed:", paste(missing_packages, collapse=", "), "\n")
    }, error = function(e) {
      cat("Failed to install Bioconductor packages:", e$message, "\n")
      # Stop execution if a critical package fails
      stop("Halting due to failed installation.")
    })
  } else {
    cat("All Bioconductor packages already installed:", paste(package_names, collapse=", "), "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# --- Step 1: Install Bioconductor Packages FIRST ---
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c(
  "ClassDiscovery", # From a previous error
  "impute",         # WGCNA dependency
  "preprocessCore", # WGCNA dependency
  "GO.db",          # WGCNA dependency
  "AnnotationDbi"   # WGCNA dependency
)
install_bioc_packages(bioc_packages)  # 改为调用修复后的函数

# 等待Bioconductor包安装完成
Sys.sleep(5)

# --- Step 2: Install CRAN Packages ---
cat("\nInstalling CRAN packages...\n")
cran_packages <- c(
  "WGCNA", 
  "gplots", 
  "pheatmap"
)

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# --- Step 3: 验证安装 ---
cat("\nVerifying package installation...\n")
all_packages <- c(bioc_packages, cran_packages)

for (pkg in all_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "FAILED to install\n")
  }
}

cat("\n===========================================\n")
cat("Package installation completed!\n")
cat("You can now run your R scripts in this directory.\n")
