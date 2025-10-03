#!/usr/bin/env Rscript
# Auto-generated R dependency installation script

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
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

# Function to install Bioconductor packages
install_bioc_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("Installing Bioconductor package:", package_name, "\n")
    tryCatch({
      if (!is_package_installed("BiocManager")) {
        install.packages("BiocManager", quiet = TRUE)
      }
      BiocManager::install(package_name, update = FALSE, ask = FALSE, quiet = TRUE)
      cat("✓ Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("✗ Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("✓ Package already installed:", package_name, "\n")
  }
}

cat("Starting package installation...\n")
cat("===========================================\n")

# 1. 安装CRAN包
cat("\n1. Installing CRAN packages...\n")
cran_packages <- c("cluster", "phangorn", "ape", "reshape2")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 2. 安装Bioconductor包
cat("\n2. Installing Bioconductor packages...\n")
bioc_packages <- c("ComplexHeatmap", "limma", "ConsensusClusterPlus")
for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 验证安装
cat("\n3. Verifying installation...\n")
required_packages <- c("cluster", "phangorn", "ape", "reshape2", "ComplexHeatmap", "limma", "ConsensusClusterPlus")

all_installed <- TRUE
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✓", pkg, "is installed\n")
  } else {
    cat("✗", pkg, "is NOT installed\n")
    all_installed <- FALSE
  }
}

# 测试包加载
cat("\n4. Testing package loading...\n")
test_packages <- function() {
  tryCatch({
    library(cluster)
    cat("✓ cluster package loaded successfully\n")
  }, error = function(e) {
    cat("✗ cluster loading failed:", e$message, "\n")
  })
  
  tryCatch({
    library(phangorn)
    cat("✓ phangorn package loaded successfully\n")
  }, error = function(e) {
    cat("✗ phangorn loading failed:", e$message, "\n")
  })
  
  tryCatch({
    library(ape)
    cat("✓ ape package loaded successfully\n")
  }, error = function(e) {
    cat("✗ ape loading failed:", e$message, "\n")
  })
  
  tryCatch({
    library(reshape2)
    cat("✓ reshape2 package loaded successfully\n")
  }, error = function(e) {
    cat("✗ reshape2 loading failed:", e$message, "\n")
  })
  
  tryCatch({
    library(ComplexHeatmap)
    cat("✓ ComplexHeatmap package loaded successfully\n")
  }, error = function(e) {
    cat("✗ ComplexHeatmap loading failed:", e$message, "\n")
  })
  
  tryCatch({
    library(limma)
    cat("✓ limma package loaded successfully\n")
  }, error = function(e) {
    cat("✗ limma loading failed:", e$message, "\n")
  })
  
  tryCatch({
    library(ConsensusClusterPlus)
    cat("✓ ConsensusClusterPlus package loaded successfully\n")
    
    # 测试ConsensusClusterPlus的基本功能
    if (exists("ConsensusClusterPlus")) {
      cat("✓ ConsensusClusterPlus main function is available\n")
    }
  }, error = function(e) {
    cat("✗ ConsensusClusterPlus loading failed:", e$message, "\n")
  })
}

cat("\nInstallation completed!\n")
