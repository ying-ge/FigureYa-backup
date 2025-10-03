#!/usr/bin/env Rscript
# Auto-generated R dependency installation script for SVM analysis
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

# Special handling for sigFeature
install_sigFeature <- function() {
  if (!is_package_installed("sigFeature")) {
    cat("Installing sigFeature from Bioconductor...\n")
    tryCatch({
      if (!is_package_installed("BiocManager")) {
        install.packages("BiocManager", quiet = TRUE)
      }
      BiocManager::install("sigFeature", update = FALSE, ask = FALSE, quiet = TRUE)
      cat("✓ Successfully installed: sigFeature\n")
    }, error = function(e) {
      cat("✗ Bioconductor installation failed:", e$message, "\n")
      
      # Alternative: try from GitHub
      cat("Trying alternative installation from GitHub...\n")
      tryCatch({
        if (!is_package_installed("remotes")) {
          install.packages("remotes", quiet = TRUE)
        }
        remotes::install_github("drjitendra/sigFeature")
        cat("✓ Successfully installed sigFeature from GitHub\n")
      }, error = function(e2) {
        cat("✗ All sigFeature installation attempts failed\n")
      })
    })
  } else {
    cat("✓ sigFeature already installed\n")
  }
}

cat("Starting R package installation for SVM analysis...\n")
cat("===========================================\n")

# 首先安装BiocManager
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager", quiet = TRUE)
}

# Installing CRAN packages (excluding sigFeature)
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("VennDiagram", "caret", "e1071", "glmnet", "randomForest", 
                   "tidyverse", "dplyr", "ggplot2", "remotes")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Special installation for sigFeature (Bioconductor)
cat("\nInstalling sigFeature...\n")
install_sigFeature()

# Installing other Bioconductor packages (if any)
cat("\nInstalling other Bioconductor packages...\n")
bioc_packages <- c()  # 添加其他Bioconductor包到这里

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 验证安装
cat("\n===========================================\n")
cat("Verifying installation...\n")

required_packages <- c("VennDiagram", "caret", "e1071", "glmnet", "randomForest", 
                       "sigFeature", "tidyverse")

success_count <- 0

for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is ready\n")
    success_count <- success_count + 1
    
    # 测试关键包的功能
    if (pkg == "sigFeature") {
      cat("Testing sigFeature functionality...\n")
      tryCatch({
        library(sigFeature)
        cat("✓ sigFeature loaded successfully\n")
      }, error = function(e) {
        cat("✗ sigFeature functionality test failed:", e$message, "\n")
      })
    }
  } else {
    cat("✗", pkg, "is MISSING\n")
  }
}

cat("\nInstallation summary:\n")
cat("Successfully installed:", success_count, "/", length(required_packages), "packages\n")

if (success_count == length(required_packages)) {
  cat("✅ All packages installed successfully!\n")
  cat("You can now run your SVM analysis scripts.\n")
} else {
  cat("⚠️  Some packages failed to install.\n")
  
  # 提供手动安装指导
  if (!is_package_installed("sigFeature")) {
    cat("\nFor manual sigFeature installation:\n")
    cat("if (!require('BiocManager', quietly = TRUE))\n")
    cat("    install.packages('BiocManager')\n")
    cat("BiocManager::install('sigFeature')\n")
    cat("# Or from GitHub:\n")
    cat("remotes::install_github('drjitendra/sigFeature')\n")
  }
}

# 提供备选特征选择方案
cat("\nAlternative feature selection packages (if sigFeature fails):\n")
cat("- Boruta: install.packages('Boruta')\n")
cat("- FSelector: install.packages('FSelector')\n") 
cat("- caret for recursive feature elimination\n")
cat("- mRMRe: BiocManager::install('mRMRe')\n")
