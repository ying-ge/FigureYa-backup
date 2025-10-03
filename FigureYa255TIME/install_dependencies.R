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
    }, error = function(e) {
      cat("Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装 BiocManager（如果需要）
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager")
}

# 根据您提供的library列表确定需要安装的包
cran_packages <- c("viridis", "gplots", "data.table", "tidyestimate")

bioc_packages <- c("GSVA", "ComplexHeatmap", "circlize")

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 特别处理：确保ComplexHeatmap版本至少为2.8
cat("\nChecking ComplexHeatmap version...\n")
if (is_package_installed("ComplexHeatmap")) {
  ch_version <- packageVersion("ComplexHeatmap")
  cat("ComplexHeatmap version:", as.character(ch_version), "\n")
  
  if (ch_version < "2.8.0") {
    cat("Upgrading ComplexHeatmap to latest version (requires >= 2.8.0)...\n")
    BiocManager::install("ComplexHeatmap", update = TRUE, ask = FALSE)
    cat("ComplexHeatmap upgraded to version:", as.character(packageVersion("ComplexHeatmap")), "\n")
  } else {
    cat("ComplexHeatmap version is sufficient (>= 2.8.0)\n")
  }
}

# 验证安装
cat("\n===========================================\n")
cat("Package installation completed!\n")

# 检查所有包是否安装成功
cat("\nVerifying package installation:\n")
required_packages <- c("viridis", "gplots", "data.table", "GSVA", "ComplexHeatmap", "circlize", "tidyestimate")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed <- FALSE
  }
}

cat("\nYou can now run your R scripts in this directory.\n")
