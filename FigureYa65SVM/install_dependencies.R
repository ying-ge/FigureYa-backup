#!/usr/bin/env Rscript
# R dependency installation script for SVM analysis

options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

is_installed <- function(pkg) requireNamespace(pkg, quietly = TRUE)

install_pkg <- function(pkg, type = "cran") {
  if (is_installed(pkg)) {
    cat("✓", pkg, "already installed\n")
    return(TRUE)
  }

  cat("Installing", pkg, "...\n")
  result <- tryCatch({
    if (type == "cran") {
      install.packages(pkg, dependencies = TRUE, quiet = TRUE)
    } else if (type == "github") {
      if (!is_installed("remotes")) install.packages("remotes", quiet = TRUE)
      remotes::install_github(pkg, quiet = TRUE)
    } else {
      if (!is_installed("BiocManager")) install.packages("BiocManager", quiet = TRUE)
      BiocManager::install(pkg, update = FALSE, ask = FALSE, quiet = TRUE)
    }
    cat("✓", pkg, "installed\n")
    TRUE
  }, error = function(e) {
    cat("✗", pkg, "failed:", conditionMessage(e), "\n")
    FALSE
  })

  result
}

cat("Starting package installation...\n")
cat("===============================\n")

# CRAN packages
cran_pkgs <- c("VennDiagram", "caret", "e1071", "glmnet", "randomForest",
               "tidyverse", "dplyr", "ggplot2", "remotes")
for (pkg in cran_pkgs) install_pkg(pkg, "cran")

# Bioconductor packages
bioc_pkgs <- c("sigFeature")
for (pkg in bioc_pkgs) {
  if (!install_pkg(pkg, "bioc")) {
    # Try GitHub fallback for sigFeature
    install_pkg("drjitendra/sigFeature", "github")
  }
}

# Verification
cat("\n===============================\n")
cat("Verification:\n")
all_pkgs <- c(cran_pkgs, bioc_pkgs)
success <- sum(sapply(all_pkgs, is_installed))
cat(success, "/", length(all_pkgs), "packages ready\n")

if (success == length(all_pkgs)) {
  cat("\n✓ Installation complete! Run your SVM analysis now.\n")
} else {
  missing <- setdiff(all_pkgs, names(installed.packages()))
  cat("\n✗ Missing packages:", paste(missing, collapse = ", "), "\n")
  if ("sigFeature" %in% missing) {
    cat("\nManual sigFeature install:\n")
    cat("BiocManager::install('sigFeature')\n")
    cat("remotes::install_github('drjitendra/sigFeature')\n")
  }
}
