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

# 特殊处理TCGAbiolinks包，确保所有依赖都正确安装
install_tcgabiolinks <- function() {
  if (is_package_installed("TCGAbiolinks")) {
    cat("Package already installed: TCGAbiolinks\n")
    return(TRUE)
  }
  
  cat("Installing TCGAbiolinks with all dependencies...\n")
  
  # 首先安装所有可能的依赖
  tcgabiolinks_deps <- c(
    "httr", "jsonlite", "XML", "data.table", "dplyr", "tidyr", 
    "readr", "purrr", "stringr", "ggplot2", "reshape2", "R.utils",
    "curl", "openssl", "digest", "RCurl", "rjson", "httr2"
  )
  
  for (pkg in tcgabiolinks_deps) {
    install_cran_package(pkg)
  }
  
  # 安装Bioconductor依赖
  bioc_deps <- c(
    "SummarizedExperiment", "GenomicRanges", "IRanges", "S4Vectors",
    "Biobase", "BiocGenerics", "BiocFileCache", "rtracklayer"
  )
  
  for (pkg in bioc_deps) {
    install_bioc_package(pkg)
  }
  
  # 安装TCGAbiolinks
  install_bioc_package("TCGAbiolinks")
  
  # 验证安装
  if (is_package_installed("TCGAbiolinks")) {
    cat("TCGAbiolinks installed successfully\n")
    return(TRUE)
  } else {
    cat("TCGAbiolinks installation may have failed\n")
    return(FALSE)
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装基础依赖
cat("\nInstalling important dependency packages first...\n")
base_dep_packages <- c("devtools", "remotes", "httr", "curl", "jsonlite", "RCurl")
for (pkg in base_dep_packages) {
  install_cran_package(pkg)
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("cowplot", "ggplot2", "ggsci", "haven", "magrittr", "reshape2", "stringr", "tidyverse", "dplyr", "tidyr")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 特殊处理TCGAbiolinks
cat("\nInstalling TCGAbiolinks with all dependencies...\n")
install_tcgabiolinks()

# Installing other Bioconductor packages
cat("\nInstalling other Bioconductor packages...\n")
bioc_packages <- c("BSgenome", "BSgenome.Hsapiens.UCSC.hg38", "MutationalPatterns", "NMF", "maftools")
for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 验证所有包是否安装成功并能加载
cat("\nVerifying package installation and loading...\n")
required_packages <- c("TCGAbiolinks", "maftools", "MutationalPatterns", "BSgenome.Hsapiens.UCSC.hg38")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
    # 测试包是否能正常加载
    tryCatch({
      suppressPackageStartupMessages(library(pkg, character.only = TRUE, quietly = TRUE))
      cat("  Package loads successfully\n")
      
      # 对于TCGAbiolinks，特别测试GDCquery_Maf函数
      if (pkg == "TCGAbiolinks") {
        if (exists("GDCquery_Maf")) {
          cat("  GDCquery_Maf function is available\n")
        } else {
          cat("  WARNING: GDCquery_Maf function not found!\n")
          all_installed <- FALSE
        }
      }
    }, error = function(e) {
      cat("  ERROR: Package has loading issues:", e$message, "\n")
      all_installed <- FALSE
    })
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed = FALSE
  }
}

# 测试TCGAbiolinks功能
if (is_package_installed("TCGAbiolinks")) {
  cat("\nTesting TCGAbiolinks functionality...\n")
  tryCatch({
    library(TCGAbiolinks)
    # 检查GDCquery_Maf函数
    if (exists("GDCquery_Maf")) {
      cat("✓ GDCquery_Maf function is available\n")
      # 可以添加简单的功能测试
      cat("  TCGAbiolinks version:", packageVersion("TCGAbiolinks"), "\n")
    } else {
      cat("✗ GDCquery_Maf function NOT found\n")
      cat("  Available functions containing 'Maf':\n")
      # 列出包含Maf的函数
      maf_funcs <- ls("package:TCGAbiolinks")[grep("Maf", ls("package:TCGAbiolinks"))]
      if (length(maf_funcs) > 0) {
        cat("   ", paste(maf_funcs, collapse = ", "), "\n")
      } else {
        cat("   No Maf-related functions found\n")
      }
    }
  }, error = function(e) {
    cat("Error testing TCGAbiolinks:", e$message, "\n")
  })
}

cat("\n===========================================\n")
if (all_installed) {
  cat("All packages successfully installed and functional!\n")
} else {
  cat("Some packages may have installation or loading issues.\n")
  cat("If GDCquery_Maf is not available, try:\n")
  cat("1. Updating TCGAbiolinks: BiocManager::install('TCGAbiolinks', update = TRUE)\n")
  cat("2. Checking function name: some versions may use different function names\n")
  cat("3. Consult TCGAbiolinks documentation for the correct function name\n")
}

cat("You can now run your R scripts in this directory.\n")
