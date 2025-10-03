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

# Function to install GitHub packages
install_github_package <- function(repo) {
  pkg_name <- basename(repo)
  if (!is_package_installed(pkg_name)) {
    cat("Installing GitHub package:", repo, "\n")
    tryCatch({
      if (!is_package_installed("remotes")) {
        install.packages("remotes")
      }
      remotes::install_github(repo)
      cat("Successfully installed:", pkg_name, "\n")
    }, error = function(e) {
      cat("Failed to install", pkg_name, ":", e$message, "\n")
    })
  } else {
    cat("Package already installed:", pkg_name, "\n")
  }
}

# Function to install kpmt package (required by ChAMP)
install_kpmt <- function() {
  if (!is_package_installed("kpmt")) {
    cat("Installing kpmt package (required by ChAMP)...\n")
    tryCatch({
      if (!is_package_installed("remotes")) {
        install.packages("remotes")
      }
      # kpmt is available on GitHub
      remotes::install_github("GreenwoodLab/kpmt")
      cat("Successfully installed: kpmt\n")
    }, error = function(e) {
      cat("Failed to install kpmt:", e$message, "\n")
      cat("Trying alternative installation method...\n")
      # Alternative: try to install from CRAN archive
      tryCatch({
        install.packages("https://cran.r-project.org/src/contrib/Archive/kpmt/kpmt_0.1.0.tar.gz", 
                        repos = NULL, type = "source")
        cat("Successfully installed: kpmt from archive\n")
      }, error = function(e2) {
        cat("Also failed to install kpmt from archive:", e2$message, "\n")
      })
    })
  } else {
    cat("Package already installed: kpmt\n")
  }
}

# Function to install ChAMP with proper dependency handling
install_champ <- function() {
  if (!is_package_installed("ChAMP")) {
    cat("Installing ChAMP package...\n")
    
    # First install kpmt (critical dependency)
    install_kpmt()
    
    # Install other ChAMP dependencies
    champ_deps <- c("limma", "minfi", "IlluminaHumanMethylation450kmanifest",
                   "IlluminaHumanMethylation450kanno.ilmn12.hg19", "DMRcate",
                   "DNAcopy", "preprocessCore", "sva", "RPMM", "doParallel", "foreach")
    
    cat("Installing ChAMP dependencies...\n")
    for (pkg in champ_deps) {
      if (!is_package_installed(pkg)) {
        tryCatch({
          BiocManager::install(pkg, update = FALSE, ask = FALSE)
          cat("Installed:", pkg, "\n")
        }, error = function(e) {
          cat("Failed to install dependency", pkg, ":", e$message, "\n")
        })
      }
    }
    
    # Now try to install ChAMP
    tryCatch({
      BiocManager::install("ChAMP", update = FALSE, ask = FALSE)
      cat("Successfully installed: ChAMP\n")
    }, error = function(e) {
      cat("Failed to install ChAMP via BiocManager:", e$message, "\n")
      cat("Trying alternative installation method...\n")
      tryCatch({
        # Try installing from GitHub as alternative
        remotes::install_github("YuanTian1991/ChAMP")
        cat("Successfully installed: ChAMP from GitHub\n")
      }, error = function(e2) {
        cat("Also failed to install ChAMP from GitHub:", e2$message, "\n")
      })
    })
  } else {
    cat("Package already installed: ChAMP\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# Install remotes first for GitHub installations
install_cran_package("remotes")

# Installing CRAN packages
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("data.table", "ggplot2", "ggpubr", "randomcoloR", "doParallel", "foreach")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Install ChAMP with proper dependency handling
install_champ()

# Installing other Bioconductor packages
cat("\nInstalling other Bioconductor packages...\n")
bioc_packages <- c("ComplexHeatmap", "clusterProfiler", "GSVA", "impute",
                  "limma", "minfi", "DMRcate", "sva")

for (pkg in bioc_packages) {
  if (pkg != "ChAMP") {  # Skip ChAMP as we already installed it
    install_bioc_package(pkg)
  }
}

# Install additional dependencies that might be needed
cat("\nInstalling additional dependencies...\n")
additional_deps <- c("IlluminaHumanMethylation450kmanifest", 
                    "IlluminaHumanMethylation450kanno.ilmn12.hg19",
                    "IlluminaHumanMethylationEPICmanifest",
                    "IlluminaHumanMethylationEPICanno.ilm10b4.hg19")

for (pkg in additional_deps) {
  if (!is_package_installed(pkg)) {
    tryCatch({
      BiocManager::install(pkg, update = FALSE, ask = FALSE)
      cat("Installed:", pkg, "\n")
    }, error = function(e) {
      cat("Failed to install", pkg, ":", e$message, "\n")
    })
  }
}

# Verify all critical packages are installed
cat("\nVerifying installation of critical packages...\n")
critical_packages <- c("ChAMP", "ComplexHeatmap", "clusterProfiler", "GSVA", "impute")
missing_packages <- c()

for (pkg in critical_packages) {
  if (!is_package_installed(pkg)) {
    missing_packages <- c(missing_packages, pkg)
    cat("❌ MISSING:", pkg, "\n")
  } else {
    cat("✅ OK:", pkg, "\n")
  }
}

cat("\n===========================================\n")
if (length(missing_packages) == 0) {
  cat("All packages successfully installed!\n")
  cat("You can now run your R scripts in this directory.\n")
} else {
  cat("Some critical packages failed to install:", paste(missing_packages, collapse = ", "), "\n")
  cat("You may need to install them manually:\n")
  for (pkg in missing_packages) {
    if (pkg == "ChAMP") {
      cat("  - ChAMP: First install kpmt: remotes::install_github('GreenwoodLab/kpmt')\n")
      cat("  - Then install ChAMP: BiocManager::install('ChAMP')\n")
    } else {
      cat("  -", pkg, ": BiocManager::install('", pkg, "')\n", sep = "")
    }
  }
}

# Test loading key packages
cat("\nTesting package loading...\n")
test_packages <- c("ChAMP", "ComplexHeatmap", "clusterProfiler", "ggplot2")
for (pkg in test_packages) {
  if (is_package_installed(pkg)) {
    tryCatch({
      library(pkg, character.only = TRUE)
      cat("✅ Successfully loaded:", pkg, "\n")
    }, error = function(e) {
      cat("❌ Failed to load", pkg, ":", e$message, "\n")
    })
  }
}
