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
      install.packages(package_name, dependencies = TRUE, quiet = FALSE)
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
      BiocManager::install(package_name, update = FALSE, ask = FALSE, quiet = FALSE)
      cat("Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

# 特殊处理GSVA包及其依赖
install_gsva_with_deps <- function() {
  cat("Installing GSVA with all dependencies...\n")
  
  # 首先安装所有必要的依赖包
  gsva_deps <- c(
    "Biobase", "BiocGenerics", "S4Vectors", "IRanges", "GenomicRanges",
    "SummarizedExperiment", "DelayedArray", "MatrixGenerics", "matrixStats",
    "AnnotationDbi", "annotate", "XML", "httr", "curl", "openssl"
  )
  
  for (pkg in gsva_deps) {
    if (pkg %in% rownames(available.packages())) {
      install_cran_package(pkg)
    } else {
      install_bioc_package(pkg)
    }
  }
  
  # 安装GSEABase（GSVA的重要依赖）
  install_bioc_package("GSEABase")
  
  # 安装GSVA
  install_bioc_package("GSVA")
  
  # 验证安装
  if (is_package_installed("GSVA")) {
    cat("GSVA installed successfully\n")
    return(TRUE)
  } else {
    cat("GSVA installation may have failed\n")
    return(FALSE)
  }
}

# 测试GSVA功能
test_gsva_functionality <- function() {
  if (!is_package_installed("GSVA")) {
    cat("GSVA not installed, cannot test functionality\n")
    return(FALSE)
  }
  
  cat("Testing GSVA functionality...\n")
  tryCatch({
    library(GSVA)
    
    # 创建测试数据
    set.seed(123)
    test_matrix <- matrix(rnorm(1000), nrow = 100, ncol = 10)
    rownames(test_matrix) <- paste0("Gene", 1:100)
    colnames(test_matrix) <- paste0("Sample", 1:10)
    
    # 创建测试基因集
    test_geneset <- list(
      Pathway1 = paste0("Gene", 1:10),
      Pathway2 = paste0("Gene", 11:20)
    )
    
    # 测试gsva函数
    cat("Testing gsva function with matrix input...\n")
    result <- gsva(test_matrix, test_geneset, verbose = FALSE)
    
    cat("✓ GSVA function works correctly with matrix input\n")
    cat("  Result dimensions:", dim(result), "\n")
    
    return(TRUE)
  }, error = function(e) {
    cat("✗ GSVA function test failed:", e$message, "\n")
    
    # 提供调试信息
    cat("Debug information:\n")
    cat("  GSVA version:", as.character(packageVersion("GSVA")), "\n")
    cat("  Available methods for gsva:\n")
    
    # 检查可用的方法
    tryCatch({
      methods <- methods("gsva")
      if (length(methods) > 0) {
        cat("   ", paste(methods, collapse = ", "), "\n")
      } else {
        cat("    No methods found for gsva\n")
      }
    }, error = function(e2) {
      cat("    Cannot retrieve methods:", e2$message, "\n")
    })
    
    return(FALSE)
  })
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装基础依赖
cat("\nInstalling important dependency packages first...\n")
base_dep_packages <- c("devtools", "remotes", "httr", "curl", "jsonlite", "RCurl", "Matrix")
for (pkg in base_dep_packages) {
  install_cran_package(pkg)
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("Seurat", "dplyr", "ggplot2", "reshape2", "tibble", "purrr")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 特殊处理GSVA及其依赖
cat("\nInstalling GSVA with all dependencies...\n")
install_gsva_with_deps()

# Installing other Bioconductor packages
cat("\nInstalling other Bioconductor packages...\n")
bioc_packages <- c("ComplexHeatmap", "GSEABase", "limma", "SingleCellExperiment")
for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 测试GSVA功能
cat("\nTesting GSVA functionality...\n")
gsva_works <- test_gsva_functionality()

# 验证所有包是否安装成功
cat("\nVerifying package installation...\n")
required_packages <- c("GSVA", "GSEABase", "limma", "ComplexHeatmap", "Seurat")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
    # 测试包是否能正常加载
    tryCatch({
      suppressPackageStartupMessages(library(pkg, character.only = TRUE, quietly = TRUE))
      cat("  Package loads successfully\n")
    }, error = function(e) {
      cat("  ERROR: Package has loading issues:", e$message, "\n")
      all_installed <- FALSE
    })
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed <- FALSE
  }
}

cat("\n===========================================\n")
if (all_installed && gsva_works) {
  cat("All packages successfully installed and functional!\n")
} else if (all_installed && !gsva_works) {
  cat("Packages installed but GSVA has functionality issues.\n")
  cat("Troubleshooting steps:\n")
  cat("1. Try updating all packages: BiocManager::install(update = TRUE)\n")
  cat("2. Check GSVA documentation for version requirements\n")
  cat("3. Try a specific GSVA version: BiocManager::install('GSVA', version = '1.46.0')\n")
} else {
  cat("Some packages failed to install.\n")
}

cat("\nIf GSVA still doesn't work, try these manual steps:\n")
cat("1. Remove and reinstall GSVA: remove.packages('GSVA'); BiocManager::install('GSVA')\n")
cat("2. Install specific version: BiocManager::install('GSVA@1.46.0')\n")
cat("3. Check sessionInfo() for version conflicts\n")

cat("You can now run your R scripts in this directory.\n")

# 提供会话信息用于调试
cat("\nSession information for debugging:\n")
sessionInfo()
