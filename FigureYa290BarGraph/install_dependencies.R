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

# Function to install from GitHub with better error handling
install_github_package <- function(repo) {
  package_name <- strsplit(repo, "/")[[1]][2]
  if (!is_package_installed(package_name)) {
    cat("Installing GitHub package:", repo, "\n")
    tryCatch({
      if (!is_package_installed("remotes")) {
        install.packages("remotes")
      }
      remotes::install_github(repo, upgrade = "never")
      cat("Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("Failed to install", repo, ":", e$message, "\n")
      # 尝试其他安装方法
      try_alternative_installation(package_name)
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

# 尝试其他安装方法
try_alternative_installation <- function(package_name) {
  if (package_name == "SeuratDisk") {
    cat("尝试其他方式安装 SeuratDisk...\n")
    
    # 方法1: 从CRAN安装（如果可用）
    tryCatch({
      install.packages("SeuratDisk")
      cat("成功从CRAN安装 SeuratDisk\n")
      return(TRUE)
    }, error = function(e) {
      cat("无法从CRAN安装:", e$message, "\n")
    })
    
    # 方法2: 安装开发版本
    cat("尝试安装开发版本...\n")
    tryCatch({
      remotes::install_github("mojaveazure/seurat-disk", ref = "develop")
      cat("成功安装开发版本\n")
      return(TRUE)
    }, error = function(e) {
      cat("无法安装开发版本:", e$message, "\n")
    })
    
    # 方法3: 安装特定版本
    cat("尝试安装特定版本...\n")
    tryCatch({
      remotes::install_github("mojaveazure/seurat-disk@0.0.0.9020")  # 一个稳定的版本
      cat("成功安装特定版本\n")
      return(TRUE)
    }, error = function(e) {
      cat("无法安装特定版本:", e$message, "\n")
    })
  }
  return(FALSE)
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装 remotes 和必要的系统依赖
if (!is_package_installed("remotes")) {
  install_cran_package("remotes")
}

# 安装系统依赖（对于 Linux 系统）
cat("\n检查系统依赖...\n")
system_deps <- c("libhdf5-dev", "libcurl4-openssl-dev", "libssl-dev", "libxml2-dev")
if (Sys.info()["sysname"] == "Linux") {
  cat("在Linux系统上，建议安装: ", paste(system_deps, collapse = ", "), "\n")
  cat("请运行: sudo apt-get install", paste(system_deps, collapse = " "), "\n")
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("Matrix", "Seurat", "ggplot2", "hdf5r", "rstatix", "devtools")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 确保 hdf5r 安装正确（这是 SeuratDisk 的关键依赖）
if (!is_package_installed("hdf5r")) {
  cat("\n特别注意：安装 hdf5r 包...\n")
  install_cran_package("hdf5r")
}

# Installing SeuratDisk from GitHub
cat("\nInstalling SeuratDisk from GitHub...\n")
install_github_package("mojaveazure/seurat-disk")

# 如果 SeuratDisk 仍然无法安装，提供替代方案
if (!is_package_installed("SeuratDisk")) {
  cat("\n警告：SeuratDisk 安装失败，但可以尝试以下替代方案:\n")
  cat("1. 使用 Seurat 自带的文件读写功能\n")
  cat("2. 使用其他格式（如RDS）保存和加载数据\n")
  cat("3. 安装其他转换包如 sceasy\n")
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# 验证安装
cat("\n验证包安装状态:\n")
required_packages <- c("Matrix", "Seurat", "SeuratDisk", "ggplot2", "hdf5r", "rstatix")
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
  }
}

cat("You can now run your R scripts in this directory.\n")
