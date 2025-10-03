#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")
options(timeout = 600)  # 增加超时时间到10分钟

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
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
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
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

# 改进的GitHub安装函数
install_github_package <- function(repo, max_attempts = 3) {
  package_name <- basename(repo)
  
  if (is_package_installed(package_name)) {
    cat("Package already installed:", package_name, "\n")
    return(TRUE)
  }
  
  cat("Installing", package_name, "from GitHub...\n")
  
  for (attempt in 1:max_attempts) {
    cat("Attempt", attempt, "of", max_attempts, "\n")
    
    tryCatch({
      # 方法1: 使用devtools
      if (!is_package_installed("devtools")) {
        install.packages("devtools")
      }
      
      # 设置更长的超时时间
      options(timeout = 600)
      
      # 尝试安装
      devtools::install_github(repo, quiet = FALSE, upgrade = "never")
      
      if (is_package_installed(package_name)) {
        cat("Successfully installed", package_name, "from GitHub\n")
        return(TRUE)
      } else {
        cat("Installation completed but package not found\n")
      }
    }, error = function(e) {
      cat("Error on attempt", attempt, ":", e$message, "\n")
      
      # 如果是JSON错误，可能是网络问题，等待后重试
      if (grepl("JSON", e$message)) {
        cat("JSON parsing error detected, waiting 30 seconds before retry...\n")
        Sys.sleep(30)
      }
    })
    
    # 等待一段时间再重试
    if (attempt < max_attempts) {
      cat("Waiting 10 seconds before next attempt...\n")
      Sys.sleep(10)
    }
  }
  
  cat("All attempts failed for", package_name, "\n")
  
  # 备选方案：尝试从CRAN或Bioconductor安装
  cat("Trying alternative installation methods...\n")
  tryCatch({
    install_cran_package(package_name)
  }, error = function(e) {
    tryCatch({
      install_bioc_package(package_name)
    }, error = function(e2) {
      cat("All installation methods failed for", package_name, "\n")
    })
  })
  
  return(FALSE)
}

cat("Starting R package installation...\n")
cat("===========================================\n")

cat("\nInstalling important CRAN dependency packages first...\n")
cran_dep_packages <- c("curl", "httr", "png", "xml2", "rvest", "httr2", "jsonlite")
for (pkg in cran_dep_packages) {
  install_cran_package(pkg)
}

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("corrplot", "devtools", "dplyr", "ggplot2", "reshape2", "remotes")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("ConsensusClusterPlus")
for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 安装GitHub包 - 使用改进的函数
cat("\nInstalling GitHub packages...\n")
install_github_package("Gibbsdavidl/ImmuneSubtypeClassifier")

# 检查最终安装状态
cat("\nChecking final installation status...\n")
required_packages <- c("corrplot", "devtools", "dplyr", "ggplot2", "reshape2", 
                      "ConsensusClusterPlus", "ImmuneSubtypeClassifier")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed <- FALSE
  }
}

cat("\n===========================================\n")
if (all_installed) {
  cat("All packages successfully installed!\n")
} else {
  cat("Some packages failed to install. You may need to:\n")
  cat("1. Check your internet connection\n")
  cat("2. Try running the script again\n")
  cat("3. Manually install missing packages\n")
}

cat("You can now run your R scripts in this directory.\n")
