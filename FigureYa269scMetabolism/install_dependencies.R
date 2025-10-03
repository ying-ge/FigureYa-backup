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

# Function to install scMetabolism (special handling)
install_scmetabolism <- function() {
  if (!is_package_installed("scMetabolism")) {
    cat("Installing scMetabolism...\n")
    tryCatch({
      if (!is_package_installed("remotes")) {
        install.packages("remotes")
      }
      remotes::install_github("wu-yc/scMetabolism")
      cat("Successfully installed: scMetabolism\n")
    }, error = function(e) {
      cat("Failed to install scMetabolism:", e$message, "\n")
      cat("Trying alternative installation method...\n")
      tryCatch({
        install.packages("scMetabolism", repos = "https://cloud.r-project.org/")
        cat("Successfully installed: scMetabolism\n")
      }, error = function(e2) {
        cat("Also failed to install scMetabolism from CRAN:", e2$message, "\n")
      })
    })
  } else {
    cat("Package already installed: scMetabolism\n")
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# Install remotes first for GitHub installations
install_cran_package("remotes")

# Installing CRAN packages (excluding SeuratData and scMetabolism)
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("RColorBrewer", "Seurat", "devtools", "dplyr", "ggplot2", 
                   "magrittr", "patchwork", "phangorn", "pheatmap", "rsvd")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# Install SeuratData from GitHub (not available on CRAN)
cat("\nInstalling SeuratData from GitHub...\n")
install_github_package("satijalab/seurat-data")

# Install scMetabolism (special handling as it's on GitHub)
cat("\nInstalling scMetabolism...\n")
install_scmetabolism()

# Installing Bioconductor packages
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("clusterProfiler", "org.Hs.eg.db", "GSVA", "GSEABase")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# Verify all critical packages are installed
cat("\nVerifying installation of critical packages...\n")
critical_packages <- c("Seurat", "SeuratData", "scMetabolism", "clusterProfiler")
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
    if (pkg == "SeuratData") {
      cat("  - SeuratData: remotes::install_github('satijalab/seurat-data')\n")
    } else if (pkg == "scMetabolism") {
      cat("  - scMetabolism: remotes::install_github('wu-yc/scMetabolism')\n")
    } else {
      cat("  -", pkg, ": install.packages('", pkg, "')\n", sep = "")
    }
  }
}

# Test loading key packages
cat("\nTesting package loading...\n")
test_packages <- c("Seurat", "dplyr", "ggplot2")
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
