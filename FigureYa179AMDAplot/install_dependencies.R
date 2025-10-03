#!/usr/bin/env Rscript
# R dependency installation script for FigureYa179AMDAplot

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

cat("Starting R package installation for FigureYa179AMDAplot...\n")
cat("===========================================\n")

# 安装CRAN包
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("ggplot2")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 安装Bioconductor包
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("DESeq2", "S4Vectors")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# 验证所有必需包是否安装成功
cat("\nVerifying required packages...\n")
required_packages <- c("ggplot2", "DESeq2", "S4Vectors", "BiocParallel")
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
  cat("You can now run FigureYa179AMDAplot.Rmd\n")
} else {
  cat("\nSome packages failed to install. Please check the error messages above.\n")
}
