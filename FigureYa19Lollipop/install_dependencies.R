#!/usr/bin/env Rscript
# 修复后的 R 依赖安装脚本
# 专门针对 FigureYa19Lollipop.Rmd 的依赖

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

cat("Starting R package installation for FigureYa19Lollipop...\n")
cat("===========================================\n")

# 首先安装 BiocManager（如果尚未安装）
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager")
}

# 安装 Bioconductor 包（包括 trackViewer）
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("trackViewer", "TCGAbiolinks", "maftools")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 安装 CRAN 包
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("RColorBrewer", "ggplot2", "grid", "grDevices")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# trackViewer 可能需要额外的系统依赖（在 Linux 环境下）
cat("\nChecking for system dependencies...\n")
if (.Platform$OS.type == "unix") {
  # trackViewer 可能需要的系统依赖
  system("sudo apt-get update && sudo apt-get install -y libcairo2-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev")
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# 验证安装
cat("\nVerifying installation...\n")
required_packages <- c("trackViewer", "RColorBrewer", "TCGAbiolinks", "maftools")
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✅", pkg, "installed successfully\n")
  } else {
    cat("❌", pkg, "installation failed\n")
  }
}

cat("\nYou can now run FigureYa19Lollipop.Rmd script!\n")
