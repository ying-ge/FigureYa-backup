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

# 下载并安装ImmuLncRNA包
install_immulncrna <- function() {
  package_name <- "ImmuLncRNA"
  package_file <- "ImmuLncRNA_0.1.0.tar.gz"
  package_url <- "http://bio-bigdata.hrbmu.edu.cn/ImmLnc/download_loading.jsp?path=jt_download/ImmuLncRNA_0.1.0.tar.gz&name=ImmuLncRNA_0.1.0.tar.gz"
  
  if (is_package_installed(package_name)) {
    cat("Package already installed:", package_name, "\n")
    return(TRUE)
  }
  
  cat("Downloading and installing ImmuLncRNA package...\n")
  cat("URL:", package_url, "\n")
  
  # 创建临时目录
  temp_dir <- tempdir()
  dest_file <- file.path(temp_dir, package_file)
  
  # 下载包文件
  tryCatch({
    cat("Downloading package file...\n")
    download.file(package_url, dest_file, mode = "wb", quiet = FALSE)
    
    if (file.exists(dest_file)) {
      cat("Download successful, file size:", file.size(dest_file), "bytes\n")
      
      # 安装本地包
      cat("Installing package from local file...\n")
      install.packages(dest_file, repos = NULL, type = "source")
      
      if (is_package_installed(package_name)) {
        cat("Successfully installed:", package_name, "\n")
        return(TRUE)
      } else {
        cat("Installation completed but package not found\n")
        return(FALSE)
      }
    } else {
      cat("Download failed: file not found\n")
      return(FALSE)
    }
  }, error = function(e) {
    cat("Download or installation failed:", e$message, "\n")
    
    # 尝试备用下载方法
    cat("Trying alternative download method...\n")
    tryCatch({
      # 使用httr包可能更稳定
      if (!is_package_installed("httr")) {
        install.packages("httr")
      }
      library(httr)
      
      response <- GET(package_url)
      if (status_code(response) == 200) {
        writeBin(content(response, "raw"), dest_file)
        cat("Alternative download successful\n")
        
        # 安装包
        install.packages(dest_file, repos = NULL, type = "source")
        
        if (is_package_installed(package_name)) {
          cat("Successfully installed via alternative method:", package_name, "\n")
          return(TRUE)
        }
      } else {
        cat("Alternative download failed, status code:", status_code(response), "\n")
      }
    }, error = function(e2) {
      cat("Alternative method also failed:", e2$message, "\n")
    })
    
    return(FALSE)
  })
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装基础依赖
cat("\nInstalling important dependency packages first...\n")
base_dep_packages <- c("devtools", "remotes", "httr", "curl", "jsonlite")
for (pkg in base_dep_packages) {
  install_cran_package(pkg)
}

# 安装标准CRAN包
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("Reds", "dplyr", "ggplot2", "scales", "tidyverse", "reshape2", "tibble", "purrr", "data.table", "rtracklayer")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 安装ImmuLncRNA包
cat("\nInstalling ImmuLncRNA package...\n")
immulncrna_success <- install_immulncrna()

# 安装Bioconductor包
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("ComplexHeatmap", "SummarizedExperiment", "TCGAbiolinks", "fgsea")
for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 验证安装
cat("\nVerifying package installation...\n")
required_packages <- c("dplyr", "ggplot2", "ComplexHeatmap", "TCGAbiolinks", "fgsea")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed <- FALSE
  }
}

# 特别检查ImmuLncRNA
if (is_package_installed("ImmuLncRNA")) {
  cat("✓ ImmuLncRNA is installed\n")
  tryCatch({
    library(ImmuLncRNA)
    cat("  ImmuLncRNA loads successfully\n")
  }, error = function(e) {
    cat("  WARNING: ImmuLncRNA has loading issues:", e$message, "\n")
  })
} else {
  cat("✗ ImmuLncRNA is NOT installed\n")
}

cat("\n===========================================\n")
if (all_installed) {
  cat("Main packages successfully installed!\n")
} else {
  cat("Some packages failed to install.\n")
}

cat("\nInstallation summary:\n")
cat("- ImmuLncRNA:", ifelse(immulncrna_success, "✓", "✗"), "\n")
cat("- Other packages:", ifelse(all_installed, "✓", "✗"), "\n")

cat("You can now run your R scripts in this directory.\n")
