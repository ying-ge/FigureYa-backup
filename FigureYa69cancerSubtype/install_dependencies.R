#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
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
      install.packages(package_name, dependencies = TRUE)
      cat("✓ Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("✗ Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("✓ Package already installed:", package_name, "\n")
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
      devtools::install_github(repo)
      cat("✓ Successfully installed:", package_name, "\n")
      return(TRUE)
    }, error = function(e) {
      cat("✗ Failed to install", package_name, ":", e$message, "\n")
      return(FALSE)
    })
  } else {
    cat("✓ Package already installed:", package_name, "\n")
    return(TRUE)
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装基础工具
if (!is_package_installed("devtools")) {
  install_cran_package("devtools")
}

# 安装CancerSubtypes从正确的GitHub仓库
cat("\nInstalling CancerSubtypes from GitHub...\n")
cancersubtypes_installed <- install_github_package("taoshengxu/CancerSubtypes")

# 安装其他CRAN包
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("data.table", "stringr", "survival", "cluster", "impute")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 安装Bioconductor依赖
cat("\nInstalling Bioconductor dependencies...\n")
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager")
}

bioc_packages <- c("impute", "ConsensusClusterPlus")
for (pkg in bioc_packages) {
  if (!is_package_installed(pkg)) {
    tryCatch({
      BiocManager::install(pkg, update = FALSE, ask = FALSE)
      cat("✓ Successfully installed:", pkg, "\n")
    }, error = function(e) {
      cat("✗ Failed to install", pkg, ":", e$message, "\n")
    })
  } else {
    cat("✓ Package already installed:", pkg, "\n")
  }
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# 验证安装
cat("\nVerifying package installation:\n")
required_packages <- c("CancerSubtypes", "data.table", "stringr", "survival", "ConsensusClusterPlus")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed <- FALSE
  }
}

# 测试CancerSubtypes功能
if (is_package_installed("CancerSubtypes")) {
  cat("\nTesting CancerSubtypes package...\n")
  tryCatch({
    library(CancerSubtypes)
    cat("✓ CancerSubtypes package loaded successfully\n")
    
    # 检查主要函数是否存在
    main_functions <- c("ExecuteCC", "ExecuteSNF", "ExecuteCoclustering", 
                       "ExecuteCNMF", "ExecuteiCluster", "ExecuteiClusterBayes")
    available_functions <- sapply(main_functions, exists)
    
    cat("Available functions:\n")
    for (func in main_functions[available_functions]) {
      cat("  ✓", func, "\n")
    }
    
  }, error = function(e) {
    cat("✗ CancerSubtypes test failed:", e$message, "\n")
  })
}

if (!all_installed) {
  cat("\nSome packages failed to install. You can try manual installation:\n")
  cat("devtools::install_github('taoshengxu/CancerSubtypes')\n")
  cat("install.packages(c('data.table', 'stringr', 'survival', 'cluster', 'impute'))\n")
  cat("BiocManager::install(c('impute', 'ConsensusClusterPlus'))\n")
}

cat("\nYou can now run your R scripts in this directory.\n")
