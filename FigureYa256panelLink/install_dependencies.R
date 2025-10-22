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

# Function to install GitHub packages
install_github_package <- function(repo, build_vignettes = FALSE) {
  package_name <- basename(repo)
  if (!is_package_installed(package_name)) {
    cat("Installing GitHub package:", repo, "\n")
    tryCatch({
      if (!is_package_installed("remotes")) {
        install.packages("remotes")
      }
      if (build_vignettes) {
        remotes::install_github(repo, build_vignettes = TRUE)
      } else {
        remotes::install_github(repo)
      }
      cat("Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("Failed to install", repo, ":", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装remotes（用于GitHub包安装）
if (!is_package_installed("remotes")) {
  install.packages("remotes")
}

# 安装CRAN包
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("ggplot2", "magrittr", "tidyverse")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 安装GitHub包
cat("\nInstalling GitHub packages...\n")
github_packages <- list(
  crosslink = list(repo = "zzwch/crosslink", build_vignettes = TRUE)
)

for (pkg_name in names(github_packages)) {
  pkg_info <- github_packages[[pkg_name]]
  install_github_package(pkg_info$repo, pkg_info$build_vignettes)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

cat("You can now run your R scripts in this directory.\n")

# 验证crosslink包是否安装成功
if (is_package_installed("crosslink")) {
  cat("✓ crosslink package successfully installed from GitHub\n")
} else {
  cat("✗ crosslink package installation failed\n")
  cat("You may need to install it manually:\n")
  cat('remotes::install_github("zzwch/crosslink", build_vignettes = TRUE)\n')
}