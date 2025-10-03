#!/usr/bin/env Rscript
# Script to install necessary dependency packages

# Set download options
options(repos = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")
options(timeout = 600)  # Increase timeout duration

# Check if package is installed
is_installed <- function(pkg) {
  pkg %in% rownames(installed.packages())
}

# Install Bioconductor package
install_bioc_package <- function(pkg) {
  if (is_installed(pkg)) {
    cat("✓", pkg, "is already installed\n")
    return(TRUE)
  }
  
  cat("Installing Bioconductor package:", pkg, "\n")
  tryCatch({
    if (!is_installed("BiocManager")) {
      install.packages("BiocManager")
    }
    BiocManager::install(pkg, update = FALSE, ask = FALSE)
    if (is_installed(pkg)) {
      cat("✓", pkg, "installed successfully\n")
      return(TRUE)
    } else {
      cat("❌", pkg, "installation failed\n")
      return(FALSE)
    }
  }, error = function(e) {
    cat("❌", pkg, "installation error:", e$message, "\n")
    return(FALSE)
  })
}

# Install CRAN package
install_cran_package <- function(pkg) {
  if (is_installed(pkg)) {
    cat("✓", pkg, "is already installed\n")
    return(TRUE)
  }
  
  cat("Installing CRAN package:", pkg, "\n")
  tryCatch({
    install.packages(pkg, dependencies = TRUE)
    if (is_installed(pkg)) {
      cat("✓", pkg, "installed successfully\n")
      return(TRUE)
    } else {
      cat("❌", pkg, "installation failed\n")
      return(FALSE)
    }
  }, error = function(e) {
    cat("❌", pkg, "installation error:", e$message, "\n")
    return(FALSE)
  })
}

# Install necessary dependency packages
install_dependencies <- function() {
  cat("Installing necessary dependency packages...\n")
  
  # Bioconductor dependencies
  bioc_deps <- c(
    "Biobase",
    "genefilter",
    "sva",
    "car",
    "impute",
    "preprocessCore"
  )
  
  # CRAN dependencies
  cran_deps <- c(
    "ggplot2",
    "cowplot",
    "ridge",
    "lars",
    "data.table",
    "foreach",
    "doParallel"
  )
  
  # Install Bioconductor dependencies
  for (pkg in bioc_deps) {
    install_bioc_package(pkg)
  }
  
  # Install CRAN dependencies
  for (pkg in cran_deps) {
    install_cran_package(pkg)
  }
}

# Main installation function
main <- function() {
  cat("Starting installation of necessary dependency packages...\n")
  cat("===========================================\n")
  
  # Install dependency packages
  install_dependencies()
  
  cat("\n===========================================\n")
  cat("✅ Dependency package installation completed!\n")
  cat("You can now run the relevant R scripts.\n")
}

# Execute installation
main()
