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

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("data.table")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("genefu", "ChAMPdata", "ComplexHeatmap", "circlize")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 检查是否有grey90包（可能是个拼写错误）
cat("\nChecking for additional packages...\n")
if (!is_package_installed("grDevices")) {
  cat("Note: grDevices is a base R package, no need to install\n")
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# 验证所有必需的包是否安装成功
cat("\nVerifying package installation...\n")
required_packages <- c("data.table", "genefu", "ChAMPdata", "ComplexHeatmap", "circlize")

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
  cat("\nSome packages failed to install. Please check the error messages above.\n")
  cat("You may need to manually install missing packages.\n")
}
