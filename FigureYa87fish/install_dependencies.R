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
install_github_package <- function(repo) {
  package_name <- basename(repo)
  if (!is_package_installed(package_name)) {
    cat("Installing GitHub package:", repo, "\n")
    tryCatch({
      if (!is_package_installed("devtools")) {
        install.packages("devtools")
      }
      if (!is_package_installed("remotes")) {
        install.packages("remotes")
      }
      # 尝试使用 remotes，它比 devtools 更稳定
      remotes::install_github(repo, dependencies = TRUE, upgrade = "never")
      cat("Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("Failed to install", package_name, ":", e$message, "\n")
      # 尝试备用方法
      cat("Trying alternative installation method...\n")
      try({
        devtools::install_github(repo, dependencies = TRUE)
        cat("Successfully installed with alternative method:", package_name, "\n")
      })
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装基础依赖
cat("\nInstalling base dependencies...\n")
base_packages <- c("devtools", "remotes")
for (pkg in base_packages) {
  install_cran_package(pkg)
}

# fishplot 可能需要的依赖
cat("\nInstalling fishplot dependencies...\n")
fishplot_deps <- c("RColorBrewer", "plotrix")
for (pkg in fishplot_deps) {
  install_cran_package(pkg)
}

# 安装 GitHub 包
cat("\nInstalling GitHub packages...\n")
github_packages <- c("chrisamiller/fishplot")

for (repo in github_packages) {
  install_github_package(repo)
}

# 验证安装
cat("\nVerifying installations...\n")
required_packages <- c("fishplot")
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is successfully installed\n")
  } else {
    cat("✗", pkg, "failed to install\n")
    # 尝试直接下载源码安装
    cat("Attempting direct source installation...\n")
    try({
      install.packages("https://github.com/chrisamiller/fishplot/archive/master.tar.gz", 
                      repos = NULL, type = "source")
    })
  }
}

cat("\n===========================================\n")
cat("Package installation completed!\n")
cat("You can now run your R scripts in this directory.\n")
