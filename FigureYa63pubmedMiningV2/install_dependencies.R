#!/usr/bin/env Rscript
# R package installation script for FigureYa63pubmedMiningV2

# Set up mirrors
options("repos" = c(CRAN = "https://cloud.r-project.org/"))

# Improved package check function
is_package_installed <- function(package_name) {
  return(requireNamespace(package_name, quietly = TRUE))
}

# Install function with better error handling
install_package <- function(package_name, type = "cran") {
  if (!is_package_installed(package_name)) {
    cat("Installing", type, "package:", package_name, "\n")
    tryCatch({
      if (type == "cran") {
        install.packages(package_name, dependencies = TRUE, quiet = TRUE)
      } else if (type == "bioc") {
        if (!is_package_installed("BiocManager")) {
          install.packages("BiocManager", quiet = TRUE)
        }
        BiocManager::install(package_name, update = FALSE, ask = FALSE, quiet = TRUE)
      }
      cat("✓ Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("✗ Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("✓ Package already installed:", package_name, "\n")
  }
}

cat("Starting package installation for PubMed mining...\n")
cat("===========================================\n")

# 安装CRAN包
cat("\n1. Installing CRAN packages...\n")
cran_packages <- c(
  "data.table", "DT", "ggplot2", "htmlwidgets", 
  "pubmed.mineR", "rentrez", "stringr"
)

for (pkg in cran_packages) {
  install_package(pkg, "cran")
}

# 验证安装
cat("\n===========================================\n")
cat("Verifying installation...\n")

required_packages <- c(
  "data.table", "stringr", "ggplot2", "rentrez", 
  "pubmed.mineR", "DT", "htmlwidgets"
)

success_count <- 0

for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is ready\n")
    success_count <- success_count + 1
    
    # 测试包是否能正常加载
    tryCatch({
      library(pkg, character.only = TRUE)
      cat("  -", pkg, "loaded successfully\n")
    }, error = function(e) {
      cat("  -", pkg, "load test failed:", e$message, "\n")
    })
  } else {
    cat("✗", pkg, "is MISSING\n")
  }
}

cat("\nInstallation summary:\n")
cat("Successfully installed:", success_count, "/", length(required_packages), "required packages\n")

# 测试关键包的功能
cat("\nTesting key package functionality...\n")

# 测试 data.table
if (is_package_installed("data.table")) {
  tryCatch({
    library(data.table)
    test_dt <- data.table(a = 1:3, b = letters[1:3])
    cat("✓ data.table functionality test passed\n")
  }, error = function(e) {
    cat("✗ data.table test failed:", e$message, "\n")
  })
}

# 测试 rentrez
if (is_package_installed("rentrez")) {
  tryCatch({
    library(rentrez)
    # 简单的测试查询
    test_search <- entrez_search(db="pubmed", term="cancer", retmax=1)
    cat("✓ rentrez functionality test passed\n")
  }, error = function(e) {
    cat("✗ rentrez test failed:", e$message, "\n")
  })
}

# 测试 pubmed.mineR
if (is_package_installed("pubmed.mineR")) {
  tryCatch({
    library(pubmed.mineR)
    cat("✓ pubmed.mineR loaded successfully\n")
  }, error = function(e) {
    cat("✗ pubmed.mineR test failed:", e$message, "\n")
  })
}

# 测试 DT
if (is_package_installed("DT")) {
  tryCatch({
    library(DT)
    test_df <- data.frame(x = 1:3, y = letters[1:3])
    dt_obj <- datatable(test_df)
    cat("✓ DT functionality test passed\n")
  }, error = function(e) {
    cat("✗ DT test failed:", e$message, "\n")
  })
}

if (success_count == length(required_packages)) {
  cat("\n✅ All required packages installed successfully!\n")
  cat("You can now run your PubMed mining scripts.\n")
  
  cat("\nAvailable packages for use:\n")
  cat("- data.table: for efficient data manipulation\n")
  cat("- stringr: for string operations\n") 
  cat("- ggplot2: for data visualization\n")
  cat("- rentrez: for NCBI Entrez database access\n")
  cat("- pubmed.mineR: for PubMed data mining\n")
  cat("- DT: for interactive data tables\n")
  cat("- htmlwidgets: for HTML widget support\n")
  
} else {
  cat("\n⚠️  Some packages failed to install.\n")
  cat("You may need to install them manually:\n")
  
  missing_packages <- required_packages[!sapply(required_packages, is_package_installed)]
  for (pkg in missing_packages) {
    cat("install.packages('", pkg, "')\n", sep = "")
  }
}
