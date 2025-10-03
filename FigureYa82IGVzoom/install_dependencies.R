#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# Function to check if file exists locally
file_exists <- function(filename) {
  return(file.exists(filename))
}

# Function to install Sushi package
install_sushi_package <- function() {
  if (!is_package_installed("Sushi")) {
    # 首先尝试从本地安装
    local_file <- "Sushi_1.20.0.tar.gz"
    if (file_exists(local_file)) {
      cat("Installing Sushi package from local file:", local_file, "\n")
      tryCatch({
        install.packages(local_file, repos = NULL, type = "source")
        cat("Successfully installed: Sushi (from local file)\n")
        return(TRUE)
      }, error = function(e) {
        cat("Failed to install Sushi from local file:", e$message, "\n")
        cat("Trying Bioconductor archive...\n")
      })
    }
    
    # 如果本地安装失败或文件不存在，尝试从Bioconductor存档安装
    cat("Installing Sushi package from Bioconductor archive...\n")
    tryCatch({
      sushi_url <- "https://www.bioconductor.org/packages/3.8/bioc/src/contrib/Sushi_1.20.0.tar.gz"
      install.packages(sushi_url, repos = NULL, type = "source")
      cat("Successfully installed: Sushi (from Bioconductor archive)\n")
      return(TRUE)
    }, error = function(e) {
      cat("Failed to install Sushi from Bioconductor archive:", e$message, "\n")
      cat("Please make sure Sushi_1.20.0.tar.gz is in the current directory\n")
      return(FALSE)
    })
  } else {
    cat("Package already installed: Sushi\n")
    return(TRUE)
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 检查当前目录文件
cat("Files in current directory:\n")
system("ls -la | grep Sushi", intern = TRUE)

# 安装Sushi包
cat("\nInstalling Sushi package...\n")
success <- install_sushi_package()

cat("\n===========================================\n")
if (success) {
  cat("Package installation completed!\n")
  cat("You can now run your R scripts in this directory.\n")
} else {
  cat("Package installation failed!\n")
  cat("Please download Sushi_1.20.0.tar.gz and place it in the current directory.\n")
}
