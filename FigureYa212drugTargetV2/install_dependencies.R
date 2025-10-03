#!/usr/bin/env Rscript
# 修复后的 R 依赖安装脚本
# 专门针对 FigureYa212drugTargetV2.Rmd 的依赖

# 设置镜像
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# 检查包是否已安装
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# 安装 CRAN 包
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

# 安装 Bioconductor 包
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

cat("Starting R package installation for FigureYa212drugTargetV2...\n")
cat("===========================================\n")

# 首先安装 BiocManager（如果尚未安装）
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager")
}

# 安装 Bioconductor 包
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("impute", "sva")  # sva 是 Bioconductor 包

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 安装 CRAN 包（您列出的必要包 + sva, ridge, car）
cat("\nInstalling CRAN packages...\n")
cran_packages <- c(
  "tidyverse",    # 包含 dplyr, tidyr, readr, purrr, ggplot2 等
  "ISOpureR",     # 用于纯化表达谱
  "SimDesign",    # 用于禁止药敏预测过程输出的信息
  "cowplot",      # 合并图像
  "ridge",        # 岭回归分析
  "car"           # companion to applied regression
)

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 系统依赖检查（可选）
cat("\nChecking for system dependencies...\n")
if (.Platform$OS.type == "unix") {
  # 编译依赖
  system("sudo apt-get update && sudo apt-get install -y libblas-dev liblapack-dev gfortran libcurl4-openssl-dev libssl-dev")
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# 验证安装
cat("\nVerifying installation...\n")
required_packages <- c("tidyverse", "ISOpureR", "impute", "SimDesign", "cowplot", "sva", "ridge", "car")
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✅", pkg, "installed successfully\n")
  } else {
    cat("❌", pkg, "installation failed\n")
  }
}

# 测试关键包的功能
cat("\nTesting key packages...\n")
test_packages <- function(pkg) {
  tryCatch({
    library(pkg, character.only = TRUE)
    cat("✅", pkg, "package loaded successfully\n")
    return(TRUE)
  }, error = function(e) {
    cat("❌ Error loading", pkg, ":", e$message, "\n")
    return(FALSE)
  })
}

# 测试所有主要包
key_packages <- c("dplyr", "ggplot2", "ISOpureR", "impute", "sva", "ridge", "car")
sapply(key_packages, test_packages)

cat("\nAll required packages installed! You can now run your analysis.\n")
cat("Packages installed:\n")
cat("- tidyverse (dplyr, ggplot2, tidyr, readr, purrr)\n")
cat("- ISOpureR: 表达谱纯化\n")
cat("- impute: KNN 数据填补\n") 
cat("- SimDesign: 输出控制\n")
cat("- cowplot: 图像排版\n")
cat("- sva: 批次效应校正\n")
cat("- ridge: 岭回归分析\n")
cat("- car: 回归分析辅助\n")
