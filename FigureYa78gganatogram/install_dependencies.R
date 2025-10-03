#!/usr/bin/env Rscript
# R package installation script
# This script installs required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(requireNamespace(package_name, quietly = TRUE))
}

# Function to install CRAN packages
install_cran_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("Installing CRAN package:", package_name, "\n")
    tryCatch({
      install.packages(package_name, dependencies = TRUE, quiet = TRUE)
      cat("✓ Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("✗ Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("✓ Package already installed:", package_name, "\n")
  }
}

# Function to install GitHub packages
install_github_package <- function(repo) {
  package_name <- basename(repo)
  if (!is_package_installed(package_name)) {
    cat("Installing GitHub package:", repo, "\n")
    tryCatch({
      if (!is_package_installed("devtools")) {
        install.packages("devtools", quiet = TRUE)
      }
      devtools::install_github(repo, quiet = TRUE)
      cat("✓ Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("✗ Failed to install", repo, ":", e$message, "\n")
    })
  } else {
    cat("✓ Package already installed:", package_name, "\n")
  }
}

# Function to download and install from URL
download_and_install_package <- function(url, local_file = "temp_package.tar.gz") {
  package_name <- "gganatogram"
  if (!is_package_installed(package_name)) {
    cat("Downloading package from:", url, "\n")
    tryCatch({
      # 下载文件
      download.file(url, destfile = local_file, quiet = TRUE)
      cat("✓ Package downloaded successfully\n")
      
      # 安装本地包
      cat("Installing from local file:", local_file, "\n")
      install.packages(local_file, repos = NULL, type = "source", quiet = TRUE)
      cat("✓ Successfully installed:", package_name, "\n")
      
      # 清理临时文件
      if (file.exists(local_file)) {
        file.remove(local_file)
        cat("✓ Temporary file cleaned up\n")
      }
    }, error = function(e) {
      cat("✗ Failed to download or install:", e$message, "\n")
      # 清理可能残留的临时文件
      if (file.exists(local_file)) {
        file.remove(local_file)
      }
    })
  } else {
    cat("✓ Package already installed:", package_name, "\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# 首先安装devtools（用于GitHub安装）
if (!is_package_installed("devtools")) {
  install_cran_package("devtools")
}

# 安装gganatogram（提供多种安装方式）
cat("\nInstalling gganatogram...\n")
cat("Trying installation methods in order:\n")
cat("1. From GitHub (recommended)\n")
cat("2. From downloaded tar.gz file (fallback)\n")

# 方法1：首先尝试从GitHub安装
github_success <- tryCatch({
  install_github_package("jespermaag/gganatogram")
  TRUE
}, error = function(e) {
  cat("GitHub installation failed:", e$message, "\n")
  FALSE
})

# 方法2：如果GitHub安装失败，尝试下载并安装
if (!github_success && !is_package_installed("gganatogram")) {
  cat("\nTrying alternative download method...\n")
  package_url <- "https://github.com/jespermaag/gganatogram/archive/refs/tags/F1000V2.tar.gz"
  download_and_install_package(package_url, "gganatogram_temp.tar.gz")
}

# 安装CRAN包
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("stringr", "gridExtra")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# 验证安装
cat("\nVerifying package installation:\n")
required_packages <- c("stringr", "gridExtra", "gganatogram")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed = FALSE
  }
}

# 测试包加载和功能
cat("\nTesting package loading and functionality...\n")

# 测试stringr包
if (is_package_installed("stringr")) {
  tryCatch({
    library(stringr)
    cat("✓ stringr package loaded successfully\n")
    
    # 测试stringr功能
    test_text <- "Hello World"
    result <- str_to_upper(test_text)
    if (result == "HELLO WORLD") {
      cat("✓ stringr functions working correctly\n")
    } else {
      cat("⚠ stringr function test inconclusive\n")
    }
  }, error = function(e) {
    cat("✗ stringr loading failed:", e$message, "\n")
  })
}

# 测试gridExtra包
if (is_package_installed("gridExtra")) {
  tryCatch({
    library(gridExtra)
    cat("✓ gridExtra package loaded successfully\n")
    
    # 测试gridExtra功能（创建简单的图形对象）
    if (exists("grid.arrange") && exists("arrangeGrob")) {
      cat("✓ gridExtra main functions available\n")
    }
  }, error = function(e) {
    cat("✗ gridExtra loading failed:", e$message, "\n")
  })
}

# 测试gganatogram包
if (is_package_installed("gganatogram")) {
  tryCatch({
    library(gganatogram)
    cat("✓ gganatogram package loaded successfully\n")
    
    # 测试gganatogram内置数据
    if (exists("hgMale_key") && exists("hgFemale_key")) {
      cat("✓ gganatogram built-in data available\n")
      cat("  - Male organs:", length(unique(hgMale_key$organ)), "organs\n")
      cat("  - Female organs:", length(unique(hgFemale_key$organ)), "organs\n")
    }
  }, error = function(e) {
    cat("✗ gganatogram loading failed:", e$message, "\n")
  })
}

if (all_installed) {
  cat("\n✅ All required packages installed successfully!\n")
  cat("You can now use stringr, gridExtra, and gganatogram in your R scripts.\n")
} else {
  cat("\n⚠️  Some packages failed to install.\n")
  cat("You may need to install them manually:\n")
  
  missing_packages <- required_packages[!sapply(required_packages, is_package_installed)]
  for (pkg in missing_packages) {
    if (pkg == "gganatogram") {
      cat("# From GitHub:\n")
      cat("devtools::install_github(\"jespermaag/gganatogram\")\n")
      cat("# Or download and install:\n")
      cat("download.file(\"https://github.com/jespermaag/gganatogram/archive/refs/tags/F1000V2.tar.gz\", \"gganatogram.tar.gz\")\n")
      cat("install.packages(\"gganatogram.tar.gz\", repos = NULL, type = \"source\")\n")
    } else {
      cat("install.packages('", pkg, "')\n", sep = "")
    }
  }
}
