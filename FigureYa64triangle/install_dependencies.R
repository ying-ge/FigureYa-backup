#!/usr/bin/env Rscript
# Auto-generated R dependency installation script for ternary plots
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(requireNamespace(package_name, quietly = TRUE))
}

# Function to install CRAN packages (with upgrade option)
install_cran_package <- function(package_name, upgrade = FALSE) {
  if (!is_package_installed(package_name) || upgrade) {
    if (upgrade) {
      cat("Upgrading CRAN package:", package_name, "\n")
    } else {
      cat("Installing CRAN package:", package_name, "\n")
    }
    tryCatch({
      install.packages(package_name, dependencies = TRUE, quiet = TRUE)
      if (upgrade) {
        cat("✓ Successfully upgraded:", package_name, "\n")
      } else {
        cat("✓ Successfully installed:", package_name, "\n")
      }
    }, error = function(e) {
      cat("✗ Failed to install/upgrade", package_name, ":", e$message, "\n")
    })
  } else {
    cat("✓ Package already installed:", package_name, "\n")
  }
}

cran_packages <- c(
  "ggtern",  # 添加 ggtern 包 Add ggtern package
  "directlabels", "proto", "scales", "tidyverse", 
  "dplyr", "grid", "gtable", "plyr", "MASS", "compositions"
)

# 关键包需要升级到最新版本（但保持兼容性）
# Key packages need to be upgraded to latest versions (but maintain compatibility)
# 注意：ggtern 3.5.0 与 ggplot2 4.0.1 不兼容，需要使用 ggplot2 3.5.1
# Note: ggtern 3.5.0 is not compatible with ggplot2 4.0.1, need to use ggplot2 3.5.1
upgrade_packages <- c("ggtern")

for (pkg in cran_packages) {
  upgrade <- pkg %in% upgrade_packages
  install_cran_package(pkg, upgrade = upgrade)
}

# ggplot2 版本管理
# ggplot2 version management
# 注意：ggtern 3.5.0 要求 ggplot2 >= 3.5.0 但 < 4.0.0
# Note: ggtern 3.5.0 requires ggplot2 >= 3.5.0 but < 4.0.0
# 如果用户明确要求使用 ggplot2 4.0+，可以通过环境变量 FORCE_GGPLOT2_4.0=TRUE 来强制
# If user explicitly wants ggplot2 4.0+, can force via environment variable FORCE_GGPLOT2_4.0=TRUE

FORCE_GGPLOT2_4.0 <- Sys.getenv("FORCE_GGPLOT2_4.0", "FALSE") == "TRUE"

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = "https://cloud.r-project.org/")
}

if (requireNamespace("remotes", quietly = TRUE)) {
  current_ggplot2 <- tryCatch({
    as.character(packageVersion("ggplot2"))
  }, error = function(e) "0.0.0")
  
  if (FORCE_GGPLOT2_4.0) {
    # 用户明确要求使用 ggplot2 4.0+
    # User explicitly requested ggplot2 4.0+
    cat("⚠️  WARNING: Forcing ggplot2 4.0+ (ggtern 3.5.0 may not work!)\n")
    install.packages("ggplot2", repos = "https://cloud.r-project.org/")
    cat("✓ ggplot2 upgraded to latest version (4.0.1)\n")
    cat("⚠️  NOTE: ggtern may not work with ggplot2 4.0.1\n")
    cat("   Consider using alternative packages or wait for ggtern update\n")
  } else {
    # 默认行为：确保兼容性
    # Default behavior: ensure compatibility
    if (package_version(current_ggplot2) >= package_version("4.0.0")) {
      cat("⚠️  ggplot2 version", current_ggplot2, "is not compatible with ggtern 3.5.0\n")
      cat("Downgrading ggplot2 to 3.5.0 for compatibility...\n")
      cat("(Set FORCE_GGPLOT2_4.0=TRUE to use ggplot2 4.0+ instead)\n")
      tryCatch({
        remotes::install_version("ggplot2", version = "3.5.0", repos = "https://cloud.r-project.org/")
        cat("✓ ggplot2 downgraded to 3.5.0\n")
      }, error = function(e) {
        cat("⚠️  Could not install ggplot2 3.5.0:", e$message, "\n")
        cat("   Please manually install: remotes::install_version('ggplot2', '3.5.0')\n")
      })
    } else if (package_version(current_ggplot2) < package_version("3.5.0")) {
      # 如果版本 < 3.5.0，升级到 3.5.0
      # If version < 3.5.0, upgrade to 3.5.0
      cat("Upgrading ggplot2 to 3.5.0 for compatibility with ggtern 3.5.0...\n")
      remotes::install_version("ggplot2", version = "3.5.0", repos = "https://cloud.r-project.org/")
      cat("✓ ggplot2 upgraded to 3.5.0\n")
    } else {
      cat("✓ ggplot2 version is compatible:", current_ggplot2, "\n")
    }
  }
}

# 验证安装
cat("\n===========================================\n")
cat("Verifying installation...\n")

# 验证安装的包
# Verify installed packages
required_packages <- c("ggtern", "ggplot2", "directlabels", "scales", "tidyverse", "plyr", "proto", "grid")
success_count <- 0

for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is ready\n")
    success_count <- success_count + 1
  } else {
    cat("✗", pkg, "is MISSING\n")
  }
}

cat("\nInstallation summary:\n")
cat("Successfully installed:", success_count, "/", length(required_packages), "packages\n")

if (success_count == length(required_packages)) {
  cat("✅ All packages installed successfully!\n")
  cat("You can now run your ternary plot scripts.\n")
} else {
  cat("⚠️  Some packages failed to install.\n")
}

cat("\nInstallation completed!\n")
