#!/usr/bin/env Rscript
# 修复后的 R 依赖安装脚本
# 专门针对 FigureYa211multiCohortImmSubtype.Rmd 的依赖

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

# 特殊安装 estimate 包
install_estimate_package <- function() {
  if (!is_package_installed("estimate")) {
    cat("Installing estimate package from source...\n")
    tryCatch({
      # 方法1: 从 R-Forge 安装
      install.packages("estimate", repos="http://r-forge.r-project.org")
      cat("Successfully installed estimate from R-Forge\n")
    }, error = function(e) {
      cat("R-Forge installation failed:", e$message, "\n")
      
      # 方法2: 从源码安装
      tryCatch({
        # 下载并安装 estimate 包
        download.file("https://svn.r-project.org/R-packages/trunk/estimate/estimate_1.0-11.tar.gz", 
                     "estimate.tar.gz")
        install.packages("estimate.tar.gz", repos = NULL, type = "source")
        cat("Successfully installed estimate from source\n")
      }, error = function(e2) {
        cat("Source installation failed:", e2$message, "\n")
        
        # 方法3: 使用备选安装方法
        tryCatch({
          if (!is_package_installed("remotes")) {
            install.packages("remotes")
          }
          # 尝试从 GitHub 或其他源安装
          remotes::install_url("https://svn.r-project.org/R-packages/trunk/estimate/estimate_1.0-11.tar.gz")
          cat("Successfully installed estimate via remotes\n")
        }, error = function(e3) {
          cat("All estimate installation methods failed:", e3$message, "\n")
          cat("Please install estimate manually:\n")
          cat("install.packages('estimate', repos='http://r-forge.r-project.org')\n")
        })
      })
    })
  } else {
    cat("Package already installed: estimate\n")
  }
}

cat("Starting R package installation for FigureYa211multiCohortImmSubtype...\n")
cat("===========================================\n")

# 首先安装 BiocManager 和 remotes（如果尚未安装）
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager")
}
if (!is_package_installed("remotes")) {
  install.packages("remotes")
}

# 安装 estimate 包（特殊处理）
cat("\nInstalling estimate package...\n")
install_estimate_package()

# 安装 Bioconductor 包
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("sva", "ConsensusClusterPlus", "GSVA", "preprocessCore")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 安装 CRAN 包
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("pheatmap", "survival", "survminer", "ggplot2", "dplyr", "tidyr", 
                  "ggpubr", "reshape2", "tibble", "readr")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 免疫分析常用的额外包
cat("\nInstalling additional immunology packages...\n")
additional_bioc_packages <- c("immunedeconv", "limma", "edgeR")
for (pkg in additional_bioc_packages) {
  install_bioc_package(pkg)
}

# 系统依赖检查
cat("\nChecking for system dependencies...\n")
if (.Platform$OS.type == "unix") {
  # 编译依赖
  system("sudo apt-get update && sudo apt-get install -y libblas-dev liblapack-dev gfortran libcurl4-openssl-dev libssl-dev libxml2-dev")
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# 验证安装
cat("\nVerifying installation...\n")
required_packages <- c("sva", "estimate", "ConsensusClusterPlus", "pheatmap", "survival", "survminer")
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✅", pkg, "installed successfully\n")
  } else {
    cat("❌", pkg, "installation failed\n")
  }
}

# 测试关键包的功能
cat("\nTesting key packages...\n")
test_packages <- c("sva", "estimate", "survival", "ggplot2")
for (pkg in test_packages) {
  if (is_package_installed(pkg)) {
    tryCatch({
      library(pkg, character.only = TRUE)
      cat("✅", pkg, "package loaded successfully\n")
    }, error = function(e) {
      cat("❌ Error loading", pkg, ":", e$message, "\n")
    })
  }
}

cat("\nYou can now run FigureYa211multiCohortImmSubtype.Rmd script!\n")
