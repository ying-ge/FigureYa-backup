#!/usr/bin/env Rscript
# Auto-generated R dependency installation script
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# Function to install CRAN packages with better error handling
install_cran_package <- function(package_name, max_attempts = 2) {
  if (!is_package_installed(package_name)) {
    cat("Installing CRAN package:", package_name, "\n")
    
    for (attempt in 1:max_attempts) {
      tryCatch({
        install.packages(package_name, dependencies = TRUE, quiet = FALSE)
        if (is_package_installed(package_name)) {
          cat("✅ Successfully installed:", package_name, "\n")
          return(TRUE)
        }
      }, error = function(e) {
        cat("Attempt", attempt, "failed:", e$message, "\n")
        if (attempt == max_attempts) {
          cat("❌ Failed to install", package_name, "\n")
          return(FALSE)
        }
        Sys.sleep(2)
      })
    }
  } else {
    cat("✅ Package already installed:", package_name, "\n")
    return(TRUE)
  }
}

# Function to install Bioconductor packages
install_bioc_package <- function(package_name, max_attempts = 2) {
  if (!is_package_installed(package_name)) {
    cat("Installing Bioconductor package:", package_name, "\n")
    
    if (!is_package_installed("BiocManager")) {
      install_cran_package("BiocManager")
    }
    
    for (attempt in 1:max_attempts) {
      tryCatch({
        BiocManager::install(package_name, update = FALSE, ask = FALSE, quiet = FALSE)
        if (is_package_installed(package_name)) {
          cat("✅ Successfully installed:", package_name, "\n")
          return(TRUE)
        }
      }, error = function(e) {
        cat("Attempt", attempt, "failed:", e$message, "\n")
        if (attempt == max_attempts) {
          cat("❌ Failed to install", package_name, "\n")
          return(FALSE)
        }
        Sys.sleep(2)
      })
    }
  } else {
    cat("✅ Package already installed:", package_name, "\n")
    return(TRUE)
  }
}

# Function to install kpmt (critical dependency for ChAMP)
install_kpmt <- function() {
  if (!is_package_installed("kpmt")) {
    cat("Attempting to install kpmt (required for ChAMP)...\n")
    
    # Try multiple methods to install kpmt
    methods <- c(
      # Method 1: Try CRAN (unlikely but possible)
      function() install_cran_package("kpmt"),
      
      # Method 2: Try Bioconductor
      function() install_bioc_package("kpmt"),
      
      # Method 3: Try GitHub (most likely)
      function() {
        if (!is_package_installed("remotes")) {
          install_cran_package("remotes")
        }
        tryCatch({
          remotes::install_github("tpq/kpmt")
          if (is_package_installed("kpmt")) {
            cat("✅ Successfully installed kpmt from GitHub\n")
            return(TRUE)
          }
        }, error = function(e) {
          cat("GitHub installation failed:", e$message, "\n")
          return(FALSE)
        })
      },
      
      # Method 4: Try installing from source
      function() {
        tryCatch({
          install.packages("https://cran.r-project.org/src/contrib/Archive/kpmt/kpmt_0.1.0.tar.gz", 
                          repos = NULL, type = "source")
          if (is_package_installed("kpmt")) {
            cat("✅ Successfully installed kpmt from source\n")
            return(TRUE)
          }
        }, error = function(e) {
          cat("Source installation failed:", e$message, "\n")
          return(FALSE)
        })
      }
    )
    
    # Try each method until one works
    for (method in methods) {
      if (method()) {
        return(TRUE)
      }
    }
    
    cat("❌ All methods failed to install kpmt\n")
    return(FALSE)
  } else {
    cat("✅ kpmt package already installed\n")
    return(TRUE)
  }
}

# Function to install ChAMP with special handling
install_champ <- function() {
  if (!is_package_installed("ChAMP")) {
    cat("Installing ChAMP package...\n")
    
    # First install kpmt
    if (!install_kpmt()) {
      cat("⚠️  kpmt installation failed - ChAMP may not work properly\n")
    }
    
    # Install ChAMP dependencies first
    champ_deps <- c(
      "minfi", "limma", "sva", "impute", "preprocessCore", "DNAcopy", 
      "marray", "qvalue", "IlluminaHumanMethylation450kmanifest",
      "IlluminaHumanMethylation450kanno.ilmn12.hg19"
    )
    
    cat("Installing ChAMP dependencies...\n")
    for (dep in champ_deps) {
      install_bioc_package(dep)
    }
    
    # Try multiple methods to install ChAMP
    methods <- c(
      # Method 1: Standard Bioconductor installation
      function() install_bioc_package("ChAMP"),
      
      # Method 2: Install specific version
      function() {
        tryCatch({
          BiocManager::install("ChAMP@2.32.0", update = FALSE, ask = FALSE)  # Older version
          if (is_package_installed("ChAMP")) {
            cat("✅ Successfully installed ChAMP version 2.32.0\n")
            return(TRUE)
          }
        }, error = function(e) {
          cat("Version-specific installation failed:", e$message, "\n")
          return(FALSE)
        })
      },
      
      # Method 3: Install from GitHub
      function() {
        if (!is_package_installed("remotes")) {
          install_cran_package("remotes")
        }
        tryCatch({
          remotes::install_github("YuanTian1991/ChAMP")
          if (is_package_installed("ChAMP")) {
            cat("✅ Successfully installed ChAMP from GitHub\n")
            return(TRUE)
          }
        }, error = function(e) {
          cat("GitHub installation failed:", e$message, "\n")
          return(FALSE)
        })
      }
    )
    
    # Try each method
    for (method in methods) {
      if (method()) {
        return(TRUE)
      }
    }
    
    cat("❌ All methods failed to install ChAMP\n")
    return(FALSE)
  } else {
    cat("✅ ChAMP package already installed\n")
    return(TRUE)
  }
}

# Alternative approach: use minfi instead of ChAMP if ChAMP fails
setup_methylation_analysis <- function() {
  if (!install_champ()) {
    cat("\n⚠️  ChAMP installation failed. Setting up alternative methylation analysis...\n")
    cat("Installing minfi and related packages for methylation analysis...\n")
    
    minfi_packages <- c(
      "minfi", "limma", "sva", "impute", "preprocessCore", "IlluminaHumanMethylation450kmanifest",
      "IlluminaHumanMethylation450kanno.ilmn12.hg19", "DMRcate", "missMethyl"
    )
    
    for (pkg in minfi_packages) {
      install_bioc_package(pkg)
    }
    
    cat("✅ Alternative methylation analysis packages installed\n")
    cat("You may need to modify your code to use minfi instead of ChAMP\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# Install basic utilities first
cat("Installing basic utilities...\n")
install_cran_package("BiocManager")
install_cran_package("remotes")

# Install CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("RColorBrewer", "survival", "tidyverse", "ggplot2", "dplyr")
for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Setup methylation analysis (ChAMP or alternative)
cat("\nSetting up methylation analysis packages...\n")
setup_methylation_analysis()

# Install other Bioconductor packages
cat("\nInstalling other Bioconductor packages...\n")
other_bioc_packages <- c("minfi", "limma")  # Ensure these are installed
for (pkg in other_bioc_packages) {
  install_bioc_package(pkg)
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# Final check
cat("\nFinal package status:\n")
required_packages <- c("RColorBrewer", "survival", "tidyverse", "minfi", "ChAMP")
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✅", pkg, "\n")
  } else {
    cat("❌", pkg, "(not installed)\n")
  }
}

# Provide guidance based on installation results
if (!is_package_installed("ChAMP")) {
  cat("\n⚠️  ChAMP was not installed. You have two options:\n")
  cat("1. Use minfi package instead for methylation analysis\n")
  cat("2. Manually install kpmt and ChAMP:\n")
  cat("   - Install system dependencies: libcurl4-openssl-dev libxml2-dev\n")
  cat("   - Try: remotes::install_github('tpq/kpmt')\n")
  cat("   - Then: BiocManager::install('ChAMP')\n")
} else {
  cat("\n✅ All packages installed successfully!\n")
}

cat("You can now run your R scripts in this directory.\n")
