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
      # 对于特定的包，尝试其他安装方法
      if (package_name == "CMScaller") {
        install_cmscaller_alternative()
      }
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

# 特殊处理 CMScaller 的安装
install_cmscaller_alternative <- function() {
  cat("尝试替代方法安装 CMScaller...\n")
  
  # 方法1: 从正确的 GitHub 仓库安装
  tryCatch({
    if (!is_package_installed("remotes")) {
      install.packages("remotes")
    }
    cat("尝试从 GitHub 安装 CMScaller: Lothelab/CMScaller\n")
    remotes::install_github("Lothelab/CMScaller")
    if (is_package_installed("CMScaller")) {
      cat("成功从 GitHub 安装 CMScaller\n")
      return(TRUE)
    }
  }, error = function(e) {
    cat("GitHub 安装失败:", e$message, "\n")
  })
  
  # 方法2: 尝试其他可能的 GitHub 仓库
  tryCatch({
    cat("尝试从其他 GitHub 仓库安装: peterawe/CMScaller\n")
    remotes::install_github("peterawe/CMScaller")
    if (is_package_installed("CMScaller")) {
      cat("成功从备用 GitHub 仓库安装 CMScaller\n")
      return(TRUE)
    }
  }, error = function(e) {
    cat("备用 GitHub 仓库安装失败:", e$message, "\n")
  })
  
  # 方法3: 安装旧版本
  tryCatch({
    if (!is_package_installed("BiocManager")) {
      install.packages("BiocManager")
    }
    cat("尝试安装旧版本 CMScaller\n")
    BiocManager::install("CMScaller", version = "3.16", update = FALSE, ask = FALSE)
    if (is_package_installed("CMScaller")) {
      cat("成功安装旧版本 CMScaller\n")
      return(TRUE)
    }
  }, error = function(e) {
    cat("旧版本安装失败:", e$message, "\n")
  })
  
  # 方法4: 从源码安装
  tryCatch({
    cat("尝试从源码安装 CMScaller\n")
    # 获取最新版本的下载链接
    bioc_url <- "https://bioconductor.org/packages/release/bioc/src/contrib/"
    available_pkgs <- available.packages(repos = bioc_url)
    
    if ("CMScaller" %in% rownames(available_pkgs)) {
      pkg_version <- available_pkgs["CMScaller", "Version"]
      pkg_url <- paste0(bioc_url, "CMScaller_", pkg_version, ".tar.gz")
      install.packages(pkg_url, repos = NULL, type = "source")
      if (is_package_installed("CMScaller")) {
        cat("成功从源码安装 CMScaller\n")
        return(TRUE)
      }
    }
  }, error = function(e) {
    cat("源码安装失败:", e$message, "\n")
  })
  
  cat("所有安装方法都失败了\n")
  return(FALSE)
}

# 安装必要的系统依赖（对于 Linux）
install_system_dependencies <- function() {
  if (Sys.info()["sysname"] == "Linux") {
    cat("在 Linux 系统上，建议安装以下系统依赖:\n")
    cat("sudo apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 安装系统依赖
install_system_dependencies()

# 首先安装 remotes 和必要的工具包
if (!is_package_installed("remotes")) {
  install_cran_package("remotes")
}

# 安装 devtools（用于 GitHub 安装）
if (!is_package_installed("devtools")) {
  install_cran_package("devtools")
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("ClassDiscovery", "gplots", "tidyverse")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 特别处理 gplots 的依赖
if (!is_package_installed("gplots")) {
  cat("特别注意：安装 gplots 的依赖...\n")
  install_cran_package("gtools")
  install_cran_package("gdata")
  install_cran_package("caTools")
  install_cran_package("KernSmooth")
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("CMScaller", "ComplexHeatmap", "clusterProfiler", "org.Hs.eg.db")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 如果 CMScaller 仍然无法安装，提供替代方案
if (!is_package_installed("CMScaller")) {
  cat("\n警告：CMScaller 安装失败\n")
  cat("可以尝试以下替代方案:\n")
  cat("1. 手动从 GitHub 安装: devtools::install_github('Lothelab/CMScaller')\n")
  cat("2. 手动实现 CMS 分类算法\n")
  cat("3. 使用其他分型工具\n")
  cat("4. 联系包作者或查看最新安装说明\n")
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# 验证安装
cat("\n验证包安装状态:\n")
required_packages <- c("ClassDiscovery", "gplots", "tidyverse", "CMScaller", 
                      "ComplexHeatmap", "clusterProfiler", "org.Hs.eg.db")
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
  }
}

cat("You can now run your R scripts in this directory.\n")
