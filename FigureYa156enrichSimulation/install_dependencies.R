#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")
options(timeout = 600)  # 增加超时时间到10分钟

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

# 特殊处理cgdsr包 - 它可能需要从GitHub安装
install_cgdsr <- function() {
  if (is_package_installed("cgdsr")) {
    cat("Package already installed: cgdsr\n")
    return(TRUE)
  }
  
  cat("Installing cgdsr package...\n")
  
  # 尝试从CRAN安装
  tryCatch({
    install.packages("cgdsr")
    if (is_package_installed("cgdsr")) {
      cat("Successfully installed cgdsr from CRAN\n")
      return(TRUE)
    }
  }, error = function(e) {
    cat("cgdsr not available on CRAN:", e$message, "\n")
  })
  
  # 如果CRAN安装失败，尝试从GitHub安装
  cat("Trying to install cgdsr from GitHub...\n")
  tryCatch({
    if (!is_package_installed("devtools")) {
      install.packages("devtools")
    }
    # cgdsr的GitHub仓库
    devtools::install_github("cBioPortal/cgdsr")
    if (is_package_installed("cgdsr")) {
      cat("Successfully installed cgdsr from GitHub\n")
      return(TRUE)
    }
  }, error = function(e) {
    cat("Failed to install cgdsr from GitHub:", e$message, "\n")
  })
  
  # 如果都失败，尝试安装旧版本
  cat("Trying to install older version of cgdsr...\n")
  tryCatch({
    # 安装旧版本
    install.packages("https://cran.r-project.org/src/contrib/Archive/cgdsr/cgdsr_1.3.0.tar.gz", 
                    repos = NULL, type = "source")
    if (is_package_installed("cgdsr")) {
      cat("Successfully installed older version of cgdsr\n")
      return(TRUE)
    }
  }, error = function(e) {
    cat("Failed to install older version of cgdsr:", e$message, "\n")
  })
  
  return(FALSE)
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装一些基础依赖
cat("\nInstalling important dependency packages first...\n")
base_dep_packages <- c("devtools", "httr", "curl", "jsonlite")
for (pkg in base_dep_packages) {
  install_cran_package(pkg)
}

# 安装cgdsr包
cat("\nInstalling cgdsr package...\n")
install_cgdsr()

# 检查可能需要的其他依赖
cat("\nInstalling potential additional dependencies...\n")
additional_packages <- c("RCurl", "RJSONIO", "plyr", "stringr")
for (pkg in additional_packages) {
  install_cran_package(pkg)
}

# 验证安装
cat("\nVerifying installation...\n")
required_packages <- c("cgdsr")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
    # 测试包是否能正常加载
    tryCatch({
      library(pkg, character.only = TRUE)
      cat("  Package loads successfully\n")
    }, error = function(e) {
      cat("  Warning: Package installed but has loading issues:", e$message, "\n")
    })
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed <- FALSE
  }
}

cat("\n===========================================\n")
if (all_installed) {
  cat("Package installation completed successfully!\n")
} else {
  cat("Package installation completed with some failures.\n")
  cat("You may need to manually install missing packages:\n")
  cat("1. Try: install.packages('cgdsr')\n")
  cat("2. Or: devtools::install_github('cBioPortal/cgdsr')\n")
  cat("3. Check https://github.com/cBioPortal/cgdsr for manual installation\n")
}

cat("You can now run your R scripts in this directory.\n")

# 如果cgdsr安装成功，测试基本功能
if (is_package_installed("cgdsr")) {
  cat("\nTesting cgdsr basic functionality...\n")
  tryCatch({
    library(cgdsr)
    cat("cgdsr package loaded successfully\n")
    # 可以添加一些简单的测试代码
  }, error = function(e) {
    cat("cgdsr package has loading issues:", e$message, "\n")
  })
}
