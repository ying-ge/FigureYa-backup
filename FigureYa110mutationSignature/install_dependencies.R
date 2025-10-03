#!/usr/bin/env Rscript
# 安装突变特征分析所需R包的脚本
# Script to install R packages required for mutation signature analysis

# 设置下载选项 / Set download options
options(repos = c(CRAN = "https://cloud.r-project.org/"))
options(timeout = 600)  # 增加超时时间 / Increase timeout
options(download.file.method = "libcurl")

# 检查包是否已安装 / Check if package is installed
is_installed <- function(pkg) {
  pkg %in% rownames(installed.packages())
}

# 安装CRAN包（带重试机制）/ Install CRAN package (with retry mechanism)
install_cran_package <- function(pkg, max_retries = 3) {
  if (is_installed(pkg)) {
    cat("✓", pkg, "已经安装 / already installed\n")
    return(TRUE)
  }
  
  for (attempt in 1:max_retries) {
    cat("尝试安装 / Attempting to install", pkg, "(尝试 / attempt", attempt, "/", max_retries, ")...\n")
    
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
      if (is_installed(pkg)) {
        cat("✓", pkg, "安装成功 / installed successfully\n")
        return(TRUE)
      }
    }, error = function(e) {
      cat("尝试 / Attempt", attempt, "失败 / failed:", e$message, "\n")
      if (attempt < max_retries) {
        cat("等待10秒后重试 / Waiting 10 seconds before retry...\n")
        Sys.sleep(10)
      }
    })
  }
  
  cat("❌", pkg, "安装失败 / installation failed\n")
  return(FALSE)
}

# 安装Bioconductor包 / Install Bioconductor package
install_bioc_package <- function(pkg, max_retries = 3) {
  if (is_installed(pkg)) {
    cat("✓", pkg, "已经安装 / already installed\n")
    return(TRUE)
  }
  
  # 确保BiocManager已安装 / Ensure BiocManager is installed
  if (!is_installed("BiocManager")) {
    install_cran_package("BiocManager")
  }
  
  for (attempt in 1:max_retries) {
    cat("尝试安装Bioconductor包 / Attempting to install Bioconductor package", pkg, "(尝试 / attempt", attempt, "/", max_retries, ")...\n")
    
    tryCatch({
      BiocManager::install(pkg, ask = FALSE, update = FALSE)
      if (is_installed(pkg)) {
        cat("✓", pkg, "安装成功 / installed successfully\n")
        return(TRUE)
      }
    }, error = function(e) {
      cat("尝试 / Attempt", attempt, "失败 / failed:", e$message, "\n")
      if (attempt < max_retries) {
        cat("等待10秒后重试 / Waiting 10 seconds before retry...\n")
        Sys.sleep(10)
      }
    })
  }
  
  cat("❌", pkg, "安装失败 / installation failed\n")
  return(FALSE)
}

# 安装所需的所有包 / Install all required packages
install_required_packages <- function() {
  cat("开始安装所需R包... / Starting installation of required R packages...\n")
  
  # CRAN包列表 / List of CRAN packages
  cran_packages <- c(
    "tidyverse",    # 数据科学工具集合 / Data science toolkit
    "magrittr",     # 管道操作符包 / Pipe operator package
    "readxl",       # Excel文件读取包 / Excel file reading package
    "stringr",      # 字符串处理包 / String processing package
    "forcats",      # 因子处理包 / Factor processing package
    "NMF"           # 非负矩阵分解包 / Non-negative matrix factorization package
  )
  
  # Bioconductor包列表 / List of Bioconductor packages
  bioc_packages <- c(
    "BSgenome.Hsapiens.UCSC.hg19"  # 人类基因组参考包（hg19）/ Human genome reference package (hg19)
  )
  
  # 安装CRAN包 / Install CRAN packages
  cat("安装CRAN包... / Installing CRAN packages...\n")
  cran_results <- sapply(cran_packages, install_cran_package)
  
  # 安装Bioconductor包 / Install Bioconductor packages
  cat("安装Bioconductor包... / Installing Bioconductor packages...\n")
  bioc_results <- sapply(bioc_packages, install_bioc_package)
  
  return(all(cran_results, bioc_results))
}

# 验证安装 / Verify installation
verify_installation <- function() {
  cat("验证安装... / Verifying installation...\n")
  
  required_packages <- c(
    "tidyverse", "magrittr", "readxl", "stringr", 
    "forcats", "NMF", "BSgenome.Hsapiens.UCSC.hg19"
  )
  
  missing_packages <- c()
  
  for (pkg in required_packages) {
    if (is_installed(pkg)) {
      cat("✓", pkg, "已安装 / installed\n")
      
      # 尝试加载包来验证 / Try to load package for verification
      tryCatch({
        library(pkg, character.only = TRUE, quietly = TRUE)
        cat("  ", pkg, "加载成功 / loaded successfully\n")
      }, error = function(e) {
        cat("  ⚠", pkg, "加载有警告 / loading warning:", e$message, "\n")
      })
    } else {
      cat("❌", pkg, "未安装 / not installed\n")
      missing_packages <- c(missing_packages, pkg)
    }
  }
  
  return(length(missing_packages) == 0)
}

# 主安装函数 / Main installation function
main <- function() {
  cat("开始安装突变特征分析所需R包...\n")
  cat("Starting installation of R packages for mutation signature analysis...\n")
  cat("===========================================\n")
  
  # 安装所需包 / Install required packages
  success <- install_required_packages()
  
  # 验证安装 / Verify installation
  is_verified <- verify_installation()
  
  cat("\n===========================================\n")
  if (is_verified) {
    cat("✅ 所有包安装验证成功！ / All packages installed successfully!\n")
    cat("你现在可以运行突变特征分析的R脚本了。\n")
    cat("You can now run the mutation signature analysis R script.\n")
  } else {
    cat("⚠ 部分包安装失败，请检查网络连接或手动安装。\n")
    cat("⚠ Some packages failed to install, please check your network connection or install manually.\n")
  }
  
  cat("\n安装完成！ / Installation completed!\n")
}

# 执行安装 / Execute installation
main()
