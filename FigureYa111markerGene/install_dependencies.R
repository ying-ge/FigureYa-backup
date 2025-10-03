#!/usr/bin/env Rscript
# This script installs all required R packages for this project,
# paying special attention to Seurat versioning.

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))

# Function to check if a package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# Function to install CRAN packages
install_cran_packages <- function(packages) {
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
      stop("Failed to install CRAN package ", pkg, ": ", e$message)
    })
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# --- Step 1: Install CRAN Dependencies, including 'remotes' ---
# 'remotes' is needed to install specific package versions.
cat("\nInstalling CRAN packages...\n")
cran_packages <- c(
  "remotes", # Essential for installing specific versions
  "patchwork",
  "dplyr",
  "ggplot2",
  "pheatmap",
  "RColorBrewer",
  "hdf5r"      # Required by the seurat2scanpy function
)
install_cran_packages(cran_packages)


# --- Step 2: Install Seurat v4 ---
# The Rmd code is written for Seurat v4. We must install a v4 version.
# Seurat v5 has breaking changes that cause the "Assay5" error.
cat("\nInstalling Seurat v4...\n")
if (!is_package_installed("Seurat") || packageVersion("Seurat") >= "5.0") {
  cat("Seurat v5 or no Seurat found. Installing Seurat v4.3.0.1...\n")
  tryCatch({
    remotes::install_version("Seurat", version = "4.3.0.1")
    cat("Successfully installed Seurat v4.3.0.1\n")
  }, error = function(e) {
    stop("Failed to install Seurat v4: ", e$message)
  })
} else {
  cat("An appropriate version of Seurat is already installed:", as.character(packageVersion("Seurat")), "\n")
}

# --- Step 3: Install any other packages if needed ---
# Your original script had "Platelet". We'll add it here.
if (!is_package_installed("Platelet")) {
    install_cran_packages("Platelet")
}


cat("\n===========================================\n")
cat("Package installation completed!\n")
cat("You can now run your R scripts in this directory.\n")
