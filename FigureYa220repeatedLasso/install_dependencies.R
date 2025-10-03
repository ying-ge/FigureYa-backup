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

cat("开始安装R包...\n")
cat("===========================================\n")

# 安装CRAN包
cat("\n安装CRAN包...\n")
cran_packages <- c("glmnet", "pbapply", "survival")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 安装Bioconductor包
cat("\n安装Bioconductor包...\n")
bioc_packages <- c("survcomp")
for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

cat("\n===========================================\n")
cat("包安装完成！\n")
cat("现在可以运行此目录中的R脚本了。\n")
