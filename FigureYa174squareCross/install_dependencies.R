#!/usr/bin/env Rscript
# Simplified R package installation script - Install ggplot2, aplot, dplyr, scales
# 简化版R包安装脚本 - 安装ggplot2, aplot, dplyr, scales

# 设置CRAN镜像 / Set CRAN mirror
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(timeout = 600)  # 增加超时时间到10分钟 / Increase timeout to 10 minutes

# 检查包是否已安装的函数 / Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# 安装CRAN包的函数 / Function to install CRAN packages
install_cran_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("正在安装包:", package_name, "\n")
    cat("Installing package:", package_name, "\n")
    tryCatch({
      install.packages(package_name, dependencies = TRUE, quiet = TRUE)
      cat("成功安装:", package_name, "\n")
      cat("Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("安装失败", package_name, ":", e$message, "\n")
      cat("Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("包已安装:", package_name, "\n")
    cat("Package already installed:", package_name, "\n")
  }
}

cat("开始安装R包...\n")
cat("Starting R package installation...\n")
cat("===========================================\n")

# 安装四个包 / Install four packages
packages_to_install <- c("ggplot2", "aplot", "dplyr", "scales")

for (pkg in packages_to_install) {
  install_cran_package(pkg)
}

cat("\n===========================================\n")

remotes::install_github("zzwch/crosslink", build_vignettes = TRUE)

# 验证安装结果 / Verify installation results
cat("验证安装结果:\n")
cat("Verifying installation results:\n")
all_installed <- TRUE
for (pkg in packages_to_install) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "已成功安装\n")
    cat("✓", pkg, "installed successfully\n")
  } else {
    cat("✗", pkg, "安装失败\n")
    cat("✗", pkg, "installation failed\n")
    all_installed <- FALSE
  }
}

if (all_installed) {
  cat("\n所有包已成功安装！\n")
  cat("\nAll packages installed successfully!\n")
  cat("您现在可以使用以下代码加载这些包：\n")
  cat("You can now load these packages with the following code:\n")
  cat("library(ggplot2)\n")
  cat("library(aplot)\n") 
  cat("library(dplyr)\n")
  cat("library(scales)  # 包含rescale函数 / Contains rescale function\n")
} else {
  cat("\n部分包安装失败，请检查网络连接或手动安装。\n")
  cat("\nSome packages failed to install, please check your network connection or install manually.\n")
}

cat("安装完成！\n")
cat("Installation completed!\n")
