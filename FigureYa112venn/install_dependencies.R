#!/usr/bin/env Rscript
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(timeout = 600)  # 增加超时时间

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# Function to install CRAN packages (vectorized)
install_cran_packages <- function(packages) {
  # Filter out already installed packages
  packages_to_install <- packages[!sapply(packages, is_package_installed)]
  if (length(packages_to_install) == 0) {
    cat("All required CRAN packages are already installed.\n")
    return()
  }
  
  for (pkg in packages_to_install) {
    cat("Installing CRAN package:", pkg, "\n")
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
      cat("Successfully installed:", pkg, "\n")
    }, error = function(e) {
      cat("Warning: Failed to install CRAN package ", pkg, ": ", e$message, "\n")
      # 不要停止，继续安装其他包
    })
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# --- Step 1: Install CRAN Packages ---
cat("\nInstalling CRAN packages...\n")
cran_packages <- c(
  "Cairo", "RColorBrewer", "VennDiagram", 
  "dplyr", "ggplot2", "grDevices", "magrittr", "purrr", "readr", 
  "stringr", "tibble", "tidyr"
)
install_cran_packages(cran_packages)

# --- Step 2: 验证安装 ---
cat("\nVerifying package installation...\n")

# 核心包验证
required_packages <- c(
  "VennDiagram", "ggplot2", "dplyr", "magrittr", "readr", 
  "purrr", "RColorBrewer", "grDevices", "Cairo", "stringr", 
  "tibble", "tidyr"
)

all_installed <- TRUE
installed_packages <- c()
failed_packages <- c()

for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
    installed_packages <- c(installed_packages, pkg)
  } else {
    cat("✗", pkg, "FAILED to install\n")
    failed_packages <- c(failed_packages, pkg)
    all_installed = FALSE
  }
}

cat("\n===========================================\n")
if (all_installed) {
  cat("All required packages installed successfully!\n")
  cat("You can now run your R scripts in this directory.\n")
} else {
  cat("Package installation completed with some failures.\n")
  cat("Installed packages:", paste(installed_packages, collapse=", "), "\n")
  cat("Failed packages:", paste(failed_packages, collapse=", "), "\n")
  cat("\nYou may need to manually install the failed packages:\n")
  cat("install.packages(c('", paste(failed_packages, collapse="', '"), "'))\n", sep="")
}
