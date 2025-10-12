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
      return(FALSE)
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
  return(TRUE)
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
      return(FALSE)
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
  return(TRUE)
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# First install BiocManager if not present
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager")
}

# 检查 LaTeX/TeX 环境
cat("\n检查是否安装了 TeX/LaTeX...\n")
latex_path <- Sys.which("tex")
if (nchar(latex_path) == 0) {
  cat("警告：您的系统未检测到 TeX/LaTeX 环境。\n")
  cat("请在命令行运行以下命令安装（如 Ubuntu）：\n")
  cat("  sudo apt-get update && sudo apt-get install texlive\n")
  cat("或安装 texlive-full 以获得更全面支持：\n")
  cat("  sudo apt-get install texlive-full\n")
  cat("如果在 GitHub Actions，请在 workflow yaml 文件加上：\n")
  cat("  - name: Install TeX Live\n")
  cat("    run: sudo apt-get update && sudo apt-get install -y texlive\n")
} else {
  cat("✓ 已检测到 TeX/LaTeX 环境：", latex_path, "\n")
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("ape", "ggtree", "pheatmap", "seqinr", "ggplot2", "tidyr", "dplyr")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("Biostrings", "msa", "ggtree", "treeio")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 特别注意：ggtree 既在CRAN也在Bioconductor，确保安装正确版本
cat("\n确保 ggtree 正确安装...\n")
if (!is_package_installed("ggtree")) {
  install_bioc_package("ggtree")
}

# 验证关键包是否安装
cat("\n===========================================\n")
cat("验证关键包安装...\n")

critical_packages <- c("Biostrings", "msa", "ggtree", "ape", "pheatmap")
for (pkg in critical_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
  }
}

# 测试 Biostrings 包的功能
cat("\n测试 Biostrings 包...\n")
tryCatch({
  if (is_package_installed("Biostrings")) {
    library(Biostrings)
    cat("✓ Biostrings 包加载成功\n")
    cat("✓ readAAStringSet 函数可用\n")
  } else {
    cat("✗ Biostrings 包未安装\n")
  }
}, error = function(e) {
  cat("✗ Biostrings 包测试失败:", e$message, "\n")
})

cat("\nPackage installation completed!\n")
cat("You can now run your R scripts in this directory.\n")

# 如果还有问题，尝试安装特定版本
cat("\n如果仍有问题，尝试安装开发版本...\n")
tryCatch({
  if (!is_package_installed("Biostrings")) {
    BiocManager::install("Biostrings", version = "devel")
  }
}, error = function(e) {
  cat("开发版本安装尝试失败:", e$message, "\n")
})
