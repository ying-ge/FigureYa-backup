#!/usr/bin/env Rscript
# 修正后的R依赖安装脚本

# 设置镜像以改善下载性能
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
      install.packages(package_name, dependencies = TRUE)
      cat("成功安装:", package_name, "\n")
    }, error = function(e) {
      cat("安装失败", package_name, ":", e$message, "\n")
    })
  } else {
    cat("包已安装:", package_name, "\n")
  }
}

# 安装GitHub包的函数
install_github_package <- function(repo) {
  package_name <- basename(repo)
  if (!is_package_installed(package_name)) {
    cat("正在安装GitHub包:", repo, "\n")
    tryCatch({
      if (!is_package_installed("devtools")) {
        install.packages("devtools")
      }
      devtools::install_github(repo)
      cat("成功安装:", package_name, "\n")
    }, error = function(e) {
      cat("安装失败", repo, ":", e$message, "\n")
    })
  } else {
    cat("包已安装:", package_name, "\n")
  }
}

# 安装SeuratData的特殊函数
install_seuratdata <- function() {
  if (!is_package_installed("SeuratData")) {
    cat("正在安装SeuratData...\n")
    tryCatch({
      # 先安装依赖
      install_cran_package("devtools")
      install_cran_package("remotes")
      
      # 尝试从GitHub安装
      remotes::install_github("satijalab/seurat-data")
      cat("成功安装: SeuratData\n")
    }, error = function(e) {
      cat("安装SeuratData失败:", e$message, "\n")
      cat("尝试替代方案：安装必要的依赖包...\n")
      
      # 安装Seurat的核心依赖
      install_cran_package("Seurat")
      install_cran_package("SeuratObject")
      install_cran_package("ggplot2")
      install_cran_package("dplyr")
    })
  } else {
    cat("包已安装: SeuratData\n")
  }
}

cat("开始安装R包...\n")
cat("===========================================\n")

# 首先安装基础工具包
install_cran_package("devtools")
install_cran_package("remotes")

# 安装CRAN包
cat("\n安装CRAN包...\n")
cran_packages <- c("RColorBrewer", "Seurat", "colorRamps", "dplyr", "future", 
                  "magrittr", "patchwork", "pheatmap", "ggplot2", "SeuratObject")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 特殊安装SeuratData
cat("\n安装SeuratData...\n")
install_seuratdata()

# 检查是否需要安装其他数据包
cat("\n检查是否需要额外的数据包...\n")
if (!is_package_installed("SeuratData")) {
  cat("SeuratData安装失败，但可以继续使用其他功能\n")
  cat("如果需要特定数据集，可以手动安装，例如：\n")
  cat("remotes::install_github('satijalab/seurat-data')\n")
}

# 安装其他可能的依赖
cat("\n安装其他可能的依赖包...\n")
additional_packages <- c("Matrix", "igraph", "RANN", "reticulate", "spatstat")
for (pkg in additional_packages) {
  install_cran_package(pkg)
}

cat("\n===========================================\n")
cat("包安装完成！\n")
cat("如果SeuratData安装失败，可以尝试以下解决方案：\n")
cat("1. 手动安装: remotes::install_github('satijalab/seurat-data')\n")
cat("2. 或者使用: devtools::install_github('satijalab/seurat-data')\n")
cat("3. 如果仍然失败，可以跳过SeuratData，使用本地数据\n")
cat("现在可以运行此目录中的R脚本了。\n")

# 测试关键包是否安装成功
cat("\n测试关键包是否可用...\n")
tryCatch({
  library(Seurat)
  library(pheatmap)
  library(RColorBrewer)
  cat("关键包加载成功！\n")
}, error = function(e) {
  cat("某些包加载失败:", e$message, "\n")
})
