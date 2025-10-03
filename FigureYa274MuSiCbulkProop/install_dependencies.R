#!/usr/bin/env Rscript
# 修复版R包安装脚本 - 特别解决SeuratData安装问题
# This script installs all required R packages for this project

# 设置镜像以优化下载速度
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# 检查包是否已安装的函数
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# 安装CRAN包的函数
install_cran_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("正在安装CRAN包:", package_name, "\n")
    tryCatch({
      install.packages(package_name, dependencies = TRUE, quiet = TRUE)
      cat("成功安装:", package_name, "\n")
    }, error = function(e) {
      cat("安装失败", package_name, ":", e$message, "\n")
    })
  } else {
    cat("包已安装:", package_name, "\n")
  }
}

# 安装Bioconductor包的函数
install_bioc_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("正在安装Bioconductor包:", package_name, "\n")
    tryCatch({
      if (!is_package_installed("BiocManager")) {
        install.packages("BiocManager", quiet = TRUE)
      }
      BiocManager::install(package_name, update = FALSE, ask = FALSE, quiet = TRUE)
      cat("成功安装:", package_name, "\n")
    }, error = function(e) {
      cat("安装失败", package_name, ":", e$message, "\n")
    })
  } else {
    cat("包已安装:", package_name, "\n")
  }
}

# 专门修复SeuratData安装的函数
install_seurat_data_fixed <- function() {
  if (!is_package_installed("SeuratData")) {
    cat("正在安装SeuratData包...\n")
    tryCatch({
      # 先安装必要的依赖
      required_deps <- c("remotes", "curl", "httr", "jsonlite", "withr")
      for (dep in required_deps) {
        if (!is_package_installed(dep)) {
          install.packages(dep, quiet = TRUE)
        }
      }
      
      # 方法1: 尝试从GitHub安装
      if (!is_package_installed("remotes")) {
        install.packages("remotes", quiet = TRUE)
      }
      
      # 设置超时时间更长
      options(timeout = 600)
      
      # 尝试从Satija Lab安装
      remotes::install_github("satijalab/seurat-data", dependencies = TRUE, upgrade = "never")
      cat("成功从GitHub安装: SeuratData\n")
      
    }, error = function(e) {
      cat("GitHub安装失败，尝试其他方法...:", e$message, "\n")
      
      # 方法2: 尝试直接安装二进制版本（如果可用）
      tryCatch({
        install.packages("SeuratData", repos = "https://satijalab.org/ran")
        cat("成功从Satija Lab仓库安装: SeuratData\n")
      }, error = function(e2) {
        cat("所有安装方法都失败了:", e2$message, "\n")
        cat("请尝试手动安装:\n")
        cat("1. 访问 https://github.com/satijalab/seurat-data\n")
        cat("2. 下载源代码并手动安装\n")
      })
    })
  } else {
    cat("包已安装: SeuratData\n")
  }
}

cat("开始R包安装过程...\n")
cat("===========================================\n")

# 首先安装基础依赖
cat("\n正在安装基础依赖包...\n")
base_deps <- c("remotes", "curl", "httr", "jsonlite", "withr", "devtools")
for (pkg in base_deps) {
  install_cran_package(pkg)
}

# 安装CRAN包
cat("\n正在安装CRAN包...\n")
cran_packages <- c("Seurat", "dplyr", "magrittr", "patchwork", "pheatmap", "ggplot2", "tibble")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 专门安装SeuratData
cat("\n正在专门安装SeuratData包...\n")
install_seurat_data_fixed()

# 安装Bioconductor包
cat("\n正在安装Bioconductor包...\n")
bioc_packages <- c("Biobase", "MuSiC", "SingleCellExperiment", "glmGamPoi", "SummarizedExperiment")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 检查并安装MuSiC（如果Bioconductor安装失败）
if (!is_package_installed("MuSiC")) {
  cat("\nMuSiC未找到，尝试从GitHub安装...\n")
  tryCatch({
    if (!is_package_installed("devtools")) {
      install.packages("devtools", quiet = TRUE)
    }
    devtools::install_github("xuranw/MuSiC")
    cat("成功从GitHub安装MuSiC\n")
  }, error = function(e) {
    cat("从GitHub安装MuSiC失败:", e$message, "\n")
  })
} else {
  cat("包已安装: MuSiC\n")
}

# 验证所有必要包是否已安装
cat("\n===========================================\n")
cat("验证安装结果...\n")
required_packages <- c("Seurat", "SeuratData", "MuSiC", "SingleCellExperiment", "SummarizedExperiment")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "已成功安装\n")
  } else {
    cat("✗", pkg, "安装失败\n")
    all_installed <- FALSE
  }
}

if (all_installed) {
  cat("\n所有必要包已成功安装!\n")
  cat("您现在可以运行您的R脚本了。\n")
} else {
  cat("\n部分包安装失败。请检查错误信息并手动安装缺失的包。\n")
  cat("对于SeuratData，您可以尝试:\n")
  cat("1. remotes::install_github('satijalab/seurat-data')\n")
  cat("2. 或者从 https://satijalab.org/ran 安装二进制版本\n")
}
