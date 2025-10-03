#!/usr/bin/env Rscript
# This script installs all required R packages for this project

# Set up mirrors for better download performance
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

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
      cat("Warning: Failed to install CRAN package", pkg, ":", e$message, "\n")
      cat("Will continue with other packages...\n")
    })
  }
}

# Function to install Bioconductor packages
install_bioc_packages <- function(packages) {
  if (!is_package_installed("BiocManager")) {
    install.packages("BiocManager")
  }
  packages_to_install <- packages[!sapply(packages, is_package_installed)]
  if (length(packages_to_install) > 0) {
    cat("Installing Bioconductor package(s):", paste(packages_to_install, collapse=", "), "\n")
    tryCatch({
      BiocManager::install(packages_to_install, update = TRUE, ask = FALSE)
      cat("Successfully installed:", paste(packages_to_install, collapse=", "), "\n")
    }, error = function(e) {
      cat("Warning: Failed to install Bioconductor packages:", e$message, "\n")
      cat("Will continue with other packages...\n")
    })
  } else {
    cat("All required Bioconductor packages are already installed.\n")
  }
}

# Function to install kpmt package from GitHub (since it's not on CRAN)
install_kpmt <- function() {
  if (!is_package_installed("kpmt")) {
    cat("Installing kpmt package from GitHub...\n")
    if (!is_package_installed("remotes")) {
      install.packages("remotes")
    }
    tryCatch({
      # 使用正确的GitHub仓库地址
      remotes::install_github("tpq/kpmt@master")
      cat("Successfully installed kpmt from GitHub\n")
    }, error = function(e) {
      cat("Warning: Failed to install kpmt from GitHub:", e$message, "\n")
      cat("Trying alternative installation method...\n")
      
      # 尝试直接下载并安装源代码
      tryCatch({
        download.file("https://github.com/tpq/kpmt/archive/master.zip", "kpmt-master.zip")
        install.packages("kpmt-master.zip", repos = NULL, type = "source")
        cat("Successfully installed kpmt from source\n")
      }, error = function(e2) {
        cat("Failed to install kpmt from source:", e2$message, "\n")
        cat("This may cause ChAMP installation to fail\n")
      })
    })
  } else {
    cat("kpmt package is already installed\n")
  }
}

# Function to install specific problematic packages with custom handling
install_problematic_packages <- function() {
  # Special handling for ChAMP which has complex dependencies
  if (!is_package_installed("ChAMP")) {
    cat("\nAttempting to install ChAMP with special handling...\n")
    
    # First install kpmt (critical dependency not on CRAN)
    install_kpmt()
    
    # First install Bioconductor dependencies
    bioc_deps <- c("minfi", "limma", "sva", "impute", "preprocessCore", "DNAcopy", 
                  "marray", "qvalue", "IlluminaHumanMethylation450kmanifest",
                  "IlluminaHumanMethylation450kanno.ilmn12.hg19")
    install_bioc_packages(bioc_deps)
    
    # Install CRAN dependencies
    cran_deps <- c("doParallel", "foreach", "parallel", "ggplot2", "reshape2",
                  "RColorBrewer", "gridExtra", "genefilter", "pamr", "cluster",
                  "som", "igraph", "scales", "plyr", "samr")
    install_cran_packages(cran_deps)
    
    # Now try to install ChAMP
    tryCatch({
      BiocManager::install("ChAMP", update = TRUE, ask = FALSE)
      if (is_package_installed("ChAMP")) {
        cat("Successfully installed ChAMP\n")
      } else {
        cat("Warning: ChAMP installation may have failed\n")
      }
    }, error = function(e) {
      cat("Warning: Failed to install ChAMP:", e$message, "\n")
      
      # Alternative: try installing older version that might have fewer dependencies
      cat("Trying to install older version of ChAMP...\n")
      tryCatch({
        # 使用特定版本的ChAMP
        BiocManager::install(version = "3.16")
        BiocManager::install("ChAMP", version = "3.16", update = TRUE, ask = FALSE)
        if (is_package_installed("ChAMP")) {
          cat("Successfully installed older version of ChAMP\n")
        }
      }, error = function(e2) {
        cat("Older version installation also failed:", e2$message, "\n")
      })
    })
  }
}

cat("Starting R package installation...\n")
cat("===========================================\n")

# --- Step 1: Install CRAN Packages ---
cat("\nInstalling CRAN packages...\n")
cran_packages <- c(
  "data.table", 
  "gplots", 
  "pheatmap",
  "magick",
  "doParallel",
  "foreach",
  "ggplot2",
  "reshape2",
  "RColorBrewer",
  "remotes"  # 确保remotes包已安装
)
install_cran_packages(cran_packages)

# --- Step 2: Install Bioconductor Packages ---
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c(
  "ComplexHeatmap",
  "ClassDiscovery",
  "IlluminaHumanMethylation450kanno.ilmn12.hg19",
  "IlluminaHumanMethylation450kmanifest",
  "minfi",
  "limma",
  "sva",
  "impute",
  "preprocessCore",  # 添加preprocessCore
  "DNAcopy"          # 添加DNAcopy
)
install_bioc_packages(bioc_packages)

# --- Step 3: Special handling for problematic packages ---
install_problematic_packages()

# --- Step 4: Verify ChAMP installation ---
cat("\nVerifying ChAMP installation...\n")
if (is_package_installed("ChAMP")) {
  cat("✓ ChAMP package is installed\n")
  
  # Try to load the package to check for runtime dependencies
  tryCatch({
    library(ChAMP)
    cat("✓ ChAMP package loads successfully\n")
  }, error = function(e) {
    cat("Warning: ChAMP installed but has loading issues:", e$message, "\n")
    cat("This might be due to missing system dependencies or version conflicts\n")
  })
} else {
  cat("Warning: ChAMP package installation failed\n")
  cat("You may need to manually install it or use an alternative approach\n")
  
  # Alternative: try installing from GitHub if Bioconductor fails
  cat("Attempting alternative installation from GitHub...\n")
  tryCatch({
    remotes::install_github("YuanTian1991/ChAMP")
    if (is_package_installed("ChAMP")) {
      cat("✓ Successfully installed ChAMP from GitHub\n")
    } else {
      cat("GitHub installation failed\n")
    }
  }, error = function(e) {
    cat("GitHub installation also failed:", e$message, "\n")
  })
}

# --- Step 5: 如果ChAMP仍然失败，提供替代方案 ---
if (!is_package_installed("ChAMP")) {
  cat("\nChAMP installation failed. Considering alternative packages...\n")
  cat("You might consider using minfi or other methylation analysis packages:\n")
  cat("- minfi: for Illumina methylation array analysis\n")
  cat("- methylumi: alternative methylation analysis package\n")
  cat("- watermelon: for DNA methylation analysis\n")
  
  # 确保minfi至少已安装
  if (!is_package_installed("minfi")) {
    install_bioc_packages("minfi")
  }
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# Provide troubleshooting advice
cat("\nTroubleshooting tips for ChAMP:\n")
cat("1. If ChAMP still fails, check system dependencies: libcurl, libxml2\n")
cat("2. Try: sudo apt-get install libcurl4-openssl-dev libxml2-dev (on Ubuntu)\n")
cat("3. Or try: brew install libcurl libxml2 (on macOS)\n")
cat("4. Try installing an older Bioconductor version: BiocManager::install(version = '3.16')\n")
cat("5. Restart R session and try loading ChAMP again\n")

cat("You can now run your R scripts in this directory.\n")
