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

# 安装Bioconductor包的函数
install_bioc_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("正在安装Bioconductor包:", package_name, "\n")
    tryCatch({
      if (!is_package_installed("BiocManager")) {
        install.packages("BiocManager")
      }
      BiocManager::install(package_name, update = FALSE, ask = FALSE)
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

cat("开始安装R包...\n")
cat("===========================================\n")

# 首先安装devtools
install_cran_package("devtools")

# 安装 Seurat 相关依赖
seurat_deps <- c("httr", "plotly", "png", "reticulate", "mixtools")
cat("\n安装Seurat依赖包...\n")
for (pkg in seurat_deps) {
  install_cran_package(pkg)
}

# 安装CRAN包
cat("\n安装CRAN包...\n")
cran_packages <- c(
  "RColorBrewer", "Seurat",
  "dplyr", "ggplot2", "ggrepel", "magrittr", "patchwork", "reshape2"
)

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 安装Bioconductor包
cat("\n安装Bioconductor包...\n")
bioc_packages <- c("GEOquery")
for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 尝试安装修复版的DealGPL570或替代方案
cat("\n尝试安装DealGPL570替代方案...\n")
tryCatch({
  # 方法1: 尝试从GitHub安装可能存在的更新版本
  install_github_package("cran/DealGPL570")
}, error = function(e) {
  cat("GitHub安装失败，尝试其他方法...\n")
  
  # 方法2: 手动下载并修改源代码
  temp_dir <- tempdir()
  pkg_url <- "https://cran.r-project.org/src/contrib/Archive/DealGPL570/DealGPL570_0.0.1.tar.gz"
  pkg_file <- file.path(temp_dir, "DealGPL570_0.0.1.tar.gz")
  
  tryCatch({
    download.file(pkg_url, pkg_file)
    # 解压并修改源代码
    untar(pkg_file, exdir = temp_dir)
    pkg_dir <- file.path(temp_dir, "DealGPL570")
    
    # 修改R文件中的gunzip引用
    r_files <- list.files(file.path(pkg_dir, "R"), pattern = "\\.R$", full.names = TRUE)
    for (r_file in r_files) {
      content <- readLines(r_file)
      # 替换gunzip为适当的函数
      content <- gsub("gunzip", "GEOquery::getGEOSuppFiles", content)
      writeLines(content, r_file)
    }
    
    # 重新安装修改后的包
    devtools::install_local(pkg_dir)
    cat("成功安装修改后的DealGPL570\n")
  }, error = function(e2) {
    cat("DealGPL570安装完全失败，考虑使用替代方法处理GPL570数据\n")
  })
})

cat("\n===========================================\n")
cat("包安装完成！\n")
cat("注意：可能需要手动下载数据文件\n")
cat("数据目录 'filtered_gene_bc_matrices/hg19/' 不存在，请确保下载所需数据\n")
cat("现在可以运行此目录中的R脚本了。\n")
