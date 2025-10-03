#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(suppressWarnings(requireNamespace(package_name, quietly = TRUE)))
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

# Function to install GitHub packages with better error handling
install_github_package <- function(repo, package_name = NULL) {
  if (is.null(package_name)) {
    package_name <- basename(repo)
  }
  
  if (!is_package_installed(package_name)) {
    cat("Installing GitHub package:", repo, "\n")
    tryCatch({
      if (!is_package_installed("remotes")) {
        install.packages("remotes", quiet = TRUE)
      }
      
      # 设置较长的超时时间并禁用GITHUB_PAT
      old_timeout <- getOption("timeout")
      old_github_pat <- Sys.getenv("GITHUB_PAT")
      options(timeout = 600)
      Sys.setenv(GITHUB_PAT = "")
      
      on.exit({
        options(timeout = old_timeout)
        if (old_github_pat != "") {
          Sys.setenv(GITHUB_PAT = old_github_pat)
        } else {
          Sys.unsetenv("GITHUB_PAT")
        }
      })
      
      remotes::install_github(repo, quiet = TRUE, upgrade = "never")
      cat("✓ Successfully installed from GitHub:", package_name, "\n")
    }, error = function(e) {
      cat("✗ Failed to install from GitHub", repo, ":", e$message, "\n")
      cat("Trying alternative installation method...\n")
      
      # 尝试使用devtools作为备选
      tryCatch({
        if (!is_package_installed("devtools")) {
          install.packages("devtools", quiet = TRUE)
        }
        devtools::install_github(repo, quiet = TRUE, upgrade = "never")
        cat("✓ Successfully installed with devtools:", package_name, "\n")
      }, error = function(e2) {
        cat("✗ All installation methods failed for", repo, "\n")
      })
    })
  } else {
    cat("✓ Package already installed:", package_name, "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装基础依赖
cat("\nInstalling base dependencies...\n")
base_packages <- c("remotes", "devtools", "BiocManager")
for (pkg in base_packages) {
  install_cran_package(pkg)
}

# 安装CRAN包
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("data.table", "pheatmap", "stringr", "ggplot2", "dplyr", "tidyr")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 安装GitHub包 - MCPcounter 需要从GitHub安装
cat("\nInstalling GitHub packages...\n")
github_packages <- c("ebecht/MCPcounter")  # MCPcounter 在GitHub上

for (repo in github_packages) {
  install_github_package(repo)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")
cat("You can now run your R scripts in this directory.\n")

# 验证关键包是否安装成功
cat("\nVerifying critical packages...\n")
critical_packages <- c("MCPcounter", "data.table", "pheatmap")
for (pkg in critical_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is ready\n")
  } else {
    cat("✗", pkg, "is MISSING\n")
  }
}
