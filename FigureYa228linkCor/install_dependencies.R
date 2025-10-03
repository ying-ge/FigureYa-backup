#!/usr/bin/env Rscript
# 修正后的R依赖安装脚本 - 离线版本 / Fixed R dependency installation script - offline version

# 设置镜像以改善下载性能（对于其他需要联网的包）
# Set mirrors for better download performance (for other packages that need internet)
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# 检查包是否已安装的函数 / Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# 安装CRAN包的函数 / Function to install CRAN packages
install_cran_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("正在安装CRAN包:", package_name, "\n")
    cat("Installing CRAN package:", package_name, "\n")
    tryCatch({
      install.packages(package_name, dependencies = TRUE)
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

# 安装Bioconductor包的函数 / Function to install Bioconductor packages
install_bioc_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("正在安装Bioconductor包:", package_name, "\n")
    cat("Installing Bioconductor package:", package_name, "\n")
    tryCatch({
      if (!is_package_installed("BiocManager")) {
        install.packages("BiocManager")
      }
      BiocManager::install(package_name, update = FALSE, ask = FALSE)
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

# 从本地tar.gz文件安装包的函数 / Function to install packages from local tar.gz files
install_local_package <- function(tar_file) {
  package_name <- gsub("\\.tar\\.gz$", "", basename(tar_file))
  package_name <- gsub("-master$", "", package_name)  # 移除-master后缀 / Remove -master suffix
  
  if (!is_package_installed(package_name)) {
    cat("正在从本地文件安装包:", tar_file, "\n")
    cat("Installing package from local file:", tar_file, "\n")
    tryCatch({
      # 检查文件是否存在 / Check if file exists
      if (!file.exists(tar_file)) {
        stop(paste("文件不存在:", tar_file))
        stop(paste("File does not exist:", tar_file))
      }
      
      # 安装本地包 / Install local package
      install.packages(tar_file, repos = NULL, type = "source")
      cat("成功从本地文件安装:", package_name, "\n")
      cat("Successfully installed from local file:", package_name, "\n")
    }, error = function(e) {
      cat("本地安装失败", tar_file, ":", e$message, "\n")
      cat("Local installation failed", tar_file, ":", e$message, "\n")
    })
  } else {
    cat("包已安装:", package_name, "\n")
    cat("Package already installed:", package_name, "\n")
  }
}

cat("开始安装R包...\n")
cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装ggcor的依赖（如果有的话） / First install ggcor dependencies (if any)
cat("\n安装ggcor的依赖包...\n")
cat("\nInstalling ggcor dependencies...\n")
ggcor_dependencies <- c("ggplot2", "dplyr", "tidyr", "tibble", "rlang", "tidygraph", "vegan")
for (pkg in ggcor_dependencies) {
  install_cran_package(pkg)
}

# 从本地文件安装ggcor / Install ggcor from local file
cat("\n从本地文件安装ggcor...\n")
cat("\nInstalling ggcor from local file...\n")
local_packages <- c("ggcor-master.tar.gz")
for (pkg_file in local_packages) {
  install_local_package(pkg_file)
}

# 安装其他CRAN包 / Install other CRAN packages
cat("\n安装其他CRAN包...\n")
cat("\nInstalling other CRAN packages...\n")
cran_packages <- c("ade4", "data.table", "ggnewscale")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 安装Bioconductor包 / Install Bioconductor packages
cat("\n安装Bioconductor包...\n")
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("GSVA")
for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 验证安装 / Verify installation
cat("\n验证包安装...\n")
cat("\nVerifying package installation...\n")
required_packages <- c("ggcor", "ade4", "data.table", "ggnewscale", "ggplot2", "GSVA", "tidygraph", "vegan")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "安装成功\n")
    cat("✓", pkg, "installed successfully\n")
  } else {
    cat("✗", pkg, "安装失败\n")
    cat("✗", pkg, "installation failed\n")
    all_installed <- FALSE
  }
}

# 测试加载ggcor包 / Test loading ggcor package
cat("\n测试ggcor包加载...\n")
cat("\nTesting ggcor package loading...\n")
result <- tryCatch({
  library(ggcor)
  cat("✓ ggcor包加载成功\n")
  cat("✓ ggcor package loaded successfully\n")
  cat("ggcor版本:", packageVersion("ggcor"), "\n")
  cat("ggcor version:", packageVersion("ggcor"), "\n")
  TRUE
}, error = function(e) {
  cat("✗ ggcor包加载失败:", e$message, "\n")
  cat("✗ ggcor package loading failed:", e$message, "\n")
  FALSE
})

cat("\n===========================================\n")
if (all_installed && result) {
  cat("所有包安装完成！\n")
  cat("All packages installed successfully!\n")
  cat("现在可以运行FigureYa228linkCor.Rmd脚本了。\n")
  cat("You can now run the FigureYa228linkCor.Rmd script.\n")
} else {
  cat("部分包安装失败，请检查错误信息。\n")
  cat("Some packages failed to install, please check the error messages.\n")
}
